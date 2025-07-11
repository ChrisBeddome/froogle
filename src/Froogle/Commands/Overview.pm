package Froogle::Commands::Overview;

use strict;
use warnings;

use feature 'say';
use List::Util qw(sum);
use Exporter;

use Froogle::Utils::Data;
use Froogle::Utils::Date;
use Froogle::Utils::Currency;

sub name {
    return "overview";
}

sub applicable_options {
    return qw(from to);
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
    my %spending = ("1" => 0, "2" => 0, "3" => 0);
    my $income = 0;
    my $assets = 0;

    my @transactions = Froogle::Utils::Data::get_transactions;

    foreach (@transactions) {
        my $transaction = $_;
        if ($transaction->{type} eq "IN") { 
            $income += $transaction->{amount};
        } elsif ($transaction->{type} eq "ASS") {
            $assets += $transaction->{amount};
        } else {
            $spending{$transaction->{necessity}} += $transaction->{amount};
        }
    }

    my $income_str = Froogle::Utils::Currency::format_currency($income, 10);
    my $assets_str = Froogle::Utils::Currency::format_currency($assets, 10);
    my $necessary = Froogle::Utils::Currency::format_currency($spending{'3'}, 10);
    my $unnecessary = Froogle::Utils::Currency::format_currency($spending{'2'}, 10);
    my $frivilous = Froogle::Utils::Currency::format_currency($spending{'1'}, 10);

    say "";
    say Froogle::Utils::Date::formatted_date_range();
    say "";
    say "Total Income:                   $income_str";
    say "";
    say "Transfer to assets:             $assets_str";    
    say "";
    say "Necessary spending:             $necessary";
    say "Unnecessary spending:           $unnecessary";
    say "Frivolous spending:             $frivilous";
    say "Total Spending:                 " . Froogle::Utils::Currency::format_currency(sum(values %spending), 10);
    say "";
    say "Net                             " . Froogle::Utils::Currency::format_currency($income - sum(values %spending) - $assets, 10);
    say "";
}

our @EXPORT_OK = qw(name run);

1;
