package Froogle::Utils::Data;

use strict;
use warnings;

use feature 'say';
use Exporter 'import';

use Froogle::Constants ();
use Froogle::Validators::FileValidator ();
use Froogle::OptionsManager ();
use Froogle::Utils::Date ();
use Froogle::Utils::Formatting ();
use Froogle::UserErrorHandler ();

sub split_line {
    my $line = shift;
    return map { s/^\s+|\s+$//gr } split /;\s*/, $line;
}

sub get_transactions {
    open(my $fh, '<', Froogle::Constants::DATA_FILE_PATH()) or die "Error when attempting to open file" .  Froogle::Constants::DATA_FILE_PATH() . ":\n$!";

    my @errors = Froogle::Validators::FileValidator::validate_file($fh);
    if (@errors > 0) {
        report_errors(@errors);
        close($fh);
        Froogle::UserErrorHandler::raise("INVALID_DATA");
    }

    my @transactions = parse_file($fh);
    @transactions = filter_transactions(@transactions);

    close($fh);

    return @transactions;
}

sub parse_file {
    my $fh = shift;
    my @records;

    while (my $line = <$fh>) {
        chomp $line;
        next if (line_empty($line));
        my %record = decode_transaction($line);
        push @records, \%record;
    }

    return @records;
}

sub report_errors {
    my (@errors) = @_;
    foreach my $error (@errors) {
        say "Error on line $error->{line}: $error->{message}";
    }
}

sub decode_transaction {
    my $line = shift;
    chomp $line;
    my @keys = Froogle::Constants::FILE_KEY_MAPPING();
    my @values = split_line($line);
    my %record;

    @record{@keys} = (undef) x @keys;

    for my $i (0 .. $#keys) {
        if (defined $values[$i] && $values[$i] ne '') {
            $record{$keys[$i]} = $values[$i];
        }
    }

    return %record;
}

sub filter_transactions {
    my %options = Froogle::OptionsManager::get_options();
    my $command = Froogle::OptionsManager::get_command();
    my @transactions = @_;
    my @filtered_transactions = ();

    foreach (@transactions) {
        my $transaction = $_;
        if ($transaction->{type} ne "OUT") {
            next if grep { $command eq $_ } qw(list details zz);
        }
        if (defined $options{from} && defined $options{to}) {
            next unless Froogle::Utils::Date::is_date_in_range($transaction->{date}, $options{from}, $options{to});
        }
        if (defined $options{necessity}) {
            next unless $transaction->{necessity} == $options{necessity};
        }
        if (defined $options{category}) {
            next unless $transaction->{category} eq $options{category};
        }
        push(@filtered_transactions, $transaction);
    }

    return @filtered_transactions;
}

sub is_unsettled {
    my $transaction = shift;
    if (defined $transaction->{owe_zz} && !$transaction->{settled}) {
        return 1;
    }
    return 0;
}

sub amount_owed_for_transaction {
    my $transaction = shift;
    if (is_unsettled($transaction)) {
        my $owe_zz = 0;
        my $amount_owed = $transaction->{owe_zz};
        if ($amount_owed eq "HALF") {
            $owe_zz += $transaction->{amount};
        } elsif ($amount_owed eq "-HALF") {
            $owe_zz -= $transaction->{amount};
        } else {
            $owe_zz += $amount_owed;
        }
        return $owe_zz;
    }
    return 0;
}

sub line_empty {
    my $line = shift;
    return Froogle::Utils::Formatting::trim($line) eq '';
}


our @EXPORT_OK = qw(split_line get_transactions is_unsettled amount_owed_for_transaction);

1;
