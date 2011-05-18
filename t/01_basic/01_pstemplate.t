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
        is(ref $engine->get_plugin('MojoX::Renderer::PSTemplate::_Plugin'), 'MojoX::Renderer::PSTemplate::_Plugin');
	}
    
    sub constractor2 : Test(5) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'basictest');
        #$t->get_ok('/')->status_is(200)->content_like(qr/Stuff Here/);
        #$t->get_ok('/')->status_is(200)->content_like(qr/Introduction/);
    }


package Test::App;
use Mojolicious::Lite;

package basictest;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Renderer::PSTemplate;

sub startup {
    my $self = shift;

    $self->types->type(xsl => 'text/html');

    my $pst = MojoX::Renderer::PSTemplate->new($self);
    $self->renderer->add_handler(pst => $pst->build);
    
    my $r = $self->routes;

    $r->route('/(*template)')->to(
        controller 	=> 'Controller',
        action 		=> 'bootstrap',
    );
    $r->route('/')->to(
        controller 	=> 'Controller',
        action 		=> 'bootstrap',
    );
}

__END__
