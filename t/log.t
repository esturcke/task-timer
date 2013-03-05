use File::Temp;
use Test::More;

use FindBin;
use lib "$FindBin::RealBin/../lib";

$ENV{LOG_DIRECTORY} = File::Temp::tempdir( CLEANUP => 1 );

BEGIN { use_ok("Task::Log") }
can_ok "Task::Log", qw/note lines archive/;

my @lines = ();
note "start", "foo bar";
push @lines, { command => "start", label => "foo bar" };
lines_match("1 note match", @lines); 

note "stop";
push @lines, { command => "stop", label => undef };

done_testing();

sub lines_match {
    my ($label, @expected) = @_;
    my @actual = Task::Log::lines;
    delete $_->{time} for @actual;
    is_deeply(\@expected, \@actual, $label); 
}
