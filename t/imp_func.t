package main;

use 5.014;

use strict;
use warnings;

use Test2::V0;
use Syntax::Operator::Eqv qw{ is_imp };

use lib qw{ inc };
use My::Module::Test qw{ title };

use constant TPLT_TRUE	=> 'is_imp( %s, %s ) is true';
use constant TPLT_FALSE	=> 'is_imp( %s, %s ) is false';

sub ok_imp;
sub not_ok_imp;

# Truth table
ok_imp 0, 0;
ok_imp 0, 1;
not_ok_imp 1, 0;
ok_imp 1, 1;

done_testing;

sub not_ok_imp {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ! is_imp( $lhs, $rhs ),
	title( TPLT_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_imp {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( is_imp( $lhs, $rhs ),
	title( TPLT_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

1;

# ex: set textwidth=72 :
