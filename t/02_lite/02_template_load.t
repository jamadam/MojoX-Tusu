package Template_Basic;
use strict;
use warnings;
use Test::More;
use MojoX::Renderer::PSTemplate;
use Test::Mojo;
use Mojolicious::Lite;
    
use Test::More tests => 12;

    my $backup;
    BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }
    BEGIN { $backup = $ENV{MOJO_MODE} || ''; $ENV{MOJO_MODE} = 'development' }

    my $pst = MojoX::Renderer::PSTemplate->new(app);
    app->renderer->add_handler(pst => $pst->build);
    
    my $cb = sub {
        my ($c) = @_;
        $pst->bootstrap($c);
    };
    
    any '/(*template)' => $cb;
    any '/' => $cb;
    
    my $t = Test::Mojo->new;
    $t->get_ok('/')->status_is(200)->content_is('default');
    $t->get_ok('/02')->status_is(200)->content_is('ok');
    
    $t->get_ok('/02/')->status_is(200)->content_is('default');
    $t->get_ok('/02/02_02')->status_is(200)->content_is('ok02_02');
