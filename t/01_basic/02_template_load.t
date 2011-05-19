package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Renderer::PSTemplate;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub template_render : Test(6) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/')->status_is(200)->content_is('default');
        $t->get_ok('/02')->status_is(200)->content_is('ok');
    }
    
    sub template_render_subdir : Test(6) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/02/')->status_is(200)->content_is('default');
        $t->get_ok('/02/02_02')->status_is(200)->content_is('ok02_02');
    }

package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Renderer::PSTemplate;

sub startup {
    my $self = shift;

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
