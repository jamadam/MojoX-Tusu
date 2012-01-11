package ComponentBase;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
    
    sub param : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/03/03_ComponentBase01.html?key=value')
			->status_is(200)
			->content_is('value');
    }
    
    sub post_param : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->post_form_ok('/03/03_ComponentBase02.html', {key => 'value2'})
			->status_is(200)
			->content_is('value2');
    }
    
    sub url_for : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/03/03_ComponentBase03.html')
			->status_is(200)
			->content_is('/path/to/file path/to/file');
    }
    
	sub redirect_to : Test(24) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('RedirectTo');
        $t->get_ok('/03/03_ComponentBase04.html?a=/hoge.html')
			->status_is(302)
			->header_like('Location' => qr{http://localhost:\d+/hoge.html$});
        $t->get_ok('/03/03_ComponentBase04.html?a=./hoge.html')
			->status_is(302)
			->header_like('Location' => qr{http://localhost:\d+/03/hoge.html$});
        $t->get_ok('/03/03_ComponentBase04.html?a=http://example.com/a/b/c.html')
			->status_is(302)
			->header_like('Location' => qr{http://example.com/a/b/c.html});
        $t->get_ok('/03/03_ComponentBase04.html?a=/')
			->status_is(302)
			->header_like('Location' => qr{http://localhost:\d+/$});
		
		local $ENV{REQUEST_URI} = '/dummy/';
		
        $t->get_ok('/03/03_ComponentBase04.html?a=./hoge2.html')
			->status_is(302)
			->header_like('Location' => qr{http://localhost:\d+/dummy/hoge2.html$});
        $t->get_ok('/03/03_ComponentBase04.html?a=/hoge2.html')
			->status_is(302)
			->header_like('Location' => qr{http://localhost:\d+/hoge2.html$});
        $t->get_ok('/03/03_ComponentBase04.html?a=http://example.com/a/b/c.html')
			->status_is(302)
			->header_like('Location' => qr{http://example.com/a/b/c.html});
        $t->get_ok('/03/03_ComponentBase04.html?a=/')
			->status_is(302)
			->header_like('Location' => qr{http://localhost:\d+/$});
	}
	
    END {
        $ENV{MOJO_MODE} = $backup;
    }

package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';
    
    sub startup {
        my $self = shift;
    
        my $tusu = $self->plugin(tusu => {
			components => {
				'SomeComponent' => undef,
			},
			document_root => 't/public_html',
		});
        my $r = $self->routes;
        $r->route('/03/03_ComponentBase02.html')->to(cb => sub {
            $tusu->bootstrap($_[0], 'SomeComponent', 'post');
        });
    }

package RedirectTo;
use strict;
use warnings;
use base 'Mojolicious';
    
    sub startup {
        my $self = shift;
    
        my $tusu = $self->plugin(tusu => {
			components => {
				'SomeComponent' => undef,
			},
			document_root => 't/public_html',
		});
        my $r = $self->routes;
        $r->route('/03/03_ComponentBase04.html')->to(cb => sub {
            $tusu->bootstrap($_[0], 'SomeComponent', 'redirect_to', $_[0]->req->param('a'));
        });
    }

package SomeComponent;
use strict;
use warnings;
use base 'MojoX::Tusu::ComponentBase';

    sub post {
        my ($self) = @_;
        $self->controller->render(handler => 'tusu', template => '/03/03_ComponentBase02.html')
    }
    
__END__
