package Froogle::Main;

use strict;
use warnings;

use Exporter 'import';

use Froogle::OptionsManager ();
use Froogle::CommandDispatcher ();

sub run {
    Froogle::OptionsManager::initialize(\@ARGV);
    my %options = Froogle::OptionsManager::get_options();
    my $command = Froogle::OptionsManager::get_command();
    Froogle::CommandDispatcher::run_command($command, %options);
}

our @EXPORT_OK = qw(run);

1;
