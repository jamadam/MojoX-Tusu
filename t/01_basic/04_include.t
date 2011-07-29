package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub template_render : Test(12) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/04/')
			->status_is(200)
			->content_is('sub ok');
        $t->get_ok('/04/index2.html')
			->status_is(200)
			->content_is('sub2 ok');
        $t->get_ok('/04/index3.html')
			->status_is(200)
			->content_is('sub3 ok');
        $t->get_ok('/04/index4.html')
			->status_is(200)
			->content_is('sub4 ok');
    }
    
    END {
        $ENV{MOJO_MODE} = $backup;
    }

package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';

sub startup {
    my $self = shift;
    my $tusu = $self->plugin(tusu => {
		document_root => 't/public_html'
	});
}

__END__
