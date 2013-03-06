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

# test start method
Task::List::start($task, 10);
running_match("Explicit running task", [ $task ]);

# test reset
Task::List::reset();
tasks_match("No tasks", {});
running_match("Nothing running", []);
my %task;

# test adding a start
Task::List::add(1, "start", "foobar");
$task->{foobar} = { label => "foobar", subtasks => {}, start => 1, time => 0 };
tasks_match("Single start task", { foobar => $task->{foobar} });
running_match("Single running task", [ $task->{foobar} ]);

# test stopping
Task::List::add(3, "stop");
$task->{foobar} = { label => "foobar", subtasks => {}, time => 2 };
tasks_match("Single stopped task", { foobar => $task->{foobar} });
running_match("Nothing running again", []);

# adding a task and a subtask
Task::List::add(5, "push", "baz");
Task::List::add(7, "push", "foobar");
Task::List::add(9, "pop");
$task->{baz_foobar} = { label => "foobar", subtasks => {}, time => 2 };
$task->{baz} = { label => "baz", subtasks => { foobar => $task->{baz_foobar} }, time => 0, start => 5 };
tasks_match("Task and stopped subtask", { foobar => $task->{foobar}, baz => $task->{baz} });
running_match("Task running with stopped subtask", [ $task->{baz} ]);

# test a stack of running tasks
Task::List::add(12, "push", "a");
Task::List::add(14, "push", "b");
Task::List::add(16, "push", "c");
$task->{baz_a_b_c} = { label => "c", subtasks => {}, time => 0, start => 16 };
$task->{baz_a_b}   = { label => "b", subtasks => { c => $task->{baz_a_b_c } }, time => 0, start => 14 };
$task->{baz_a}     = { label => "a", subtasks => { b => $task->{baz_a_b} }, time => 0, start => 12 };
$task->{baz}{subtasks}{a} = $task->{baz_a};
tasks_match("Task stack", { foobar => $task->{foobar}, baz => $task->{baz} });
running_match("Task stack running", [ $task->{baz}, $task->{baz_a}, $task->{baz_a_b}, $task->{baz_a_b_c} ]);

# stop everything
Task::List::add(20, "stop");
delete $task->{baz}{start};
delete $task->{baz_a}{start};
delete $task->{baz_a_b}{start};
delete $task->{baz_a_b_c}{start};
$task->{baz}{time} += 15;
$task->{baz_a}{time} += 8;
$task->{baz_a_b}{time} += 6;
$task->{baz_a_b_c}{time} += 4;
tasks_match("After break tasks", { foobar => $task->{foobar}, baz => $task->{baz} });
running_match("After break running", []);

# stop up to a label
Task::List::add(25, "push", "baz");
Task::List::add(26, "push", "a");
Task::List::add(27, "push", "b");
Task::List::add(28, "pop", "a");
$task->{baz}{start} = 25;
$task->{baz_a}{time} += 2;
$task->{baz_a_b}{time} += 1;
tasks_match("After stop with label", { foobar => $task->{foobar}, baz => $task->{baz} });
running_match("Running after stop with label", [ $task->{baz} ]);

# start a stack and switch to another timer
Task::List::add(30, "push", "a");
Task::List::add(31, "push", "b");
Task::List::add(32, "start", "foobar");
delete $task->{baz}{start};
$task->{baz}{time} += 7;
$task->{baz_a}{time} += 2;
$task->{baz_a_b}{time} += 1;
$task->{foobar}{start} = 32;
tasks_match("Start a new task with stack running", { foobar => $task->{foobar}, baz => $task->{baz} });
running_match("Running after starting new task", [ $task->{foobar} ]);

# pause a stack
Task::List::add(33, "start", "baz");
Task::List::add(34, "push", "a");
Task::List::add(35, "push", "b");
Task::List::add(36, "pause");
$task->{foobar}{time} += 1;
delete $task->{foobar}{start};
$task->{baz}{time} += 3;
$task->{baz_a}{time} += 2;
$task->{baz_a_b}{time} += 1;
tasks_match("Paused", { foobar => $task->{foobar}, baz => $task->{baz} });
running_match("Paused but running", [ $task->{baz}, $task->{baz_a}, $task->{baz_a_b} ]);

# resume that stack
Task::List::add(39, "resume");
$task->{baz}{start} = 39;
$task->{baz_a}{start} = 39;
$task->{baz_a_b}{start} = 39;
tasks_match("Resume", { foobar => $task->{foobar}, baz => $task->{baz} });
running_match("Resumed and running", [ $task->{baz}, $task->{baz_a}, $task->{baz_a_b} ]);

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
