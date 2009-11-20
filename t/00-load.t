#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Template::Any::ProcessDir' );
}

diag( "Testing Template::Any::ProcessDir $Template::Any::ProcessDir::VERSION, Perl $], $^X" );
