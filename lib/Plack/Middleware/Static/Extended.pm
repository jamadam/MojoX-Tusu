package Plack::Middleware::Static::Extended;
use strict;
use warnings;
use parent qw/Plack::Middleware::Static/;
use Plack::App::File::Extended;
    
    sub _handle_static {
        my($self, $env) = @_;
    
        my $path_match = $self->path or return;
        my $path = $env->{PATH_INFO} || '';
        
        for ($path) {
            my $matched = ref $path_match eq 'CODE'
                                                    ? $path_match->($_)
                                                    : $_ =~ $path_match;
            return unless $matched;
        }
        
        $self->{file} ||= Plack::App::File::Extended->new({
            root                => $self->root || '.',
            encoding            => $self->encoding,
            path                => $path || '/',
        });
        
        local $env->{PATH_INFO} = $path;
        return $self->{file}->call($env);
    }

1;

__END__

=head1 NAME

Plack::Middleware::Static::Extended - Serve static file if Permission ok

=head1 SYNOPSIS

    use Plack::Builder;
    
    builder {
        enable "Static::Extended",
            path => qr{^/(images|js|css)/},
            root => './htdocs/',
            ;
        $app;
    };
  
=head1 DESCRIPTION

Permission check

=head1 CONFIGURATIONS

=head2 path => regexp or code ref

See L<Plack::App::File>

=head2 root => string

See L<Plack::App::File>

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
