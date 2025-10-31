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

sub defaults {
    return ();
}

sub run {
    my $user_confirmation = get_confirmation("Are you sure you want to mark all transactions as settled? (y/n):");
    return unless $user_confirmation;

    my @transactions = Froogle::Utils::Data::get_transactions();
    backup_file();

    foreach my $transaction (@transactions) {
        if (Froogle::Utils::Data::is_unsettled($transaction)) {
            $transaction->{settled} = 1;
        }
    }

    Froogle::Utils::Data::write_transactions_to_file(@transactions);

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
        chomp $response;
    }
    return lc($response) eq 'y' ? 1 : 0;
}

sub backup_file {
    my $file = Froogle::Constants::DATA_FILE_PATH();
    my $backup_file = $file . '.bak';
    unlink $backup_file if -e $backup_file;
    rename $file, $backup_file or die "Could not backup file: $!";
}


our @EXPORT_OK = qw(name run);

1;
