package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub template_render : Test(6) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/')->status_is(200)->content_is('05 default a');
        $t->get_ok('/index.txt')->status_is(200)->content_is('05 index.txt a');
    }

package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Tusu;

sub startup {
    my $self = shift;

    my $tusu = MojoX::Tusu->new($self);
    $tusu->document_root('t/01_basic/05_public_html');
    $tusu->extensions_to_render([qw(html htm xml txt)]);
    $self->renderer->add_handler(pst => $tusu->build);
    
    my $cb = sub {
        my ($c) = @_;
        $tusu->bootstrap($c);
    };
    
    my $r = $self->routes;
    $r->route('/(*template)')->to(cb => $cb);
    $r->route('/')->to(cb => $cb);
}

__END__
