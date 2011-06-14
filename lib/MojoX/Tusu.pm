package MojoX::Tusu;
use strict;
use warnings;
use Try::Tiny;
use Text::PSTemplate::Plugable;
use base qw(Mojo::Base);
use Carp;
use Mojolicious::Static;
our $VERSION = '0.19';
$VERSION = eval $VERSION;
    
    __PACKAGE__->attr('engine', sub {Text::PSTemplate::Plugable->new});
    __PACKAGE__->attr('extensions_to_render', sub {['html','htm','xml']});
    __PACKAGE__->attr('directory_index', sub {['index.html','index.htm']});
    __PACKAGE__->attr('error_document', sub {{}});
    
    # internal use
    __PACKAGE__->attr('_app');
    __PACKAGE__->attr('_default_route_set');
    
    ### ---
    ### Constractor
    ### ---
    sub new {
        
        my ($class, $app) = @_;
        my $self = $class->SUPER::new;
        
        $app->on_process(sub {
            my ($app, $c) = @_;
            if (! $self->_default_route_set) {
                $self->_default_route_set(1);
                $app->routes
                    ->route('/:template', template => qr{.*})
                    ->name('')
                    ->to(cb => sub {$_[0]->render(handler => 'tusu')});
            }
            $self->_dispatch($app, $c);
        });
        
        $self->_app($app);
        $self->document_root($app->home->rel_dir('public_html'));
        
        $self->plug(
            'MojoX::Tusu::ComponentBase' => undef,
            'MojoX::Tusu::Plugin::Util' => '',
            'MojoX::Tusu::Plugin::Mojolicious' => 'Mojolicious',
        );
        
        $app->renderer->add_handler(tusu => sub { $self->_render(@_) });
        
        return $self;
    }
    
    ### ---
    ### document_root is combined path for both static and renderer
    ### ---
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
    
    ### ---
    ### Delegate method to Text::PSTemplate::plug with init hook for component
    ### ---
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
    
    ### ---
    ### bootstrap for frameworking
    ### ---
    sub bootstrap {
        
        my ($self, $c, $plugin, $action) = @_;
        
        local $MojoX::Tusu::controller = $c;
        return $self->engine->get_plugin($plugin)->$action($c);
    }
    
    ### ---
    ### Custom dispacher
    ### ---
    sub _dispatch {
        
        my ($self, $app, $c) = @_;
        
        my $tx = $c->tx;
        if ($tx->is_websocket) {
            $c->res->code(undef);
        }
        $app->sessions->load($c);
        my $plugins = $app->plugins;
        $plugins->run_hook(before_dispatch => $c);
        
        my $path = $tx->req->url->path->to_string || '/';
        
        my $not_found;
        
        my $check_result = $self->_check_file_type($path);
        
        if (! $check_result->{type}) {
            $not_found = 1;
        } elsif ($check_result->{type} eq 'directory') {
            $c->redirect_to($path. '/');
            $tx->res->code(301);
            return;
        } elsif (! _permission_ok($check_result->{path})) {
            $self->_render_error_document($c, 403);
            return;
        }
        
        if (! $not_found) {
            
            $path = $check_result->{path};
            
            ### dynamic content
            for my $ext (@{$self->extensions_to_render}) {
                if ($path !~ m{\.} || $path =~ m{\.$ext$}) {
                    my $res = $tx->res;
                    if (my $code = ($tx->req->error)[1]) {
                        $res->code($code)
                    } elsif ($tx->is_websocket) {
                        $res->code(426)
                    }
                    if ($app->routes->dispatch($c) && ! $res->code) {
                        $c->render_not_found;
                    }
                    return;
                }
            }
            
            ## This must not be happen
            if ($path =~ m{((\.(cgi|php|rb))|/)$}) {
                $self->_render_error_document($c, 403);
                return;
            }
        }
        
        ### defaults to static content
        if (! $app->static->serve($c, $path, '')) {
            $c->stash->{'mojo.static'} = 1;
            $c->rendered;
        }
        if (! $tx->res->code) {
            $self->_render_error_document($c, 404);
        }
        $plugins->run_hook_reverse(after_static_dispatch => $c);
    }
    
    ### ---
    ### Render Error document
    ### ---
    sub _render_error_document {
        
        my ($self, $c, $code, $debug_message) = @_;
        
        my $resource = $c->tx->req->url->path->to_string;
        
        $c->app->log->debug(qq/Resource "$resource" not found./);
        
        if ($self->_app->mode eq 'production') {
            if (my $template = $self->error_document->{$code}) {
                $c->render(handler => 'tusu', template => $template);
                $c->res->code($code);
                $c->rendered;
                return;
            }
        }
        if ($code == 404) {
            $c->render_not_found;
        } else {
            $c->render_exception($debug_message || 'Unknown Error');
        }
        $c->res->code($code);
    }
    
    ### ---
    ### fill directory_index candidate
    ### ---
    sub _fill_filename {
        
        my ($path, $directory_index) = @_;
        for my $default (@{$directory_index}) {
            my $path = File::Spec->catfile($path, $default);
            if (-f $path) {
                return $path;
            }
        }
        return;
    }
    
    ### ---
    ### find file and type
    ### ---
    sub _check_file_type {
        
        my ($self, $name) = @_;
        $name ||= '';
        my $leading_slash  = (substr($name, 0, 1) eq '/');
        my $trailing_slash = (substr($name, -1, 1) eq '/');
        $name =~ s{^/}{};
        my $path = File::Spec->catfile($self->_app->renderer->root, $name);
        if (-f $path) {
            return {type => 'file', path => $path};
        }
        if ($trailing_slash) {
            if (my $fixed_path = _fill_filename($path, $self->directory_index)) {
                return {type => 'file', path => $fixed_path};
            }
        } elsif (-d $path) {
            return {type => 'directory'};
        }
        return {};
    }
    
    ### ---
    ### foo/bar.html    -> public_html/foo/bar.html
    ### foo/            -> public_html/foo/index.html
    ### foo             -> public_html/foo
    ### ---
    sub _filename_trans {
        
        my ($template_base, $directory_index, $name) = @_;
        $name ||= '';
        my $leading_slash = substr($name, 0, 1) eq '/';
        my $trailing_slash = substr($name, -1, 1) eq '/';
        $name =~ s{^/}{};
        my $dir;
        if ($leading_slash) {
            $dir = $template_base;
        } else {
            $dir = (File::Spec->splitpath(Text::PSTemplate->get_current_filename))[1];
        }
        my $path = File::Spec->catfile($dir, $name);
        if ($trailing_slash) {
            if (my $fixed_path = _fill_filename($path, $directory_index)) {
                return $fixed_path;
            }
        }
        return $path;
    }
    
    ### ---
    ### Check if others readable
    ### ---
    sub _permission_ok {
        
        my ($name) = @_;
        if ($name && -f $name && ((stat($name))[2] & 4)) {
            $name =~ s{(^|/)[^/]+$}{};
            while (-d $name) {
                if (! ((stat($name))[2] & 1)) {
                    return 0;
                }
                $name =~ s{(^|/)[^/]+$}{};
            }
            return 1;
        }
        return 0;
    }
    
    ### ---
    ### tusu renderer
    ### ---
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
            $c->app->log->error(qq(Template error in "$options->{template}": $err));
            $self->_render_error_document($c, 500, "$err");
            $$output = '';
            return 0;
        };
        return 1;
    }

