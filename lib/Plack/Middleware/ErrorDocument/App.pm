package Plack::Middleware::ErrorDocument::App;
use strict;
use warnings;
use parent qw(Plack::Middleware);
use Plack::MIME;
use Plack::Util;

sub call {
    my $self = shift;
    my $env  = shift;

    my $r = $self->app->($env);

    $self->response_cb($r, sub {
        my $r = shift;
        if (is_error($r->[0]) && exists $self->{$r->[0]}) {
            my $error_res = $self->{$r->[0]}->($env);
            $r->[1] = $error_res->[1];
            $r->[2] = $error_res->[2];
        }
    });
}

1;

__END__

=head1 NAME

Plack::Middleware::ErrorDocument::App - Set Error Document by plack app

=head1 SYNOPSIS
    
    # in app.psgi
    use Plack::Builder;
    
    builder {
        enable "ErrorDocument::App",
        404 => sub {
            my $env = shift;
            local $env->{PATH_INFO} = '/error_document/404.html',
            $app->($env);
        },
        500 => sub {
            ...
        },
        $app;
    };

=head1 DESCRIPTION

Plack::Middleware::ErrorDocument allows you to customize error screen
by setting plack app per status code.

=head1 AUTHOR

sugama, E<lt>sugama@jamadam.comE<gt>

=head1 SEE ALSO

L<Plack::Middleware::ErrorDocument>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by sugama.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
