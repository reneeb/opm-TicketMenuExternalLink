# --
# Kernel/Output/HTML/OutputFilterTicketMenuExternalLink.pm
# Copyright (C) 2013 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterTicketMenuExternalLink;

use strict;
use warnings;

use URI;

use Kernel::System::Encode;
use Kernel::System::Time;
use Kernel::System::Ticket;

our $VERSION = 0.01;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Object (qw(MainObject ConfigObject LogObject LayoutObject ParamObject)) {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    $Self->{EncodeObject} = $Param{EncodeObject} || Kernel::System::Encode->new( %{$Self} );
    $Self->{TimeObject}   = $Param{TimeObject}   || Kernel::System::Time->new( %{$Self} );
    $Self->{TicketObject} = $Param{TicketObject} || Kernel::System::Ticket->new( %{$Self} );

    $Self->{UserID} = $Param{UserID};

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;
    return 1 if $Templatename ne 'AgentTicketZoom';

    my ($TicketID) = ${$Param{Data}} =~ m{<ul \s+ class="Actions" .*? TicketID=(\d+)}xms;

    return 1 if !$TicketID;

    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID => $TicketID,
        UserID   => $Self->{UserID},
    );

    my $URL        = $Self->{ConfigObject}->Get( 'ExternalLink::URL' );
    my $Attributes = $Self->{ConfigObject}->Get( 'ExternalLink::Attributes' );
    my $LinkName   = $Self->{ConfigObject}->Get( 'ExternalLink::LinkName' );

    if ( !$LinkName ) {
        my $URI   = URI->new( $URL );
        $LinkName = $URI->host;
    }

    my $AttrString = join " ", map{ my $Value = $Attributes->{$_}; qq~$_="$Value"~ }keys %{$Attributes || {}};
    $AttrString  ||= '';

    my $LinkTemplate = qq~
        <li>
            <a href="$URL" $AttrString>\$Text{"\$QData{"LinkName"}"}</a>
        </li>
    ~;

    my $Snippet = $Self->{LayoutObject}->Output(
        Template => $LinkTemplate,
        Data     => {
            %ENV,
            %Ticket,
            TicketID => $TicketID,
            LinkName => $LinkName,
        },
    ); 

    my $LinkType = $Self->{ConfigObject}->Get('Ticket::Frontend::MoveType');
    if ( $LinkType eq 'form' ) {
        ${ $Param{Data} } =~ s{(<li class="">\s*?<form.*?<select name="DestQueueID".*?</li>)}{$Snippet $1}ms;
    }
    else {
        ${ $Param{Data} } =~ s{(<li>.*?<a href=".*?Action=AgentTicketMove;TicketID=\d+;".*?</li>)}{$Snippet $1}ms;
    }

    return ${ $Param{Data} };
}

1;
