use strict;
use warnings;
use feature 'say';

my $data_file_path = "./test/data.txt";

open(my $fh, '<', $data_file_path) or die "Error when attempting to open file $data_file_path:\n$!";

while (my $line = <$fh>) {
    chomp $line;
    my $error = validate_line($line);
    if ($error) {
        say "Error in line: $line - $error";
    }
}

seek($fh, 0, 0) or die "Could not seek: $!";

my $spending = 0;
my $income = 0;
my $owe_zz = 0;

while (my $line = <$fh>) {
    my @fields = split /\s*;\s*/, $line;

    if ($fields[1] eq "IN") { 
        $income += $fields[2];
    } else {
        $spending += $fields[2];
    }

    if (scalar @fields == 8 && $fields[7] == 0) {
        $owe_zz += $fields[6];
    }
}

say "Total Spending: ${spending}";
say "Total Income:   ${income}";
say "Chris Owes ZZ:  ${owe_zz}";

close($fh);

sub validate_line {
    my ($line) = @_;
    my @fields = split /\s*;\s*/, $line;
    @fields = map { s/^\s+|\s+$//gr } @fields; #trim whitespace

    unless ($fields[0] =~ /^\d{4}-\d{2}-\d{2}$/) {
        return "Invalid date format";
    }

    unless ($fields[2] =~ /^\d+(\.\d+)?$/ && $fields[2] > 0) {
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

    my %valid_codes = map { $_ => 1 } qw(GRC DNG ENT HOS SRV HOM TRP PET CLT HLT GFT SLF MSC INC SAV ASS);
    unless (exists $valid_codes{$fields[3]}) {
        return "Invalid category code";
    }

    # The fifth field can be any string (no validation needed)

    unless ($fields[5] =~ /^[123]$/) {
        return "Sixth field should be 1, 2, or 3";
    }

    return undef if @fields <= 6;

    if ($fields[6] ne '' && $fields[6] !~ /^-?\d+(\.\d+)?$/) {
        return "Seventh field should be a number or empty";
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
