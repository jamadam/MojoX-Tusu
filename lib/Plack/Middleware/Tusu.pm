package Plack::Middleware::Tusu;
use strict;
use warnings;
use parent qw(Plack::Middleware);
use Plack::Util::Accessor qw(parser directory_index document_root extensions_to_render encoding);
use Text::PSTemplate;
use Plack::App::TextPstemplate;
use Plack::App::File::Extended;
use Try::Tiny;
our $VERSION = '0.01';
    
    sub prepare_app {
        my $self = shift;
        
        if (! $self->document_root) {
            $self->document_root('./public_html');
        }
        
        if (! $self->directory_index) {
            $self->directory_index(qw{index.html index.htm});
        }
        
        if (! $self->extensions_to_render) {
            $self->extensions_to_render(['html','htm','xml']);
        }
        
        $self->{_text_pstemplate} = Plack::App::TextPstemplate->new({
            parser          => $self->parser,
            directory_index => $self->directory_index,
            document_root   => $self->document_root,
            encoding        => $self->encoding,
        })->to_app;
        
        $self->{_static} = Plack::App::File::Extended->new({
            root => $self->document_root,
            path => qr{.},
        })->to_app;
    }

    sub call {
        my ($self, $env) = @_;
        
        my $path = $env->{PATH_INFO};
        local $Mojolicious::Plugin::Tusu::CONTROLLER = $env->{'MOJO.CONTROLLER'};
        for my $ext (@{$self->extensions_to_render}) {
            if ($path !~ m{\.} || $path =~ m{\.$ext$}) {
                return $self->{_text_pstemplate}->($env);
            }
        }
        
        return $self->{_static}->($env);
    }

1;

__END__

=head1 NAME

Plack::Middleware::Text::PSTemplate - 

=head1 SYNOPSIS

    use Plack::Middleware::Text::PSTemplate;
    Plack::Middleware::Text::PSTemplate->new;

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

sugama, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by sugama.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
