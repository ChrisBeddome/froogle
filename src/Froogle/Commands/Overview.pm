package Froogle::Commands::Overview;

use strict;
use warnings;

use List::Util qw(sum);
use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::Data ();
use Froogle::Utils::Date ();
use Froogle::Output::Overview ();

sub name {
    return "overview";
}

sub applicable_options {
    return qw(from to);
}

sub applicable_transaction_types {
    return Froogle::Constants::TRANSACTION_TYPES();
}

sub defaults {
    return (
        to => Froogle::Utils::Date::get_today(),
        from => Froogle::Utils::Date::get_start_of_month()
    );
}

sub run {
    my ($class, $options) = @_;
    my %spending = (
        Froogle::Constants::NECESSITY_FRIVOLOUS() => 0,
        Froogle::Constants::NECESSITY_UNNECESSARY() => 0,
        Froogle::Constants::NECESSITY_NECESSARY() => 0
    );
    my $income = 0;
    my $pas_transfers = 0;
    my $sas_transfers = 0;

    my @transactions = Froogle::Utils::Data::get_transactions(
        types => [applicable_transaction_types()],
        from => $options->{from},
        to => $options->{to},
    );

    foreach my $transaction (@transactions) {
        if ($transaction->{type} eq Froogle::Constants::TRANSACTION_TYPE_INCOME()) {
            $income += $transaction->{amount};
        } elsif ($transaction->{type} eq Froogle::Constants::TRANSACTION_TYPE_TRANSFER()) {
            if ($transaction->{category} eq Froogle::Constants::CATEGORY_PURCHASE_ASSET()) {
                $pas_transfers += $transaction->{amount};
            } elsif ($transaction->{category} eq Froogle::Constants::CATEGORY_SELL_ASSET()) {
                $sas_transfers += $transaction->{amount};
            }
        } else {
            $spending{$transaction->{necessity}} += $transaction->{amount};
        }
    }

    my $total_spending = sum(values %spending);

    Froogle::Output::Overview::print_report(
        from => $options->{from},
        to => $options->{to},
        income => $income,
        purchase_assets => $pas_transfers,
        sell_assets => $sas_transfers,
        net_transfers => $pas_transfers - $sas_transfers,
        necessary_spending => $spending{Froogle::Constants::NECESSITY_NECESSARY()},
        unnecessary_spending => $spending{Froogle::Constants::NECESSITY_UNNECESSARY()},
        frivolous_spending => $spending{Froogle::Constants::NECESSITY_FRIVOLOUS()},
        total_spending => $total_spending,
        net => $income - $total_spending,
    );
}

our @EXPORT_OK = qw(name run);

1;
