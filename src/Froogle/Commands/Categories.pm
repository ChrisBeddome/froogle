package Froogle::Commands::Categories;

use strict;
use warnings;

use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::Data ();
use Froogle::Utils::Date ();
use Froogle::Output::Categories ();

sub name {
    return "cats";
}

sub applicable_options {
    return qw(from to);
}

sub applicable_transaction_types {
    return (Froogle::Constants::TRANSACTION_TYPE_INCOME(), Froogle::Constants::TRANSACTION_TYPE_EXPENSE());
}

sub defaults {
    return (
        to => Froogle::Utils::Date::get_today(),
        from => Froogle::Utils::Date::get_start_of_month()
    );
}

sub run {
    my ($class, $options) = @_;
    my %spending_per_categories;
    my @transactions = Froogle::Utils::Data::get_transactions(
        types => [applicable_transaction_types()],
        from => $options->{from},
        to => $options->{to},
    );
    for my $key (keys %{Froogle::Constants::OUT_CATEGORY_CODES()}) {
        $spending_per_categories{$key} = 0;
    }
    for my $transaction (@transactions) {
        if ($transaction->{type} eq Froogle::Constants::TRANSACTION_TYPE_EXPENSE()) {
            $spending_per_categories{$transaction->{category}} += $transaction->{amount};
        }
    }

    # Added up in a fixed order: adding the amounts in hash order could round the
    # total, and so the percentages, differently from run to run
    my $total_spending = 0;
    foreach my $category (sort keys %spending_per_categories) {
        $total_spending += $spending_per_categories{$category};
    }
    my $total_income = Froogle::Utils::Data::total_income_for_transactions(@transactions);

    # Equal amounts are ordered by name, so the output doesn't vary between runs
    my $category_names = Froogle::Constants::OUT_CATEGORY_CODES();
    my @sorted_keys = sort {
        $spending_per_categories{$b} <=> $spending_per_categories{$a} || $category_names->{$a} cmp $category_names->{$b}
    } keys %spending_per_categories;

    my @rows = ();
    for my $key (@sorted_keys) {
        my $amount = $spending_per_categories{$key};
        push(@rows, {
            name => $category_names->{$key},
            amount => $amount,
            percentage_of_spending => $total_spending > 0 ? $amount / $total_spending * 100 : 0,
            percentage_of_income => $total_income > 0 ? $amount / $total_income * 100 : 0,
        });
    }

    Froogle::Output::Categories::print_report(
        from => $options->{from},
        to => $options->{to},
        rows => \@rows,
    );
}

our @EXPORT_OK = qw(name run);

1;
