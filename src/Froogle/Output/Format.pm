package Froogle::Output::Format;

use strict;
use warnings;

use Exporter 'import';

use Froogle::Constants ();

sub format_currency {
    my ($dollars, $width) = @_;

    my $formatted_amount = sprintf("%.2f", $dollars);
    # Floating point noise around zero (e.g. income minus equal spending) would
    # otherwise show as -0.00, depending on the order amounts were summed in
    $formatted_amount = '0.00' if $formatted_amount eq '-0.00';

    if (defined $width) {
        my $total_length = $width - 1;  # Subtract 1 for the dollar sign
        return sprintf("\$%${total_length}s", $formatted_amount);
    }

    return "\$" . $formatted_amount;
}

sub who_owe_who_text {
    my $amount = shift;
    my $primary = Froogle::Constants::USER_NAME_PRIMARY();
    my $secondary = Froogle::Constants::USER_NAME_SECONDARY();
    return $amount >= 0 ? "$primary Owes $secondary" : "$secondary Owes $primary";
}

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

sub formatted_date_range {
    my ($from, $to) = @_;
    return format_date($from) . " - " . format_date($to);
}

sub format_date {
    my $date = shift;
    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    return $months[substr($date, 5, 2) - 1] . " " . substr($date, 8, 2) . " " . substr($date, 0, 4);
}

our @EXPORT_OK = qw(format_currency who_owe_who_text truncate_or_pad format_percentage formatted_date_range);

1;
