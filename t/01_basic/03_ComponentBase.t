package ComponentBase;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub param : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/03_ComponentBase01.html?key=value')->status_is(200)->content_is('value');
    }
    
    sub post_param : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->post_form_ok('/03_ComponentBase02.html', {key => 'value2'})->status_is(200)->content_is('value2');
    }
    
    sub url_for : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/03_ComponentBase03.html')->status_is(200)->content_is('/path/to/file path/to/file');
    }

package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Tusu;
    
    sub startup {
        my $self = shift;
    
        my $tusu = MojoX::Tusu->new($self);
        $tusu->document_root('t/public_html');
        $tusu->engine->plug('SomeComponent');
        
        my $cb = sub {
            my ($c) = @_;
            $tusu->bootstrap($c, 'SomeComponent');
        };
        
        my $r = $self->routes;
        $r->route('/(*template)')->to(cb => $cb);
        $r->route('/')->to(cb => $cb);
    }

package SomeComponent;
use strict;
use warnings;
use base 'MojoX::Tusu::ComponentBase';

    sub post {
        shift->get(@_);
    }
    
__END__
