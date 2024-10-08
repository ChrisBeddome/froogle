package Froogle::Utils::FormattingUtils;

use strict;
use warnings;

use Exporter;

sub truncate_or_pad {
    my ($input, $length, $pad_left) = @_;
     if (length($input) > $length) {
        $input = substr($input, 0, $length) . '...';
    }
    $length += 3; #for ellipsis
    return $pad_left ? sprintf("%${length}s", $input) : sprintf("%-${length}s", $input);
}

sub format_percentage {
    my ($number) = @_;

    my $formatted = sprintf("%.2f%%", $number);

    if ($number < 10) {
        $formatted = "  $formatted";
    } elsif ($number < 100) {
        $formatted = " $formatted";
    }

    return $formatted;
}

sub trim {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

our @EXPORT_OK = qw(truncate_or_pad format_percentage trim);

1;

