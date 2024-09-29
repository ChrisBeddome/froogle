use strict;
use warnings;

use feature 'say';

use List::Util qw(sum);
use Getopt::Long;

require './Constants.pm';
require './FileValidator.pm';
require './Utils.pm';
require './FileUtils.pm';

use constant COMMAND_MAPPING => {
    "help" => \&help,
    "overview" => \&overview,
    "list" => \&list,
    "details" => \&details,
    "cats" => \&categories,
    "zz" => \&zz_owe,
    "settle" => \&settle
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
    $options{to} = get_today() unless defined $options{to} || grep { $command eq $_ } qw(zz help settle);
    $options{from} = get_start_of_month() unless defined $options{from} || grep { $command eq $_ } qw(zz help settle);

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
        'cats' => ['command', 'from', 'to'],
        'zz' => ['command'],
        'settle' => ['command']
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

    if (defined $options{from} && !Utils::validate_date($options{from})) {
        die "Invalid date format for 'from' option";
    }

    if (defined $options{to} && !Utils::validate_date($options{to})) {
        die "Invalid date format for 'to' option";
    }

    if (defined $options{necessity} && ($options{necessity} < 1 || $options{necessity} > 3)) {
        die "Necessity must be 1, 2, or 3";
    }

    if (defined $options{category} && !exists COMBINED_CATEGORY_CODES()->{$options{category}}) {
        die "Invalid category code";
    }
}

