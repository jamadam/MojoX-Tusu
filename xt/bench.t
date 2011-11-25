package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Mojo::Template;
use Text::PSTemplate;
use Benchmark qw(countit) ;
use Mojo::Util;

    __PACKAGE__->runtests;
	
    sub template_engine : Test(4) {
		
		my $mt = Mojo::Template->new;
		my $pst = Text::PSTemplate->new;
        $pst->set_filter('=', \&Mojo::Util::html_escape);
		
		my $mt_countit = sub {
			my $str = $_[0];
			countit(1, sub{
				$mt->render($str)
			})->iters
		};
		my $pst_countit = sub {
			my $str = $_[0];
			countit(1, sub{
				$pst->parse($str)
			})->iters
		};
		is($pst_countit->('aaa') >= $mt_countit->('aaa'), 1);
		is($pst_countit->(q{<%= echo('aaa') %>}) >= $mt_countit->(q{<%= 'aaa' %>}), 1);
		
		is($pst_countit->(<<'EOF1') >= $mt_countit->(<<'EOF2'), 1);
<% each([1 .. 3] => 'i')<<BLOCK %>
<%= $i %>
<% BLOCK %>
EOF1
%  for my $i (1..3) {
%=    $i
%  }
EOF2
		
		is($pst_countit->(<<'EOF1') >= $mt_countit->(<<'EOF2'), 1);
<%= if(1)<<BLOCK %>
works!
<% BLOCK %>
EOF1
% if (1) {
works!
% }
EOF2
	}

__END__
