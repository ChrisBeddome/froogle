package Froogle::Commands::Categories;

use strict;
use warnings;

use feature 'say';
use List::Util qw(sum);
use Exporter;

use Froogle::Constants;
use Froogle::Utils::DataUtils;
use Froogle::Utils::DateUtils;
use Froogle::Utils::CurrencyUtils;
use Froogle::Utils::FormattingUtils;

sub name {
    return "cats";
}

sub run {
    my %spending_per_categories;
    my @transactions = Froogle::Utils::DataUtils::get_transactions;
    for my $key (keys %{Froogle::Constants::OUT_CATEGORY_CODES()}) {
        $spending_per_categories{$key} = 0;
    }
    for my $transaction (@transactions) {
        if ($transaction->{type} eq "OUT") {
            $spending_per_categories{$transaction->{category}} += $transaction->{amount};
        }
    }
    say "";
    say Froogle::Utils::DateUtils::formatted_date_range();
    say "";

    my $total_spending = sum(values %spending_per_categories);
    my $total_income = total_income_for_transactions(@transactions);

    my @sorted_keys = sort { $spending_per_categories{$b} <=> $spending_per_categories{$a} } keys %spending_per_categories;
    say "Category                              Amount    Percentage (spending)    Percentage (income)";
    say "=" x 92;
    for my $key (@sorted_keys) {
        my $cat_text = Froogle::Utils::FormattingUtils::truncate_or_pad(Froogle::Constants::OUT_CATEGORY_CODES()->{$key}, 30);
        my $percentage_of_spending = $total_spending > 0 ? $spending_per_categories{$key} / $total_spending * 100 : 0;
        my $percentage_of_income = $total_income > 0 ? $spending_per_categories{$key} / $total_income * 100 : 0;
        my $percentage_of_spending_text = Froogle::Utils::FormattingUtils::format_percentage($percentage_of_spending);
        my $percentage_of_income_text = Froogle::Utils::FormattingUtils::format_percentage($percentage_of_income);
        say $cat_text . Froogle::Utils::CurrencyUtils::format_currency($spending_per_categories{$key}, 10) . "                   " . $percentage_of_spending_text . "                " . $percentage_of_income_text;
    }

    say "";
}

sub total_income_for_transactions {
    my @transactions = @_;
    my $total = 0;
    foreach (@transactions) {
        my $transaction = $_;
        if ($transaction->{type} eq "IN") {
            $total += $transaction->{amount};
        }
    }
    return $total;
}

our @EXPORT_OK = qw(name run);

1;
