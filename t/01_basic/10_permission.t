package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
	sub _permission_ok : Test(4) {
		is(MojoX::Tusu::_permission_ok('t/public_html/10/permission_ok/permission_ok.html'), 1);
		is(MojoX::Tusu::_permission_ok('t/public_html/10/permission_ok/permission_ng.html'), 0);
		is(MojoX::Tusu::_permission_ok('t/public_html/10/permission_ng/permission_ok.html'), 0);
		is(MojoX::Tusu::_permission_ok('t/public_html/10/permission_ng/permission_ng.html'), 0);
	}
	
    sub template_render : Test(8) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        $t->get_ok('/10/permission_ok/permission_ok.html')->status_is(200);
        $t->get_ok('/10/permission_ok/permission_ng.html')->status_is(403);
        $t->get_ok('/10/permission_ng/permission_ok.html')->status_is(403);
        $t->get_ok('/10/permission_ng/permission_ng.html')->status_is(403);
    }

	$ENV{MOJO_MODE} = $backup;

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
