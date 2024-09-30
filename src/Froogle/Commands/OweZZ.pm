package Froogle::Commands::OweZZ;

use strict;
use warnings;

use feature 'say';
use Exporter;

use Froogle::Constants;
use Froogle::Utils::DataUtils;
use Froogle::Utils::CurrencyUtils;

sub name {
    return "zz";
}

sub run {
    my $owe_zz = 0;
    my @need_settling = ();

    my @transactions = Froogle::Utils::DataUtils::get_transactions;
    foreach (@transactions) {
        my $transaction = $_;
        if (Froogle::Utils::DataUtils::is_unsettled($transaction)) {
            push(@need_settling, $transaction); 
            $owe_zz += Froogle::Utils::DataUtils::amount_owed_for_transaction($transaction);
        }
    }

    say "";
    for my $i (0 .. $#need_settling) {
        say Froogle::Utils::CurrencyUtils::format_debt_line($need_settling[$i]);
    }
    say "                                                                ==============";
    say Froogle::Utils::CurrencyUtils::who_owe_who_text($owe_zz) . ":                                                      " . Froogle::Utils::CurrencyUtils::format_currency(abs($owe_zz), 10);
    say "";
}

our @EXPORT_OK = qw(name run);

1;
