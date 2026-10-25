package Froogle::Commands::OweZZ;

use strict;
use warnings;

use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::Data ();
use Froogle::Output::OweZZ ();

sub name {
    return "zz";
}

sub applicable_options {
    return qw();
}

sub applicable_transaction_types {
    return (Froogle::Constants::TRANSACTION_TYPE_EXPENSE());
}

sub defaults {
    return ();
}

sub run {
    my $total_owed = 0;
    my @debts = ();

    my @transactions = Froogle::Utils::Data::get_transactions(types => [applicable_transaction_types()]);
    foreach my $transaction (@transactions) {
        if (Froogle::Utils::Data::is_unsettled($transaction)) {
            my $amount_owed = Froogle::Utils::Data::amount_owed_for_transaction($transaction);
            push(@debts, { transaction => $transaction, amount_owed => $amount_owed });
            $total_owed += $amount_owed;
        }
    }

    Froogle::Output::OweZZ::print_report(
        debts => \@debts,
        total_owed => $total_owed,
    );
}

our @EXPORT_OK = qw(name run);

1;
