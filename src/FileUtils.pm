package FileUtils;

use Exporter;

sub split_line {
    my $line = shift;
    return map { s/^\s+|\s+$//gr } split /;\s*/, $line;
}

our @EXPORT_OK = qw(split_line);

1;

