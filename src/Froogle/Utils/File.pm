package Froogle::Utils::File;

use strict;
use warnings;

use Exporter 'import';
use Cwd 'abs_path';
use File::Basename; 

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
    return find_dir_from_root("froogle");
}

sub application_root {
    return find_dir_from_root("Froogle");
}

sub find_dir_from_root {
    my $dirname = shift;
    my $filepath = abs_path(__FILE__);

    my $pos = index($filepath, $dirname);
    if ($pos != -1) {
        return substr($filepath, 0, $pos + length($dirname));
    } else {
        die "Directory not found: $dirname"
    }
}

sub package_name_from_file {
    my $filepath = shift;

    if ($filepath =~ m{(.*?/Froogle)}s) {
        my $modified_path = $';
        $modified_path =~ s/\.pm$//;
        $modified_path =~ s{[/\\]}{::}g;
        return "Froogle" . $modified_path;
    }

    return undef;
}

our @EXPORT_OK = qw(package_name_from_file path_from_project_root path_from_application_root);

1;

