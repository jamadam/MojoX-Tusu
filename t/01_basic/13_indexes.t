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
	
    sub auto_escape : Test(8) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('TestCase1');
        $t->get_ok('/13/')
			->content_like(qr{<title>Index of /13/</title>})
			->content_like(qr{4B})
			->content_like(qr{1.7KB})
			->content_like(qr{<a class="dir" href="..">..</a>})
			->content_unlike(qr{<a class="dir" href=".">})
			->content_like(qr{<a class="dir" href="some_dir">some_dir</a>})
			->content_like(qr{\d\d\d\d-\d\d-\d\d \d\d:\d\d})
    }
		{
			package TestCase1;
			use strict;
			use warnings;
			use base 'Mojolicious';
			
			sub startup {
				my $self = shift;
				my $tusu = $self->plugin(
					tusu => {
						document_root => 't/public_html',
						indexes			=> 1,
					}
				);
			}
		}
	
    END {
        $ENV{MOJO_MODE} = $backup;
    }

__END__
