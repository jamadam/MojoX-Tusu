package Mojolicious::Command::Generate::TusuApp;
use Mojo::Base 'Mojolicious::Command::Generate::App';

has description => <<'EOF';
Generate MojoX::Tusu application directory structure.
EOF
has usage => <<"EOF";
usage: $0 generate tusu app [NAME]
EOF

# "I say, you've damaged our servants quarters... and our servants."
sub run {
  my ($self, $class) = @_;
  $class ||= 'MyMojoxTusuApp';

  # Prevent bad applications
  die <<EOF unless $class =~ /^[A-Z](?:\w|\:\:)+$/;
Your application name has to be a well formed (camel case) Perl module name
like "MyApp".
EOF

  # Script
  my $name = $self->class_to_file($class);
  $self->render_to_rel_file('mojo', "$name/script/$name", $class);
  $self->chmod_file("$name/script/$name", 0744);

  # Appclass
  my $app = $self->class_to_path($class);
  $self->render_to_rel_file('appclass', "$name/lib/$app", $class);

  # Controller
  my $controller = "${class}::YourComponent";
  my $path       = $self->class_to_path($controller);
  $self->render_to_rel_file('controller', "$name/lib/$path", $controller);

  # Test
  $self->render_to_rel_file('test', "$name/t/basic.t", $class);

  # Log
  $self->create_rel_dir("$name/log");

  # Layout and Templates
  $self->renderer->line_start('%%');
  $self->renderer->tag_start('<%%');
  $self->renderer->tag_end('%%>');

  $self->render_to_rel_file('index.html', "$name/public_html/index.html");
  $self->render_to_rel_file('copyright.html', "$name/public_html/copyright.html");
  $self->render_to_rel_file('htmlhead.html', "$name/public_html/htmlhead.html");
  $self->render_to_rel_file('commons/index.css', "$name/public_html/commons/index.css");
  $self->render_to_rel_file('inquiry/index.html', "$name/public_html/inquiry/index.html");
  $self->render_to_rel_file('inquiry/thanks.html', "$name/public_html/inquiry/thanks.html");
}

1;
__DATA__
@@ mojo
% my $class = shift;
#!/usr/bin/env perl

use strict;
use warnings;

use File::Basename 'dirname';
use File::Spec;

use lib join '/', File::Spec->splitdir(dirname(__FILE__)), 'lib';
use lib join '/', File::Spec->splitdir(dirname(__FILE__)), '..', 'lib';

# Check if Mojo is installed
eval 'use Mojolicious::Commands';
die <<EOF if $@;
It looks like you don't have the Mojolicious Framework installed.
Please visit http://mojolicio.us for detailed installation instructions.

EOF

# Application
$ENV{MOJO_APP} ||= '<%= $class %>';

# Start commands
Mojolicious::Commands->start;
@@ appclass
% my $class = shift;
package <%= $class %>;
use Mojo::Base 'Mojolicious';
use MojoX::Tusu;

# This method will run once at server start
sub startup {
  my $self = shift;
  my $tusu = MojoX::Tusu->new($self);
  $tusu->plug('<%= $class %>::YourComponent', 'YC');
  
  # Following lines are optional
  
  # $tusu->extensions_to_render([qw(html htm xml)]);
  # $tusu->document_root($self->home->rel_dir('www'));
  # $tusu->encoding(['Shift_JIS', 'utf8']);
  # $tusu->output_encoding('auto');
  
  # special route
  my $r = $self->routes;
  $r->route('/inquiry/')->via('post')->to(cb => sub {
    $tusu->bootstrap($_[0], '<%= $class %>::YourComponent', 'post');
  });
}

1;
@@ controller
% my $class = shift;
package <%= $class %>;
use base 'MojoX::Tusu::ComponentBase';

  # This function can be called inside templates.
  sub your_function : TplExport {
    my ($self) = @_;
    my $c = $self->controller;
    return 'your_function called';
  }
  
  sub post {
    my ($self, $c) = @_;
    
    # validate
    
    # sendmail
    
    $c->render(handler => 'tusu', template => '/inquiry/thanks.html');
  }

