package Froogle::Commands::Help;

use strict;
use warnings;

use feature 'say';
use Exporter;

use Froogle::Constants;

sub name {
    return "help";
}

sub applicable_options {
    return qw();
}

sub validate_options {
    my %options = (@_);
    return 1;
}

sub defaults {
    return ();
}

sub run {
    say "";
    say "Commands: ";
    say "";
    say "   overview:  Displays a summary of income and spending for the specified date range";
    say "   list:      Lists all spending transactions for the specified date range";
    say "   details:   Lists all spending transactions for the specified date range with additional details";
    say "   zz:        Displays a summary of money owed";
    say "   cats:      Displays a summary of spending per category";
    say "   settle:    Updates all outstanding shared transactions to be marked as settled";
    say "";
    say "Options: ";
    say "";
    say "   -f, --from:      Start date for the date range (default: start of the current month)";
    say "   -t, --to:        End date for the date range (default: today)";
    say "   -n, --necessity: Filter transactions by necessity (1 = frivolous, 2 = unnecessary, 3 = necessary)";
    say "   -c, --category:  Filter transactions by category code";
    say "";
    say "Category codes: ";
    say "";
    say "   Income: ";
    for my $key (sort keys %{Froogle::Constants::IN_CATEGORY_CODES()}) {
        say "       $key: " . Froogle::Constants::IN_CATEGORY_CODES()->{$key};
    }
    say "";
    say "   Expenses: ";
    for my $key (sort keys %{Froogle::Constants::OUT_CATEGORY_CODES()}) {
        say "       $key: " . Froogle::Constants::OUT_CATEGORY_CODES()->{$key};
    }
    say "";
    say "   Transfers: ";
    for my $key (sort keys %{Froogle::Constants::TRF_CATEGORY_CODES()}) {
        say "       $key: " . Froogle::Constants::TRF_CATEGORY_CODES()->{$key};
    }
    say "";
    say "Examples: ";
    say "";
    say "   list all transactions for the month of January 2021: ";
    say "       => froogle list -f 2021-01-01 -t 2021-01-31";
    say "";
    say "   list all transactions for the month of January 2021 in the 'Groceries' category: ";
    say "       => froogle list -f 2021-01-01 -t 2021-01-31 -c GRC";
    say "";
    say "   list all details of transactions for the current month that are 'necessary': ";
    say "       => froogle details -n 3";
    say "";
}

our @EXPORT_OK = qw(name run);

1;
