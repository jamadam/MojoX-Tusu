package MojoX::Tusu::ComponentBase;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    sub init {
        ### Must be implemented on sub classes.
    }
    
    sub _dummy : TplExport {
        
    }
    
    sub controller {
        
        return $MojoX::Tusu::controller;
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

MojoX::Tusu::ComponentBase - Base Class for WAF component

=head1 SYNOPSIS
    
    package YourComponent;
    use strict;
    use warnings;
    use base qw(MojoX::Tusu::ComponentBase);
    
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
        my ($self, @your_args) = @_;
        # ...
        return '';
    }
    
    <% YourComponent::some_func(@your_args) %>

=head1 DESCRIPTION

C<MojoX::Tusu::ComponentBase> is a Component Base class for
MojoX::Tusu sub framework on mojolicious. This class inherits
all methods from Text::PSTemplate::PluginBase.

=head1 METHODS

=head2 controller

Returns current Mojolicious::Controller instance.

=head2 $self->init($app)

This is a hook method for initializing component. This will automatically be
called from MojoX::Tusu->plug method.

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
to treats corresponding HTTP methods.

=head1 SEE ALSO

L<Text::PSTemplate>, L<MojoX::Renderer>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
