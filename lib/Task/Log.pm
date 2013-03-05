package Task::Log;

=head1 NAME

Task::Log - Reader, writer and archiver of task logs

=head1 SYNOPSIS

  use Task::Log;
  my $dir = config->{LOG_DIRECTORY};

=cut

use Modern::Perl;
use Exporter qw/import/;
our @EXPORT = qw/note/;

use POSIX qw/strftime/;
use Date::Parse;
use Task::Config;

use constant LOG_LINE => qr/^(\w+ \w+  ?\d+ \d+:\d+:\d+ \d+) (\w+)(?: (.+))?$/;

=head1 METHODS

=head2 file

Get the log file.

  my $file = file;

=cut
sub file {
    return state $file = config->{LOG_DIRECTORY} . config->{LOG_FILE};
}
    
=head2 note

Write to the log.

  note "start", "task name";

=cut
sub note {
    open my $log, ">>", file or die "Failed to open log file " . file . ": $!\n";
    say $log scalar localtime . " " . join(" ", @_);    
}

=head2 lines

Fetch the split log lines.

    my @lines = Task::Log::lines;

=cut
sub lines {
    open my $log, "<", file or return ();
    my @lines = ();
    while (<$log>) {
        my ($time, $command, $label) = $_ =~ LOG_LINE or die "Failed to parse $_ [$.]"; 
        push @lines, { command => $command, label => $label, time => str2time $time };
    }
    return @lines;
}

=head2 archive

Archive the log file. Die if there is not file to archive.

=cut
sub archive {
    my $file = file;
    my $archive = config->{LOG_DIRECTORY} . strftime "%Y-%m-%d_%H:%M:%S", localtime;
    die "No file to archive" unless -e $file;
    `mv $file $archive`;
    `gzip $archive`;
}

=head1 AUTHOR

Erik J. Sturcke

=cut

1;
