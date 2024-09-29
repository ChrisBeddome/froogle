package Utils;

use Exporter;

sub validate_date {
    my ($date) = @_;
    return $date =~ /^\d{4}-\d{2}-\d{2}$/ ? 1 : 0;
}
our @EXPORT_OK = qw(validate_date);

1;

