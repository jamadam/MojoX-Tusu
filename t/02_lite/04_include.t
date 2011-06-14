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

use Test::More tests => 12;
    my $tusu = MojoX::Tusu->new(app);
    $tusu->document_root('t/public_html');
    my $t = Test::Mojo->new;
    $t->get_ok('/04/')->status_is(200)->content_is('sub ok');
    $t->get_ok('/04/index2.html')->status_is(200)->content_is('sub2 ok');
    $t->get_ok('/04/index3.html')->status_is(200)->content_is('sub3 ok');
    $t->get_ok('/04/index4.html')->status_is(200)->content_is('sub4 ok');

    $ENV{MOJO_MODE} = $backup;

__END__
