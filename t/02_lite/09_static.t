package Template_Basic;
use strict;
use warnings;
use Test::More;
use MojoX::Tusu;
use Test::Mojo;
use Mojolicious::Lite;

use Test::More tests => 24;

    my $backup;
    BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }
    BEGIN { $backup = $ENV{MOJO_MODE} || ''; $ENV{MOJO_MODE} = 'production' }

    my $tusu = MojoX::Tusu->new(app);
    $tusu->document_root(app->home->rel_dir('../public_html'));
    
    my $t = Test::Mojo->new;
    $t->get_ok('/09/img/a.gif')
		->status_is(200)
		->header_is('Content-Type', 'image/gif')
		->content_like(qr/GIF89a/);
    $t->get_ok('/09/img/not_found.gif')
		->status_is(404)
		->text_is('title', 'Page Not Found');

    $tusu->directory_index(['a.gif']);

    $t->get_ok('/09/img/a.gif')
		->status_is(200)
		->header_is('Content-Type', 'image/gif')
		->content_like(qr/GIF89a/);
    $t->get_ok('/09/img/')
		->status_is(200)
		->header_is('Content-Type', 'image/gif')
		->content_like(qr/GIF89a/);

	$t->get_ok('/mojolicious-pinstripe.gif')
		->status_is(200)
		->header_is('Content-Type', 'image/gif');
	$t->get_ok('/mojolicious-noraptor.png')
		->status_is(200)
		->header_is('Content-Type', 'image/png');
	$t->get_ok('/js/lang-proto.js')
		->status_is(200)
		->header_is('Content-Type', 'application/x-javascript');
    
    $ENV{MOJO_MODE} = $backup;

__END__
