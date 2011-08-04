package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub basic : Test(7) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/09/img/a.gif')
			->status_is(200)
			->header_is('Content-Type', 'image/gif')
			->content_like(qr/GIF89a/);
        $t->get_ok('/09/img/not_found.gif')
			->status_is(404)
			->content_like(qr{Not Found}i);
    }
    
    sub directory_indexed : Test(8) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp2');
        $t->get_ok('/09/img/a.gif')
			->status_is(200)
			->header_is('Content-Type', 'image/gif')
			->content_like(qr/GIF89a/);
        $t->get_ok('/09/img/')
			->status_is(200)
			->header_is('Content-Type', 'image/gif')
			->content_like(qr/GIF89a/);
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
    my $tusu = $self->plugin(tusu => {document_root => $self->home->rel_dir('../public_html')});
}

package SomeApp2;
use strict;
use warnings;
use base 'Mojolicious';

sub startup {
    my $self = shift;
    my $tusu = $self->plugin(tusu => {
		document_root => $self->home->rel_dir('../public_html'),
		directory_index => ['a.gif'],
	});
}

__END__
