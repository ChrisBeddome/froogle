use warnings;
use feature 'say';
use List::Util qw(sum);

use constant CATEGORY_CODES => {
    'GRC' => 'Groceries',
    'DNG' => 'Dining',
    'ENT' => 'Entertainment/Leisure',
    'HOS' => 'Housing',
    'SRV' => 'Services',
    'HOM' => 'Home Improvement/household supplies/decor',
    'TRP' => 'Transportation',
    'PET' => 'Pets',
    'CLT' => 'Clothing',
    'HLT' => 'Health',
    'GFT' => 'Gifts',
    'SLF' => 'Self Improvement',
    'TOY' => 'Toys/Hobbies',
    'MSC' => 'Miscellaneous',
    'INC' => 'Income',
    'SAV' => 'Savings',
    'ASS' => 'Assets'
};
use constant DATA_FILE_PATH => $ENV{'BUDGET_DATA_FILE_PATH'};
use constant KEY_MAPPING => qw(date type amount category desc necessity owe_zz settled);
use constant COMMAND_MAPPING => {
    "overview" => \&overview,
    "zz" => \&zz_owe
};

main();

sub main {
    my $command = $ARGV[0] || "overview";
    my $arg = $ARGV[1];
    my $func = COMMAND_MAPPING->{$command} ;
    die "Command not recognized: $command" if !defined $func;
    $func->();
}

sub process {
    my $execution_block = shift;

    unless (ref $execution_block eq 'CODE') {
        die "The first argument must be a code reference.";
    }

    open(my $fh, '<', DATA_FILE_PATH) or die "Error when attempting to open file" .  DATA_FILE_PATH . ":\n$!";

    my @errors = validate_file($fh);
    if (@errors > 0) {
        report_errors(@errors);
        close($fh);
        die "Data contains errors; Exiting."
    }

    my $transactions = parse_file($fh);
    close($fh);

    foreach my $transaction (@$transactions) {
        $execution_block->($transaction);
    }
}

sub overview {
    my %spending = ("1" => 0, "2" => 0, "3" => 0);
    my $income = 0;
    my $owe_zz = 0;

    process(sub {
        my $transaction = shift;
        if ($transaction->{type} eq "IN") { 
            $income += $transaction->{amount};
        } else {
            $spending{$transaction->{necessity}} += $transaction->{amount};
        }
        $owe_zz += amount_owed_for_transaction($transaction);
    });

    $income = format_currency($income, 10);
    $necessary = format_currency($spending{'3'}, 10);
    $unnecessary = format_currency($spending{'2'}, 10);
    $frivilous = format_currency($spending{'1'}, 10);

    say "";
    say "Total Income:                   $income";
    say "";
    say "Necessary spending:             $necessary";
    say "Unnecessary spending:           $unnecessary";
    say "Frivolous spending:             $frivilous";
    say "Total Spending:                 " . format_currency(sum(values %spending), 10);
    say "";
    say who_owe_who_text($owe_zz) . ":                  " . format_currency(abs($owe_zz), 10);
    say "";
}

sub zz_owe {
    my $owe_zz = 0;
    my @need_settling = ();

    process(sub {
        my $transaction = shift;
        if (is_unsettled($transaction)) {
            push(@need_settling, $transaction); 
            $owe_zz += amount_owed_for_transaction($transaction);
        }
    });

    say "";
    for my $i (0 .. $#need_settling) {
        say format_debt_line($need_settling[$i]);
    }
    say "                                                                ==============";
    say who_owe_who_text($owe_zz) . ":                                                      " . format_currency(abs($owe_zz), 10);
    say "";

}

sub validate_file {
    my $fh = shift;
    my @errors = ();

    while (my $line = <$fh>) {
        chomp $line;
        my $error = validate_line($line);
        if ($error) {
            push(@errors, {line => $., message => $error}); 
        }
    }

    seek($fh, 0, 0) or die "Could not seek: $!";
    return @errors;
}

