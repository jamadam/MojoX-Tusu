package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub constractor : Test(5) {
        
        my $app = Test::App->new;
        my $r = MojoX::Tusu->new($app);
        is(ref $r, 'MojoX::Tusu');
        is(ref $app->pst, 'Text::PSTemplate::Plugable');
        my $engine = $r->engine;
        is(ref $engine, 'Text::PSTemplate::Plugable');
        is(ref $engine->get_plugin('MojoX::Tusu::ComponentBase'), 'MojoX::Tusu::ComponentBase');
        is(ref $engine->get_plugin('MojoX::Tusu::Component::Mojolicious'), 'MojoX::Tusu::Component::Mojolicious');
    }

package Test::App;
use Mojolicious::Lite;

__END__