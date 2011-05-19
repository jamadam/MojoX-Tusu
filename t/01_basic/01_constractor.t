package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Renderer::PSTemplate;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub constractor : Test(5) {
        
        my $app = Test::App->new;
        my $r = MojoX::Renderer::PSTemplate->new($app);
        is(ref $r, 'MojoX::Renderer::PSTemplate');
        is(ref $app->pst, 'Text::PSTemplate::Plugable');
        my $engine = $r->engine;
        is(ref $engine, 'Text::PSTemplate::Plugable');
        is(ref $engine->get_plugin('MojoX::Renderer::PSTemplate::ComponentBase'), 'MojoX::Renderer::PSTemplate::ComponentBase');
        is(ref $engine->get_plugin('MojoX::Renderer::PSTemplate::Mojolicious'), 'MojoX::Renderer::PSTemplate::Mojolicious');
    }

package Test::App;
use Mojolicious::Lite;

__END__
