package MojoX::Renderer::PSTemplate;
use strict;
use warnings;
use Try::Tiny;
use Text::PSTemplate::Plugable;
use base qw(Mojo::Base);
use Carp;
use Switch;
our $VERSION = '0.06';
$VERSION = eval $VERSION;
    
    __PACKAGE__->attr('engine');
    
    sub new {
        
        my ($class, $app) = @_;
        my $self = $class->SUPER::new;
        my $engine = Text::PSTemplate::Plugable->new;
        $engine->plug('MojoX::Renderer::PSTemplate::_Plugin', 'Mojo');
		$app->attr('pst');
		$app->pst($engine);
        return $self->engine($engine);
    }
    
    sub build {
        
        my ($self) = @_;
        return sub { $self->_render(@_) };
    }
    
    sub _render {
        
        my ($self, $renderer, $c, $output, $options) = @_;
        
        local $MojoX::Renderer::PSTemplate::controller = $c;
        
        my $name = $renderer->template_name($options);
        
        my $engine = Text::PSTemplate::Plugable->new($self->engine);
        my $base_dir = $c->app->home->rel_file('templates');
		$engine->set_filename_trans_coderef(sub {
			_filename_trans($base_dir, @_);
		});
        
        local $SIG{__DIE__} = undef;
        
        try {
            $$output = $engine->parse_file($name);
        }
        catch {
            my $err = $_ || 'Unknown Error';
            $name ||= '';
            $c->app->log->error(qq(Template error in "$name": $err));
            $c->render_exception($err);
            $$output = '';
            return 0;
        };
        return 1;
    }
    
	### ---
	### foo/bar.html.pst -> template/foo/bar.html
	### foo/.html.pst -> template/foo/index.html
	### ---
	sub _filename_trans {
		
		my ($template_base, $name) = @_;
		if (defined $name) {
			$name =~ s{\.pst$}{};
			my $ext = ($name =~ s{/\.(\w+)$}{/}) ? $1 : 'html';
			$name =~ s{/$}(/index);
			my $full_name = ($name =~ m{[a-zA-Z0-9_]\..+$}) ? $name : "$name.$ext";
			my $file_path;
			my $parent_tpl = Text::PSTemplate->get_current_filename;
			if (! $parent_tpl || substr($full_name, 0, 1) eq '/') {
				$full_name =~ s{^/}{};
				$file_path = File::Spec->catfile($template_base, $full_name);
			} else {
				my (undef, $dir, undef) = File::Spec->splitpath($parent_tpl);
				$file_path = File::Spec->catfile($dir, $full_name);
			}
			if (-e $file_path) {
				return $file_path;
			}
			croak "$file_path not found";
		}
		return File::Spec->catfile($template_base, 'index.html');
	}
    
	### --------------
	### bootstrap for frameworking
	### --------------
	sub bootstrap {
	
		my ($self, $c, $plugin) = @_;
		
		$plugin ||= 'MojoX::Renderer::PSTemplate::ActionBase';
		my $plugin_obj = $c->app->pst->get_plugin($plugin);
		
        switch ($c->req->method) {
            case 'GET'  {
                return $plugin_obj->get($c);
            }
            case 'HEAD'  {
                return $plugin_obj->head($c);
            }
            case 'POST' {
                return $plugin_obj->post($c);
            }
            case 'DELETE'  {
                return $plugin_obj->delete($c);
            }
            case 'PUT'  {
                return $plugin_obj->put($c);
            }
			case 'OPTIONS' {
                return $plugin_obj->options($c);
			}
			case 'TRACE' {
                return $plugin_obj->trace($c);
			}
			case 'PATCH' {
                return $plugin_obj->patch($c);
			}
			case 'LINK' {
                return $plugin_obj->link($c);
			}
			case 'UNLINK' {
                return $plugin_obj->unlink($c);
			}
        }
		return $plugin_obj->get($c);
	}

package MojoX::Renderer::PSTemplate::_Plugin;
use strict;
use warnings;
use base qw(MojoX::Renderer::PSTemplate::ActionBase);
use File::Basename 'basename';
use File::Spec;
    
    sub param : TplExport {
        
        my ($self, $c) = @_;
        return $c->param(@_[2.. scalar (@_)]);
    }
    
    sub url_for : TplExport {
        
        my ($self, $c) = @_;
        my $path = $c->url_for(@_[2.. scalar (@_)]);
		if ($ENV{SCRIPT_NAME}) {
			if (my $rubbish = basename($ENV{SCRIPT_NAME})) {
				$path =~ s{$rubbish/}{};
			}
		}
		return $path;
    }

1;

__END__

=head1 NAME

MojoX::Renderer::PSTemplate - Text::PSTemplate renderer for Mojo

=head1 SYNOPSIS

    sub startup {
        ....

        use MojoX::Renderer::PSTemplate;
        my $pst = MojoX::Renderer::PSTemplate->new($self);
        
        # initialize Text::PSTemplate::Plugable if necessary
        $pst->engine->plug('some_plugin');
        $pst->engine->set_...();
        
        $self->renderer->add_handler(pst => $pst->build);
    }

=head1 DESCRIPTION

The C<MojoX::Renderer::PSTemplate> is a Text::PSTemplate renderer
for mojo. Also it allows you to work on meta frameworking which suitable for
PSTemplate. A helper plugin for PSTemplate will automatically be pluged.

=head1 METHODS

=head2 MojoX::Renderer::PSTemplate->new($app)

Constractor. This returns MojoX::Renderer::PSTemplate instance.
    
    $instance = MojoX::Renderer::PSTemplate->new($app)

=head2 $instance->engine

This method returns Text::PSTemplate::Plugable instance.

=head2 $instance->build()

This method returns a handler for the Mojo renderer.

    my $renderer = $instance->build()
    $self->renderer->add_handler(pst => $pst->build);

=head2 $instance->bootstrap($controller, [$plugin])

Not written yet.

    $r->route('/')->to(cb => sub {
        $pst->bootstrap($c, $plugin);
    });
    
=head1 HELPERS

Following template functions(helper) will automatically be available.

=head2 param

    <% Mojo::param('key') %>

=head2 url_for

    <% Mojo::url_for('/path/to/file') %>

=head1 SEE ALSO

L<Text::PSTemplate>, L<MojoX::Renderer>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
