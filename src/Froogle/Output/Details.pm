package Froogle::Output::Details;

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

    foreach my $transaction (@{ $report{transactions} }) {
        say "";
        print_transaction($transaction);
        say "";
    }
    say "";
}

sub print_transaction {
    my $transaction = shift;
    say "Date:           $transaction->{date}";
    say "Amount:         " . Froogle::Output::Format::format_currency($transaction->{amount});
    say "Category:       $transaction->{category}";
    say "Description:    $transaction->{desc}" if defined $transaction->{desc};
    say "Necessity:      " . format_necessity($transaction->{necessity});
}

sub format_necessity {
    my $necessity_num = shift;
    return Froogle::Constants::NECESSITY_CODES->{$necessity_num};
}

our @EXPORT_OK = qw(print_report);

1;
