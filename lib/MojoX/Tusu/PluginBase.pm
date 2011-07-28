package MojoX::Tusu::PluginBase;
use strict;
use warnings;
use base qw(Text::PSTemplate::PluginBase);
    
    sub controller {
        
        return $MojoX::Tusu::CONTROLLER;
    }

1;

__END__

=head1 NAME

MojoX::Tusu::PluginBase - Base Class for template plugins for MojoX::Tusu

=head1 SYNOPSIS
    
    package YourPlugin;
    use strict;
    use warnings;
    use base qw(MojoX::Tusu::PluginBase);
    
    # inside template..
    # <% YourPlugin::some_func(@your_args) %>

=head1 DESCRIPTION

C<MojoX::Tusu::PluginBase> is a Plugin Base class for
MojoX::Tusu sub framework on mojolicious. This class inherits
all method from Text::PSTemplate::PluginBase.

=head1 METHODS

=head2 controller

Returns current Mojolicious::Controller instance.

=head1 SEE ALSO

L<Text::PSTemplate>, L<MojoX::Renderer>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
