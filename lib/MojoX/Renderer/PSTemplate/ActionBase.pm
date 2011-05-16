package MojoX::Renderer::PSTemplate::ActionBase;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    sub _dummy : TplExport {
        
    }
    
    sub preceding_args {
        
        return $MojoX::Renderer::PSTemplate::controller;
    }
	
	sub get {
		
		my ($self, $c) = @_;
		my $template = $c->stash('template') || '';
		$c->render(
			handler => 'pst',
			format	=> ($template =~ s{\.([^.]+)$}{}) ? $1 : 'html',
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

1;

__END__

=head1 NAME

MojoX::Renderer::PSTemplate::ActionBase - Base Action Class for PSTemplate WAF 

=head1 SYNOPSIS
	
	package YourAction;
	use strict;
	use warnings;
	use base qw(MojoX::Renderer::PSTemplate::ActionBase);
	
	sub get {
		my ($self, $controller) = @_;
		$controller->render(
			handler => 'pst',
			format	=> ($template =~ s{\.([^.]+)$}{}) ? $1 : 'html',
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
	
	sub some_func : TplExport {
		my ($self, $controller, @your_args) = @_;
		# ...
		return '';
	}

=head1 DESCRIPTION

C<MojoX::Renderer::PSTemplate::ActionBase> is a Mojo Action Base class for
MojoX::Renderer::PSTemplate. This class inherits all method from
Text::PSTemplate::PluginBase.

=head1 METHODS

=head2 preceding_args

This method overrides the super class method for prepending controller instance
into template function arguments. This is internal use only so you don't have to
worry about it.

=head2 get 
=head2 post
=head2 head
=head2 delete
=head2 put

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
