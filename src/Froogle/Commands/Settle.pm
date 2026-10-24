package Froogle::Commands::Settle;

use strict;
use warnings;

use feature 'say';
use Cwd ();
use File::Copy ();
use File::Temp ();
use IO::Handle ();
use Exporter 'import';

use Froogle::Constants ();
use Froogle::Utils::Data ();

sub name {
    return "settle";
}

sub applicable_options {
    return qw();
}

sub defaults {
    return ();
}

sub run {
    my $user_confirmation = get_confirmation("Are you sure you want to mark all transactions as settled? (y/n):");
    return unless $user_confirmation;

    # Validate the whole file first so nothing is written if it is invalid
    Froogle::Utils::Data::get_transactions();

    # Resolve symlinks so the file they point to is updated rather than replaced
    my $file = Cwd::abs_path(Froogle::Constants::DATA_FILE_PATH());
    my @lines = map { Froogle::Utils::Data::settle_line($_) } read_lines($file);

    backup_file($file);
    write_lines_atomically($file, @lines);

    say "";
    say "All outstanding shared transactions have been marked as settled";
    say "";
}

sub get_confirmation {
    my $prompt = shift // "Are you sure? (y/n): ";
    my $response = '';
    while ($response !~ /^[yn]$/i) {
        say $prompt;
        $response = <STDIN>;
        return 0 unless defined $response;  # stdin closed, treat as "n"
        chomp $response;
    }
    return lc($response) eq 'y' ? 1 : 0;
}

sub read_lines {
    my $file = shift;
    open my $fh, '<', $file or die "Could not open $file: $!";
    my @lines = <$fh>;
    close $fh;
    return @lines;
}

sub backup_file {
    my $file = shift;
    File::Copy::copy($file, $file . '.bak') or die "Could not backup file: $!";
}

# Writes to a temporary file beside $file and renames it into place,
# so $file is never left partially written
sub write_lines_atomically {
    my ($file, @lines) = @_;
    my $temp = File::Temp->new(TEMPLATE => "$file.XXXXXX");  # removed on failure
    print $temp @lines or die "Could not write $temp: $!";
    $temp->flush and $temp->sync or die "Could not write $temp: $!";
    chmod((stat $file)[2] & 07777, $temp->filename) or die "Could not set permissions on $temp: $!";
    rename $temp->filename, $file or die "Could not replace $file: $!";
}


our @EXPORT_OK = qw(name run);

1;
