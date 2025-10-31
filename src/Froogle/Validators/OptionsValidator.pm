package Froogle::Validators::OptionsValidator;

use strict;
use warnings;

use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::Date ();
use Froogle::UserErrorHandler ();
use Froogle::CommandDispatcher ();

sub run_validations {
    my ($command, %options) = @_;

    my $command_package = Froogle::CommandDispatcher::get_package_from_command($command);
    my @applicable_options = $command_package->applicable_options();

    for my $option ( grep { $_ ne 'command' } keys %options ) {
        if (defined $options{$option} && !grep { $_ eq $option } @applicable_options) {
            Froogle::UserErrorHandler::raise('INVALID_OPTION', "Option '$option' not applicable to '${command}' command");
        }
    }

    #current unused by any package
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

our @EXPORT_OK = qw(run_validations);

1;
