package main;

use 5.014;

use strict;
use warnings;

use utf8;

use Test2::V0;
use Syntax::Operator::Eqv qw{ :imp };

BEGIN {
    plan skip_all => "No PL_infix_plugin"
	unless XS::Parse::Infix::HAVE_PL_INFIX_PLUGIN;
}

use lib qw{ inc };
use My::Module::Test qw{ title };

use constant TPLT_IMP_HI_TRUE	=> '%s ==>> %s is true';
use constant TPLT_IMP_HI_FALSE	=> '%s ==>> %s is false';
use constant TPLT_IMP_LO_TRUE	=> '%s imp %s is true';
use constant TPLT_IMP_LO_FALSE	=> '%s imp %s is false';

sub ok_imp_hi;
sub ok_imp_lo;
sub not_ok_imp_hi;
sub not_ok_imp_lo;

# Truth table
ok_imp_hi 0, 0;
ok_imp_hi 0, 1;
not_ok_imp_hi 1, 0;
ok_imp_hi 1, 1;
ok_imp_lo 0, 0;
ok_imp_lo 0, 1;
not_ok_imp_lo 1, 0;
ok_imp_lo 1, 1;

done_testing;

sub not_ok_imp_hi {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ! ( $lhs ==>> $rhs ),
	title( TPLT_IMP_HI_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub not_ok_imp_lo {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ! ( $lhs imp $rhs ),
	title( TPLT_IMP_LO_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_imp_hi {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( $lhs ==>> $rhs,
	title( TPLT_IMP_HI_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_imp_lo {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ( $lhs imp $rhs ),
	title( TPLT_IMP_LO_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

1;

# ex: set textwidth=72 :
