package Froogle::Commands::Overview;

use strict;
use warnings;

use feature 'say';
use List::Util qw(sum);
use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::Data ();
use Froogle::Utils::Date ();
use Froogle::Utils::Currency ();

sub name {
    return "overview";
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
    my %spending = (
        Froogle::Constants::NECESSITY_FRIVOLOUS() => 0,
        Froogle::Constants::NECESSITY_UNNECESSARY() => 0,
        Froogle::Constants::NECESSITY_NECESSARY() => 0
    );
    my $income = 0;
    my $pas_transfers = 0;
    my $sas_transfers = 0;

    my @transactions = Froogle::Utils::Data::get_transactions;

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

    my $width = Froogle::Constants::CURRENCY_FORMAT_WIDTH();
    my $income_str = Froogle::Utils::Currency::format_currency($income, $width);
    my $pas_str = Froogle::Utils::Currency::format_currency($pas_transfers, $width);
    my $sas_str = Froogle::Utils::Currency::format_currency($sas_transfers, $width);
    my $net_transfers = $pas_transfers - $sas_transfers;
    my $net_transfers_str = Froogle::Utils::Currency::format_currency($net_transfers, $width);
    my $necessary = Froogle::Utils::Currency::format_currency($spending{Froogle::Constants::NECESSITY_NECESSARY()}, $width);
    my $unnecessary = Froogle::Utils::Currency::format_currency($spending{Froogle::Constants::NECESSITY_UNNECESSARY()}, $width);
    my $frivolous = Froogle::Utils::Currency::format_currency($spending{Froogle::Constants::NECESSITY_FRIVOLOUS()}, $width);

    say "";
    say Froogle::Utils::Date::formatted_date_range();
    say "";
    say "Total Income:                   $income_str";
    say "";
    say "Purchase Assets:                $pas_str";
    say "Sell Assets:                    $sas_str";
    say "Net Transfers:                  $net_transfers_str";
    say "";
    say "Necessary spending:             $necessary";
    say "Unnecessary spending:           $unnecessary";
    say "Frivolous spending:             $frivolous";
    say "Total Spending:                 " . Froogle::Utils::Currency::format_currency(sum(values %spending), $width);
    say "";
    say "Net                             " . Froogle::Utils::Currency::format_currency($income - sum(values %spending), $width);
    say "";
}

our @EXPORT_OK = qw(name run);

1;
