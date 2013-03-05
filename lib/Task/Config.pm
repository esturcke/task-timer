package Task::Config;

=head1 NAME

Task::Config

=head1 SYNOPSIS

  use Task::Config;
  my $dir = config->{LOG_DIRECTORY};

=cut

use Modern::Perl;
use Exporter qw/import/;
our @EXPORT = qw/config/;

use constant OPTIONS     => qw/LOG_DIRECTORY LOG_FILE SHORT/;
use constant CONFIG_LINE => qr/^\s*(.*?)\s*=\s*(.*?)\s*$/;

=head1 METHODS

=head2 config

Fetches the config hash, reading the config files the first time only.

  config->{SHORT};

=cut
sub config {
    state $config;
    return $config if $config;

    # defaults
    $config = {
        LOG_DIRECTORY => "$FindBin::RealBin/log/",
        LOG_FILE      => "current",
        SHORT         => 0,
    };

    # update via config files and environment
    update($config, from_file($_)) for ("/etc/task-timer", "$ENV{HOME}/.task-timer");
    update($config, %ENV);
    return $config;
}

=head2 update

Updates the config hash with a set of values.

  update($config, %values);

=cut
sub update {
    my ($config, %values) = @_;
    map { $config->{$_} = $values{$_} if defined $values{$_} } OPTIONS;
}

=head2 from_file

Reads values from a config file ignoring anything invalid.

  update($config, from_file($file));

=cut
sub from_file {
    my ($file) = @_;
    return unless -e $file;
    open my $fh, "<", $file or die "Failed to open configuration file $file: $!";   
    return map { $_ =~ CONFIG_LINE  } <$fh>;
}

=head1 AUTHOR

Erik J. Sturcke

=cut

1;
