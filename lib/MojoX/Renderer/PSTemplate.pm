package MojoX::Renderer::PSTemplate;
use strict;
use warnings;
#use File::Spec ();
#use Mojo::Command;
use Try::Tiny;
use Text::PSTemplate::Plugable;
use parent qw(Mojo::Base);
our $VERSION = '0.01';
$VERSION = eval $VERSION;
    
    __PACKAGE__->attr('pstemplate');
    
    sub build {
        my $self = shift->SUPER::new(@_);
        $self->_init(@_);
        return sub { $self->_render(@_) };
    }
    
    sub _init {
        my ($self, %args) = @_;
    
        my $app = $args{mojo} || $args{app};
        my $pst = $args{pst} || Text::PSTemplate::Plugable->new;
        $self->pstemplate($pst);
    
        return $self;
    }
    
    sub _render {
        my ($self, $renderer, $c, $output, $options) = @_;
    
        my $name = $c->stash->{'template_name'}
            || $renderer->template_name($options);
        
        $self->pstemplate->set_var(%{$c->stash});
        
        try {
            $$output = $self->pstemplate->parse_file($name);
        }
        catch {
            my $err = $_;
            $c->app->log->error(qq(Template error in "$name": $err));
            $c->render_exception($err);
            $$output = '';
            return 0;
        };
        
        return 1;
    }


1;

__END__

=head1 NAME

MojoX::Renderer::PSTemplate - Text::PSTemplate renderer for Mojo

=head1 SYNOPSIS

    sub startup {
        ....

        # Via mojolicious plugin
        $self->plugin('pstemplate_renderer');

        # or manually
        use MojoX::Renderer::PSTemplate;
        my $pst = MojoX::Renderer::PSTemplate->build(
            mojo             => $self,
            template_options => { },
        );
        $self->renderer->add_handler(tx => $pst);
    }

=head1 DESCRIPTION

The C<MojoX::Renderer::PSTemplate> module is called by C<MojoX::Renderer> for
any matching template.

=head1 METHODS

=head2 build

    $renderer = MojoX::Renderer::PSTemplate->build(...)

This method returns a handler for the Mojo renderer.

Supported parameters are:

=over

=item mojo

C<build> currently uses a C<mojo> parameter pointing to the base class
object (C<Mojo>).

=item template_options

A hash reference of options that are passed to Text::PSTemplate->new().

=back

=head1 SEE ALSO

L<Text::PSTemplate>, L<MojoX::Renderer>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