1;

__END__

=head1 NAME

MojoX::Tusu - Apache-like dispatcher for Mojolicious

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
            $tusu->bootstrap($_[0], 'Your::Component', 'your_method');
        });
    }

=head1 DESCRIPTION

C<MojoX::Tusu> is a sub framework on Mojolicious using Text::PSTemplate
for renderer. With this framework, you can deploy directory based web sites
onto Mojolicious at once.

This framework automatically activate own dispacher which behaves like apache
web server. You can build your web site into single document root directory
named public_html in hierarchal structure. The document root directory can
contain both server-parsed-documents and static files such as images.

MojoX::Tusu doesn't require files to be named like index.html.ep style but just
like index.html. You can specify which files to be server parsable by telling
it extensions. It also provides some more apache-like features such as
directory_index, error_document and file permissions checking.

One of the intent of this module is to enhance existing static websites into
dynamic with minimal effort. The chances are that most typical website data are
transplantable with no change at all.

=head2 Components & Plugins

Mojo::Tusu provides object oriented component & plugin framework. You can
easily add your custom features into your website. The following is a example
for plugin development.

    <span><% questionize('Hello') %></span>

To make it possible, you should write a module like this. 

    package MyUtility;
    use strict;
    use warnings;
    use base 'MojoX::Tusu::PluginBase';
    
    sub questionize : TplExport {
        my ($self, $sentence) = @_;
        my $c = $self->controller; # mojolicious controller in case you need
        return $sentence . '?';
    }

To activate this plugin, you must plug-in this at mojolicious startup method.

    sub startup {
        my $self = shift;
        my $tusu = MojoX::Tusu->new($self);
        $tusu->plug('YourUtility', ''); ## second argument is the namespace
    }

The following is a example for component development.

    <div id="productContainer">
        <% Product::list_by_category('books', 10) %>
    </div>

To make it possible, you should write a module like this.

    package Product;
    use strict;
    use warnings;
    use base 'MojoX::Tusu::ComponentBase';
    
    sub init {
        my ($self, $app) = @_;
        $self->set_ini({...}); ### DB SETTING OR SOMETHING
    }
    
    sub list_by_category : TplExport {
        my ($self, $category, $limit) = @_;
        my $c = $self->controller; # mojolicious controller in case you need
        
        # MAY BE ACCESS TO YOUR MODELS HERE
        
        return $html_snippet;
    }

To activate this component, you must plug-in this at mojolicious startup method.

    sub startup {
        my $self = shift;
        my $tusu = MojoX::Tusu->new($self);
        $tusu->plug('Product');
    }

The only difference between plugins and components is that components can have
an init method to have own data.

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

=head2 $instance->error_document($hash_ref)

This method setup custom error pages like apache's ErrorDocument.

    $instance->error_document({
        404 => '/errors/404.html',
        403 => '/errors/403.html',
        500 => '/errors/405.html',
    })

=head1 SEE ALSO

L<Mojolicious>, L<Text::PSTemplate>, L<MojoX::Renderer>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
