package Mojolicious::Command::Generate::TusuApp;
use Mojo::Base 'Mojolicious::Command::Generate::App';
use Text::PSTemplate;
use Text::PSTemplate::File;
use File::Basename;
use File::Spec;
use File::Path;
use File::Copy;

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
  $self->render_to_rel_file($class, "script/my_app", 'script/<<% $app %>>');
  $self->chmod_file("$app/script/$app", 0744);
  $self->render_to_rel_file($class, "lib/MyApp.pm", 'lib/<<% $class %>>.pm');
  $self->render_to_rel_file($class, "lib/MyApp/YourComponent.pm", 'lib/<<% $class %>>/YourComponent.pm');
  $self->render_to_rel_file($class, "t/basic.t");
  $self->render_to_rel_file($class, 'public_html/index.html');
  $self->render_to_rel_file($class, 'public_html/copyright.html');
  $self->render_to_rel_file($class, 'public_html/htmlhead.html');
  $self->render_to_rel_file($class, 'public_html/commons/index.css');
  $self->render_to_rel_file($class, 'public_html/inquiry/index.html');
  $self->render_to_rel_file($class, 'public_html/inquiry/thanks.html');
  $self->create_rel_dir("$app/log");
  $self->bundle_lib($class, 'Mojolicious.pm');
    $self->bundle_lib($class, 'Mojo.pm');
    $self->bundle_lib($class, 'Mojo/Asset.pm');
    $self->bundle_lib($class, 'Mojo/Asset/File.pm');
    $self->bundle_lib($class, 'Mojo/Asset/Memory.pm');
    $self->bundle_lib($class, 'Mojo/Base.pm');
    $self->bundle_lib($class, 'Mojo/ByteStream.pm');
    $self->bundle_lib($class, 'Mojo/Cache.pm');
    $self->bundle_lib($class, 'Mojo/Command.pm');
    $self->bundle_lib($class, 'Mojo/Content.pm');
    $self->bundle_lib($class, 'Mojo/Content/MultiPart.pm');
    $self->bundle_lib($class, 'Mojo/Content/Single.pm');
    $self->bundle_lib($class, 'Mojo/Cookie.pm');
    $self->bundle_lib($class, 'Mojo/Cookie/Request.pm');
    $self->bundle_lib($class, 'Mojo/Cookie/Response.pm');
    $self->bundle_lib($class, 'Mojo/CookieJar.pm');
    $self->bundle_lib($class, 'Mojo/Date.pm');
    $self->bundle_lib($class, 'Mojo/DOM.pm');
    $self->bundle_lib($class, 'Mojo/DOM/Collection.pm');
    $self->bundle_lib($class, 'Mojo/DOM/CSS.pm');
    $self->bundle_lib($class, 'Mojo/DOM/HTML.pm');
    $self->bundle_lib($class, 'Mojo/Exception.pm');
    $self->bundle_lib($class, 'Mojo/Headers.pm');
    $self->bundle_lib($class, 'Mojo/HelloWorld.pm');
    $self->bundle_lib($class, 'Mojo/Home.pm');
    $self->bundle_lib($class, 'Mojo/IOLoop.pm');
    $self->bundle_lib($class, 'Mojo/IOWatcher.pm');
    $self->bundle_lib($class, 'Mojo/IOWatcher/Epoll.pm');
    $self->bundle_lib($class, 'Mojo/IOWatcher/KQueue.pm');
    $self->bundle_lib($class, 'Mojo/JSON.pm');
    $self->bundle_lib($class, 'Mojo/Loader.pm');
    $self->bundle_lib($class, 'Mojo/Log.pm');
    $self->bundle_lib($class, 'Mojo/Message.pm');
    $self->bundle_lib($class, 'Mojo/Message/Request.pm');
    $self->bundle_lib($class, 'Mojo/Message/Response.pm');
    $self->bundle_lib($class, 'Mojo/Parameters.pm');
    $self->bundle_lib($class, 'Mojo/Path.pm');
    $self->bundle_lib($class, 'Mojo/Resolver.pm');
    $self->bundle_lib($class, 'Mojo/Server.pm');
    $self->bundle_lib($class, 'Mojo/Server/CGI.pm');
    $self->bundle_lib($class, 'Mojo/Server/Daemon.pm');
    $self->bundle_lib($class, 'Mojo/Server/FastCGI.pm');
    $self->bundle_lib($class, 'Mojo/Server/Hypnotoad.pm');
    $self->bundle_lib($class, 'Mojo/Server/Morbo.pm');
    $self->bundle_lib($class, 'Mojo/Server/PSGI.pm');
    $self->bundle_lib($class, 'Mojo/Template.pm');
    $self->bundle_lib($class, 'Mojo/Transaction.pm');
    $self->bundle_lib($class, 'Mojo/Transaction/HTTP.pm');
    $self->bundle_lib($class, 'Mojo/Transaction/WebSocket.pm');
    $self->bundle_lib($class, 'Mojo/Upload.pm');
    $self->bundle_lib($class, 'Mojo/URL.pm');
    $self->bundle_lib($class, 'Mojo/UserAgent.pm');
    $self->bundle_lib($class, 'Mojo/UserAgent/Transactor.pm');
    $self->bundle_lib($class, 'Mojo/Util.pm');
    $self->bundle_lib($class, 'Mojolicious.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Cgi.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Daemon.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Eval.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Fastcgi.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Generate.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Generate/App.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Generate/Gitignore.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Generate/Hypnotoad.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Generate/LiteApp.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Generate/Makefile.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Get.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Inflate.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Psgi.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Routes.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Test.pm');
    $self->bundle_lib($class, 'Mojolicious/Command/Version.pm');
    $self->bundle_lib($class, 'Mojolicious/Commands.pm');
    $self->bundle_lib($class, 'Mojolicious/Controller.pm');
    $self->bundle_lib($class, 'Mojolicious/Guides.pod');
    $self->bundle_lib($class, 'Mojolicious/Guides/Cheatsheet.pod');
    $self->bundle_lib($class, 'Mojolicious/Guides/CodingGuidelines.pod');
    $self->bundle_lib($class, 'Mojolicious/Guides/Cookbook.pod');
    $self->bundle_lib($class, 'Mojolicious/Guides/FAQ.pod');
    $self->bundle_lib($class, 'Mojolicious/Guides/Growing.pod');
    $self->bundle_lib($class, 'Mojolicious/Guides/Rendering.pod');
    $self->bundle_lib($class, 'Mojolicious/Guides/Routing.pod');
    $self->bundle_lib($class, 'Mojolicious/Lite.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/CallbackCondition.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/Charset.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/Config.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/DefaultHelpers.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/EplRenderer.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/EpRenderer.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/HeaderCondition.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/I18n.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/JsonConfig.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/Mount.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/PodRenderer.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/PoweredBy.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/RequestTimer.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugin/TagHelpers.pm');
    $self->bundle_lib($class, 'Mojolicious/Plugins.pm');
    $self->bundle_lib($class, 'Mojolicious/public/amelia.png');
    $self->bundle_lib($class, 'Mojolicious/public/css/prettify-mojo.css');
    $self->bundle_lib($class, 'Mojolicious/public/css/prettify.css');
    $self->bundle_lib($class, 'Mojolicious/public/failraptor.png');
    $self->bundle_lib($class, 'Mojolicious/public/favicon.ico');
    $self->bundle_lib($class, 'Mojolicious/public/js/jquery.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-apollo.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-clj.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-css.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-go.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-hs.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-lisp.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-lua.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-ml.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-n.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-proto.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-scala.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-sql.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-tex.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-vb.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-vhdl.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-wiki.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-xq.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/lang-yaml.js');
    $self->bundle_lib($class, 'Mojolicious/public/js/prettify.js');
    $self->bundle_lib($class, 'Mojolicious/public/mojolicious-arrow.png');
    $self->bundle_lib($class, 'Mojolicious/public/mojolicious-black.png');
    $self->bundle_lib($class, 'Mojolicious/public/mojolicious-box.png');
    $self->bundle_lib($class, 'Mojolicious/public/mojolicious-clouds.png');
    $self->bundle_lib($class, 'Mojolicious/public/mojolicious-noraptor.png');
    $self->bundle_lib($class, 'Mojolicious/public/mojolicious-notfound.png');
    $self->bundle_lib($class, 'Mojolicious/public/mojolicious-pinstripe.gif');
    $self->bundle_lib($class, 'Mojolicious/public/mojolicious-white.png');
    $self->bundle_lib($class, 'Mojolicious/Renderer.pm');
    $self->bundle_lib($class, 'Mojolicious/Routes.pm');
    $self->bundle_lib($class, 'Mojolicious/Routes/Match.pm');
    $self->bundle_lib($class, 'Mojolicious/Routes/Pattern.pm');
    $self->bundle_lib($class, 'Mojolicious/Sessions.pm');
    $self->bundle_lib($class, 'Mojolicious/Static.pm');
    $self->bundle_lib($class, 'Mojolicious/templates/exception.development.html.ep');
    $self->bundle_lib($class, 'Mojolicious/templates/exception.html.ep');
    $self->bundle_lib($class, 'Mojolicious/templates/mojobar.html.ep');
    $self->bundle_lib($class, 'Mojolicious/templates/not_found.development.html.ep');
    $self->bundle_lib($class, 'Mojolicious/templates/not_found.html.ep');
    $self->bundle_lib($class, 'Mojolicious/templates/perldoc.html.ep');
    $self->bundle_lib($class, 'Mojolicious/Types.pm');
    $self->bundle_lib($class, 'ojo.pm');
    $self->bundle_lib($class, 'Test/Mojo.pm');
}

sub render_to_rel_file {
  my ($self, $class, $path, $path_to) = @_;
  my $app = $self->class_to_file($class);
  my $parser = Text::PSTemplate->new;
  $parser->set_delimiter('<<%', '%>>');
  $parser->set_var(class => $class, app => $app);
  my $template = File::Spec->rel2abs(File::Spec->catfile(dirname(__FILE__), 'TusuApp', $path));
  my $content = $parser->parse_file($template);
  $path_to = $path_to ? $parser->parse($path_to) : $path;
  $self->write_file("$app/". $path_to, $content);
  return $self;
}

sub bundle_lib {
    my ($self, $class, $lib) = @_;
    my $app = $self->class_to_file($class);
    my $path_to = File::Spec->catfile($app,'extlib', $lib);
    $self->create_dir(dirname($path_to));
    copy(find_lib($lib), $path_to);
    print "  [copy] $path_to\n";
    return $self;
}

sub find_lib {
  
  my $name = shift;
  for my $base (@INC) {
    if (-e "$base/$name") {
      return "$base/$name";
    }
  }
  return;
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
