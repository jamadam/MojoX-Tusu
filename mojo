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

# "My eyes! The goggles do nothing!"
Mojolicious::Commands->start;

__END__

=head1 NAME

mojo - The Mojolicious Command System

=head1 SYNOPSIS

  % mojo --help

=head1 DESCRIPTION

List and run L<Mojolicious> commands as described in
L<Mojolicious::Commands>.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
