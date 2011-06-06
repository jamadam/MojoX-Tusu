package MojoX::Tusu;
use strict;
use warnings;
use Try::Tiny;
use Text::PSTemplate::Plugable;
use base qw(Mojo::Base);
use Carp;
use Switch;
use Mojolicious::Static;
our $VERSION = '0.16';
$VERSION = eval $VERSION;
    
    __PACKAGE__->attr('engine');
    __PACKAGE__->attr('app');
    __PACKAGE__->attr('extensions_to_render', sub {[qw(html htm xml)]});
    __PACKAGE__->attr('default_route_set');
    
    sub new {
        
        my ($class, $app) = @_;
        my $self = $class->SUPER::new;
        
        $app->on_process(sub {
            my ($app, $c) = @_;
            if (! $self->default_route_set) {
                $self->default_route_set(1);
                my $cb = sub {$self->bootstrap(@_)};
                my $r = $app->routes;
                $r->route('/(*template)')->to(cb => $cb);
                $r->route('/')->to(cb => $cb);
            }
            _dispatch($app, $c, $self->extensions_to_render);
        });
        
        $self->app($app);
        $self->engine(Text::PSTemplate::Plugable->new);
        $self->document_root($app->home->rel_dir('public_html'));
        
        $self->plug(
            'MojoX::Tusu::ComponentBase' => undef,
            'MojoX::Tusu::Plugin::Util' => '',
            'MojoX::Tusu::Plugin::Mojolicious' => 'Mojolicious',
        );
        
        return $self;
    }
    
    sub extensions_to_render {
        
        my ($self, $value) = @_;
        $self->extensions_to_render($value);
    }
    
    sub document_root {
        
        my ($self, $value) = @_;
        my $app = $self->app;
        if ($value) {
            $app->static->root($value);
            $app->renderer->root($value);
        }
        return $app->renderer->root;
    }
    
    sub _dispatch {
        
        my ($app, $c, $extensions_to_render) = @_;
        
        my $tx = $c->tx;
        if ($tx->is_websocket) {
            $c->res->code(undef);
        }
        $app->sessions->load($c);
        my $plugins = $app->plugins;
        $plugins->run_hook(before_dispatch => $c);
        
        my $path = $tx->req->url->path->to_string;
        my $ext = join '|', @{$extensions_to_render};
        if (! $path || $path !~ m{\.} || $path =~ m{(\.($ext))$}) {
            my $res = $tx->res;
            if (my $code = ($tx->req->error)[1]) {
                $res->code($code)
            } elsif ($tx->is_websocket) {
                $res->code(426)
            }
            if ($app->routes->dispatch($c)) {
                if (! $res->code) {
                    $c->render_not_found
                }
            }
        } elsif ($path =~ m{((\.(cgi|php|rb))|/)$}) {## This block never run
            $tx->res->code(401);
            $c->render_exception('401');
        } else {
            if ($app->static->dispatch($c)) {
                if (! $tx->res->code) {
                    $c->render_not_found
                }
            }
            $plugins->run_hook_reverse(after_static_dispatch => $c);
        }
    }
    
    sub plug {
        
        my ($self, @plugins) = @_;
        my $plugin;
        while (scalar @plugins) {
            my $plugin_name = shift @plugins;
            my $as = shift @plugins;
            $plugin = $self->engine->plug($plugin_name, $as);
            if ($plugin->isa('MojoX::Tusu::ComponentBase')) {
                $plugin->init($self->app);
            }
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
        
        my $name = $renderer->template_name($options) || '';
        
        my $engine = Text::PSTemplate::Plugable->new($self->engine);
        my $base_dir = $c->app->renderer->root;
        $engine->set_filename_trans_coderef(sub {
            _filename_trans($base_dir, @_);
        });
        
        local $SIG{__DIE__} = undef;
        
        try {
            $$output = $engine->parse_file('/'. $name);
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
            $name =~ s{(?<=/)$}(index);
            $name =~ s{(?<=/)(?=\.)}(index);
            $name =~ s{(^|/)([^\.]+)$}{$1$2.html};
            my $path;
            if (substr($name, 0, 1) eq '/') {
                $name =~ s{^/}{};
                $path = File::Spec->catfile($template_base, $name);
            } else {
                my $parent_tpl = Text::PSTemplate->get_current_filename;
                my (undef, $dir, undef) = File::Spec->splitpath($parent_tpl);
                $path = File::Spec->catfile($dir, $name);
            }
            if (-e $path) {
                return $path;
            }
            croak "$path not found";
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
        my $plugin_obj = $self->engine->get_plugin($plugin);
        
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

    $tusu->document_root('www');

=head2 $instance->engine

Returns Text::PSTemplate::Plugable instance.

=head2 $instance->app

Returns Mojolicious app instance.

=head2 $instance->plug($plug_name, [$namespace])

This is delegate method for Text::PSTemplate::Plugable->plug method to hook
MojoX::Tusu::ComponentBase->init. $namespace defaults to full name of package.

    my $tusu = MojoX::Tusu->new($self);
    $tusu->plug('Text::PSTemplate::Plugin::HTML', 'HTML');

You also can plug multiple plugins at once.

    $tusu->plug(
        'Namespace::A' => 'A',   # namespace is A
        'Namespace::B' => '',    # namespace is ''
        'Namespace::C' => undef, # namespace is Namespace::C
    );

=head2 $instance->build()

Returns a handler for the Mojo renderer.
    
    sub startup {
        $self->renderer->add_handler(pst => $tusu->build);
    }

=head2 $instance->bootstrap($controller, [$component])

This method is a sub dispacher method. Each HTTP request methods will be routed
to corresponding mthods of given component class. $component defaults to
'MojoX::Tusu::ComponentBase'.

    $r->route('/')->to(cb => sub {
        $tusu->bootstrap($c, 'Your::Component');
    });

=head2 $instance->extensions_to_render($array_ref)

This method sets the extensions to be parsed by tusu renderer. If request
doesn't match any of extensions, dispatcher try to render it as static file.
Following settting is the default.

    $tusu->extensions_to_render(['html','htm','xml'])

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
