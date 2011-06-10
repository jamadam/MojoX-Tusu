package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub request_not_found : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/08/not_found.html')->status_is(404)->text_is('title', 'Page Not Found');
    }
    
    sub request_not_found2 : Test(3) {
        $ENV{MOJO_MODE} = 'development';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/08/not_found.html')->status_is(404)->text_is('title', 'Page Not Found');
    }
    
    sub internal_not_found : Test(4) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/08/')->status_is(500)->text_is('title', 'Server Error')
            ->element_exists('div#raptor');
    }
    
    sub internal_not_found2 : Test(4) {
        $ENV{MOJO_MODE} = 'development';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/08/')->status_is(500)->text_is('title', 'Server Error')->content_like(qr{t/public_html/08/not_exist.html not found at t/public_html/08/index.html line 1});
    }
    
    sub if_file_is_directory_then_301  : Test(8) {
        $ENV{MOJO_MODE} = 'development';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/08/dir')->status_is(301)->header_like('location', qr{/08/dir/});
        $t->get_ok('/08/dir2')->status_is(404); 
        $t->get_ok('/08')->status_is(301)->header_like('location', qr{/08/});
    }
    
    sub error_document_set : Test(4) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'ErrorDocument');
        $t->get_ok('/08/not_found.html')->status_is(404)->content_is('404');
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
    $tusu->document_root('t/public_html');
}

package ErrorDocument;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Tusu;

sub startup {
    my $self = shift;
    my $tusu = MojoX::Tusu->new($self);
	$tusu->error_document({
		404 => '/08/err/404.html',
		403 => '/08/err/403.html',
		500 => '/08/err/500.html',
	});
    $tusu->document_root('t/public_html');
}

__END__
