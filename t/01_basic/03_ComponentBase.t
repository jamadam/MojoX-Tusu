package ComponentBase;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
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
    
        my $tusu = MojoX::Tusu->new($self, {
			plugins => {
				'SomeComponent' => undef,
			},
		});
        $tusu->document_root('t/public_html');
        
        my $r = $self->routes;
        $r->route('/03/03_ComponentBase02.html')->to(cb => sub {
            $tusu->bootstrap($_[0], 'SomeComponent', 'post');
        });
    }

package SomeComponent;
use strict;
use warnings;
use base 'MojoX::Tusu::ComponentBase';

    sub post {
        
        my ($self, $c) = @_;
        $c->render(handler => 'tusu', template => '/03/03_ComponentBase02.html')
    }
    
__END__
