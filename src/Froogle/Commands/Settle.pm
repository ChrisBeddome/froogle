package Froogle::Commands::Settle;

use strict;
use warnings;

use feature 'say';
use Cwd ();
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
    my @file_info = stat($file) or die "Could not read $file: $!";
    my $mode = $file_info[2] & 07777;  # permission bits, kept for the backup and the new file
    my @original_lines = read_lines($file);
    my @settled_lines = map { Froogle::Utils::Data::settle_line($_) } @original_lines;

    write_lines_atomically($file . '.bak', $mode, @original_lines);
    write_lines_atomically($file, $mode, @settled_lines);

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

# Writes to a temporary file beside $file and renames it into place, so $file is
# never left partially written. The rename replaces whatever is at $file (even a
# symlink or a read-only file) rather than writing through it
sub write_lines_atomically {
    my ($file, $mode, @lines) = @_;
    my $temp = File::Temp->new(TEMPLATE => "$file.XXXXXX");  # removed on failure
    print $temp @lines or die "Could not write $temp: $!";
    $temp->flush and $temp->sync or die "Could not write $temp: $!";
    chmod($mode, $temp->filename) or die "Could not set permissions on $temp: $!";
    rename $temp->filename, $file or die "Could not replace $file: $!";
}


our @EXPORT_OK = qw(name run);

1;
