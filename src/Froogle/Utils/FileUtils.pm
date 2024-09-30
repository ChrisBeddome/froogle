package Froogle::Utils::FileUtils;

use strict;
use warnings;

use Exporter;

sub package_name_from_file {
    my $filepath = shift;

    # Find the position of the first occurrence of 'Froogle'
    if ($filepath =~ m{(.*?/Froogle)}s) {
        # Get the part after 'Froogle'
        my $modified_path = $';

        # Remove the .pm extension if it exists
        $modified_path =~ s/\.pm$//;

        # Replace path separators with '::'
        $modified_path =~ s{[/\\]}{::}g;

        # Return the modified path
        return "Froogle" . $modified_path;
    }

    # If 'Froogle' not found, return undef
    return undef;
}

our @EXPORT_OK = qw(package_name_from_file);

1;

