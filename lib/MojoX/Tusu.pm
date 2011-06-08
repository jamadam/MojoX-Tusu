package MojoX::Tusu;
use strict;
use warnings;
use Try::Tiny;
use Text::PSTemplate::Plugable;
use base qw(Mojo::Base);
use Carp;
use Switch;
use Mojolicious::Static;
our $VERSION = '0.18';
$VERSION = eval $VERSION;
    
    __PACKAGE__->attr('engine');
    __PACKAGE__->attr('extensions_to_render', sub {[qw(html htm xml)]});
    __PACKAGE__->attr('directory_index', sub {[qw(index.html index.htm)]});
    
    # internal use
    __PACKAGE__->attr('_app');
    __PACKAGE__->attr('_default_route_set');
    
    sub new {
        
        my ($class, $app) = @_;
        my $self = $class->SUPER::new;
        
        $app->on_process(sub {
            my ($app, $c) = @_;
            if (! $self->_default_route_set) {
                $self->_default_route_set(1);
                my $cb = sub {$_[0]->render(handler => 'tusu')};
                my $r = $app->routes;
                $r->route('/(*template)')->to(cb => $cb);
                $r->route('/')->to(cb => $cb);
            }
            _dispatch($app, $c, $self->extensions_to_render);
        });
        
        $self->_app($app);
        $self->engine(Text::PSTemplate::Plugable->new);
        $self->document_root($app->home->rel_dir('public_html'));
        
        $self->plug(
            'MojoX::Tusu::ComponentBase' => undef,
            'MojoX::Tusu::Plugin::Util' => '',
            'MojoX::Tusu::Plugin::Mojolicious' => 'Mojolicious',
        );
        
        $app->renderer->add_handler(pst => sub { $self->_render(@_) }); # deprecated
        $app->renderer->add_handler(tusu => sub { $self->_render(@_) });
        
        return $self;
    }
    
    sub document_root {
        
        my ($self, $value) = @_;
        my $app = $self->_app;
        if ($value) {
            $app->static->root($value);
            $app->renderer->root($value);
            $self->engine->set_filename_trans_coderef(sub {
                _filename_trans($value, $self->directory_index, @_);
            });
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
                $plugin->init($self->_app);
            }
        }
        return $plugin;
    }
    
    sub _render {
        
        my ($self, $renderer, $c, $output, $options) = @_;
        
        local $MojoX::Tusu::controller = $c;
        
        my $engine = Text::PSTemplate::Plugable->new($self->engine);
        
        local $SIG{__DIE__} = undef;
        
        try {
            $$output = $engine->parse_file('/'. $options->{template});
        }
        catch {
            my $err = $_ || 'Unknown Error';
            if (! $c->stash('mojo.rendered')) {
                $c->app->log->error(qq(Template error in "$options->{template}": $err));
                $c->render_exception("$err");
                $$output = '';
            }
            return 0;
        };
        return 1;
    }
    
    ### ---
    ### foo/bar.html    -> public_html/foo/bar.html
    ### foo/.html       -> public_html/foo/index.html
    ### foo/            -> public_html/foo/index.html
    ### foo             -> public_html/foo or public_html/foo/index.html
    ### ---
    sub _filename_trans {
        
        my ($template_base, $directory_index, $name) = @_;
        $name ||= '';
        $name =~ s{(?<=/)(\.\w+)+$}{};
        my $path;
        for my $default (@{$directory_index}) {
            my $name = $name;
            $name =~ s{(^|/)$}($1$default);
            if (substr($name, 0, 1) eq '/') {
                $name =~ s{^/}{};
                $path = File::Spec->catfile($template_base, $name);
            } else {
                my $parent_tpl = Text::PSTemplate->get_current_filename;
                my (undef, $dir, undef) = File::Spec->splitpath($parent_tpl);
                $path = File::Spec->catfile($dir, $name);
            }
            if (-f $path) {
                return $path;
            }
        }
        if ($name !~ m{/$}) {
            if (! Text::PSTemplate->get_current_filename && -d $path) {
                $MojoX::Tusu::controller->redirect_to($name. '/');
                $MojoX::Tusu::controller->tx->res->code(301);
                $MojoX::Tusu::controller->rendered;
                croak "$path is a directory";
            }
            return _filename_trans($template_base, $directory_index, $name. '/');
        }
        if (! Text::PSTemplate->get_current_filename) {
            $MojoX::Tusu::controller->render_not_found();
            $MojoX::Tusu::controller->rendered;
        }
        croak "$path not found";
    }
    
    ### --------------
    ### bootstrap for frameworking
    ### --------------
    sub bootstrap {
        
        my ($self, $c, $plugin, $action) = @_;
        
        local $MojoX::Tusu::controller = $c;
        return $self->engine->get_plugin($plugin)->$action($c);
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
        
        # following is optional
        
        $tusu->document_root($self->home->rel_dir('www2'));
        $tusu->extensions_to_render([qw(html htm xml txt)]);
        
        # initialize Text::PSTemplate::Plugable if necessary
        
        my $plugin_instance = $tusu->plug('some_plugin');
        $tusu->engine->set_...();
        $tusu->plug('Your::Component', 'YC');
        
        $r->route('/specific/path')->to(cb => sub {
			$tusu->bootstrap($_[0], 'Your::Component', 'post');
        });
    }

=head1 DESCRIPTION

The C<MojoX::Tusu> is a sub framework on Mojolicious using Text::PSTemplate
for renderer.

=head1 METHODS

=head2 MojoX::Tusu->new($app)

Constractor. This returns MojoX::Tusu instance.
    
    $instance = MojoX::Tusu->new($app)

=head2 $instance->document_root($directory)

Set root directory for templates and static files. Following example is default
setting.

    $tusu->document_root($self->home->rel_dir('public_html'));

=head2 directory_index($candidate1 [, $candidate2])

This method sets default file names for searching files in directory when
path_info is ended with directory name. Following example is the default
setting.

    $tusu->directory_index(['index.html', 'index.htm']);

=head2 $instance->engine

Returns Text::PSTemplate::Plugable instance.

=head2 $instance->plug($plug_name, [$namespace])

This is delegate method for Text::PSTemplate::Plugable->plug to hook
MojoX::Tusu::ComponentBase->init. All arguments are thrown at
Text::PSTemplate::Plugable->plug. See L<Text::PSTemplate::Plugable>.

    my $tusu = MojoX::Tusu->new($self);
    $tusu->plug('Text::PSTemplate::Plugin::HTML', 'HTML');

You also can plug multiple plugins at once.

    $tusu->plug(
        'Namespace::A' => 'A',   # namespace is A
        'Namespace::B' => '',    # namespace is ''
        'Namespace::C' => undef, # namespace is Namespace::C
    );

=head2 $instance->bootstrap($controller, $component, $method)

This method is a sub dispacher method. Each HTTP request methods will be routed
to corresponding mthods of given component class. $component defaults to
'MojoX::Tusu::ComponentBase'.

    $r->route('/some/path')->via('post')->to(cb => sub {
        $tusu->bootstrap($c, 'Your::Component', 'post');
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
