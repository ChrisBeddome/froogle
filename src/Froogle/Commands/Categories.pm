package Froogle::Commands::Categories;

use strict;
use warnings;

use feature 'say';
use List::Util qw(sum);
use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::Data ();
use Froogle::Utils::Date ();
use Froogle::Utils::Currency ();
use Froogle::Utils::Formatting ();

sub name {
    return "cats";
}

sub applicable_options {
    return qw(from to);
}

sub defaults {
    return (
        to => Froogle::Utils::Date::get_today(),
        from => Froogle::Utils::Date::get_start_of_month()
    );
}

sub run {
    my %spending_per_categories;
    my @transactions = Froogle::Utils::Data::get_transactions;
    for my $key (keys %{Froogle::Constants::OUT_CATEGORY_CODES()}) {
        $spending_per_categories{$key} = 0;
    }
    for my $transaction (@transactions) {
        if ($transaction->{type} eq Froogle::Constants::TRANSACTION_TYPE_EXPENSE()) {
            $spending_per_categories{$transaction->{category}} += $transaction->{amount};
        }
    }
    say "";
    say Froogle::Utils::Date::formatted_date_range();
    say "";

    my $total_spending = sum(values %spending_per_categories);
    my $total_income = Froogle::Utils::Data::total_income_for_transactions(@transactions);

    my @sorted_keys = sort { $spending_per_categories{$b} <=> $spending_per_categories{$a} } keys %spending_per_categories;
    say "Category                                    Amount    Percentage (spending)    Percentage (income)";
    say "=" x Froogle::Constants::SEPARATOR_LENGTH_CATEGORIES();
    for my $key (@sorted_keys) {
        my $cat_text = Froogle::Utils::Formatting::truncate_or_pad(
            Froogle::Constants::OUT_CATEGORY_CODES()->{$key},
            Froogle::Constants::CATEGORY_TEXT_WIDTH()
        );
        my $percentage_of_spending = $total_spending > 0 ? $spending_per_categories{$key} / $total_spending * 100 : 0;
        my $percentage_of_income = $total_income > 0 ? $spending_per_categories{$key} / $total_income * 100 : 0;
        my $percentage_of_spending_text = Froogle::Utils::Formatting::format_percentage($percentage_of_spending);
        my $percentage_of_income_text = Froogle::Utils::Formatting::format_percentage($percentage_of_income);
        say $cat_text . Froogle::Utils::Currency::format_currency($spending_per_categories{$key}, Froogle::Constants::CURRENCY_FORMAT_WIDTH()) . "                   " . $percentage_of_spending_text . "                " . $percentage_of_income_text;
    }

    say "";
}

our @EXPORT_OK = qw(name run);

1;
