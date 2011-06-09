package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub basic : Test(7) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/09/img/a.gif')->status_is(200)->header_is('Content-Type', 'image/gif')->content_like(qr/GIF89a/);
        $t->get_ok('/09/img/not_found.gif')->status_is(404)->text_is('title', 'Page Not Found');
    }
    
    sub directory_indexed : Test(8) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp2');
        $t->get_ok('/09/img/a.gif')->status_is(200)->header_is('Content-Type', 'image/gif')->content_like(qr/GIF89a/);
        $t->get_ok('/09/img/')->status_is(200)->header_is('Content-Type', 'image/gif')->content_like(qr/GIF89a/);
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
    $tusu->document_root($self->home->rel_dir('../public_html'));
}

package SomeApp2;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Tusu;

sub startup {
    my $self = shift;
    my $tusu = MojoX::Tusu->new($self);
    $tusu->document_root($self->home->rel_dir('../public_html'));
	$tusu->directory_index(['a.gif']);
}

__END__
