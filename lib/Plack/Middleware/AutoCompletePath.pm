package Plack::Middleware::AutoCompletePath;
use strict;
use warnings;
use parent qw/Plack::Middleware/;
use Plack::Util::Accessor qw( names );
    
    sub call {
        my ($self, $env) = @_;
        my $path = $env->{PATH_INFO} || '/';
        if (substr($path, -1, 1) eq '/') {
            for my $try (@{$self->names}) {
                local $env->{PATH_INFO} = $path. $try;
                my $res = $self->app->($env);
                if ($res->[0] != '404') {
                    return $res;
                }
            }
        }
        return $self->app->($env);
    }

1;

__END__

=head1 NAME

Plack::Middleware::Static::Extended - serve static files like apache

=head1 SYNOPSIS

    use Plack::Builder;
    
    builder {
        enable "Static::Extended",
            path => qr{^/(images|js|css)/},
            root => './htdocs/',
            default => ['index.html', 'index.htm'],
            ;
        $app;
    };
  
=head1 DESCRIPTION

This is a middleware for serving static files with some apache-like features.
This internally uses L<Plack::App::Directory> and implemented like
L<Plack::Middleware::Static>.

=head1 CONFIGURATIONS

=head2 path => regexp or code ref

See L<Plack::App::File>

=head2 root => string

See L<Plack::App::File>

=head2 default => array ref

This option works as apache's DirectoryIndex for overriding index page
if requests path don't ended with file name.

    default => ['index.html', 'index.htm']

=head1 AUTHOR

sugama, E<lt>sugama@jamadam.comE<gt>

=head1 SEE ALSO

L<Plack::App::Directory>,
L<Plack::App::File>,
L<Plack::Middleware::Static>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by sugama.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
