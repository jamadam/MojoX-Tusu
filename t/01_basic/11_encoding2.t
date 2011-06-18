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
	
    sub file_is_shiftjis : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'TestCase1');
        $t->get_ok('/11/')
			->header_is('Content-Type', 'text/html;charset=UTF-8')
			->content_is('シフトJISのファイル');
    }
		{
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
		}
    
    sub file_and_output_is_shiftjis : Test(3) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'TestCase2');
        $t->get_ok('/11/')
			->header_is('Content-Type', 'text/html;charset=Shift_JIS')
			->content_is('シフトJISのファイル');
	}
		{
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
				$tusu->output_charset_auto_detect(1);
			}
		}
    
    sub file_and_output_is_shiftjis_mojolicious_encoding_ommited : Test(6) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new(app => 'TestCase3');
        $t->get_ok('/11/')
			->header_is('Content-Type', 'text/html;charset=Shift_JIS')
			->content_is('シフトJISのファイル');
        $t->get_ok('/11/utf8.html')
			->header_is('Content-Type', 'text/html;charset=UTF-8')
			->content_is('utf8のファイル漢字あいうえおかきくけこ');
	}
		{
			package TestCase3;
			use strict;
			use warnings;
			use base 'Mojolicious';
			use MojoX::Tusu;
			
			sub startup {
				my $self = shift;
				my $tusu = MojoX::Tusu->new($self);
				$tusu->document_root('t/public_html');
				$tusu->encoding(['Shift-JIS', 'utf8']);
				$tusu->output_charset_auto_detect(1);
				$self->renderer->encoding('euc-jp');
			}
		}
	
    END {
        $ENV{MOJO_MODE} = $backup;
    }

__END__
