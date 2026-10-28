package Froogle::Output::List;

use strict;
use warnings;

use feature 'say';
use Exporter 'import';

use Froogle::Constants ();
use Froogle::Output::Format ();

sub print_report {
    my %report = @_;

    say "";
    say Froogle::Output::Format::formatted_date_range($report{from}, $report{to});
    say "";

    foreach my $transaction (@{ $report{transactions} }) {
        print_transaction($transaction);
    }
    say "";
}

sub print_transaction {
    my $transaction = shift;
    my $desc = $transaction->{'desc'} // Froogle::Constants::COMBINED_CATEGORY_CODES()->{$transaction->{'category'}};
    my $amount = Froogle::Output::Format::format_currency($transaction->{amount}, Froogle::Constants::CURRENCY_FORMAT_WIDTH());
    say "$amount on $transaction->{date} for $desc";
}

our @EXPORT_OK = qw(print_report);

1;
