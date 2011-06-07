package Template_Basic;
use strict;
use warnings;
use Test::More;
use MojoX::Tusu;
use Test::Mojo;
use Mojolicious::Lite;

use Test::More tests => 9;

    my $backup;
    BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }
    BEGIN { $backup = $ENV{MOJO_MODE} || ''; $ENV{MOJO_MODE} = 'development' }
    
    my $tusu = MojoX::Tusu->new(app);
    $tusu->document_root('t/public_html');
    my $t = Test::Mojo->new;
    $t->get_ok('/04/')->status_is(200)->content_is('sub ok');
    $t->get_ok('/04/index2.html')->status_is(200)->content_is('sub2 ok');
    $t->get_ok('/04/index3.html')->status_is(200)->content_is('sub3 ok');

__END__
