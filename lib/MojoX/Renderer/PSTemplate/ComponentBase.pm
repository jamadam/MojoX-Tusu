package MojoX::Renderer::PSTemplate::ComponentBase;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
use File::Basename 'basename';
use File::Spec;
    
    sub _dummy : TplExport {
        
    }
    
    sub param : TplExport {
        
        my ($self, $name, $escape) = @_;
		my $c = $self->controller;
        my $val = $c->param($name);
        if ($val && $escape) {
            $val = Text::PSTemplate::Plugin::HTML->escape($val);
        }
        return $val;
    }
    
    sub post_param : TplExport {
        
        my ($self, $name, $escape) = @_;
		my $c = $self->controller;
        my $val = $c->req->body_params->param($name);
        if ($val && $escape) {
            $val = Text::PSTemplate::Plugin::HTML->escape($val);
        }
        return $val;
    }
    
    sub url_for : TplExport {
        
        my ($self) = @_;
		my $c = $self->controller;
        my $path = $c->url_for(@_[1.. scalar (@_)]);
        if ($ENV{SCRIPT_NAME}) {
            if (my $rubbish = basename($ENV{SCRIPT_NAME})) {
                $path =~ s{$rubbish/}{};
            }
        }
        return $path;
    }
    
    sub controller {
        
        return $MojoX::Renderer::PSTemplate::controller;
    }
    
    sub get {
        
        my ($self, $c) = @_;
        my $template = $c->stash('template') || '';
        $c->render(
            handler => 'pst',
            format  => ($template =~ s{\.([^.]+)$}{}) ? $1 : 'html',
            template => $template,
        );
    }
    
    sub post {
        die 'Must be implemented by sub class';
    }
    
    sub head {
        die 'Must be implemented by sub class';
    }
    
    sub put {
        die 'Must be implemented by sub class';
    }
    
    sub delete {
        die 'Must be implemented by sub class';
    }
    
    sub options {
        die 'Must be implemented by sub class';
    }
    
    sub trace {
        die 'Must be implemented by sub class';
    }
    
    sub patch {
        die 'Must be implemented by sub class';
    }
    
    sub link {
        die 'Must be implemented by sub class';
    }
    
    sub unlink {
        die 'Must be implemented by sub class';
    }

1;

__END__

=head1 NAME

MojoX::Renderer::PSTemplate::ComponentBase - Base Class for WAF component

=head1 SYNOPSIS
    
    package YourComponent;
    use strict;
    use warnings;
    use base qw(MojoX::Renderer::PSTemplate::ComponentBase);
    
    sub get {
        my ($self, $controller) = @_;
        $controller->render(
            handler => 'pst',
            format  => ($template =~ s{\.([^.]+)$}{}) ? $1 : 'html',
            template => $template,
        );
    }
    sub post {
        my ($self, $controller) = @_;
        # ...
    }
    sub put {
        my ($self, $controller) = @_;
        # ...
    }
    # ...
    sub some_func : TplExport {
        my ($self, $controller, @your_args) = @_;
        # ...
        return '';
    }
    
    <% some_func(@your_args) %>

=head1 DESCRIPTION

C<MojoX::Renderer::PSTemplate::ActionBase> is a Component Base class for
MojoX::Renderer::PSTemplate meta framework on mojolicious. This class inherits
all method from Text::PSTemplate::PluginBase.

=head1 Template Functions

=head2 url_for($path)

Generate a portable Mojo::URL object with base for a route, path or URL. This
also strips script name on CGI environment.

=head2 param($name, [$escape])

Returns GET parameter value.

=head2 post_param($name, [$escape])

Returns POST parameter value.

=head1 METHODS

=head2 controller

Returns current Mojolicious::Controller instance.

=head2 get 
=head2 post
=head2 head
=head2 delete
=head2 put
=head2 options
=head2 patch
=head2 trace
=head2 link
=head2 unlink

These methods must be overridden by sub classes to act as a MVC Controller
for to treats corresponding HTTP methods.

=head1 SEE ALSO

L<Text::PSTemplate>, L<MojoX::Renderer>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
