package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use MojoX::Tusu;
use Test::Mojo;
use utf8;
use Encode;
use Encode::Guess;

    my $backup = $ENV{MOJO_MODE} || '';
    
    __PACKAGE__->runtests;
	
    sub file_is_shiftjis : Test(2) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'TestCase1');
        $t->get_ok('/11/')
			->content_is('シフトJISのファイル');
		warn guess_encoding($t->tx->res->body, 'Shift-JIS', 'utf8');
		warn guess_encoding(Encode::decode('utf8', $t->tx->res->body), 'Shift-JIS', 'utf8');
		warn Encode::decode('utf8', $t->tx->res->body);
    }
    
    sub file_and_output_shiftjis : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'TestCase2');
        $t->get_ok('/11/')
			->header_is('Content-Type', 'text/html;charset=Shift_JIS')
			->content_is('シフトJISのファイル');
	}
    
    END {
        $ENV{MOJO_MODE} = $backup;
    }

package TestCase1;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Tusu;

sub startup {
    my $self = shift;
    my $tusu = MojoX::Tusu->new($self);
    $tusu->document_root('t/public_html');
	$tusu->encoding(['Shift-JIS', 'utf8']);
}

package TestCase2;
use strict;
use warnings;
use base 'Mojolicious';
use MojoX::Tusu;

sub startup {
    my $self = shift;
    my $tusu = MojoX::Tusu->new($self);
    $tusu->document_root('t/public_html');
	$tusu->encoding(['Shift-JIS', 'utf8']);
}

__END__
