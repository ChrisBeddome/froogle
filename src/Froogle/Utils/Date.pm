package Froogle::Utils::Date;

use strict;
use warnings;

use Exporter 'import';

sub validate_date {
    my ($date) = @_;
    return $date =~ /^\d{4}-\d{2}-\d{2}$/ ? 1 : 0;
}

# Stricter than validate_date: the month must be 01-12 and the day 01-31.
# The day isn't checked against the length of the month, so e.g. 2024-09-31
# still works as an inclusive end of September
sub validate_option_date {
    my ($date) = @_;
    return 0 unless validate_date($date);
    my ($month, $day) = (split /-/, $date)[1, 2];
    return ($month >= 1 && $month <= 12 && $day >= 1 && $day <= 31) ? 1 : 0;
}

sub get_today {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;
    return sprintf("%04d-%02d-%02d", $year, $mon, $mday);
}

sub get_start_of_month {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;
    return sprintf("%04d-%02d-01", $year, $mon);
}

# Compares two YYYY-MM-DD dates as numbers with the dashes removed: negative if the
# first is earlier, zero if equal, positive if later. Comparing as numbers rather than
# strings keeps an option value with a trailing newline (which validate_date accepts)
# equal to the same date
sub compare_dates {
    my ($first, $second) = @_;

    my $first_number = $first;
    $first_number =~ s/-//g;

    my $second_number = $second;
    $second_number =~ s/-//g;

    return $first_number <=> $second_number;
}

our @EXPORT_OK = qw(validate_date validate_option_date get_today get_start_of_month compare_dates);

1;

