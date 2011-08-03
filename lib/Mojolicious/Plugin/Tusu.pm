package Mojolicious::Plugin::Tusu;
use strict;
use warnings;
use Try::Tiny;
use Text::PSTemplate;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util;
use Carp;

    our $APP;
    our $CONTROLLER;
    
    __PACKAGE__->attr('engine');
    __PACKAGE__->attr('extensions_to_render');
    __PACKAGE__->attr('directory_index');
    __PACKAGE__->attr('error_document');
    __PACKAGE__->attr('document_root');
    
    # internal use
    __PACKAGE__->attr('_default_route_set');
    
    sub validate_hash {
        my ($hash_ref, @allow) = @_;
        my %keys;
        $keys{$_} = 1 foreach(@allow);
        for my $key (keys %$hash_ref) {
            if (! $keys{$key}) {
                croak "Unknown argument $key";
            }
        }
    }

    sub register {
        my ($self, $app, $args) = @_;
        
        my $default_args = {
            document_root           => $app->home->rel_dir('public_html'),
            encoding                => 'utf8',
            extensions_to_render    => ['html','htm','xml'],
            directory_index         => ['index.html','index.htm'],
            error_document          => {},
            components              => {},
        };
        
        validate_hash($args, keys %$default_args);
        
        $args = {%$default_args, %$args};
        
        my $engine = Text::PSTemplate->new;
        
        {
            local $APP = $app;
            $engine->plug(
                'MojoX::Tusu::ComponentBase'            => undef,
                'MojoX::Tusu::Component::Util'          => '',
                'MojoX::Tusu::Component::Mojolicious'   => 'Mojolicious',
                %{$args->{components}}
            );
        }
        
        $engine->set_encoding($args->{encoding});
        
        $self->engine($engine);
        $self->directory_index($args->{directory_index});
        $self->error_document($args->{error_document});
        $self->extensions_to_render($args->{extensions_to_render});
        $self->document_root($args->{document_root});
        
        $app->plugin(plack_middleware => [
            AutoCompletePath => {
                names => $self->directory_index
            },
            'Tusu' => {
                parser                  => $engine,
                directory_index         => $self->directory_index,
                document_root           => $self->document_root,
                extensions_to_render    => $self->extensions_to_render,
            },
        ]);
        
        return $self;
    }
    
    ### ---
    ### bootstrap for frameworking
    ### ---
    sub bootstrap {
        
        my ($self, $c, $component, $action) = @_;
        local $CONTROLLER = $c;
        return $self->engine->get_plugin($component)->$action($c);
    }

1;

__END__

=head1 NAME

Mojolicious::Plugin::Tusu - Apache-like dispatcher for Mojolicious

=head1 SYNOPSIS

    use Mojolicious::Plugin::Tusu;

For non lite app

    sub startup {
        my $self = shift;
        my $tusu = $self->plugin(tusu => {});
    }

OR

    sub startup {
        my $self = shift;
        my $tusu = $self->plugin(tusu => {
            document_root => $self->home->rel_dir('www2'),
            components => {
                'Your::Component' => 'YC',
            },
            extensions_to_render => [qw(html htm xml txt)],
        });
        
        $r->route('/specific/path')->to(cb => sub {
            $tusu->bootstrap($_[0], 'Your::Component', 'your_method');
        });
    }

For lite app

    my $tusu = plugin tusu => {...};

=head1 DESCRIPTION

C<Mojolicious::Plugin::Tusu> is a sub framework on Mojolicious using
Text::PSTemplate for renderer. With this framework, you can deploy directory
based web sites onto Mojolicious at once.

This framework automatically activate own dispatcher which behaves like apache
web server. You can build your web site into single document root directory
named public_html in hierarchal structure. The document root directory can
contain both server-parsed-documents and static files such as images.

Mojolicious::Plugin::Tusu doesn't require files to be named like index.html.ep
style but just like index.html. You can specify which files to be server
parsable by telling it the extensions. It also provides some more apache-like
features such as directory_index, error_document and file permissions checking.

One of the intent of this module is to enhance existing static websites into
dynamic with minimal effort. The chances are that most typical website data are
transplantable with no change at all.

=head1 OPTIONS

=head2 document_root => string

This option sets root directory for templates and static files. Following
example is default setting.

    my $tusu = $self->plugin(tusu => {
        document_root => $self->home->rel_dir('public_html')
    });

=head2 components => hash

    my $tusu = $self->plugin(tusu => {
        components => {
            'Namespace::A' => 'A',   # namespace is A
            'Namespace::B' => '',    # namespace is ''
            'Namespace::C' => undef, # namespace is Namespace::C
        },
    });

=head2 encoding => string or array ref

This option sets encoding for template files. Array ref causes auto detection
active.

    my $tusu = $self->plugin(tusu => {
        encoding => 'Shift-JIS',
    });
    
    or..
    
    my $tusu = $self->plugin(tusu => {
        encoding => ['Shift-JIS', 'utf8'],
    });

=head2 directory_index => array ref

This option sets default file names for searching files in directory when
the request path doesn't ended with file name. And this setting also affects to
inside template context such as include('path') function. Following example is
the default setting.

    my $tusu = Mojolicious::Plugin::Tusu->new($app);
    $tusu->directory_index(['index.html', 'index.htm']);

=head2 extensions_to_render => array ref

This option sets the extensions to be parsed by tusu renderer. If request
doesn't match any of extensions, dispatcher try to render it as static file.
Following setting is the default.

    my $tusu = Mojolicious::Plugin::Tusu->new($self);
    $tusu->extensions_to_render(['html','htm','xml'])

=head2 error_document => hash ref

This option setup custom error pages like apache's ErrorDocument.

    $instance->error_document({
        404 => '/errors/404.html',
        403 => '/errors/403.html',
        500 => '/errors/405.html',
    })

=head1 METHODS

=head2 Mojolicious::Plugin::Tusu->new($app)

Constructor. 
    
    $tusu = Mojolicious::Plugin::Tusu->new($app)

=head2 $instance->register($app)

This method internally called.

=head2 $instance->engine

This returns Text::PSTemplate instance. You can customize the template system
behavior by calling parser methods directly.
    
    my $tusu = Mojolicious::Plugin::Tusu->new($app);
    my $pst = $tusu->engine;
    $pst->set_delimiter('<!--', '-->');

=head2 $instance->bootstrap($controller, $component, $method)

This method is a sub dispatcher method. You can specify a class and a method the
route to be dispatched to.

    my $tusu = Mojolicious::Plugin::Tusu->new($self);
    $r->route('/some/path')->via('post')->to(cb => sub {
        $tusu->bootstrap($c, 'Your::Component', 'post');
    });

=head1 What does Tusu mean?

Tusu means mojo in Ainu languages which is spoken by the native inhabitants of
Hokkaido prefecture, Japan.

=head1 SEE ALSO

L<Mojolicious>, L<Text::PSTemplate>

L<http://en.wikipedia.org/wiki/Ainu_languages>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
