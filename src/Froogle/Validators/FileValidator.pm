package Froogle::Validators::FileValidator;

use strict;
use warnings;

use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::Date ();
use Froogle::Utils::Data ();
use Froogle::Utils::Formatting ();

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
    return if line_empty($line);

    my @fields = Froogle::Utils::Data::split_line($line);

    my $date_idx = Froogle::Constants::FIELD_INDEX_DATE();
    my $type_idx = Froogle::Constants::FIELD_INDEX_TYPE();
    my $amount_idx = Froogle::Constants::FIELD_INDEX_AMOUNT();

    return "Invalid date format" unless Froogle::Utils::Date::validate_date($fields[$date_idx]);

    unless ($fields[$amount_idx] =~ /^\d+(\.\d+)?$/ && $fields[$amount_idx] >= 0) {
        return "Third field should be a positive number";
    }

    if ($fields[$type_idx] eq Froogle::Constants::TRANSACTION_TYPE_INCOME()) {
        return validate_income(@fields);
    } elsif ($fields[$type_idx] eq Froogle::Constants::TRANSACTION_TYPE_EXPENSE()) {
        return validate_expense(@fields);
    } elsif ($fields[$type_idx] eq Froogle::Constants::TRANSACTION_TYPE_TRANSFER()) {
        return validate_transfer(@fields);
    }

    return "Invalid transaction type";
}

sub validate_income {
    my (@fields) = @_;
    my $category_idx = Froogle::Constants::FIELD_INDEX_CATEGORY();
    return "Invalid number of fields" unless @fields >= 3 && @fields <= 5;
    return "Invalid category code" unless exists Froogle::Constants::IN_CATEGORY_CODES()->{$fields[$category_idx]};
    return undef;
}

sub validate_expense {
    my (@fields) = @_;

    my $category_idx = Froogle::Constants::FIELD_INDEX_CATEGORY();
    my $necessity_idx = Froogle::Constants::FIELD_INDEX_NECESSITY();
    my $owe_zz_idx = Froogle::Constants::FIELD_INDEX_OWE_ZZ();
    my $settled_idx = Froogle::Constants::FIELD_INDEX_SETTLED();

    return "Invalid number of fields" unless @fields >= 6 && @fields <= 8;
    return "Invalid category code" unless exists Froogle::Constants::OUT_CATEGORY_CODES()->{$fields[$category_idx]};

    my $necessity = $fields[$necessity_idx];
    unless ($necessity eq Froogle::Constants::NECESSITY_FRIVOLOUS() ||
            $necessity eq Froogle::Constants::NECESSITY_UNNECESSARY() ||
            $necessity eq Froogle::Constants::NECESSITY_NECESSARY()) {
        return "Sixth field should be 1, 2, or 3";
    }

    return undef if @fields <= 6;

    my $owe_field = $fields[$owe_zz_idx];
    my $half = Froogle::Constants::SPECIAL_VALUE_HALF();
    my $neg_half = Froogle::Constants::SPECIAL_VALUE_NEGATIVE_HALF();

    if ($owe_field ne '' && $owe_field !~ /^-?\d+(\.\d+)?$/ && $owe_field ne $half && $owe_field ne $neg_half) {
        return "Seventh field should be a number, '$half', '$neg_half' or empty";
    }

    return "Eighth field must not be empty if seventh field is present" if @fields < 8;

    if ($owe_field eq '' && $fields[$settled_idx] ne '') {
        return "Eighth field should be empty if seventh is empty";
    }
    elsif ($fields[$settled_idx] ne '' && $fields[$settled_idx] !~ /^[01]$/) {
        return "Eighth field should be 0 or 1";
    }

    return undef;
}

sub validate_transfer {
    my (@fields) = @_;

    my $category_idx = Froogle::Constants::FIELD_INDEX_CATEGORY();
    return "Invalid number of fields" unless @fields >= 3 && @fields <= 5;
    return "Invalid category code" unless exists Froogle::Constants::TRF_CATEGORY_CODES()->{$fields[$category_idx]};
    return undef;
}

sub line_empty {
    my $line = shift;
    return Froogle::Utils::Formatting::trim($line) eq '';
}

our @EXPORT_OK = qw(validate_file);

1;
