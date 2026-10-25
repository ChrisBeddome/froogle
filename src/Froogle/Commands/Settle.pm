package Froogle::Commands::Settle;

use strict;
use warnings;

use feature 'say';
use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::Data ();

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
    my $user_confirmation = get_confirmation("Are you sure you want to mark all transactions as settled? (y/n):");
    return unless $user_confirmation;

    # Validate the whole file first so nothing is written if it is invalid
    Froogle::Utils::Data::get_transactions(types => [applicable_transaction_types()]);

    my @original_lines = Froogle::Utils::Data::read_data_file();
    my @settled_lines = map { Froogle::Utils::Data::settle_line($_) } @original_lines;

    Froogle::Utils::Data::backup_data_file(@original_lines);
    Froogle::Utils::Data::write_data_file(@settled_lines);

    say "";
    say "All outstanding shared transactions have been marked as settled";
    say "";
}

sub get_confirmation {
    my $prompt = shift // "Are you sure? (y/n): ";
    my $response = '';
    while ($response !~ /^[yn]$/i) {
        say $prompt;
        $response = <STDIN>;
        return 0 unless defined $response;  # stdin closed, treat as "n"
        chomp $response;
    }
    return lc($response) eq 'y' ? 1 : 0;
}


our @EXPORT_OK = qw(name run);

1;
