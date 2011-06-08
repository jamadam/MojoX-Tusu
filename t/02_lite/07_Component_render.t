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
    BEGIN { $backup = $ENV{MOJO_MODE} || ''; $ENV{MOJO_MODE} = 'development' }
    
    my $tusu = MojoX::Tusu->new(app);
    $tusu->document_root('t/public_html');
    $tusu->plug('SomeComponent');
    
    my $r = app->routes;
    $r->route('/07/some_component')->to(cb => sub {
        $tusu->bootstrap($_[0], 'SomeComponent', 'get');
    });
    
    my $t = Test::Mojo->new;
    $t->get_ok('/')->status_is(200)->content_is('default');
    $t->get_ok('/07/some_component/')->status_is(200)->content_is('index2');

	$ENV{MOJO_MODE} = $backup;

package SomeComponent;
use strict;
use warnings;
use base 'MojoX::Tusu::ComponentBase';

    sub get {
        
        my ($self, $c) = @_;
        $c->render(handler => 'tusu', template => '07/some_component/index2.html');
    }

__END__
