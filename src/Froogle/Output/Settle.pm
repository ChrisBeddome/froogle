package Froogle::Output::Settle;

use strict;
use warnings;

use feature 'say';
use Exporter 'import';

# Asks before settling. Returns 1 for "y", and 0 for "n" or when stdin is closed
sub confirm_settle {
    my $prompt = "Are you sure you want to mark all transactions as settled? (y/n):";
    my $response = '';
    while ($response !~ /^[yn]$/i) {
        say $prompt;
        $response = <STDIN>;
        return 0 unless defined $response;  # stdin closed, treat as "n"
        chomp $response;
    }
    return lc($response) eq 'y' ? 1 : 0;
}

sub print_settled {
    say "";
    say "All outstanding shared transactions have been marked as settled";
    say "";
}

our @EXPORT_OK = qw(confirm_settle print_settled);

1;
