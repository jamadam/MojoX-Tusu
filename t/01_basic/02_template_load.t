package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';
    
    __PACKAGE__->runtests;
    
    sub template_render : Test(9) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/')
			->status_is(200)
			->content_is('default');
        $t->get_ok('/02/')
			->status_is(200)
			->content_is('default');
        $t->get_ok('/02/02_02.html')
			->status_is(200)
			->content_is('ok02_02');
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
	$self->plugin(tusu => {document_root => 't/public_html'});
}

__END__
