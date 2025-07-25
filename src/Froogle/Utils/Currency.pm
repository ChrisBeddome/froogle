package Froogle::Utils::Currency;

use strict;
use warnings;

use Exporter;

use Froogle::Constants;
use Froogle::Utils::Data;

sub format_currency {
    my ($dollars, $width) = @_;

    my $formatted_amount = sprintf("%.2f", $dollars);

    if (defined $width) {
        my $total_length = $width - 1;  # Subtract 1 for the dollar sign
        return sprintf("\$%${total_length}s", $formatted_amount);
    }

    return "\$" . $formatted_amount;
}

sub format_debt_line {
    my $transaction = shift;
    my $desc = $transaction->{'desc'} // Froogle::Constants::COMBINED_CATEGORY_CODES()->{$transaction->{'category'}};
    my $amount_owed = Froogle::Utils::Data::amount_owed_for_transaction($transaction);
    return who_owe_who_text($amount_owed) . "         " . Froogle::Utils::Formatting::truncate_or_pad($desc, 30)  . "             " . Froogle::Utils::Currency::format_currency(abs($amount_owed), 10);
}

sub who_owe_who_text {
    my $amount = shift;
    return $amount >= 0 ? "Chris Owes ZZ" : "ZZ Owes Chris";
}

our @EXPORT_OK = qw(format_currency format_debt_line who_owe_who_text);

1;

