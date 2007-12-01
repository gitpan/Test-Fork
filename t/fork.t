#!/usr/bin/perl -w

use Test::More tests => 10;

use_ok 'Test::Fork';

fork_ok(2, sub{ 
    pass("child 1");
    pass("child 1 again");
});

fork_ok(2, sub { 
    pass("child 2");
    pass("child 2 again");
});

pass("parent");

# Give the kids a chance to finish and the reaper to run.
sleep 1;
sleep 1;
sleep 1;

pass("parent again");

ok( Test::More->builder->use_numbers );
