package Froogle::OptionsManager;

use strict;
use warnings;

use Getopt::Long qw(GetOptionsFromArray);
use Exporter;

use Froogle::Utils::Date;
use Froogle::CommandDispatcher;
use Froogle::UserErrorHandler;
use Froogle::Validators::OptionsValidator;

my $command;
my $command_package;
my %options;

sub initialize {
    my $args = shift;
    $command = command_from_args($args);
    $command_package = Froogle::CommandDispatcher::get_package_from_command($command);
    Froogle::UserErrorHandler::raise('COMMAND_NOT_FOUND') unless $command_package;
    %options = options_from_args($args);
    %options = combine_with_defaults(%options);
    Froogle::Validators::OptionsValidator::run_validations($command, %options);
}

sub get_options {
    return %options;
}

sub get_command {
    return $command;
}

sub options_from_args {
    my $args = shift;
    my %temp_options = parse_options($args);
    return %temp_options;
}

sub combine_with_defaults {
    my %temp_options = @_;
    my %defaults = $command_package->defaults();
    
    for my $key (keys %defaults) {
        $temp_options{$key} //= $defaults{$key};
    }
    
    return %temp_options;
}

sub parse_options {
    my $args = shift;
    my %options;
    GetOptionsFromArray($args,
        'from|f=s'   => \$options{from},
        'to|t=s'   => \$options{to},
        'necessity|n=i'   => \$options{necessity},
        'category|c=s'   => \$options{category}
    ) or Froogle::UserErrorHandler::raise("INVALID_OPTION");

    for my $key (keys %options) {
        delete $options{$key} unless defined $options{$key};
    }

    return %options;
}

sub command_from_args {
    my $args = shift;
    my $command = Froogle::Constants::DEFAULT_COMMAND;
    my $first_arg = shift @$args;

    # If the first argument is not an option (doesn't start with '-'), treat it as a command
    if (defined $first_arg && $first_arg !~ /^-/) {
        $command = $first_arg;
    } else {
        unshift @$args, $first_arg if defined $first_arg;  # Push back the first arg if not a command
    }
    return $command;
}


our @EXPORT_OK = qw(initialize get_options get_command);

1;