1;
@@ index.html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
  <head>
    <title>Welcome to the MojoX::Tusu Web Framework!</title>
    <% include('/htmlhead.html') %>
  </head>
  <body>
    <h1>
      Skeleton Site
    </h1>
    <div id="main">
      <h2>
        Welcome to the MojoX::Tusu Web Framework!
      </h2>
      This is the document "public_html/index.html".
      <br />Is the following line says 'Your function called?'
      <br />That's a dynamically generated content with a tag \<% YC::your_function() %>.
      <hr />
      <% YC::your_function() %>
      <hr />
      <a href="./inquiry/">inquiry(skeleton)</a>
    </div>
    <div id="footer">
      <% include('/copyright.html') %>
    </div>
  </body>
</html>
@@ copyright.html
<div>
  Copyright jamadam.com alright reserved.
</div>
@@ htmlhead.html
<link type="text/css" rel="stylesheet" href="http://yui.yahooapis.com/3.2.0/build/cssreset/reset-min.css" />
<link type="text/css" rel="stylesheet" href="http://yui.yahooapis.com/3.2.0/build/cssbase/base-min.css" />
<link type="text/css" rel="stylesheet" href="http://yui.yahooapis.com/3.2.0/build/cssfonts/fonts-min.css" />
<link type="text/css" rel="stylesheet" href="/commons/index.css" />
@@ commons/index.css
@charset "utf-8";

p,
div {
	margin-bottom:1em;
}
h1 {
	padding:20px;
}
#main {
	margin-left:40px;
	margin-bottom:20px;
	padding:0 20px 20px;
}
#footer {
	padding:0 20px;
}
@@ inquiry/index.html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
  <head>
    <title>Welcome to the MojoX::Tusu Web Framework!</title>
    <% include('/htmlhead.html') %>
  </head>
  <body>
    <h1>
      Demo
    </h1>
    <div id="main">
      <h2>
        Inquiry
      </h2>
      <div>
        <form method="post" action="./">
          <div>
            <input type="text" name="name" value="" />
            <input type="submit" value="send mail" />
          </div>
        </form>
      </div>
      <div>
        <a href="../">Back to home</a>
      </div>
    </div>
    <div id="footer">
      <% include('/copyright.html') %>
    </div>
  </body>
</html>
@@ inquiry/thanks.html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
  <head>
    <title>Welcome to the MojoX::Tusu Web Framework!</title>
    <% include('/htmlhead.html') %>
  </head>
  <body>
    <h1>
      Demo
    </h1>
    <div id="main">
      <h2>
        Thank you for asking something!
      </h2>
      <div>
        <% post_param('name', 1) %>
      </div>
      <div>
        <a href="../">Back to home</a>
      </div>
    </div>
    <div id="footer">
      <% include('/copyright.html') %>
    </div>
  </body>
</html>
@@ test
% my $class = shift;
#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 5;
use Test::Mojo;

use_ok '<%= $class %>';

# Test
my $t = Test::Mojo->new(app => '<%= $class %>');

$t->get_ok('/')->status_is(200)
  ->content_type_is('text/html;charset=UTF-8')
  ->content_like(qr/MojoX::Tusu Web Framework/i);

$t->post_ok('/inquiry/')->status_is(200)
  ->content_type_is('text/html;charset=UTF-8')
  ->content_like(qr/Thank you/i);
__END__
=head1 NAME

Mojolicious::Command::Generate::TusuApp - MojoX::Tusu App Generator Command

=head1 SYNOPSIS

  use Mojolicious::Command::Generate::TusuApp;

  my $app = Mojolicious::Command::Generate::TusuApp->new;
  $app->run(@ARGV);

=head1 DESCRIPTION

L<Mojolicious::Command::Generate::App> is a application generator.

=head1 ATTRIBUTES

L<Mojolicious::Command::Generate::TusuApp> inherits all attributes from
L<Mojo::Command> and implements the following new ones.

=head2 C<description>

  my $description = $app->description;
  $app            = $app->description('Foo!');

Short description of this command, used for the command list.

=head2 C<usage>

  my $usage = $app->usage;
  $app      = $app->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Mojolicious::Command::Generate::TusuApp> inherits all methods from
L<Mojo::Command> and implements the following new ones.

=head2 C<run>

  $app->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
