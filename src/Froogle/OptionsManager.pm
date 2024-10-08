package Froogle::OptionsManager;

use Getopt::Long qw(GetOptionsFromArray);
use Exporter;

use Froogle::Utils::DateUtils;
use Froogle::CommandDispatcher;

my %options;

sub get_options {
    return %options;
}

sub set_options_from_command_line_args {
    my $args = shift;
    my %temp_options = parse_options($args);
    %temp_options = set_defaults(%temp_options);
    validate_options(%temp_options);
    %options = %temp_options;
}

sub parse_options {
    my $args = shift;
    my %options;
    $options{command} = get_command($args);
    GetOptionsFromArray($args,
        'from|f=s'   => \$options{from},
        'to|t=s'   => \$options{to},
        'necessity|n=i'   => \$options{necessity},
        'category|c=s'   => \$options{category}
    ) or die "Error in command line arguments";
    return %options;
}

sub set_defaults {
    my %options = @_;
    my $command = $options{command};
    $options{to} = Froogle::Utils::DateUtils::get_today() unless defined $options{to} || grep { $command eq $_ } qw(zz help settle);
    $options{from} = Froogle::Utils::DateUtils::get_start_of_month() unless defined $options{from} || grep { $command eq $_ } qw(zz help settle);

    return %options;
}

sub get_command {
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
    my $command = $options{command};
    my $command_package = Froogle::CommandDispatcher::get_package_from_command($command);
    
    my $validate_method = $command_package->can('validate_options');
    if ($validate_method) {
        $validate_method->(%options);
    }

    # my %applicable_options = (
    #     'help'=> ['command'],
    #     'overview' => ['command', 'from', 'to'],
    #     'list' => ['command', 'from', 'to', 'necessity', 'category'],
    #     'details' => ['command', 'from', 'to', 'necessity', 'category'],
    #     'cats' => ['command', 'from', 'to'],
    #     'zz' => ['command'],
    #     'settle' => ['command']
    # );

    # for my $option (keys %options) {
    #     if (defined $options{$option} && !grep { $_ eq $option } @{$applicable_options{$command}}) {
    #         die "Option '$option' not applicable to '${command}' command";
    #     }
    # }

    if (defined $options{from} && $options{to}) {
        if ($options{from} gt $options{to}) {
            die "From date must be before to date";
        }   
    }

    if (defined $options{from} && !Froogle::Utils::DateUtils::validate_date($options{from})) {
        die "Invalid date format for 'from' option";
    }

    if (defined $options{to} && !Froogle::Utils::DateUtils::validate_date($options{to})) {
        die "Invalid date format for 'to' option";
    }

    if (defined $options{necessity} && ($options{necessity} < 1 || $options{necessity} > 3)) {
        die "Necessity must be 1, 2, or 3";
    }

    if (defined $options{category} && !exists Froogle::Constants::COMBINED_CATEGORY_CODES()->{$options{category}}) {
        die "Invalid category code";
    }
}

our @EXPORT_OK = qw(get_options_from_command_line_args);

1;
