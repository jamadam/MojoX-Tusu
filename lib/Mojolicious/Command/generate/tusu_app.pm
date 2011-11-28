package Mojolicious::Command::generate::tusu_app;
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Command::generate::app';
use Text::PSTemplate;
use Text::PSTemplate::File;
use File::Basename;
use File::Spec;
use File::Path;
use File::Copy;
use LWP::Simple;

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
    $self->chmod_file("$app/script/$app", 744);
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
    
    $self->bundle_dist($class, 'Mojolicious');
    
    print "  [bundle distribution] MojoX::Tusu\n";
    my @bundle = qw(
        Mojolicious/Command/generate/tusu_app.pm
        Mojolicious/Command/generate/tusu_app/lib/MyApp.pm
        Mojolicious/Command/generate/tusu_app/lib/MyApp/YourComponent.pm
        Mojolicious/Command/generate/tusu_app/public_html/commons/index.css
        Mojolicious/Command/generate/tusu_app/public_html/copyright.html
        Mojolicious/Command/generate/tusu_app/public_html/error_document/404.html
        Mojolicious/Command/generate/tusu_app/public_html/htmlhead.html
        Mojolicious/Command/generate/tusu_app/public_html/index.html
        Mojolicious/Command/generate/tusu_app/public_html/inquiry/index.html
        Mojolicious/Command/generate/tusu_app/public_html/inquiry/thanks.html
        Mojolicious/Command/generate/tusu_app/script/my_app
        Mojolicious/Command/generate/tusu_app/t/basic.t
        Mojolicious/Plugin/Tusu.pm
        MojoX/Tusu.pm
        MojoX/Tusu/Component/Mojolicious.pm
        MojoX/Tusu/Component/Util.pm
        MojoX/Tusu/ComponentBase.pm
        Text/PSTemplate.pm
        Text/PSTemplate/Block.pm
        Text/PSTemplate/DateTime.pm
        Text/PSTemplate/Exception.pm
        Text/PSTemplate/File.pm
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

sub bundle_dist {
    my ($self, $class, $dist_name) = @_;
    for my $package (_get_lib_names($dist_name)) {
        $self->bundle_lib($class, $package);
    }
    print "  [bundle distribution] $dist_name\n";
    return $self;
}

sub _get_lib_names {
    my $dist = shift;
    my $uri = "http://cpanmetadb.appspot.com/v1.0/package/$dist";
    if (my $yaml = LWP::Simple::get($uri)) {
        if ($yaml =~ qr{distfile:\s+(.+)\-[\d\.]+\.tar.gz}) {
            my @paths = split(qr{/}, $1);
            my $path = (uc $paths[-2]). '/'. $paths[-1];
            no strict 'refs';
            my $dist_file = $dist;
            $dist_file =~ s{::}{/}g;
            eval {
                require "$dist_file.pm"; ## no critic
            };
            my $ver = ${"$dist\::VERSION"};
            my $uri2 = "http://cpansearch.perl.org/src/$path-$ver/MANIFEST";
            my $manifest = LWP::Simple::get($uri2);
            return grep {my $a = $_; $a =~ s{^lib/}{}} split(qr{\s+}s, $manifest);
        }
    }
}

1;

__END__

=head1 NAME

Mojolicious::Command::generate::tusu_app - MojoX::Tusu App Generator Command

=head1 SYNOPSIS

  use Mojolicious::Command::generate::tusu_app;

  my $app = Mojolicious::Command::generate::tusu_app->new;
  $app->run(@ARGV);

=head1 DESCRIPTION

L<Mojolicious::Command::generate::app> is a application generator.

=head1 ATTRIBUTES

L<Mojolicious::Command::generate::tusu_app> inherits all attributes from
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

L<Mojolicious::Command::generate::tusu_app> inherits all methods from
L<Mojo::Command> and implements the following new ones.

=head2 C<run>

  $app->run(@ARGV);

=head2 C<render_to_file>

Not written yet.

=head2 C<render_to_rel_file>

Not written yet.

=head2 C<bundle_dist>

Not written yet.

=head2 C<bundle_lib>

Not written yet.

=head2 C<find_lib>

Not written yet.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
