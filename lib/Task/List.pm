package Task::List;

=head1 NAME

Task::List - Collector of tasks

=head1 SYNOPSIS

  use Task::List;
  Task::List::reset();
  Task::List::add("start", "foo");
  my $tasks   = Task::List::all();
  my $running = Task::List::running();

=cut

use Modern::Perl;

my $tasks   = {};
my $running = [];
my $last    = undef;

=head1 METHODS

=head2 reset

Reset the list.

  Task::List::reset;

=cut
sub reset {
    $tasks = {};
    $running = [];
    $last = undef;
}

=head2 last

Last task pushed of popped from the task stack

  Task::List::add("stop");
  my $stopped = Task::List::last;

=cut
sub last {
    return $last;
}

=head2 new

Create a new task with default values/

  my $task = new;

=cut
sub new {
    { label => shift, time => 0, subtasks => {} };
}

=head2 start

Start a timer.

  start($task, $time);

=cut
sub start {
    my ($task, $time) = @_;
    $task->{start} = $time;
    push @$running, $task;
    $last = $task;
}

=head2 stop

Stop the top most timer

  my $task = stop($time);

=cut
sub stop {
    my ($time) = @_;
    my $task = pop @$running or return;
    $task->{time} += $time - $task->{start} if $task->{start};
    delete $task->{start};
    return $last = $task;
}

=head2 add

Adds an item to the list

  Task::List::add($time, "start", "label");

=cut
sub add {
    my ($time, $command, $label) = @_;
    $time //= time;
    given ($command) {
        when ("push") {
            my $task = @$running
                     ? $running->[-1]{subtasks}{$label} ||= new($label)
                     : $tasks->{$label}                 ||= new($label);
            start($task, $time);
        }
        when ("pop") {
            if ($label) {
                die "No task with label $label running" unless grep { $_->{label} eq $label } @$running;
                while (@$running && stop($time)->{label} ne $label) {}
            }
            else {
                die "Nothing to pop" unless @$running;
                stop($time);
            }
        }
        when ("pause") {
            for (@$running) {
                $_->{time} += $time - $_->{start} if $_->{start};
                delete $_->{start};
            }
            $last = $running->[-1];
        }
        when ("resume") {
            $_->{start} = $time for @$running;
            $last = $running->[-1];
        }
        when ("start") {
            stop($time) while @$running;
            start($tasks->{$label} ||= new($label), $time);
        }
        when ("stop") {
            stop($time) while @$running;
        }
        when ("reset") {
            $running = [] if @$running && $running->[0]{label} eq $label;
            delete $tasks->{$label};
        }
        default {
            die "Unknown command $command in logs";
        }
    }
}

=head2 all

Gets all the task as a nested set of hash refs.

  my $tasks = Task::List::all;

=cut
sub all {
    return $tasks;
}

=head2 running

Gets stack of running tasks as an array ref.

  my $running = Task::List::running;

=cut
sub running {
    return $running;
}

=head1 AUTHOR

Erik J. Sturcke

=cut

1;
