package Froogle::Commands::Details;

use strict;
use warnings;

use feature 'say';
use Exporter;

use Froogle::Utils::DataUtils;
use Froogle::Utils::DateUtils;
use Froogle::Utils::CurrencyUtils;

sub name {
    return "details";
}

sub run {
    my @transactions = Froogle::Utils::DataUtils::get_transactions;

    say "";
    say Froogle::Utils::DateUtils::formatted_date_range();

    foreach (@transactions) {
        my $transaction = $_;
        say "";
        print_transaction($transaction);
        say "";
    }
    say "";
}

sub print_transaction {
    my $transaction = shift;
    say "Date:           $transaction->{date}";
    say "Amount:         " . Froogle::Utils::CurrencyUtils::format_currency($transaction->{amount});
    say "Category:       $transaction->{category}" unless $transaction->{type} eq "IN";
    say "Description:    $transaction->{desc}" if defined $transaction->{desc};
    say "Necessity:      " . format_necessity($transaction->{necessity}) unless $transaction->{type} eq "IN";
}

sub format_necessity {
    my $necessity_num = shift;
    my %necessary = ("1" => "Frivolous", "2" => "Unnecessary", "3" => "Necessary");
    return $necessary{$necessity_num};
}

our @EXPORT_OK = qw(name run);

1;
