package main;

use 5.014;

use strict;
use warnings;

use Test2::V0;
use Syntax::Operator::Eqv qw{ implies };

use lib qw{ inc };
use My::Module::Test qw{ title };

use constant TPLT_TRUE	=> 'implies( %s, %s ) is true';
use constant TPLT_FALSE	=> 'implies( %s, %s ) is false';

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
    my $rslt = $ctx->ok( ! implies( $lhs, $rhs ),
	title( TPLT_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_imp {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( implies( $lhs, $rhs ),
	title( TPLT_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

1;

# ex: set textwidth=72 :
