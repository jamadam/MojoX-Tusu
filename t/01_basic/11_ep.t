package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;
    
    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub template_render : Test(8) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'SomeApp');
        #$t->get_ok('/11/23.html')->status_is(200)->content_is('');
        $t->get_ok('/11/')->status_is(200);#->content_is('');
    }
    
    END {
        $ENV{MOJO_MODE} = $backup;
    }

package SomeApp;
use strict;
use warnings;
use Mojo::Base 'Mojolicious';
use MojoX::Tusu;

sub startup {
    my $self = shift;
    my $tusu = MojoX::Tusu->new($self);
	$tusu->document_root('/home/sugama/www/dev/cpan/MojoX-Tusu/trunk/t/public_html');
	#$self->renderer->root('/home/sugama/www/dev/cpan/MojoX-Tusu/trunk/t/public_html');
	my $r = $self->routes;
	$r->route('/11/')->to(cb => sub{
		my $c = shift;
		warn '===1';
		$c->render;
	});
}

__END__
