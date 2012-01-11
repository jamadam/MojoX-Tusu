package Template_Basic;
use strict;
use warnings;
use lib 'lib';

    my $backup;
    BEGIN { $ENV{MOJO_NO_IPV6} = $ENV{MOJO_POLL} = 1 }
    BEGIN { $backup = $ENV{MOJO_MODE} || ''; $ENV{MOJO_MODE} = 'development' }

use Test::More;
use Test::Mojo;
use Mojolicious::Lite;
    
use Test::More tests => 9;

    my $tusu = plugin tusu => {
		components => {
			'SomeComponent' => undef,
		},
		document_root => 't/public_html',
	};
    
    any '/03/03_ComponentBase02.html' => sub {
        $tusu->bootstrap($_[0], 'SomeComponent', 'post');
    };
    
    my $t = Test::Mojo->new;
    $t->get_ok('/03/03_ComponentBase01.html?key=value')
		->status_is(200)
		->content_is('value');
    $t->post_form_ok('/03/03_ComponentBase02.html', {key => 'value2'})
		->status_is(200)
		->content_is('value2');
    $t->get_ok('/03/03_ComponentBase03.html')
		->status_is(200)
		->content_is('/path/to/file path/to/file');

    $ENV{MOJO_MODE} = $backup;

package SomeComponent;
use strict;
use warnings;
use base 'MojoX::Tusu::ComponentBase';

    sub post {
        my ($self) = @_;
        $self->controller->render(handler => 'tusu', template => '/03/03_ComponentBase02.html')
    }
