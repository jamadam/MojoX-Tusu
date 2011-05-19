package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Renderer::PSTemplate;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub template_render : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/01')->status_is(200)->content_is('ok');
    }
    
    sub template_render_subdir : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/01/01_01')->status_is(200)->content_is('ok01_01');
    }

package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Renderer::PSTemplate;

sub startup {
    my $self = shift;
    $self->types->type(xsl => 'text/html');

    my $pst = MojoX::Renderer::PSTemplate->new($self);
    $self->renderer->add_handler(pst => $pst->build);
    
    my $cb = sub {
        my ($c) = @_;
        $pst->bootstrap($c);
    };
    
    my $r = $self->routes;
    $r->route('/(*template)')->to(cb => $cb);
    $r->route('/')->to(cb => $cb);
}

__END__
