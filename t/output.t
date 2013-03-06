use Modern::Perl;
use File::Temp;
use Test::More;
use Test::Output;

use FindBin;
use lib "$FindBin::RealBin/../lib";
use Task::Config;

$ENV{LOG_DIRECTORY} = File::Temp::tempdir( CLEANUP => 1 );

BEGIN { use_ok("Task::Output") }
can_ok "Task::Output", qw/respond respond_short respond_long/;

stdout_is { respond "Foo"        } "",      "No short";
stdout_is { respond "Foo", undef } "",      "No short 2";
stdout_is { respond "Foo", "Bar" } "Bar\n", "But long";
stdout_is { respond undef, "Bar" } "Bar\n", "But long 3";
stdout_is { respond_short "Foo"  } "",       "No short 3";
stdout_is { respond_long  "Foo"  } "Foo\n",  "Bug long 3";

$ENV{SHORT} = 1;
Task::Config::reset();
stdout_is { respond "Foo"        } "Foo\n", "Now short";
stdout_is { respond "Foo", undef } "Foo\n", "Now short 2";
stdout_is { respond "Foo", "Bar" } "Foo\n", "Now short 3";
stdout_is { respond undef, "Bar" } "",      "No long 3";
stdout_is { respond_short "Foo"  } "Foo\n", "Now short 4";
stdout_is { respond_long  "Foo"  } "",      "No long 3";

done_testing();
