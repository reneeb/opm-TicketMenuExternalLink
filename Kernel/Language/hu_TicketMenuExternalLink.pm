# --
# Kernel/Language/hu_TicketMenuExternalLink.pm - the Hungarian translation of TicketMenuExternalLink
# Copyright (C) 2016 Perl-Services, http://www.perl-services.de
# Copyright (C) 2016 Balázs Úr, http://www.otrs-megoldasok.hu
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::hu_TicketMenuExternalLink;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    # Kernel/Config/Files/TicketMenuExternalLink.xml
    $Lang->{'Module to show link to external site in ticket menu.'} =
        'Egy modul egy külső oldalra mutató hivatkozás megjelenítéséhez a jegymenüben.';
    $Lang->{'Module to show link to external site in ticket menu (overview "large").'} =
        'Egy modul egy külső oldalra mutató hivatkozás megjelenítéséhez a jegymenüben („nagy” áttekintő).';
    $Lang->{'URL of the link.'} = 'A hivatkozás URL címe.';
    $Lang->{'Name of the link.'} = 'A hivatkozás neve.';
    $Lang->{'Attributes for the &lt;a&gt;-tag.'} = 'Az &lt;a&gt; címke attribútumai.';

    # Kernel/Config/Files/ZZZTicketMenuExternalLink.xml
    $Lang->{'More external links.'} = 'További külső hivatkozások.';

    return 1;
}

1;
