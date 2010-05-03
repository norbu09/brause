#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'brause' );
}

diag( "Testing brause $brause::VERSION, Perl $], $^X" );
