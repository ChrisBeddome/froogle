use warnings;
use feature 'say';
use List::Util qw(sum);
use Getopt::Long;

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
# use constant DATA_FILE_PATH => $ENV{'BUDGET_DATA_FILE_PATH'};
use constant DATA_FILE_PATH => './test/data.txt';
use constant KEY_MAPPING => qw(date type amount category desc necessity owe_zz settled);
use constant COMMAND_MAPPING => {
    "help" => \&help,
    "overview" => \&overview,
    "list" => \&list,
    "details" => \&details,
    "zz" => \&zz_owe
};

my %options;

main();

sub main {
    %options = get_options();
    my $func = COMMAND_MAPPING->{$options{command}};
    die "Command not recognized: $options{command}" if !defined $func;
    $func->();
}

sub get_options {
    my %local_options = parse_options();
    %local_options = set_defaults(%local_options);
    validate_options(%local_options);
    return %local_options;
}

sub parse_options {
    my %options;
    $options{command} = get_command();
    GetOptions(
        'from|f=s'   => \$options{from},
        'to|t=s'   => \$options{to},
        'necessity|n=i'   => \$options{necessity},
        'category|c=s'   => \$options{category}
    ) or die "Error in command line arguments";
    return %options;
}

sub set_defaults {
    my %options = @_;
    my $command = $options{command};
    $options{to} = get_today() unless defined $options{to} || $command eq "zz" || $command eq "help";
    $options{from} = get_start_of_month() unless defined $options{from} || $command eq "zz" || $command eq "help";
    return %options;
}

sub get_command {
    my $command = 'overview'; #default
    my $first_arg = shift @ARGV;

    # If the first argument is not an option (doesn't start with '-'), treat it as a command
    if (defined $first_arg && $first_arg !~ /^-/) {
        $command = $first_arg;
    } else {
        unshift @ARGV, $first_arg if defined $first_arg;  # Push back the first arg if not a command
    }
    return $command;
}


sub validate_options {
    my (%options) = @_;
    my $command = $options{command};

    my %applicable_options = (
        'help'=> ['command'],
        'overview' => ['command', 'from', 'to'],
        'list' => ['command', 'from', 'to', 'necessity', 'category'],
        'details' => ['command', 'from', 'to', 'necessity', 'category'],
        'zz' => ['command']
    );

    for my $option (keys %options) {
        if (defined $options{$option} && !grep { $_ eq $option } @{$applicable_options{$command}}) {
            die "Option '$option' not applicable to '${command}' command";
        }
    }

    if (defined $options{from} && $options{to}) {
        if ($options{from} gt $options{to}) {
            die "From date must be before to date";
        }   
    }

    if (defined $options{from} && $options{from} !~ /^\d{4}-\d{2}-\d{2}$/) {
        die "Invalid date format for 'from' option";
    }

    if (defined $options{to} && $options{to} !~ /^\d{4}-\d{2}-\d{2}$/) {
        die "Invalid date format for 'to' option";
    }

    if (defined $options{necessity} && ($options{necessity} < 1 || $options{necessity} > 3)) {
        die "Necessity must be 1, 2, or 3";
    }

    if (defined $options{category} && !exists CATEGORY_CODES->{$options{category}}) {
        die "Invalid category code";
    }
}

sub get_transactions {
    open(my $fh, '<', DATA_FILE_PATH) or die "Error when attempting to open file" .  DATA_FILE_PATH . ":\n$!";

    my @errors = validate_file($fh);
    if (@errors > 0) {
        report_errors(@errors);
        close($fh);
        die "Data contains errors; Exiting."
    }

    my @transactions = parse_file($fh);
    @transactions = filter_transactions(@transactions);

    close($fh);

    return @transactions;
}

sub help {
    say "";
    say "Commands: ";
    say "";
    say "   overview:  Displays a summary of income and spending for the specified date range";
    say "   list:      Lists all transactions for the specified date range";
    say "   details:   Lists all transactions for the specified date range with additional details";
    say "   zz:        Displays a summary of money owed";
    say "";
    say "Options: ";
    say "";
    say "   -f, --from:      Start date for the date range (default: start of the current month)";
    say "   -t, --to:        End date for the date range (default: today)";
    say "   -n, --necessity: Filter transactions by necessity (1 = frivolous, 2 = unnecessary, 3 = necessary)";
    say "   -c, --category:  Filter transactions by category code";
    say "";
    say "Category codes: ";
    say "";
    for my $key (sort keys %{CATEGORY_CODES()}) {
        say "   $key: " . CATEGORY_CODES->{$key};
    }
    say "";
    say "Examples: ";
    say "";
    say "   list all transactions for the month of January 2021: ";
    say "       => froogle list -f 2021-01-01 -t 2021-01-31";
    say "";
    say "   list all transactions for the month of January 2021 in the 'Groceries' category: ";
    say "       => froogle list -f 2021-01-01 -t 2021-01-31 -c GRC";
    say "";
    say "   list all details of transactions for the current month that are 'necessary': ";
    say "       => froogle details -n 3";
    say "";

}

