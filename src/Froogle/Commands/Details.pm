package Froogle::Commands::Details;

use strict;
use warnings;

use feature 'say';
use Exporter;

use Froogle::Utils::Data;
use Froogle::Utils::Date;
use Froogle::Utils::Currency;
use Froogle::Constants;

sub name {
    return "details";
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
    say "Amount:         " . Froogle::Utils::Currency::format_currency($transaction->{amount});
    say "Category:       $transaction->{category}";
    say "Description:    $transaction->{desc}" if defined $transaction->{desc};
    say "Necessity:      " . format_necessity($transaction->{necessity});
}

sub format_necessity {
    my $necessity_num = shift;
    return Froogle::Constants::NECESSITY_CODES->{$necessity_num};
}

our @EXPORT_OK = qw(name run);

1;
