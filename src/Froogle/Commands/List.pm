package Froogle::Commands::List;

use strict;
use warnings;

use feature 'say';
use Exporter;

use Froogle::Constants;
use Froogle::Utils::DataUtils;
use Froogle::Utils::DateUtils;
use Froogle::Utils::CurrencyUtils;

sub name {
    return "list";
}

sub run {
    my @transactions = Froogle::Utils::DataUtils::get_transactions;

    say "";
    say Froogle::Utils::DateUtils::formatted_date_range();
    say "";

    foreach (@transactions) {
        my $transaction = $_;
        print_transaction($transaction);
    }
    say "";
}

sub print_transaction {
    my $transaction = shift;
    my $desc = $transaction->{'desc'} // Froogle::Constants::COMBINED_CATEGORY_CODES()->{$transaction->{'category'}};
    my $amount = Froogle::Utils::CurrencyUtils::format_currency($transaction->{amount}, 10);
    my $type = $transaction->{type};
    say "$amount on $transaction->{date} for $desc";
}


our @EXPORT_OK = qw(name run);

1;
