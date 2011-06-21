package Mojolicious::Command::Generate::TusuApp;
use Mojo::Base 'Mojolicious::Command::Generate::App';
use Text::PSTemplate;
use File::Basename;
use File::Spec;

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
  my $app = $self->class_to_file($class);
  $self->render_to_rel_file($class, "script/my_app", "$app/script/$app");
  $self->chmod_file("$app/script/$app", 0744);
  $self->render_to_rel_file($class, "lib/MyApp.pm", "$app/lib/$class.pm");
  $self->render_to_rel_file($class, "lib/MyApp/YourComponent.pm", "$app/lib/$class/YourComponent.pm");
  $self->render_to_rel_file($class, "t/basic.t");
  $self->render_to_rel_file($class, 'public_html/index.html');
  $self->render_to_rel_file($class, 'public_html/copyright.html');
  $self->render_to_rel_file($class, 'public_html/htmlhead.html');
  $self->render_to_rel_file($class, 'public_html/commons/index.css');
  $self->render_to_rel_file($class, 'public_html/inquiry/index.html');
  $self->render_to_rel_file($class, 'public_html/inquiry/thanks.html');
  $self->create_rel_dir("$app/log");
}

sub render_to_file {
  my ($self, $data, $path) = @_;
  $self->write_file($path, $data);
  $self;
}

sub render_to_rel_file {
  my ($self, $class, $path, $path_to) = @_;
  my $app = $self->class_to_file($class);
  my $parser = Text::PSTemplate->new;
  $parser->set_delimiter('<<%', '%>>');
  $parser->set_var(class => $class);
  my $template = File::Spec->rel2abs(File::Spec->catfile(dirname(__FILE__), 'TusuApp', $path));
  $self->render_to_file($parser->parse_file($template), ($path_to || "$app/$path"));
}

1;

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

=head2 C<render_to_file>

Not written yet.

=head2 C<render_to_rel_file>

Not written yet.

Run this command.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
