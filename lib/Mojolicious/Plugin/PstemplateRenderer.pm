package Mojolicious::Plugin::PstemplateRenderer;
use strict;
use warnings;
use MojoX::Renderer::PSTemplate;
use parent qw(Mojolicious::Plugin);
    
    sub register {
        my ($self, $app, $args) = @_;
    
        $args ||= {};
    
        my $tpl = MojoX::Renderer::PSTemplate->build(app => $app, %$args);
        $app->renderer->add_handler(pst => $tpl);
    }


1;

__END__

=head1 NAME

Mojolicious::Plugin::Pstemplate - Text::Pstemplate plugin

=head1 SYNOPSIS

    # Mojolicious
    $self->plugin('pstemplate_renderer');
    $self->plugin(pstemplate_renderer => {
        template_options => { syntax => 'TTerse', ...}
    });

    # Mojolicious::Lite
    plugin 'pstemplate_renderer';
    plugin pstemplate_renderer => {
        template_options => { syntax => 'TTerse', ...}
    };

=head1 DESCRIPTION

L<Mojolicous::Plugin::Pstemplate> is a simple loader for
L<MojoX::Renderer::Pstemplate>.

=head1 METHODS

L<Mojolicious::Plugin::Pstemplate> inherits all methods from
L<Mojolicious::Plugin> and overrides the following ones:

=head2 register

    $plugin->register

Registers renderer in L<Mojolicious> application.

=head1 SEE ALSO

L<MojoX::Renderer::Pstemplate>, L<Mojolicious>

=cut

