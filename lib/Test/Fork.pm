package Test::Fork;

use strict;
use warnings;

our $VERSION = '0.01_01';

use base 'Test::Builder::Module';
our @EXPORT = qw(fork_ok);

my $CLASS = __PACKAGE__;


=head1 NAME

Test::Fork - test code which forks

=head1 SYNOPSIS

    use Test::More tests => 5;
    use Test::Fork;
    
    fork_ok(2, sub{
        is 23, 42;
        is 42, 23;
    });
    
    is 99, 23;

=head1 DESCRIPTION

B<THIS IS ALPHA CODE!>  The implementation is unreliable and the interface
is subject to change.

Because each test has a number associated with it, testing code which forks
is problematic.  Coordinating the test number amongst the parent and child
processes is complicated.  Test::Fork provides a function to smooth over
the complications.

=head2 Functions

Each function is exported by default.

=head3 B<fork_ok>

    fork_ok( $num_tests, sub {
        ...child test code...
    });

Runs the given child test code in a forked process.

$num_tests is the number of tests in your child test code.
Consider it to be a sub-plan.

fork_ok() itself is a test, if the fork fails it will fail.  fork_ok()
test does not count towards your $num_tests.

    fork_ok( 2, sub {
        is $foo, $bar;
        ok Something->method;
    });

=cut

my %running_children;
my $Is_Child = 0;

sub fork_ok ($&) {
    my($num_tests, $child_sub) = @_;
    
    my $tb = $CLASS->builder;    
    my $pid = fork;

    # Failed fork
    if( !defined $pid ) {
        return $tb->ok(0, "fork() failed: $!");
    }
    # Parent
    elsif( $pid ) {
        $tb->use_numbers(0);
        $running_children{$pid}++;
        $tb->current_test($tb->current_test + $num_tests);

        return $tb->ok(1, "fork() succeeded");
    }

    # Child
    $Is_Child = 1;

    $tb->use_numbers(0);
    $tb->no_ending(1);
    
    $child_sub->();
    exit;
}

END {
    while( !$Is_Child and keys %running_children ) {
        _reaper();
    }
}

sub _reaper {
    my $child_pid = wait;
    delete $running_children{$child_pid};

    $CLASS->builder->use_numbers(1) unless keys %running_children;
}

$SIG{CHLD} = \&_reaper;


=head1 CAVEATS

The failure of tests in a child process cannot be detected by the parent.
Therefore, the normal end-of-test reporting done by Test::Builder will
not notice failed child tests.

Test::Fork turns off test numbering in order to avoid test counter
coordination issues.  It turns it back on once the children are done
running.


=head1 SEE ALSO

L<Test::MultiFork>


=head1 AUTHOR

Michael G Schwern E<lt>schwern@pobox.comE<gt>


=head1 BUGS and FEEDBACK

Please send all bugs and feature requests to 
I<bug-Test-Fork> at I<rt.cpan.org> or use the web interface via
L<http://rt.cpan.org>.


=head1 COPYRIGHT and LICENSE

Copyright 2007 by Michael G Schwern E<lt>schwern@pobox.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>

=cut

42;
