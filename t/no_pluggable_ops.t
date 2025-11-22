package main;

use 5.014;

use strict;
use warnings;
;
use utf8;

use Test2::V0;
use XS::Parse::Infix 0.44;

BEGIN {
    plan skip_all => "Perl $^V supports pluggable operators"
	if XS::Parse::Infix::HAVE_PL_INFIX_PLUGIN;
}

use Syntax::Operator::Eqv ();	# Explicitly import nothing.

if ( my $exception = dies { Syntax::Operator::Eqv->import( '(==)' ) } ) {
    is index( $exception, 'Infix operators require at least Perl v5.38' ),
	0, 'Got correct import exception on Perl before v5.38';
} else {
    fail 'Import (==) succeeded on Perl before v5.38';
}

done_testing;

1;

# ex: set textwidth=72 :