sub get_transactions {
    open(my $fh, '<', Constants::DATA_FILE_PATH()) or die "Error when attempting to open file" .  Constants::DATA_FILE_PATH() . ":\n$!";

    my @errors = FileValidator::validate_file($fh);
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
    say "   list:      Lists all spending transactions for the specified date range";
    say "   details:   Lists all spending transactions for the specified date range with additional details";
    say "   zz:        Displays a summary of money owed";
    say "   cats:      Displays a summary of spending per category";
    say "   settle:    Updates all outstanding shared transactions to be marked as settled";
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
    say "   Income: ";
    for my $key (sort keys %{Constants::IN_CATEGORY_CODES()}) {
        say "       $key: " . Constants::IN_CATEGORY_CODES()->{$key};
    }
    say "";
    say "   Expenses: ";
    for my $key (sort keys %{Constants::OUT_CATEGORY_CODES()}) {
        say "       $key: " . Constants::OUT_CATEGORY_CODES()->{$key};
    }
    say "";
    say "   Assets: ";
    for my $key (sort keys %{Constants::ASS_CATEGORY_CODES()}) {
        say "       $key: " . Constants::ASS_CATEGORY_CODES()->{$key};
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
    my $assets = 0;

    my @transactions = get_transactions;

    foreach (@transactions) {
        my $transaction = $_;
        if ($transaction->{type} eq "IN") { 
            $income += $transaction->{amount};
        } elsif ($transaction->{type} eq "ASS") {
            $assets += $transaction->{amount};
        } else {
            $spending{$transaction->{necessity}} += $transaction->{amount};
        }
    }

    my $income_str = format_currency($income, 10);
    my $assets_str = format_currency($assets, 10);
    my $necessary = format_currency($spending{'3'}, 10);
    my $unnecessary = format_currency($spending{'2'}, 10);
    my $frivilous = format_currency($spending{'1'}, 10);

    say "";
    say formatted_date_range_text();
    say "";
    say "Total Income:                   $income_str";
    say "";
    say "Transfer to assets:             $assets_str";    
    say "";
    say "Necessary spending:             $necessary";
    say "Unnecessary spending:           $unnecessary";
    say "Frivolous spending:             $frivilous";
    say "Total Spending:                 " . format_currency(sum(values %spending), 10);
    say "";
    say "Net                             " . format_currency($income - sum(values %spending) - $assets, 10);
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

sub categories {
    my %spending_per_categories;
    my @transactions = get_transactions;
    for my $key (keys %{Constants::OUT_CATEGORY_CODES()}) {
        $spending_per_categories{$key} = 0;
    }
    for my $transaction (@transactions) {
        if ($transaction->{type} eq "OUT") {
            $spending_per_categories{$transaction->{category}} += $transaction->{amount};
        }
    }
    say "";
    say formatted_date_range_text();
    say "";
    
    my $total_spending = sum(values %spending_per_categories);
    my $total_income = total_income_for_transactions(@transactions);

    my @sorted_keys = sort { $spending_per_categories{$b} <=> $spending_per_categories{$a} } keys %spending_per_categories;
    say "Category                              Amount    Percentage (spending)    Percentage (income)";
    say "=" x 92;
    for my $key (@sorted_keys) {
        my $cat_text = truncate_or_pad(Constants::OUT_CATEGORY_CODES()->{$key}, 30);
        my $percentage_of_spending = $total_spending > 0 ? $spending_per_categories{$key} / $total_spending * 100 : 0;
        my $percentage_of_income = $total_income > 0 ? $spending_per_categories{$key} / $total_income * 100 : 0;
        my $percentage_of_spending_text = format_percentage($percentage_of_spending);
        my $percentage_of_income_text = format_percentage($percentage_of_income);
        say $cat_text . format_currency($spending_per_categories{$key}, 10) . "                   " . $percentage_of_spending_text . "                " . $percentage_of_income_text;
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

sub settle {
    my $user_confirmation = get_confirmation("Are you sure you want to mark all transactions as settled? (y/n):");
    return unless $user_confirmation;

    my @transactions = get_transactions;
    backup_file();

    foreach (@transactions) {
        my $transaction = $_;
        if (is_unsettled($transaction)) {
            $transaction->{settled} = 1;
        }
    }

    write_file(@transactions);

    say "";
    say "All outstanding shared transactions have been marked as settled";
    say "";
}

sub print_transaction_simple {
    my $transaction = shift;
    my $desc = $transaction->{'desc'} // COMBINED_CATEGORY_CODES()->{$transaction->{'category'}};
    my $amount = format_currency($transaction->{amount}, 10);
    my $type = $transaction->{type};
    say "$amount on $transaction->{date} for $desc";
}

sub print_transaction_detailed {
    my $transaction = shift;
    say "Date:           $transaction->{date}";
    say "Amount:         " . format_currency($transaction->{amount});
    say "Category:       $transaction->{category}" unless $transaction->{type} eq "IN";
    say "Description:    $transaction->{desc}" if defined $transaction->{desc};
    say "Necessity:      " . format_necessity($transaction->{necessity}) unless $transaction->{type} eq "IN";
}


sub parse_file {
    my $fh = shift;
    my @records;

    while (my $line = <$fh>) {
        chomp $line;
        my %record = decode_transaction($line);
        push @records, \%record;
    }

    return @records;
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
    my $desc = $transaction->{'desc'} // COMBINED_CATEGORY_CODES()->{$transaction->{'category'}};
    my $amount_owed = amount_owed_for_transaction($transaction);
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

sub format_percentage {
    my ($number) = @_;

    my $formatted = sprintf("%.2f%%", $number);

    if ($number < 10) {
        $formatted = "  $formatted";
    } elsif ($number < 100) {
        $formatted = " $formatted";
    }

    return $formatted;
}

sub filter_transactions {
    my @transactions = @_;
    my @filtered_transactions = ();

    foreach (@transactions) {
        my $transaction = $_;
        if ($transaction->{type} ne "OUT") {
            next if grep { $options{command} eq $_ } qw(list details zz);
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

sub decode_transaction {
    my $line = shift;
    chomp $line;
    my @keys = Constants::FILE_KEY_MAPPING();
    my @values = FileUtils::split_line($line);
    my %record;

    @record{@keys} = (undef) x @keys;

    for my $i (0 .. $#keys) {
        if (defined $values[$i] && $values[$i] ne '') {
            $record{$keys[$i]} = $values[$i];
        }
    }

    return %record;
}

sub encode_transaction {
    my $record = shift;
    my @keys = Constants::FILE_KEY_MAPPING();
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
    my $file = Constants::DATA_FILE_PATH();
    my $backup_file = $file . '.bak';
    unlink $backup_file if -e $backup_file;
    rename $file, $backup_file or die "Could not backup file: $!";
}

sub write_file {
    my @transactions = @_;
    open my $fh, '>', Constants::DATA_FILE_PATH() or die "Could not open output file: $!";
    foreach (@transactions) {
        my $transaction = $_;
        print $fh encode_transaction($transaction) . "\n";
    }
    close $fh;
}

sub total_income_for_transactions {
    my @transactions = @_;
    my $total = 0;
    foreach (@transactions) {
        my $transaction = $_;
        if ($transaction->{type} eq "IN") {
            $total += $transaction->{amount};
        }
    }
    return $total;
}

sub is_empty {
    my ($string) = @_;
    return $string =~ /^\s*$/ ? 1 : 0;
}
