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

use Test::More tests => 6;
    my $tusu = MojoX::Tusu->new(app);
    $tusu->document_root('t/public_html/06');
    $tusu->extensions_to_render([qw(html htm xml txt)]);
    my $t = Test::Mojo->new;
    $t->get_ok('/')->status_is(200)->content_is('06 default a');
    $t->get_ok('/index.txt')->status_is(200)->content_is('06 index.txt a');

    $ENV{MOJO_MODE} = $backup;

__END__
