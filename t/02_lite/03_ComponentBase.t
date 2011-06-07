package Template_Basic;
use strict;
use warnings;
use Test::More;
use MojoX::Tusu;
use Test::Mojo;
use Mojolicious::Lite;
    
use Test::More tests => 9;

    my $backup;
    BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }
    BEGIN { $backup = $ENV{MOJO_MODE} || ''; $ENV{MOJO_MODE} = 'development' }

    my $tusu = MojoX::Tusu->new(app);
    $tusu->engine->plug('SomeComponent');
    app->renderer->add_handler(pst => $tusu->build);
    
    my $cb = sub {
        my ($c) = @_;
        $tusu->bootstrap($c, 'SomeComponent');
    };
    
    any '/(*template)' => $cb;
    any '/' => $cb;
    
    my $t = Test::Mojo->new;
    $t->get_ok('/03_ComponentBase01.html?key=value')->status_is(200)->content_is('value');
    $t->post_form_ok('/03_ComponentBase02.html', {key => 'value2'})->status_is(200)->content_is('value2');
    $t->get_ok('/03_ComponentBase03.html')->status_is(200)->content_is('/path/to/file path/to/file');

package SomeComponent;
use strict;
use warnings;
use base 'MojoX::Tusu::ComponentBase';

    sub post {
        shift->get(@_);
    }
