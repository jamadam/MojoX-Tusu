package MojoX::Tusu;
use strict;
use warnings;
use Try::Tiny;
use Text::PSTemplate::Plugable;
use base qw(Mojo::Base);
use Carp;
use Switch;
use Mojolicious::Static;
our $VERSION = '0.12';
$VERSION = eval $VERSION;
    
    __PACKAGE__->attr('engine');
    __PACKAGE__->attr('app');
    
    sub new {
        
        my ($class, $app) = @_;
        my $self = $class->SUPER::new;
        my $engine = Text::PSTemplate::Plugable->new;
        $engine->plug('MojoX::Tusu::ComponentBase');
        $engine->plug('MojoX::Tusu::Plugin::Util', '');
        $engine->plug('MojoX::Tusu::Plugin::Mojolicious', 'Mojolicious');
        $app->attr('pst');
        $app->pst($engine);
        $self->app($app);
        $self->engine($engine);
        
        $self->document_root($app->home->rel_dir('public_html'));
        
        $app->on_process(\&_dispatch);
        
        return $self;
    }
    
    sub document_root {
        
        my ($self, $value) = @_;
        my $app = $self->app;
        if ($value) {
            my $static = Mojolicious::Static->new;
            $static->root($value);
            $app->static($static);
            $app->renderer->root($value);
        }
        return $app->renderer->root($value);
    }
    
    sub _dispatch {
        
        my ($self, $c) = @_;
        
        my $tx = $c->tx;
        if ($tx->is_websocket) {
            $c->res->code(undef);
        }
        $self->sessions->load($c);
        my $plugins = $self->plugins;
        $plugins->run_hook(before_dispatch => $c);
        
        my $path = $tx->req->url->path->to_string;
        if (! $path || $path !~ m{\.} || $path =~ m{((\.(html|htm|xml)))$}) {
            my $res = $tx->res;
            if (my $code = ($tx->req->error)[1]) {
                $res->code($code)
            } elsif ($tx->is_websocket) {
                $res->code(426)
            }
            if ($self->routes->dispatch($c)) {
                if (! $res->code) {
                    $c->render_not_found
                }
            }
        } elsif ($path =~ m{((\.(cgi|php|rb))|/)$}) {
            $tx->res->code(401);
            $c->render_exception('401');
        } else {
            if ($self->static->dispatch($c)) {
                if (! $tx->res->code) {
                    $c->render_not_found
                }
            }
            $plugins->run_hook_reverse(after_static_dispatch => $c);
        }
    }
    
    sub plug {
        
        my ($self, $plugin_name, $as) = @_;
        my $plugin = $self->engine->plug($plugin_name, $as);
        if ($plugin->isa('MojoX::Tusu::ComponentBase')) {
            $plugin->init($self->app);
        }
        return $plugin;
    }
    
    sub build {
        
        my ($self) = @_;
        return sub { $self->_render(@_) };
    }
    
    sub _render {
        
        my ($self, $renderer, $c, $output, $options) = @_;
        
        local $MojoX::Tusu::controller = $c;
        
        my $name = $renderer->template_name($options);
        
        my $engine = Text::PSTemplate::Plugable->new($self->engine);
        my $base_dir = $c->app->renderer->root;
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
            $c->render_exception("$err");
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
        
        local $MojoX::Tusu::controller = $c;
        
        $plugin ||= 'MojoX::Tusu::ComponentBase';
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

1;

__END__

=head1 NAME

MojoX::Tusu - Text::PSTemplate Framework on Mojolicious

=head1 SYNOPSIS

    sub startup {
        ....

        use MojoX::Tusu;
        my $tusu = MojoX::Tusu->new($self);
        
        # initialize Text::PSTemplate::Plugable if necessary
        $tusu->plug('some_plugin');
        $tusu->engine->set_...();
        
        $self->renderer->add_handler(pst => $tusu->build);

        my $cb = sub {
            my ($c) = @_;
            if (my $x = $c->req->query_params->param('x')) {
                $tusu->bootstrap($c, $x);
            } else {
                $tusu->bootstrap($c);
            }
        };
        $r->route('/(*template)')->to(cb => $cb);
        $r->route('/')->to(cb => $cb);
    }

=head1 DESCRIPTION

The C<MojoX::Tusu> is a sub framework on Mojolicious using Text::PSTemplate
for renderer.

=head1 METHODS

=head2 MojoX::Tusu->new($app)

Constractor. This returns MojoX::Tusu instance.
    
    $instance = MojoX::Tusu->new($app)

=head2 $instance->document_root($app, $directory)

Set root directory for templates and static files. This defaults to
'public_html'.

    my $root = $tusu->root;
    $tusu->root('www');

=head2 $instance->engine

Returns Text::PSTemplate::Plugable instance.

=head2 $instance->app

Returns Mojolicious app instance.

=head2 $instance->plug($plug_name, [$namespace])

This is delegate method for Text::PSTemplate::Plugable->plug method to hook
MojoX::Tusu::ComponentBase->init. $namespace default to full name of package.

    my $tusu = MojoX::Tusu->new($self);
    $tusu->plug('Text::PSTemplate::Plugin::HTML', 'HTML');

=head2 $instance->build()

Returns a handler for the Mojo renderer.

    my $renderer = $instance->build()
    $self->renderer->add_handler(pst => $tusu->build);

=head2 $instance->bootstrap($controller, [$component])

This method is a sub dispacher method. Each HTTP request methods will be routed
to corresponding mthods of given component class. $component default to
'MojoX::Tusu::ComponentBase'.

    $r->route('/')->to(cb => sub {
        $tusu->bootstrap($c, 'Your::Component');
    });

Each component classes must have methods such as get(), post() etc.

=head1 SEE ALSO

L<Mojolicious>, L<Text::PSTemplate>, L<MojoX::Renderer>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
