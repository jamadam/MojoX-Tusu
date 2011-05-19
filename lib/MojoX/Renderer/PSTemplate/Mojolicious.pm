package MojoX::Renderer::PSTemplate::Mojolicious;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    sub param : TplExport {
        
        my ($self) = @_;
        return $self->controller->param(@_[1.. scalar (@_)]);
    }
    
    sub url_for : TplExport {
        
        my ($self) = @_;
        return $self->controller->url_for(@_[1.. scalar (@_)]);
    }

1;

__END__

=head1 NAME

MojoX::Renderer::PSTemplate::Mojolicious - Plugin port to Mojolicious helpers

=head1 SYNOPSIS
    
    <% Mojolicious::param(@args) %>
    <% Mojolicious::url_for(@args) %>

=head1 DESCRIPTION

=head1 Template Functions

=head2 param($name)

Returns GET parameter value.

=head2 url_for($name)

Generate a portable Mojo::URL object with base for a route, path or URL.

=head1 METHODS

=head1 SEE ALSO

L<Mojolicious::Controller>, L<Text::PSTemplate>, L<MojoX::Renderer>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
