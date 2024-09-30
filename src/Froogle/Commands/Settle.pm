package Froogle::Commands::Settle;

use strict;
use warnings;

use feature 'say';
use Exporter;

use Froogle::Constants;
use Froogle::Utils::DataUtils;

sub name {
    return "settle";
}

sub run {
    my $user_confirmation = get_confirmation("Are you sure you want to mark all transactions as settled? (y/n):");
    return unless $user_confirmation;

    my @transactions = Froogle::Utils::DataUtils::get_transactions();
    backup_file();

    foreach (@transactions) {
        my $transaction = $_;
        if (Froogle::Utils::DataUtils::is_unsettled($transaction)) {
            $transaction->{settled} = 1;
        }
    }

    write_file(@transactions);

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

sub encode_transaction {
    my $record = shift;
    my @keys = Froogle::Constants::FILE_KEY_MAPPING();
    my @values = ();
    for my $key (@keys) {
        my $val = $record->{$key};
        $val = '' if !defined $val;
        push @values, $val;
    }
    my $line = join(' ; ', @values);
    $line =~ s/[ ;]+$//;  # Remove any combination of whitespace and semicolons from the end
    return $line;
}

sub backup_file {
    my $file = Froogle::Constants::DATA_FILE_PATH();
    my $backup_file = $file . '.bak';
    unlink $backup_file if -e $backup_file;
    rename $file, $backup_file or die "Could not backup file: $!";
}

sub write_file {
    my @transactions = @_;
    open my $fh, '>', Froogle::Constants::DATA_FILE_PATH() or die "Could not open output file: $!";
    foreach (@transactions) {
        my $transaction = $_;
        print $fh encode_transaction($transaction) . "\n";
    }
    close $fh;
}

sub is_empty {
    my ($string) = @_;
    return $string =~ /^\s*$/ ? 1 : 0;
}

our @EXPORT_OK = qw(name run);

1;
