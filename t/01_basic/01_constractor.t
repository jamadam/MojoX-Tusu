package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;

    __PACKAGE__->runtests;
    
    sub constractor : Test(4) {
        
        my $app = Test::App->new;
        my $r = MojoX::Tusu->new($app);
        is(ref $r, 'MojoX::Tusu');
        my $engine = $r->engine;
        is(ref $engine, 'Text::PSTemplate');
        is(ref $engine->get_plugin('MojoX::Tusu::ComponentBase'), 'MojoX::Tusu::ComponentBase');
        is(ref $engine->get_plugin('MojoX::Tusu::Plugin::Mojolicious'), 'MojoX::Tusu::Plugin::Mojolicious');
    }

package Test::App;
use Mojolicious::Lite;

__END__
