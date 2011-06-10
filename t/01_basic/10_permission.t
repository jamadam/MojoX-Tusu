package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;
    
    BEGIN {
        chmod(0755, 't/00_partial/f/t01/permission_ok');
        chmod(0744, 't/00_partial/f/t01/permission_ng');
        chmod(0755, 't/00_partial/f/t01/permission_ok/permission_ok.html');
        chmod(0700, 't/00_partial/f/t01/permission_ok/permission_ng.html');
        chmod(0755, 't/00_partial/f/t01/permission_ng/permission_ok.html');
        chmod(0700, 't/00_partial/f/t01/permission_ng/permission_ng.html');
    }
    
    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub template_render : Test(8) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/10/permission_ok/permission_ok.html')->status_is(200);
        $t->get_ok('/10/permission_ok/permission_ng.html')->status_is(403);
        $t->get_ok('/10/permission_ng/permission_ok.html')->status_is(403);
        $t->get_ok('/10/permission_ng/permission_ng.html')->status_is(403);
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

__END__
