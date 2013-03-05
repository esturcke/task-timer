use File::Temp;
use Test::More;

use FindBin;
use lib "$FindBin::RealBin/../lib";

my $dir = File::Temp::tempdir( CLEANUP => 1 );
$ENV{LOG_DIRECTORY} = $dir;

BEGIN { use_ok("Task::Config") }

is(config->{LOG_DIRECTORY}, $dir, "Directory from environment"); 

$ENV{LOG_DIRECTORY} = "foobar";
is(config->{LOG_DIRECTORY}, $dir, "Only read configs once"); 

done_testing();
