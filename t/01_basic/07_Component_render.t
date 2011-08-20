package ComponentBase_render;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Test::Mojo;

    my $backup = $ENV{MOJO_MODE} || '';
	
	sub ini_basic : Test(6) {
		my $tpl = Text::PSTemplate->new;
		my $component = IniTest->new($tpl);
		$component->foo('b');
		is($component->foo, 'b', 'set attr');
	}
		{
			package IniTest;
			use strict;
			use warnings;
			use base 'MojoX::Tusu::ComponentBase';
			__PACKAGE__->attr('foo');
		}
	
	sub ini_set : Test(2) {
		my $app = SomeApp2->new;
	}
		{
			package SomeApp2;
			use strict;
			use warnings;
			use base 'Mojolicious';
			use Test::More;
				
				sub startup {
					my $self = shift;
					my $tusu = $self->plugin(tusu => {
						components => {
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
        $t->get_ok('/07/some_component/index2.html')
			->status_is(200)
			->content_is('index2');
    }
		{
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
						document_root => 't/public_html'
					});
					
					my $r = $self->routes;
					$r->route('/07/some_component/index2.html')->to(cb => sub {
						$tusu->bootstrap($_[0], 'SomeComponent', 'get');
					});
				}
		}
	{
		package SomeComponent;
		use strict;
		use warnings;
		use base 'MojoX::Tusu::ComponentBase';
			
			__PACKAGE__->attr('key1');
			__PACKAGE__->attr('app');
			
			my $inited;
			
			sub init {
				my ($self, $app) = @_;
				$self->key1('value1');
				$self->app($app);
			}
		
			sub get {
				my ($self, $c) = @_;
				$c->render(handler => 'tusu', template => '07/some_component/index2.html');
			}
	}
    
    END {
        $ENV{MOJO_MODE} = $backup;
    }

    __PACKAGE__->runtests;
    
__END__
