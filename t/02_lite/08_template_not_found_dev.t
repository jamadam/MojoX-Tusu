package Template_Basic;
use strict;
use warnings;

    my $backup;
    BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }
    BEGIN { $backup = $ENV{MOJO_MODE} || ''; $ENV{MOJO_MODE} = 'development' }

use Test::More;
use MojoX::Tusu;
use Test::Mojo;
use Mojolicious::Lite;
use Test::More tests => 11;

    my $tusu = MojoX::Tusu->new(app);
    $tusu->document_root('t/public_html');
    
    my $t = Test::Mojo->new;
    $t->get_ok('/08/not_found.html')
		->status_is(404)
		->text_is('title', 'Page Not Found');
    $t->get_ok('/08/')
		->status_is(500)
		->text_is('title', 'Server Error')
		->content_like(qr{t/public_html/08/not_exist.html})
		->content_like(qr{at t/public_html/08/index.html line 1});
	$t->get_ok('/08/directory_index_fail/')
		->status_is(404)
		->text_is('title', 'Page Not Found');

    $ENV{MOJO_MODE} = $backup;

__END__
