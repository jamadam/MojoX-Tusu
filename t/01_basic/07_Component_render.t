package ComponentBase_render;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';

    __PACKAGE__->runtests;
	
	sub ini_set : Test(2) {
		my $app = SomeApp2->new;
	}
		{
			package SomeApp2;
			use strict;
			use warnings;
			use base 'Mojolicious';
			use MojoX::Tusu;
			use Test::More;
				
				sub startup {
					my $self = shift;
					my $tusu = MojoX::Tusu->new($self, {
						plugins => {
							'SomeComponent' => undef,
						},
					});
					my $SomeComponent = $tusu->engine->get_plugin('SomeComponent');
					is($SomeComponent->key1, 'value1');
					is($SomeComponent->app, $self);
				}
		}
    
    sub param : Test(6) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/')
			->status_is(200)
			->content_is('default');
        $t->get_ok('/07/some_component/')
			->status_is(200)
			->content_is('index2');
    }
		{
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
						document_root => 't/public_html'
					});
					
					my $r = $self->routes;
					$r->route('/07/some_component')->to(cb => sub {
						$tusu->bootstrap($_[0], 'SomeComponent', 'get');
					});
				}
		}
	{
		package SomeComponent;
		use strict;
		use warnings;
		use base 'MojoX::Tusu::ComponentBase';
			
			my $inited;
			
			sub init {
				my ($self, $app) = @_;
				$self->set_ini({'key1' => 'value1', app => $app});
			}
			
			sub key1 {
				my ($self) = @_;
				return $self->ini('key1');
			}
			
			sub app {
				my ($self) = @_;
				return $self->ini('app');
			}
		
			sub get {
				
				my ($self, $c) = @_;
				$c->render(handler => 'tusu', template => '07/some_component/index2.html');
			}
	}
		
    
    END {
        $ENV{MOJO_MODE} = $backup;
    }
    
__END__
