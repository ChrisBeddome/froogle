package Froogle::Validators::FileValidator;

use strict;
use warnings;

use Exporter;

use Froogle::Constants;
use Froogle::Utils::DateUtils;
use Froogle::Utils::DataUtils;

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

sub validate_line {
    my ($line) = @_;
    my @fields = Froogle::Utils::DataUtils::split_line($line);

    return "Invalid date format" unless Froogle::Utils::DateUtils::validate_date($fields[0]);

    unless ($fields[2] =~ /^\d+(\.\d+)?$/ && $fields[2] >= 0) {
        return "Third field should be a positive number";
    }

    if ($fields[1] eq "IN") { 
        return validate_income(@fields);
    } elsif ($fields[1] eq "OUT") {
        return validate_expense(@fields);
    } elsif ($fields[1] eq "ASS") {
        return validate_asset(@fields);
    }

    return "Invalid transaction type";
}

sub validate_income {
    my (@fields) = @_;
    return "Invalid number of fields" unless @fields >= 3 && @fields <= 5;
    return "Invalid category code" unless exists Froogle::Constants::IN_CATEGORY_CODES()->{$fields[3]};
    return undef;
}

sub validate_expense {
    my (@fields) = @_;

    return "Invalid number of fields" unless @fields >= 6 && @fields <= 8;
    return "Invalid category code" unless exists Froogle::Constants::OUT_CATEGORY_CODES()->{$fields[3]};

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

sub validate_asset {
    my (@fields) = @_;

    return "Invalid number of fields" unless @fields >= 3 && @fields <= 5;
    return "Invalid category code" unless exists Froogle::Constants::ASS_CATEGORY_CODES()->{$fields[3]};
    return undef;
}

our @EXPORT_OK = qw(validate_file);

1;