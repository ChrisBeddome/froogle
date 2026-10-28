package Froogle::Output::OweZZ;

use strict;
use warnings;

use feature 'say';
use Exporter 'import';

use Froogle::Constants ();
use Froogle::Output::Format ();

sub print_report {
    my %report = @_;

    say "";
    foreach my $debt (@{ $report{debts} }) {
        say format_debt_line($debt);
    }
    say "                                                                ==============";
    say Froogle::Output::Format::who_owe_who_text($report{total_owed}) . ":                                                      " . Froogle::Output::Format::format_currency(abs($report{total_owed}), Froogle::Constants::CURRENCY_FORMAT_WIDTH());
    say "";
}

sub format_debt_line {
    my $debt = shift;
    my $transaction = $debt->{transaction};
    my $desc = $transaction->{'desc'} // Froogle::Constants::COMBINED_CATEGORY_CODES()->{$transaction->{'category'}};
    my $amount_owed = $debt->{amount_owed};
    return Froogle::Output::Format::who_owe_who_text($amount_owed) . "         " . Froogle::Output::Format::truncate_or_pad($desc, Froogle::Constants::DESCRIPTION_TEXT_WIDTH()) . "             " . Froogle::Output::Format::format_currency(abs($amount_owed), Froogle::Constants::CURRENCY_FORMAT_WIDTH());
}

our @EXPORT_OK = qw(print_report);

1;
