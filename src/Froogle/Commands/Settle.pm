package Froogle::Commands::Settle;

use strict;
use warnings;

use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::Data ();
use Froogle::Output::Settle ();

sub name {
    return "settle";
}

sub applicable_options {
    return qw();
}

sub applicable_transaction_types {
    return Froogle::Constants::TRANSACTION_TYPES();
}

sub defaults {
    return ();
}

sub run {
    my $user_confirmation = Froogle::Output::Settle::confirm_settle();
    return unless $user_confirmation;

    # Validate the whole file first so nothing is written if it is invalid
    Froogle::Utils::Data::get_transactions(types => [applicable_transaction_types()]);

    my @original_lines = Froogle::Utils::Data::read_data_file();
    my @settled_lines = map { Froogle::Utils::Data::settle_line($_) } @original_lines;

    Froogle::Utils::Data::backup_data_file(@original_lines);
    Froogle::Utils::Data::write_data_file(@settled_lines);

    Froogle::Output::Settle::print_settled();
}


our @EXPORT_OK = qw(name run);

1;
