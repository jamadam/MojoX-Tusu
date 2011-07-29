package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub template_render : Test(6) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
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

sub startup {
    my $self = shift;

    my $tusu = $self->plugin(tusu => {
		document_root => 't/public_html/06',
        extensions_to_render => [qw(html htm xml txt)],
	});
}

__END__
