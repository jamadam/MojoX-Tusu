package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub template_render : Test(4) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/09/img/a.gif')->status_is(200)->header_is('Content-Type', 'image/gif')->content_like(qr/GIF89a/);
    }

	$ENV{MOJO_MODE} = $backup;

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
