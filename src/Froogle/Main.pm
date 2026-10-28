package Froogle::Main;

use strict;
use warnings;

use Exporter 'import';

use Froogle::OptionsManager ();
use Froogle::CommandDispatcher ();

# An error while running (bad options, bad data, a failed command) ends the program
# with exit status 1. An uncaught die would exit with whatever errno happened to hold,
# so the status would vary from error to error. Errors while the modules are loading
# happen before this runs and are not caught here
sub run {
    my $succeeded = eval {
        Froogle::OptionsManager::initialize(\@ARGV);
        my %options = Froogle::OptionsManager::get_options();
        my $command = Froogle::OptionsManager::get_command();
        Froogle::CommandDispatcher::run_command($command, \%options);
        1;
    };
    return if $succeeded;

    print STDERR $@;
    exit 1;
}

our @EXPORT_OK = qw(run);

1;
