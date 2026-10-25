package Froogle::Commands::Help;

use strict;
use warnings;

use Exporter 'import';

use Froogle::Constants ();
use Froogle::Output::Help ();

sub name {
    return "help";
}

sub applicable_options {
    return qw();
}

sub applicable_transaction_types {
    return ();
}

sub defaults {
    return ();
}

sub run {
    Froogle::Output::Help::print_help(
        income_categories => Froogle::Constants::IN_CATEGORY_CODES(),
        expense_categories => Froogle::Constants::OUT_CATEGORY_CODES(),
        transfer_categories => Froogle::Constants::TRF_CATEGORY_CODES(),
    );
}

our @EXPORT_OK = qw(name run);

1;
