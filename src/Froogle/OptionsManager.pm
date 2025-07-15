package Froogle::OptionsManager;

use Getopt::Long qw(GetOptionsFromArray);
use Exporter;

use Froogle::Utils::Date;
use Froogle::CommandDispatcher;
use Froogle::UserErrorHandler;

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
    validate_options(%options);
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
    my $command = 'overview'; #default
    my $first_arg = shift @$args;

    # If the first argument is not an option (doesn't start with '-'), treat it as a command
    if (defined $first_arg && $first_arg !~ /^-/) {
        $command = $first_arg;
    } else {
        unshift @$args, $first_arg if defined $first_arg;  # Push back the first arg if not a command
    }
    return $command;
}

sub validate_options {
    my (%options) = @_;

    my @applicable_options = $command_package->applicable_options();

    for my $option ( grep { $_ ne 'command' } keys %options ) {
        if (defined $options{$option} && !grep { $_ eq $option } @applicable_options) {
            Froogle::UserErrorHandler::raise('INVALID_OPTION', "Option '$option' not applicable to '${command}' command");
        }
    }

    my $command_specific_validations = $command_package->can('validate_options');

    if ($command_specific_validations) {
        $command_specific_validations->(%options);
    }

    run_general_validations(%options);
}

sub run_general_validations {
    my %options = @_;

    if (defined $options{from} && !Froogle::Utils::Date::validate_date($options{from})) {
        Froogle::UserErrorHandler::raise('INVALID_OPTION', "Invalid date format for 'from' option: $options{from}");
    }

    if (defined $options{to} && !Froogle::Utils::Date::validate_date($options{to})) {
        Froogle::UserErrorHandler::raise('INVALID_OPTION', "Invalid date format for 'to' option: $options{to}");
    }

    if (defined $options{from} && $options{to}) {
        if ($options{from} gt $options{to}) {
            Froogle::UserErrorHandler::raise('INVALID_OPTION', "From date must be before to date");
        }   
    }

    if (defined $options{necessity} && ($options{necessity} < 1 || $options{necessity} > 3)) {
        Froogle::UserErrorHandler::raise('INVALID_OPTION', "Necessity must be 1, 2, or 3");
    }

    if (defined $options{category} && !exists Froogle::Constants::COMBINED_CATEGORY_CODES()->{$options{category}}) {
        Froogle::UserErrorHandler::raise('INVALID_OPTION', "Invalid category code: $options{category}");
    }
}

our @EXPORT_OK = qw(initialize get_options get_command);

1;
