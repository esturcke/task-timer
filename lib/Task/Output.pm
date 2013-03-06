package Task::Output;

=head1 NAME

Task::Output - Output to user/scipts

=head1 SYNOPSIS

  use Task::Output
  respond $short_message, $long_message;
  respond_short $short_message;
  respond_long $long_message

=cut

use Modern::Perl;
use Exporter qw/import/;
our @EXPORT = qw/respond respond_short respond_long/;

use Task::Config;

=head1 METHODS

=head2 respond

Send output to standard out.

  respond $short, $long;

=cut
sub respond {
    my ($short, $long) = @_;
    my $message = config->{SHORT} ? $short : $long;
    say $message if defined $message;
}
    
=head2 respond_short

Write a short message.

  respond_short "foo";

=cut
sub respond_short {
    respond shift;
}

=head2 respond_long

White a long message.

    respond_long "Foo bar";

=cut
sub respond_long {
    respond undef, shift;
}

=head1 AUTHOR

Erik J. Sturcke

=cut

1;
