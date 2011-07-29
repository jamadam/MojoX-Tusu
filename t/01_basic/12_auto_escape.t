package Template_Basic;
use strict;
use warnings;
use lib 'lib';
use base 'Test::Class';
use Test::More;
use Test::Mojo;
use utf8;
use Encode;
use Encode::Guess;

    my $backup = $ENV{MOJO_MODE} || '';
    
    __PACKAGE__->runtests;
	
    sub auto_escape : Test(2) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('TestCase1');
        $t->get_ok('/12/index.html')
			->content_is("<&>&lt;&amp;&gt;");
    }
		{
			package TestCase1;
			use strict;
			use warnings;
			use base 'Mojolicious';
			
			sub startup {
				my $self = shift;
				my $tusu = $self->plugin(tusu => {document_root => 't/public_html'});
			}
		}
	
    END {
        $ENV{MOJO_MODE} = $backup;
    }

__END__
