package ComponentBase_render;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub param : Test(6) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/')->status_is(200)->content_is('default');
        $t->get_ok('/07/some_component/')->status_is(200)->content_is('index2');
    }

package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Tusu;
    
    sub startup {
        my $self = shift;
    
        my $tusu = MojoX::Tusu->new($self);
        $tusu->plug('SomeComponent');
        
        my $r = $self->routes;
        $r->route('/07/some_component')->to(cb => sub {
            my ($c) = @_;
            $tusu->bootstrap($c, 'SomeComponent');
        });
    }

package SomeComponent;
use strict;
use warnings;
use base 'MojoX::Tusu::ComponentBase';

    sub get {
        
        my ($self, $c) = @_;
        $c->render(handler => 'tusu', template => '07/some_component/index2.html');
    }
    
__END__
