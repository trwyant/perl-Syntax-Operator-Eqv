package main;

use 5.014;

use strict;
use warnings;

use utf8;

use Test2::V0;
use Syntax::Operator::Eqv;

BEGIN {
    plan skip_all => "No PL_infix_plugin"
	unless XS::Parse::Infix::HAVE_PL_INFIX_PLUGIN;
}

use lib qw{ inc };
use My::Module::Test qw{ title };

use constant TPLT_IMP_L_TRUE	=> '%s imp %s is true';
use constant TPLT_IMP_L_FALSE	=> '%s imp %s is false';
use constant TPLT_IMP_U_TRUE	=> '%s IMP %s is true';
use constant TPLT_IMP_U_FALSE	=> '%s IMP %s is false';

sub ok_imp;
sub ok_IMP;
sub not_ok_imp;
sub not_ok_IMP;

# Truth table
ok_imp 0, 0;
ok_imp 0, 1;
not_ok_imp 1, 0;
ok_imp 1, 1;
ok_IMP 0, 0;
ok_IMP 0, 1;
not_ok_IMP 1, 0;
ok_IMP 1, 1;

done_testing;

sub not_ok_imp {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ! ( $lhs imp $rhs ),
	title( TPLT_IMP_L_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub not_ok_IMP {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ! ( $lhs IMP $rhs ),
	title( TPLT_IMP_U_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_imp {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( $lhs imp $rhs,
	title( TPLT_IMP_L_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_IMP {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ( $lhs IMP $rhs ),
	title( TPLT_IMP_U_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

1;

# ex: set textwidth=72 :
