package Plack::App::TextPstemplate;
use strict;
use warnings;
use parent qw(Plack::Component);
use Plack::Util::Accessor qw(parser directory_index document_root encoding);
use Text::PSTemplate;
use Try::Tiny;
use Plack::MIME;
our $VERSION = '0.01';
    
    sub prepare_app {
        my $self = shift;
        
        if (! $self->document_root) {
            $self->document_root('./public_html');
        }
        
        if (! $self->directory_index) {
            $self->directory_index(qw{index.html index.htm});
        }
        
        my $parser = $self->parser || Text::PSTemplate->new;
        $parser->set_filter('=', \&Mojo::Util::html_escape);
        $parser->set_filename_trans_coderef(sub {
            _filename_trans($self->document_root, $self->directory_index, @_);
        });
        $self->parser($parser);
    }

    sub call {
        my ($self, $env) = @_;
        my $path = $self->parser->file_name_trans($env->{PATH_INFO});
        if (-d $path && substr($env->{PATH_INFO}, -1, 1) ne '/') {
            return [
                301,
                [
                    'Location' => $env->{PATH_INFO}. '/',
                    'Content-Type' => 'text/plain',
                    'Content-Length' => 8,
                ],
                [ 'Redirect' ],
            ];
        } elsif (! -f $path) {
            return [
                404,
                [
                    'Content-Type' => 'text/plain',
                    'Content-Length' => 9,
                ],
                ['not found'],
            ];
        }
        
        if (! _permission_ok($path)) {
            return [
                403,
                [
                    'Content-Type' => 'text/plain',
                    'Content-Length' => 9,
                ],
                ['forbidden'],
            ];
        }
        
        my $body =
            Text::PSTemplate->new($self->parser)->parse_file($env->{PATH_INFO});
        
        my $mime = Plack::MIME->mime_type($env->{PATH_INFO});
        return [
            200,
            [
                'Content-Type'   => $mime. ';charset=UTF-8',
                'Content-Length' => length($body),
            ],
            [$body],
        ];
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
    
    ### ---
    ### foo/bar.html    -> public_html/foo/bar.html
    ### foo/            -> public_html/foo/index.html
    ### foo             -> public_html/foo
    ### ---
    sub _filename_trans {
        
        my ($template_base, $directory_index, $name) = @_;
        $name ||= '';
        my $leading_slash = substr($name, 0, 1) eq '/';
        my $trailing_slash = substr($name, -1, 1) eq '/';
        $name =~ s{^/}{};
        my $dir;
        if ($leading_slash || ! Text::PSTemplate->get_current_filename) {
            $dir = $template_base;
        } else {
            $dir = (File::Spec->splitpath(Text::PSTemplate->get_current_filename))[1];
        }
        my $path = File::Spec->catfile($dir, $name);
        if ($trailing_slash) {
            if (my $fixed_path = _fill_filename($path, $directory_index)) {
                return $fixed_path;
            }
        }
        return $path;
    }
    
    ### ---
    ### fill directory_index candidate
    ### ---
    sub _fill_filename {
        
        my ($path, $directory_index) = @_;
        for my $default (@{$directory_index}) {
            my $path = File::Spec->catfile($path, $default);
            if (-f $path) {
                return $path;
            }
        }
        return;
    }

1;

__END__

=head1 NAME

Plack::Middleware::Text::PSTemplate - 

=head1 SYNOPSIS

    use Plack::Middleware::Text::PSTemplate;
    Plack::Middleware::Text::PSTemplate->new;

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

sugama, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by sugama.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
