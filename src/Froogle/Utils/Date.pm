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

sub formatted_date_range {
    my %options = Froogle::OptionsManager::get_options();
    return format_date($options{from}) . " - " . format_date($options{to});
}

sub format_date {
    my $date = shift;
    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    return $months[substr($date, 5, 2) - 1] . " " . substr($date, 8, 2) . " " . substr($date, 0, 4);
}

sub is_date_in_range {
    my ($date, $from, $to) = @_;

    # Remove the dashes
    $date =~ s/-//g;
    $from =~ s/-//g;
    $to =~ s/-//g;

    if ($date >= $from && $date <= $to) {
        return 1;
    } else {
        return 0;
    }
}

our @EXPORT_OK = qw(validate_date validate_option_date get_today get_start_of_month formatted_date_range is_date_in_range);

1;