sub overview {
    my %spending = ("1" => 0, "2" => 0, "3" => 0);
    my $income = 0;

    my @transactions = get_transactions;

    foreach (@transactions) {
        my $transaction = $_;
        if ($transaction->{type} eq "IN") { 
            $income += $transaction->{amount};
        } else {
            $spending{$transaction->{necessity}} += $transaction->{amount};
        }
    }

    $income = format_currency($income, 10);
    $necessary = format_currency($spending{'3'}, 10);
    $unnecessary = format_currency($spending{'2'}, 10);
    $frivilous = format_currency($spending{'1'}, 10);


    say "";
    say formatted_date_range_text();
    say "";
    say "Total Income:                   $income";
    say "";
    say "Necessary spending:             $necessary";
    say "Unnecessary spending:           $unnecessary";
    say "Frivolous spending:             $frivilous";
    say "Total Spending:                 " . format_currency(sum(values %spending), 10);
    say "";
}

sub list {
    my @transactions = get_transactions;

    say "";
    say formatted_date_range_text();
    say "";

    foreach (@transactions) {
        my $transaction = $_;
        print_transaction_simple($transaction);
    }
    say "";
}

sub details {
    my @transactions = get_transactions;

    say "";
    say formatted_date_range_text();

    foreach (@transactions) {
        my $transaction = $_;
        say "";
        print_transaction_detailed($transaction);
        say "";
    }
    say "";
}

sub zz_owe {
    my $owe_zz = 0;
    my @need_settling = ();

    my @transactions = get_transactions;
    foreach (@transactions) {
        my $transaction = $_;
        if (is_unsettled($transaction)) {
            push(@need_settling, $transaction); 
            $owe_zz += amount_owed_for_transaction($transaction);
        }
    }

    say "";
    for my $i (0 .. $#need_settling) {
        say format_debt_line($need_settling[$i]);
    }
    say "                                                                ==============";
    say who_owe_who_text($owe_zz) . ":                                                      " . format_currency(abs($owe_zz), 10);
    say "";
}

sub print_transaction_simple {
    my $transaction = shift;
    my $desc = $transaction->{'desc'} // CATEGORY_CODES->{$transaction->{'category'}};
    my $amount = format_currency($transaction->{amount}, 10);
    my $type = $transaction->{type};
    $type = "IN " if ($type eq "IN");
    say "$amount $type on $transaction->{date} for $desc";
}

sub print_transaction_detailed {
    my $transaction = shift;
    say "Date:           $transaction->{date}";
    say "Type:           $transaction->{type}";
    say "Amount:         " . format_currency($transaction->{amount});
    say "Category:       $transaction->{category}" unless $transaction->{type} eq "IN";
    say "Description:    $transaction->{desc}" if defined $transaction->{desc};
    say "Necessity:      " . format_necessity($transaction->{necessity}) unless $transaction->{type} eq "IN";
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

    return @records;
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

sub format_necessity {
    my $necessity_num = shift;
    my %necessary = ("1" => "Frivolous", "2" => "Unnecessary", "3" => "Necessary");
    return $necessary{$necessity_num};
}

sub filter_transactions {
    my @transactions = @_;
    my @filtered_transactions = ();

    foreach (@transactions) {
        my $transaction = $_;
        if ($transaction->{type} eq "IN") {
            next if $options{command} eq "list" || $options{command} eq "details" || $options{command} eq "zz";
        }
        if (defined $options{from} && defined $options{to}) {
            next unless is_date_in_range($transaction->{date}, $options{from}, $options{to});
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

sub is_date_in_range {
    my ($date, $from, $to) = @_;

    # Remove the dashes
    $date =~ s/-//g;
    $from =~ s/-//g;
    $to =~ s/-//g;

    if ($date >= $from && $date <= $to) {
        return 1;
    } else {
        return 0;
    }
}

sub get_today {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;
    return sprintf("%04d-%02d-%02d", $year, $mon, $mday);
}

sub get_start_of_month {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;
    return sprintf("%04d-%02d-01", $year, $mon);
}

sub format_date {
    my $date = shift;
    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    return $months[substr($date, 5, 2) - 1] . " " . substr($date, 8, 2) . " " . substr($date, 0, 4);
}

sub formatted_date_range_text {
    return format_date($options{from}) . " - " . format_date($options{to});
}
