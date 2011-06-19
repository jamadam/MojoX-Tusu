use strict;
use warnings;
use Test::Memory::Cycle;
use Test::More;
use MojoX::Tusu;

my $app = SomeApp->new;
memory_cycle_ok( $app );


package SomeApp;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Tusu;

sub startup {
    my $self = shift;
    #my $tusu = MojoX::Tusu->new($self);
    #$tusu->document_root('t/public_html');
}

__END__