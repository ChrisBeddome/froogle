package Froogle::CommandDispatcher;

use strict;
use warnings;

use Exporter;

use Froogle::Constants;
use Froogle::Utils::FileUtils;

my %command_package_mapping;

sub run_command {
    my ($command, $options) = @_;
    my $package = $command_package_mapping{$command};
    die "Command not found: $command, run froogle help to see list of available commands." unless $package;
    $package->run($options);
}

sub initialize {
    my @files = get_command_files();
    load_all_command_files(@files);
    %command_package_mapping = build_mapping(@files);
}

sub get_command_files {
    return glob(Froogle::Constants::COMMAND_DIRECTORY() . "/*.pm");
}

sub load_all_command_files {
    my @files = @_;
    foreach my $file (@files) {
        my $package_name = Froogle::Utils::FileUtils::package_name_from_file($file);

        eval {
            require $file;
        };

        if ($@) {
            die "Failed to load $file: $@";
        }
    }
}

sub build_mapping {
    my @files = @_;
    my %mapping = ();
    foreach my $file (@files) {
        my $package_name = Froogle::Utils::FileUtils::package_name_from_file($file);
        my $command_name = $package_name->name();
        die "Command $command_name does not have a run sub" unless $package_name->can("run");
        $mapping{$command_name} = $package_name
    }

    return %mapping;
}

initialize();

our @EXPORT_OK = qw(run_command);

1;
