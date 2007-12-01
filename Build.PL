#!/usr/bin/perl -w

BEGIN { require 5.006 }

use Module::Build;

my $build = Module::Build->new(
    module_name     => 'Test::Fork',
    license         => 'perl',
    requires        => {
        'Test::Builder::Module'     => '0.02',
        'Test::More'                => '0.62',
    },
);

$build->create_build_script;
