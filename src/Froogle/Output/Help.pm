package Froogle::Output::Help;

use strict;
use warnings;

use feature 'say';
use Exporter 'import';

sub print_help {
    my %help = @_;

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
    print_categories($help{income_categories});
    say "";
    say "   Expenses: ";
    print_categories($help{expense_categories});
    say "";
    say "   Transfers: ";
    print_categories($help{transfer_categories});
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

sub print_categories {
    my $categories = shift;
    for my $code (sort keys %$categories) {
        say "       $code: $categories->{$code}";
    }
}

our @EXPORT_OK = qw(print_help);

1;
