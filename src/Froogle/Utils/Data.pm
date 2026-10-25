package Froogle::Utils::Data;

use strict;
use warnings;

use feature 'say';
use Cwd ();
use File::Temp ();
use IO::Handle ();
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

    my ($transactions, $errors) = parse_file($fh);
    close($fh);

    if (@$errors > 0) {
        report_errors(@$errors);
        Froogle::UserErrorHandler::raise("INVALID_DATA");
    }

    return filter_transactions(@$transactions);
}

# Validates and decodes every line in a single pass, splitting each line once
sub parse_file {
    my $fh = shift;
    my (@records, @errors);

    while (my $line = <$fh>) {
        chomp $line;
        next if (line_empty($line));
        my @fields = split_line($line);
        my $error = Froogle::Validators::FileValidator::validate_fields(@fields);
        if ($error) {
            push(@errors, {line => $., message => $error});
            next;
        }
        push @records, decode_fields(@fields);
    }

    return (\@records, \@errors);
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
    return %{ decode_fields(split_line($line)) };
}

sub decode_fields {
    my @values = @_;
    my @keys = Froogle::Constants::FILE_KEY_MAPPING();
    my %record;

    @record{@keys} = (undef) x @keys;

    for my $i (0 .. $#keys) {
        if (defined $values[$i] && $values[$i] ne '') {
            $record{$keys[$i]} = $values[$i];
        }
    }

    return \%record;
}

sub filter_transactions {
    my %options = Froogle::OptionsManager::get_options();
    my $command = Froogle::OptionsManager::get_command();
    my @transactions = @_;
    my @filtered_transactions = ();

    foreach my $transaction (@transactions) {
        if ($transaction->{type} ne Froogle::Constants::TRANSACTION_TYPE_EXPENSE()) {
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
        if ($amount_owed eq Froogle::Constants::SPECIAL_VALUE_HALF()) {
            $owe_zz += $transaction->{amount};
        } elsif ($amount_owed eq Froogle::Constants::SPECIAL_VALUE_NEGATIVE_HALF()) {
            $owe_zz -= $transaction->{amount};
        } else {
            $owe_zz += $amount_owed;
        }
        return $owe_zz;
    }
    return 0;
}

sub total_income_for_transactions {
    my @transactions = @_;
    my $total = 0;
    foreach my $transaction (@transactions) {
        if ($transaction->{type} eq Froogle::Constants::TRANSACTION_TYPE_INCOME()) {
            $total += $transaction->{amount};
        }
    }
    return $total;
}

# Marks an unsettled transaction line as settled. Only the SETTLED field is
# changed, so the rest of the line keeps its exact formatting
sub settle_line {
    my $line = shift;
    return $line if line_empty($line);

    my %transaction = decode_transaction($line);
    return $line unless is_unsettled(\%transaction);

    my $fields_before_settled = Froogle::Constants::FIELD_INDEX_SETTLED();
    $line =~ s/^((?:[^;]*;){$fields_before_settled}\s*)0/${1}1/;
    return $line;
}

sub read_data_file {
    my $file = data_file_real_path();
    open my $fh, '<', $file or die "Could not open $file: $!";
    my @lines = <$fh>;
    close $fh;
    return @lines;
}

# Writes the lines to the data file's backup (the data file path plus .bak)
sub backup_data_file {
    my @lines = @_;
    my $file = data_file_real_path();
    write_lines_atomically($file . '.bak', data_file_mode($file), @lines);
}

sub write_data_file {
    my @lines = @_;
    my $file = data_file_real_path();
    write_lines_atomically($file, data_file_mode($file), @lines);
}

my $resolved_data_file_path;

# Resolves symlinks so writes update the file a link points to rather than replacing the
# link. Resolved once, so reading, backing up and writing all use the same file even if
# writing the backup changes where a chain of links leads
sub data_file_real_path {
    if (!defined $resolved_data_file_path) {
        $resolved_data_file_path = Cwd::abs_path(Froogle::Constants::DATA_FILE_PATH());
    }
    return $resolved_data_file_path;
}

# Permission bits of the data file, kept for the backup and the rewritten file
sub data_file_mode {
    my $file = shift;
    my @file_info = stat($file) or die "Could not read $file: $!";
    return $file_info[2] & 07777;
}

# Writes to a temporary file beside $file and renames it into place, so $file is
# never left partially written. The rename replaces whatever is at $file (even a
# symlink or a read-only file) rather than writing through it
sub write_lines_atomically {
    my ($file, $mode, @lines) = @_;
    my $temp = File::Temp->new(TEMPLATE => "$file.XXXXXX");  # removed on failure
    print $temp @lines or die "Could not write $temp: $!";
    $temp->flush and $temp->sync or die "Could not write $temp: $!";
    chmod($mode, $temp->filename) or die "Could not set permissions on $temp: $!";
    rename $temp->filename, $file or die "Could not replace $file: $!";
}

sub line_empty {
    my $line = shift;
    return Froogle::Utils::Formatting::trim($line) eq '';
}


our @EXPORT_OK = qw(split_line get_transactions is_unsettled amount_owed_for_transaction total_income_for_transactions settle_line read_data_file backup_data_file write_data_file);

1;
