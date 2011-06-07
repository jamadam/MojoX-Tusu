package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub template_render : Test(12) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/')->status_is(200)->content_is('default');
        #$t->get_ok('/02')->status_is(200)->content_is('default');
        #$t->get_ok('/02/')->status_is(200)->content_is('default');
        #$t->get_ok('/02/02_02.html')->status_is(200)->content_is('ok02_02');
    }
    
    sub not_found : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        #$t->get_ok('/02/not_found.html')->status_is(404)->text_is('title', 'Page Not Found');
    }
    
    sub not_found2 : Test(3) {
        $ENV{MOJO_MODE} = 'development';
        my $t = Test::Mojo->new(app => 'SomeApp');
        #$t->get_ok('/02/not_found.html')->status_is(404)->text_is('title', 'Page Not Found');
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
}

__END__
