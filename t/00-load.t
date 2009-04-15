#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Path::Mapper' );
}

diag( "Testing Path::Mapper $Path::Mapper::VERSION, Perl $], $^X" );
