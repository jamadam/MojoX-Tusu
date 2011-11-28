use strict;
use warnings;
use Test::UseAllModules;

BEGIN {
    all_uses_ok(except => qw(
        Mojolicious::Command::generate::tusu_app::.*
    ));
}
