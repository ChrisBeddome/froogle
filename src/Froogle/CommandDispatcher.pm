package Froogle::CommandDispatcher;

use strict;
use warnings;

use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::File ();
use Froogle::UserErrorHandler ();


my %command_package_mapping;

sub run_command {
    my ($command, $options) = @_;
    my $package = get_package_from_command($command);
    Froogle::UserErrorHandler::raise('COMMAND_NOT_FOUND') unless $package;
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
        my $package_name = Froogle::Utils::File::package_name_from_file($file);

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
        my $package_name = Froogle::Utils::File::package_name_from_file($file);
        my $command_name = $package_name->name();
        die "Command $command_name does not have a run sub" unless $package_name->can("run");
        $mapping{$command_name} = $package_name
    }

    return %mapping;
}

sub get_package_from_command {
    my $command = shift;
    return $command_package_mapping{$command};
}

initialize();

our @EXPORT_OK = qw(run_command get_package_from_command);

1;
