package Froogle::Output::Errors;

use strict;
use warnings;

use feature 'say';
use Exporter 'import';

# Reports the lines of the data file that failed validation
sub print_validation_errors {
    my @errors = @_;
    foreach my $error (@errors) {
        say "Error on line $error->{line}: $error->{message}";
    }
}

our @EXPORT_OK = qw(print_validation_errors);

1;
