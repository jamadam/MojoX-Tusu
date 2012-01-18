package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub request_not_found : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/08/not_found.html')
			->status_is(404)
			->text_like('title', qr{Page not found}i);
    }
    
    sub request_not_found2 : Test(3) {
        $ENV{MOJO_MODE} = 'development';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/08/not_found.html')
			->status_is(404)
			->text_like('title', qr{Page not found}i);
    }
    
    sub request_not_found3 : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/08/directory_index_fail/')
			->status_is(404)
			->text_like('title', qr{Page not found}i);
    }
    
    sub request_not_found4 : Test(3) {
        $ENV{MOJO_MODE} = 'development';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/08/directory_index_fail/')
			->status_is(404)
			->text_like('title', qr{Page not found}i);
    }
    
    sub internal_not_found : Test(4) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/08/')
			->status_is(500)
			->text_like('title', qr{Server error}i)
            ->element_exists('div#raptor');
    }
    
    sub internal_not_found2 : Test(5) {
        $ENV{MOJO_MODE} = 'development';
        my $t = Test::Mojo->new('SomeApp');
		use File::Spec;
		my $expected1 = File::Spec->catfile(qw(t public_html 08 not_exist.html));
		my $expected2 = File::Spec->catfile(qw(t public_html 08 index.html));
        $t->get_ok('/08/')
			->status_is(500)
			->text_like('title', qr{Server error}i)
			->content_like(qr{\Q$expected1\E})
			->content_like(qr{at \Q$expected2\E line 1});
    }
    
    sub if_file_is_directory_then_301  : Test(8) {
        $ENV{MOJO_MODE} = 'development';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/08/dir')
			->status_is(301)
			->header_like('location', qr{/08/dir/});
        $t->get_ok('/08/dir2')
			->status_is(404); 
        $t->get_ok('/08')
			->status_is(301)
			->header_like('location', qr{/08/});
    }
    
    sub error_document_set : Test(4) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('ErrorDocument');
        $t->get_ok('/08/not_found.html')
			->status_is(404)
			->content_is('404');
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
    my $tusu = $self->plugin(tusu => {document_root => 't/public_html'});
}

package ErrorDocument;
use strict;
use warnings;
use base 'Mojolicious';

sub startup {
    my $self = shift;
    my $tusu = $self->plugin(tusu => {
		document_root => 't/public_html',
		error_document => {
			404 => '/08/err/404.html',
			403 => '/08/err/403.html',
			500 => '/08/err/500.html',
		}
	});
}

__END__
