package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub template_render : Test(9) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/04/')->status_is(200)->content_is('sub ok');
        $t->get_ok('/04/index2.html')->status_is(200)->content_is('sub2 ok');
        $t->get_ok('/04/index3.html')->status_is(200)->content_is('sub3 ok');
    }

package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Tusu;

sub startup {
    my $self = shift;
    MojoX::Tusu->new($self);
}

__END__
