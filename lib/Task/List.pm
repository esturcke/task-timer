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

=head1 METHODS

=head2 reset

Reset the list.

  Task::List::reset;

=cut
sub reset {
    $tasks = {};
    $running = [];
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
}

=head2 stop

Stop the top most timer

  my $task = stop($time);

=cut
sub stop {
    my ($time) = @_;
    my $task = pop @$running or return;
    $task->{time} += $time - $task->{start};
    delete $task->{start};
    return $task;
}

=head2 add

Adds an item to the list

  Task::List::add($time, "start", "label");

=cut
sub add {
    my ($command, $label, $time) = @_;
    $time //= time;
    given ($command) {
        when ("start") {
            stop($time) while @$running;
            start($tasks->{$label} ||= new($label), $time);
        }
        when ("stop") {
            stop($time);
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
