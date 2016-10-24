# --
# Copyright (C) 2013 - 2016 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::TicketMenuExternalLinkOverview;

use strict;
use warnings;

use URI;

our $VERSION = 0.02;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{UserID} = $Param{UserID};

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;
    return 1 if $Templatename ne 'AgentTicketOverviewPreview';

    my @Groups = split /\s*,\s*/, $Param{Groups} // '';

    if ( @Groups ) {
        my $Found = grep{ my $Test = $LayoutObject->{"UserIsGroup[$_]"}; $Test && lc $Test eq 'yes' }@Groups;
        return if !$Found;
    }

    for my $Block ( ${$Param{Data}} =~ m{(AgentTicketClose;TicketID=\d+ .*? </li>)}xmsg ) {

        my ($TicketID) = $Block =~ m{TicketID=(\d+)}xms;

        next if !$TicketID;

        my %Ticket = $TicketObject->TicketGet(
            TicketID => $TicketID,
            UserID   => $Self->{UserID},
        );

        my $URL        = $ConfigObject->Get( 'ExternalLink::URL' );
        my $Attributes = $ConfigObject->Get( 'ExternalLink::Attributes' );
        my $LinkName   = $ConfigObject->Get( 'ExternalLink::LinkName' );

        my $MoreLinks  = $ConfigObject->Get( 'MoreExternalLinks' ) || {};
        my @AllLinks   = map { $MoreLinks->{$_} } sort keys %{$MoreLinks};
    
        if ( $URL ) {
            unshift @AllLinks, {
                LinkName   => $LinkName,
                URL        => $URL,
                Attributes => $Attributes,
            };
        }
    
        my $StringToInclude = '';
        for my $Link ( @AllLinks ) {
            my ($LinkName, $URL, $Attributes) = @{ $Link }{ qw/LinkName URL Attributes/ };
    
            if ( !$LinkName ) {
                my $URI   = URI->new( $URL );
                $LinkName = $URI->host;
            }
    
            my $AttrString = join " ", map{ my $Value = $Attributes->{$_}; qq~$_='$Value'~ }keys %{$Attributes || {}};
            $AttrString  ||= '';
        
            my $LinkTemplate = qq~
                <li>
                    <a href="$URL" $AttrString>[% Data.LinkName | html %]</a>
                </li>
            ~;
    
            my $Snippet = $LayoutObject->Output(
                Template => $LinkTemplate,
                Data     => {
                    %ENV,
                    %Ticket,
                    TicketID => $TicketID,
                    LinkName => $LinkName,
                },
            );
    
            $StringToInclude .= $Snippet;
        }


        ${ $Param{Data} } =~ s{\Q$Block\E\K}{$StringToInclude}mgs;
    }

    return ${ $Param{Data} };
}

1;
