# --
# Kernel/Language/de_TicketMenuExternalLink.pm - the German translation of TicketMenuExternalLink
# Copyright (C) 2016 - 2022 Perl-Services, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_TicketMenuExternalLink;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    # Kernel/Config/Files/TicketMenuExternalLink.xml
    $Lang->{'Module to show link to external site in ticket menu.'} =
        'Modul zum Anzeigen Links auf externe Seiten im Ticketmenü.';
    $Lang->{'Module to show link to external site in ticket menu (overview "large").'} =
        'Modul zum Anzeigen Links auf externe Seiten im Ticketmenü (Ticketübersichten "Large").';
    $Lang->{'URL of the link.'} = 'URL des Links.';
    $Lang->{'Name of the link.'} = 'Name des Links.';
    $Lang->{'Attributes for the &lt;a&gt;-tag.'} = 'Attribute für das &lt;a&gt;-tag.';

    # Kernel/Config/Files/ZZZTicketMenuExternalLink.xml
    $Lang->{'More external links.'} = 'Weitere externe Links.';

    return 1;
}

1;
