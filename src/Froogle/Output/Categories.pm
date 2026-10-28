package Froogle::Output::Categories;

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
    say "Category                                    Amount    Percentage (spending)    Percentage (income)";
    say "=" x Froogle::Constants::SEPARATOR_LENGTH_CATEGORIES();
    foreach my $row (@{ $report{rows} }) {
        my $category_text = Froogle::Output::Format::truncate_or_pad($row->{name}, Froogle::Constants::CATEGORY_TEXT_WIDTH());
        my $amount_text = Froogle::Output::Format::format_currency($row->{amount}, Froogle::Constants::CURRENCY_FORMAT_WIDTH());
        my $percentage_of_spending_text = Froogle::Output::Format::format_percentage($row->{percentage_of_spending});
        my $percentage_of_income_text = Froogle::Output::Format::format_percentage($row->{percentage_of_income});
        say $category_text . $amount_text . "                   " . $percentage_of_spending_text . "                " . $percentage_of_income_text;
    }

    say "";
}

our @EXPORT_OK = qw(print_report);

1;
