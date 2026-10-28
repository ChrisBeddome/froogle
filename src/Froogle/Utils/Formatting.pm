package Froogle::Utils::Formatting;

use strict;
use warnings;

use Exporter 'import';

sub trim {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

our @EXPORT_OK = qw(trim);

1;

