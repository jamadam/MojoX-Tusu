package Template_Basic;
use strict;
use warnings;
use lib 'lib';
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
    
    sub t01_permission_ok : Test(4) {
        is(MojoX::Tusu::_permission_ok('t/00_partial/f/t01/permission_ok/permission_ok.html'), 1);
        is(MojoX::Tusu::_permission_ok('t/00_partial/f/t01/permission_ok/permission_ng.html'), 0);
        is(MojoX::Tusu::_permission_ok('t/00_partial/f/t01/permission_ng/permission_ok.html'), 0);
        is(MojoX::Tusu::_permission_ok('t/00_partial/f/t01/permission_ng/permission_ng.html'), 0);
    }
    
    sub t02_fill_filename : Test(9) {
        is(MojoX::Tusu::_fill_filename('t/00_partial/f/t02', ['index.html']), 't/00_partial/f/t02/index.html');
        is(MojoX::Tusu::_fill_filename('t/00_partial/f/t02/', ['index.html']), 't/00_partial/f/t02/index.html');
        is(MojoX::Tusu::_fill_filename('t/00_partial/f/t02/a', ['index.html']), 't/00_partial/f/t02/a/index.html');
        is(MojoX::Tusu::_fill_filename('t/00_partial/f/t02/a/', ['index.html']), 't/00_partial/f/t02/a/index.html');
        is(MojoX::Tusu::_fill_filename('t/00_partial/f/t02/b/', ['index.html']), undef);
        is(MojoX::Tusu::_fill_filename('t/00_partial/f/t02', ['index2.html']), undef);
        is(MojoX::Tusu::_fill_filename('t/00_partial/f/t02/', ['index2.html']), undef);
        is(MojoX::Tusu::_fill_filename('t/00_partial/f/t02/a', ['index2.html']), undef);
        is(MojoX::Tusu::_fill_filename('t/00_partial/f/t02/a/', ['index2.html']), undef);
    }

__END__