sub parse_file {
    my $fh = shift;
    my @records;

    while (my $line = <$fh>) {
        chomp $line;

        my @values = split_line($line);
        my @keys = KEY_MAPPING;
        my %record;

        @record{@keys} = (undef) x @keys;

        for my $i (0 .. $#keys) {
            if (defined $values[$i] && $values[$i] ne '') {
                $record{$keys[$i]} = $values[$i];
            }
        }

        push @records, \%record;
    }

    return \@records;
}

sub validate_line {
    my ($line) = @_;
    my @fields = split_line($line);

    unless ($fields[0] =~ /^\d{4}-\d{2}-\d{2}$/) {
        return "Invalid date format";
    }

    unless ($fields[2] =~ /^\d+(\.\d+)?$/ && $fields[2] >= 0) {
        return "Third field should be a positive number";
    }

    if ($fields[1] eq "IN") { 
        return validate_income(@fields);
    } elsif ($fields[1] eq "OUT") {
        return validate_expense(@fields);
    }

    return "Invalid transaction type";
}

sub validate_income {
    my (@fields) = @_;

    return "Invalid number of fields" unless @fields >= 3 && @fields <= 5;
    return undef;
}

sub validate_expense {
    my (@fields) = @_;

    return "Invalid number of fields" unless @fields >= 6 && @fields <= 8;

    unless (exists CATEGORY_CODES->{$fields[3]}) {
        return "Invalid category code";
    }

    # The fifth field can be any string (no validation needed)

    unless ($fields[5] =~ /^[123]$/) {
        return "Sixth field should be 1, 2, or 3";
    }

    return undef if @fields <= 6;

    if ($fields[6] ne '' && $fields[6] !~ /^-?\d+(\.\d+)?$/ && $fields[6] ne 'HALF' && $fields[6] ne '-HALF') {
        return "Seventh field should be a number, 'HALF', '-HALF' or empty";
    }

    return "Eighth field must not be empty if seventh field is present" if @fields < 8;

    if ($fields[6] eq '' && $fields[7] ne '') {
        return "Eighth field should be empty if seventh is empty";
    }
    elsif ($fields[7] ne '' && $fields[7] !~ /^[01]$/) {
        return "Eighth field should be 0 or 1";
    }

    return undef;
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

sub is_unsettled {
    my $transaction = shift;
    if (defined $transaction->{owe_zz} && !$transaction->{settled}) {
        return 1;
    }
    return 0;
}

sub report_errors {
    my (@errors) = @_;
    foreach my $error (@errors) {
        say "Error on line $error->{line}: $error->{message}";
    }
}

sub split_line {
    my $line = shift;
    return map { s/^\s+|\s+$//gr } split /;\s*/, $line;
}

sub format_currency {
    my ($dollars, $width) = @_;

    my $formatted_amount = sprintf("%.2f", $dollars);

    if (defined $width) {
        my $total_length = $width - 1;  # Subtract 1 for the dollar sign
        return sprintf("\$%${total_length}s", $formatted_amount);
    }

    return "\$" . $formatted_amount;
}

sub who_owe_who_text {
    my $amount = shift;
    return $amount >= 0 ? "Chris Owes ZZ" : "ZZ Owes Chris";
}

sub format_debt_line {
    my $transaction = shift;
    my $desc = $transaction->{'desc'} // CATEGORY_CODES->{$transaction->{'category'}};
    $amount_owed = amount_owed_for_transaction($transaction);
    return who_owe_who_text($amount_owed) . "         " . truncate_or_pad($desc, 30)  . "             " . format_currency(abs($amount_owed), 10);
}

sub truncate_or_pad {
    my ($input, $length, $pad_left) = @_;
     if (length($input) > $length) {
        $input = substr($input, 0, $length) . '...';
    }
    $length += 3; #for ellipsis
    return $pad_left ? sprintf("%${length}s", $input) : sprintf("%-${length}s", $input);
}
