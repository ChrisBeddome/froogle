package Froogle::Main;

use strict;
use warnings;

use Exporter;

use Froogle::OptionsManager;
use Froogle::CommandDispatcher;

sub run {
    Froogle::OptionsManager::set_options_from_command_line_args(\@ARGV);
    my %options = Froogle::OptionsManager::get_options();
    Froogle::CommandDispatcher::run_command($options{command}, %options);
}

our @EXPORT_OK = qw(run);

1;
