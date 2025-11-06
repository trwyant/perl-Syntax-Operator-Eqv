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

use constant TPLT_EQV_L_TRUE	=> '%s eqv %s is true';
use constant TPLT_EQV_L_FALSE	=> '%s eqv %s is false';
use constant TPLT_EQV_U_TRUE	=> '%s EQV %s is true';
use constant TPLT_EQV_U_FALSE	=> '%s EQV %s is false';

sub ok_eqv;
sub ok_EQV;
sub not_ok_eqv;
sub not_ok_EQV;

# Truth table
ok_eqv 0, 0;
not_ok_eqv 0, 1;
not_ok_eqv 1, 0;
ok_eqv 1, 1;
ok_EQV 0, 0;
not_ok_EQV 0, 1;
not_ok_EQV 1, 0;
ok_EQV 1, 1;

# Binding strength
ok 0 eqv 0 && 0, '&& binds more tightly than eqv';
ok( ! ( 0 eqv 1 and 0 ), 'and binds more loosely than eqv' );
ok( ( 0 EQV 0 and 0 ), 'and binds more tightly than EQV' );
#
# Other stuff
ok_eqv 0, '';
ok_eqv 1, 2;
ok_eqv 42, 'answer';
ok_eqv 1, \0;
ok_eqv 2, [];
ok_eqv {}, \&is_eqv;
not_ok_eqv 0, '0 but true';
{
    my @left;
    my @right;
    ok @left eqv @right, 'Empty arrays are equivalent';
    @left = ( 'A' );
    ok ! ( @left eqv @right ), 'Non-empty array not equivalent to empty array';
    @right = qw{ alpha beta };
    ok @left eqv @right, 'Non-empty arrays are equivalent';

}

=begin comment

# The following abandoned in place. See Eqv.xs for why.

# Warning
{
    my $warnings = warnings {
	ok_eqv 0, undef;
    };
    is @$warnings, 1, 'Got 1 warning'
	or diag map { "$_\n" } @$warnings;
    ok ! index( $warnings->[0],
	'use of uninitialized value' ),
	'Got correct warning';
}

{
    my $warnings = warnings {
	no warnings qw{ uninitialized };
	# NOTE can't use ok_eqv here because the eqv operation must be
	# in the scope of the 'no warnings ...';
	my ( $lhs, $rhs ) = ( 0 );
	ok $lhs eqv $rhs, title( TPLT_EQV_L_TRUE, $lhs, $rhs );
    };
    is @$warnings, 0,
	q/Got no warnings under "no warnings 'uninitialized';/
	or diag @$warnings;
}

=end comment

=cut

done_testing;

sub not_ok_eqv {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ! ( $lhs eqv $rhs ),
	title( TPLT_EQV_L_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub not_ok_EQV {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ! ( $lhs EQV $rhs ),
	title( TPLT_EQV_U_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_eqv {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( $lhs eqv $rhs,
	title( TPLT_EQV_L_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_EQV {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ( $lhs EQV $rhs ),
	title( TPLT_EQV_U_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

1;

# ex: set textwidth=72 :
