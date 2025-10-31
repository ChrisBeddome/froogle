package Froogle::UserErrorHandler;

use Carp ();

use strict;
use warnings;

my %error_messages = (
    COMMAND_NOT_FOUND => "Command not found. Run 'froogle help' to see list of available commands.",
    NO_DATA_FILE => "Could not find data file at given location. Please check that the file exists and is properly setup in the env var FROOGLE_DATA_FILE_PATH",
    INVALID_DATA => "Invalid data found, Run 'froogle help' for syntax options",
    INVALID_OPTION => "Options invalid"
);

sub raise {
    my ($code, $custom_msg) = @_;
    my $message = $error_messages{$code};


    # if both custom and base message exist, we concat the two. 
    # if only one exists, we print that
    # if neither exists, we print a default
    if (defined $custom_msg) {
        $message = defined $message
        ? "$message\n$custom_msg"
        : $custom_msg;
    }

    $message //= "Unknown error occurred (code: $code)";

    if (Froogle::Constants::ENVIRONMENT() eq 'development') {
        Carp::confess($message);
    } else {
        die "$message\n";
    }
}

1;
