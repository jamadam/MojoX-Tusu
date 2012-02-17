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
	
    sub auto_escape : Test(16) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('TestCase1');
        $t->get_ok('/')
			->content_like(qr{<title>Index of /</title>})
			->content_like(qr{4B})
			->content_like(qr{1.7KB})
			->content_unlike(qr{<a class="dir" href=".">})
			->content_like(qr{<a class="dir" href="some_dir">some_dir</a>})
			->content_like(qr{\d\d\d\d-\d\d-\d\d \d\d:\d\d});
        $t->get_ok('/some_dir/')
			->content_like(qr{<a class="dir" href="..">..</a>})
			->content_like(qr{test.html});
        $t->get_ok('/some_dir2/')
			->content_is(q{index file exists});
        $t->get_ok('/some_dir3/file_list.css')
			->content_is(q{file_list.css});
        $t->get_ok('/tusu_asset/file_list.css')
			->content_like(qr{\@charset "UTF\-8"});
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
						document_root => 't/public_html/13',
						indexes			=> 1,
					}
				);
			}
		}
	
    END {
        $ENV{MOJO_MODE} = $backup;
    }

__END__
