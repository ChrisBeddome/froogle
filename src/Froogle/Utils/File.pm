package Froogle::Utils::File;

use strict;
use warnings;

use Exporter 'import';
use Cwd 'abs_path';
use File::Basename;
use File::Spec;

sub path_from_project_root {
    my $filepath = shift;
    $filepath = "/$filepath" unless substr($filepath, 0, 1) eq '/';
    return abs_path(project_root() . $filepath);
}

sub path_from_application_root {
    my $filepath = shift;
    $filepath = "/$filepath" unless substr($filepath, 0, 1) eq '/';
    return abs_path(application_root() . $filepath);
}

sub project_root {
    # When running under PAR, use the directory where the executable is located
    if ($ENV{PAR_TEMP}) {
        return abs_path(dirname($ENV{PAR_PROGNAME} || $0));
    }
    # The application root is <project root>/src/Froogle
    return dirname(dirname(application_root()));
}

sub application_root {
    # When running under PAR, modules are in $PAR_TEMP/inc/lib
    if ($ENV{PAR_TEMP}) {
        return File::Spec->catdir($ENV{PAR_TEMP}, 'inc', 'lib', 'Froogle');
    }
    # This file is <application root>/Utils/File.pm
    return dirname(dirname(abs_path(__FILE__)));
}

sub package_name_from_file {
    my $filepath = shift;

    # Match the last Froogle directory, in case an ancestor directory has the same name
    if ($filepath =~ m{(.*/Froogle)(?=[/\\])}s) {
        my $modified_path = $';
        $modified_path =~ s/\.pm$//;
        $modified_path =~ s{[/\\]}{::}g;
        return "Froogle" . $modified_path;
    }

    return undef;
}

our @EXPORT_OK = qw(package_name_from_file path_from_project_root path_from_application_root);

1;

