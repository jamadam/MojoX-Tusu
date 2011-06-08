package Template_Basic;
use strict;
use warnings;
use Test::More;
use MojoX::Tusu;
use Test::Mojo;
use Mojolicious::Lite;

use Test::More tests => 6;

    my $backup;
    BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }
    BEGIN { $backup = $ENV{MOJO_MODE} || ''; $ENV{MOJO_MODE} = 'production' }

    my $tusu = MojoX::Tusu->new(app);
    $tusu->document_root('t/public_html');
    
    my $t = Test::Mojo->new;
    $t->get_ok('/09/img/a.gif')->status_is(200)->header_is('Content-Type', 'image/gif')->content_like(qr/GIF89a/);

__END__
