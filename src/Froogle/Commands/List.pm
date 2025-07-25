package Froogle::Commands::List;

use strict;
use warnings;

use feature 'say';
use Exporter;

use Froogle::Constants;
use Froogle::Utils::Data;
use Froogle::Utils::Date;
use Froogle::Utils::Currency;

sub name {
    return "list";
}

sub applicable_options {
    return qw(from to necessity category);
}

sub validate_options {
    my %options = (@_);
    return 1;
}

sub defaults {
    return (
        to => Froogle::Utils::Date::get_today(),
        from => Froogle::Utils::Date::get_start_of_month()
    );
}

sub run {
    my @transactions = Froogle::Utils::Data::get_transactions;

    say "";
    say Froogle::Utils::Date::formatted_date_range();
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
    my $amount = Froogle::Utils::Currency::format_currency($transaction->{amount}, 10);
    my $type = $transaction->{type};
    say "$amount on $transaction->{date} for $desc";
}


our @EXPORT_OK = qw(name run);

1;
