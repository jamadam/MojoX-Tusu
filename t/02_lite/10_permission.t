package Template_Basic;
use strict;
use warnings;

    my $backup;
    BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }
    BEGIN { $backup = $ENV{MOJO_MODE} || ''; $ENV{MOJO_MODE} = 'production' }

use Test::More;
use MojoX::Tusu;
use Test::Mojo;
use Mojolicious::Lite;

use Test::More tests => 11;
    
    BEGIN {
        chmod(0755, 't/00_partial/f/t01/permission_ok');
        chmod(0744, 't/00_partial/f/t01/permission_ng');
        chmod(0755, 't/00_partial/f/t01/permission_ok/permission_ok.html');
        chmod(0700, 't/00_partial/f/t01/permission_ok/permission_ng.html');
        chmod(0755, 't/00_partial/f/t01/permission_ng/permission_ok.html');
        chmod(0700, 't/00_partial/f/t01/permission_ng/permission_ng.html');
    }

    my $tusu = MojoX::Tusu->new(app);
    $tusu->document_root('t/public_html');
    
    my $t = Test::Mojo->new;
    $t->get_ok('/10/permission_ok/permission_ok.html')->status_is(200);
    $t->get_ok('/10/permission_ok/permission_ng.html')->status_is(403);
    $t->get_ok('/10/permission_ng/permission_ok.html')->status_is(403);
    $t->get_ok('/10/permission_ng/permission_ng.html')->status_is(403);

	$tusu->error_document({
		404 => '/08/err/404.html',
		403 => '/08/err/403.html',
		500 => '/08/err/500.html',
	});
	
	$t->get_ok('/10/permission_ng/permission_ng.html')
		->status_is(403)
		->content_is('403');
	
    $ENV{MOJO_MODE} = $backup;

__END__
