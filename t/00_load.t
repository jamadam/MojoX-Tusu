use strict;
use warnings;
use Test::UseAllModules;

BEGIN {
    all_uses_ok(except => [
        qr/Mojolicious::Command::Generate::TusuApp::.*/,
    ]);
}
