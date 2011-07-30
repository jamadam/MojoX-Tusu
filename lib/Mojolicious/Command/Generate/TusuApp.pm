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
    $class ||= 'MyTusuApp';
    
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
    
    my @bundle = qw(
        Mojolicious.pm
        Mojo.pm
        Mojo/Asset.pm
        Mojo/Asset/File.pm
        Mojo/Asset/Memory.pm
        Mojo/Base.pm
        Mojo/ByteStream.pm
        Mojo/Cache.pm
        Mojo/Command.pm
        Mojo/Content.pm
        Mojo/Content/MultiPart.pm
        Mojo/Content/Single.pm
        Mojo/Cookie.pm
        Mojo/Cookie/Request.pm
        Mojo/Cookie/Response.pm
        Mojo/CookieJar.pm
        Mojo/Date.pm
        Mojo/DOM.pm
        Mojo/DOM/Collection.pm
        Mojo/DOM/CSS.pm
        Mojo/DOM/HTML.pm
        Mojo/Exception.pm
        Mojo/Headers.pm
        Mojo/HelloWorld.pm
        Mojo/Home.pm
        Mojo/IOLoop.pm
        Mojo/IOWatcher.pm
        Mojo/IOWatcher/Epoll.pm
        Mojo/IOWatcher/KQueue.pm
        Mojo/JSON.pm
        Mojo/Loader.pm
        Mojo/Log.pm
        Mojo/Message.pm
        Mojo/Message/Request.pm
        Mojo/Message/Response.pm
        Mojo/Parameters.pm
        Mojo/Path.pm
        Mojo/Resolver.pm
        Mojo/Server.pm
        Mojo/Server/CGI.pm
        Mojo/Server/Daemon.pm
        Mojo/Server/FastCGI.pm
        Mojo/Server/Hypnotoad.pm
        Mojo/Server/Morbo.pm
        Mojo/Server/PSGI.pm
        Mojo/Template.pm
        Mojo/Transaction.pm
        Mojo/Transaction/HTTP.pm
        Mojo/Transaction/WebSocket.pm
        Mojo/Upload.pm
        Mojo/URL.pm
        Mojo/UserAgent.pm
        Mojo/UserAgent/Transactor.pm
        Mojo/Util.pm
        Mojolicious.pm
        Mojolicious/Command/Cgi.pm
        Mojolicious/Command/Daemon.pm
        Mojolicious/Command/Eval.pm
        Mojolicious/Command/Fastcgi.pm
        Mojolicious/Command/Generate.pm
        Mojolicious/Command/Generate/App.pm
        Mojolicious/Command/Generate/Gitignore.pm
        Mojolicious/Command/Generate/Hypnotoad.pm
        Mojolicious/Command/Generate/LiteApp.pm
        Mojolicious/Command/Generate/Makefile.pm
        Mojolicious/Command/Get.pm
        Mojolicious/Command/Inflate.pm
        Mojolicious/Command/Psgi.pm
        Mojolicious/Command/Routes.pm
        Mojolicious/Command/Test.pm
        Mojolicious/Command/Version.pm
        Mojolicious/Commands.pm
        Mojolicious/Controller.pm
        Mojolicious/Guides.pod
        Mojolicious/Guides/Cheatsheet.pod
        Mojolicious/Guides/CodingGuidelines.pod
        Mojolicious/Guides/Cookbook.pod
        Mojolicious/Guides/FAQ.pod
        Mojolicious/Guides/Growing.pod
        Mojolicious/Guides/Rendering.pod
        Mojolicious/Guides/Routing.pod
        Mojolicious/Lite.pm
        Mojolicious/Plugin.pm
        Mojolicious/Plugin/CallbackCondition.pm
        Mojolicious/Plugin/Charset.pm
        Mojolicious/Plugin/Config.pm
        Mojolicious/Plugin/DefaultHelpers.pm
        Mojolicious/Plugin/EplRenderer.pm
        Mojolicious/Plugin/EpRenderer.pm
        Mojolicious/Plugin/HeaderCondition.pm
        Mojolicious/Plugin/I18n.pm
        Mojolicious/Plugin/JsonConfig.pm
        Mojolicious/Plugin/Mount.pm
        Mojolicious/Plugin/PodRenderer.pm
        Mojolicious/Plugin/PoweredBy.pm
        Mojolicious/Plugin/RequestTimer.pm
        Mojolicious/Plugin/TagHelpers.pm
        Mojolicious/Plugins.pm
        Mojolicious/public/amelia.png
        Mojolicious/public/css/prettify-mojo.css
        Mojolicious/public/css/prettify.css
        Mojolicious/public/failraptor.png
        Mojolicious/public/favicon.ico
        Mojolicious/public/js/jquery.js
        Mojolicious/public/js/lang-apollo.js
        Mojolicious/public/js/lang-clj.js
        Mojolicious/public/js/lang-css.js
        Mojolicious/public/js/lang-go.js
        Mojolicious/public/js/lang-hs.js
        Mojolicious/public/js/lang-lisp.js
        Mojolicious/public/js/lang-lua.js
        Mojolicious/public/js/lang-ml.js
        Mojolicious/public/js/lang-n.js
        Mojolicious/public/js/lang-proto.js
        Mojolicious/public/js/lang-scala.js
        Mojolicious/public/js/lang-sql.js
        Mojolicious/public/js/lang-tex.js
        Mojolicious/public/js/lang-vb.js
        Mojolicious/public/js/lang-vhdl.js
        Mojolicious/public/js/lang-wiki.js
        Mojolicious/public/js/lang-xq.js
        Mojolicious/public/js/lang-yaml.js
        Mojolicious/public/js/prettify.js
        Mojolicious/public/mojolicious-arrow.png
        Mojolicious/public/mojolicious-black.png
        Mojolicious/public/mojolicious-box.png
        Mojolicious/public/mojolicious-clouds.png
        Mojolicious/public/mojolicious-noraptor.png
        Mojolicious/public/mojolicious-notfound.png
        Mojolicious/public/mojolicious-pinstripe.gif
        Mojolicious/public/mojolicious-white.png
        Mojolicious/Renderer.pm
        Mojolicious/Routes.pm
        Mojolicious/Routes/Match.pm
        Mojolicious/Routes/Pattern.pm
        Mojolicious/Sessions.pm
        Mojolicious/Static.pm
        Mojolicious/templates/exception.development.html.ep
        Mojolicious/templates/exception.html.ep
        Mojolicious/templates/mojobar.html.ep
        Mojolicious/templates/not_found.development.html.ep
        Mojolicious/templates/not_found.html.ep
        Mojolicious/templates/perldoc.html.ep
        Mojolicious/Types.pm
        ojo.pm
        Test/Mojo.pm
        Text/PSTemplate.pm
        Text/PSTemplate/Block.pm
        Text/PSTemplate/DateTime.pm
        Text/PSTemplate/Exception.pm
        Text/PSTemplate/File.pm
        Text/PSTemplate/Manual.pod
        Text/PSTemplate/ManualJP.pod
        Text/PSTemplate/Plugable.pm
        Text/PSTemplate/Plugin/CGI.pm
        Text/PSTemplate/Plugin/Control.pm
        Text/PSTemplate/Plugin/Developer.pod
        Text/PSTemplate/Plugin/Env.pm
        Text/PSTemplate/Plugin/Extends.pm
        Text/PSTemplate/Plugin/FS.pm
        Text/PSTemplate/Plugin/HTML.pm
        Text/PSTemplate/Plugin/Time.pm
        Text/PSTemplate/Plugin/Time2.pm
        Text/PSTemplate/Plugin/TSV.pm
        Text/PSTemplate/Plugin/Util.pm
        Text/PSTemplate/PluginBase.pm
        Mojolicious/Plugin/Tusu.pm
        MojoX/Tusu/ComponentBase.pm
        MojoX/Tusu/Plugin/Mojolicious.pm
        MojoX/Tusu/Plugin/Util.pm
    );
    
    for my $file (@bundle) {
        $self->bundle_lib($class, $file);
    }
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
