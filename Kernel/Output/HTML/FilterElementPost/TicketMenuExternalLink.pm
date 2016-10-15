# --
# Copyright (C) 2013 - 2016 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::TicketMenuExternalLink;

use strict;
use warnings;

use URI;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::Log
    Kernel::System::Ticket
    Kernel::System::Web::Request
    Kernel::Output::HTML::Layout
);

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
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;
    return 1 if $Templatename ne 'AgentTicketZoom';

    my ($TicketID) = $ParamObject->GetParam( Param => 'TicketID' );
    #${$Param{Data}} =~ m{<ul \s+ class="Actions" .*? TicketID=(\d+)}xms;

    return 1 if !$TicketID;

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

    my $LinkType = $ConfigObject->Get('Ticket::Frontend::MoveType');
    if ( $LinkType eq 'form' ) {
        ${ $Param{Data} } =~ s{(<li class="">\s*?<form.*?<select name="DestQueueID".*?</li>)}{$StringToInclude $1}ms;
    }
    else {
        ${ $Param{Data} } =~ s{(<li>.*?<a href=".*?Action=AgentTicketMove;TicketID=\d+;".*?</li>)}{$StringToInclude $1}ms;
    }

    return ${ $Param{Data} };
}

1;
