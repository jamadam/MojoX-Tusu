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

  # Static
  $self->render_to_rel_file('static', "$name/public_html/index.html");
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
  # $tusu->extensions_to_render([qw(html htm xml)]);
  # $tusu->document_root($self->home->rel_dir('www'));
  # $tusu->encoding(['Shift_JIS', 'utf8']);
  # $tusu->output_encoding('auto');
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

1;
@@ static
<!doctype html><html>
  <head><title>Welcome to the MojoX::Tusu Web Framework!</title></head>
  <body>
    <h2>Welcome to the MojoX::Tusu Web Framework!</h2>
    This is the document "public_html/index.html".
    <br />Is the following line says 'Your function called?'
    <br />That's a dynamically generated content with a tag \<% YC::your_function() %>.
    <hr />
    <% YC::your_function() %>
    <hr />
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
