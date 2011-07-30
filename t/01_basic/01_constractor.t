package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub constractor : Test(4) {
        
        my $app = Test::App->new;
        $app->plugin(tusu => {});
        my $r = Mojolicious::Plugin::Tusu->new($app);
        $r->register($app, {});
        is(ref $r, 'Mojolicious::Plugin::Tusu');
        my $engine = $r->engine;
        is(ref $engine, 'Text::PSTemplate');
        is(ref $engine->get_plugin('MojoX::Tusu::ComponentBase'), 'MojoX::Tusu::ComponentBase');
        is(ref $engine->get_plugin('MojoX::Tusu::Component::Mojolicious'), 'MojoX::Tusu::Component::Mojolicious');
    }

package Test::App;
use Mojolicious::Lite;

__END__
