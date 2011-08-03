package Plack::App::File::Extended;
use parent qw(Plack::App::File);
use strict;
use warnings;
use Plack::Request;
use Plack::Util::Accessor qw( path );
    
    sub should_handle {
        my($self, $file) = @_;
        return -d $file || -f $file;
    }
    
    sub serve_path {
        my($self, $env, $file, $fullpath) = @_;
        
        if (! _permission_ok($file, $self->root)) {
            return $self->return_403;
        }
        
        if (-f $file) {
            return $self->SUPER::serve_path($env, $file, $fullpath);
        }
        
        my $dir_url = $env->{SCRIPT_NAME} . $env->{PATH_INFO};
        
        if ($dir_url !~ m{/$}) {
            return $self->return_dir_redirect($env);
        }
    }
    
    ### ---
    ### Check if others readable
    ### ---
    sub _permission_ok {
        
        my ($name, $base) = @_;
        $base ||= '';
        if ($^O eq 'MSWin32') {
            return 1;
        }
        if ($name && -f $name && ((stat($name))[2] & 4)) {
            $name =~ s{(^|/)[^/]+$}{};
            while (-d $name) {
                if ($name eq $base) {
                    return 1;
                }
                if (! ((stat($name))[2] & 1)) {
                    return 0;
                }
                $name =~ s{(^|/)[^/]+$}{};
            }
            return 1;
        }
        return 0;
    }
    
    sub return_dir_redirect {
        my ($self, $env) = @_;
        my $uri = Plack::Request->new($env)->uri;
        return [ 301,
            [
                'Location' => $uri . '/',
                'Content-Type' => 'text/plain',
                'Content-Length' => 8,
            ],
            [ 'Redirect' ],
        ];
    }

1;

__END__

=head1 NAME

Plack::App::Directory - Serve static files from document root with directory index

=head1 SYNOPSIS

  # app.psgi
  use Plack::App::Directory;
  my $app = Plack::App::Directory->new({ root => "/path/to/htdocs" })->to_app;

=head1 DESCRIPTION

This is a static file server PSGI application with directory index a la Apache's mod_autoindex.

=head1 CONFIGURATION

=over 4

=item root

Document root directory. Defaults to the current directory.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack::App::File>

=cut
