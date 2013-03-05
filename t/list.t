use Modern::Perl;
use File::Temp;
use Test::More;

use FindBin;
use lib "$FindBin::RealBin/../lib";

$ENV{LOG_DIRECTORY} = File::Temp::tempdir( CLEANUP => 1 );

BEGIN { use_ok("Task::List") }
can_ok "Task::List", qw/reset add all running/;

my $task = Task::List::new("foo");
is_deeply($task, { label => "foo", time => 0, subtasks => {} }, "New task");

Task::List::start($task, 10);
running_match("Explicit running task", [ $task ]);

Task::List::reset();
tasks_match("No tasks", {});
running_match("Nothing running", []);

Task::List::add("start", "foobar", 1);
my $task1 = { label => "foobar", subtasks => {}, start => 1, time => 0 };
tasks_match("Single start task", { foobar => $task1 });
running_match("Single running task", [ $task1 ]);

done_testing();

sub tasks_match {
    my ($label, $expected) = @_;
    my $actual = Task::List::all;
    is_deeply($actual, $expected, $label); 
}

sub running_match {
    my ($label, $expected) = @_;
    my $actual = Task::List::running;
    is_deeply($actual, $expected, $label);
}
