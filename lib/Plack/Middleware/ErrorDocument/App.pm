package Plack::Middleware::ErrorDocument::App;
use strict;
use warnings;
use parent qw(Plack::Middleware);
use Plack::MIME;
use Plack::Util;
use Plack::Util::Accessor qw( apps );

use HTTP::Status qw(is_error);

sub call {
    my $self = shift;
    my $env  = shift;

    my $r = $self->app->($env);

    $self->response_cb($r, sub {
        my $r = shift;
        if (exists $self->{$r->[0]}) {
            my $error_res = $self->{$r->[0]}->($env);
            $r->[1] = $error_res->[1];
            $r->[2] = $error_res->[2];
        }
    });
}

1;

__END__

=head1 NAME

Plack::Middleware::ErrorDocument - Set Error Document based on HTTP status code

=head1 SYNOPSIS

  # in app.psgi
  use Plack::Builder;

  builder {
      enable "Plack::Middleware::ErrorDocument",
          500 => '/uri/errors/500.html', 404 => '/uri/errors/404.html',
          subrequest => 1;
      $app;
  };

=head1 DESCRIPTION

Plack::Middleware::ErrorDocument allows you to customize error screen
by setting paths (file system path or URI path) of error pages per
status code.

=head1 CONFIGURATIONS

=over 4

=item subrequest

A boolean flag to serve error pages using a new GET sub request.
Defaults to false, which means it serves error pages using file
system path.

  builder {
      enable "Plack::Middleware::ErrorDocument",
          502 => '/home/www/htdocs/errors/maint.html';
      enable "Plack::Middleware::ErrorDocument",
          404 => '/static/404.html', 403 => '/static/403.html', subrequest => 1;
      $app;
  };

This configuration serves 502 error pages from file system directly
assuming that's when you probably maintain database etc. but serves
404 and 403 pages using a sub request so your application can do some
logic there like logging or doing suggestions.

When using a subrequest, the subrequest should return a regular '200' response.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

=cut
