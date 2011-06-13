package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub template_render : Test(6) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/')
			->status_is(200)
			->content_is('06 default a');
        $t->get_ok('/index.txt')
			->status_is(200)
			->content_is('06 index.txt a');
    }
    
    END {
        $ENV{MOJO_MODE} = $backup;
    }

package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Tusu;

sub startup {
    my $self = shift;

    my $tusu = MojoX::Tusu->new($self);
    $tusu->document_root('t/public_html/06');
    $tusu->extensions_to_render([qw(html htm xml txt)]);
}

__END__
