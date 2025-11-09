package main;

use 5.014;

use strict;
use warnings;

use utf8;

use Test2::V0;
use Syntax::Operator::Eqv qw{ :eqv };

BEGIN {
    plan skip_all => "No PL_infix_plugin"
	unless XS::Parse::Infix::HAVE_PL_INFIX_PLUGIN;
}

use lib qw{ inc };
use My::Module::Test qw{ title };

use constant TPLT_EQV_HI_TRUE	=> '%s <==> %s is true';
use constant TPLT_EQV_HI_FALSE	=> '%s <==> %s is false';
use constant TPLT_EQV_LO_TRUE	=> '%s eqv %s is true';
use constant TPLT_EQV_LO_FALSE	=> '%s eqv %s is false';

sub ok_eqv_hi;
sub ok_eqv_lo;
sub not_ok_eqv_hi;
sub not_ok_eqv_lo;

# Truth table
ok_eqv_hi 0, 0;
not_ok_eqv_hi 0, 1;
not_ok_eqv_hi 1, 0;
ok_eqv_hi 1, 1;
ok_eqv_lo 0, 0;
not_ok_eqv_lo 0, 1;
not_ok_eqv_lo 1, 0;
ok_eqv_lo 1, 1;

# Binding strength
ok 0 <==> 0 && 0, '&& binds more tightly than <==>';
ok( ! ( 0 <==> 1 and 0 ), 'and binds more loosely than <==>' );
ok( ( 0 eqv 0 and 0 ), 'and binds more tightly than eqv' );
#
# Other stuff
ok_eqv_hi 0, '';
ok_eqv_hi 1, 2;
ok_eqv_hi 42, 'answer';
ok_eqv_hi 1, \0;
ok_eqv_hi 2, [];
ok_eqv_hi {}, \&is_eqv;
not_ok_eqv_hi 0, '0 but true';
{
    my @left;
    my @right;
    ok @left <==> @right, 'Empty arrays are equivalent';
    @left = ( 'A' );
    ok ! ( @left <==> @right ), 'Non-empty array not equivalent to empty array';
    @right = qw{ alpha beta };
    ok @left <==> @right, 'Non-empty arrays are equivalent';

}

=begin comment

# The following abandoned in place. See Eqv.xs for why.

# Warning
{
    my $warnings = warnings {
	ok_eqv_hi 0, undef;
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
	# NOTE can't use ok_eqv_hi here because the <==> operation must be
	# in the scope of the 'no warnings ...';
	my ( $lhs, $rhs ) = ( 0 );
	ok $lhs <==> $rhs, title( TPLT_EQV_HI_TRUE, $lhs, $rhs );
    };
    is @$warnings, 0,
	q/Got no warnings under "no warnings 'uninitialized';/
	or diag @$warnings;
}

=end comment

=cut

done_testing;

sub not_ok_eqv_hi {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ! ( $lhs <==> $rhs ),
	title( TPLT_EQV_HI_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub not_ok_eqv_lo {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ! ( $lhs eqv $rhs ),
	title( TPLT_EQV_LO_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_eqv_hi {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( $lhs <==> $rhs,
	title( TPLT_EQV_HI_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_eqv_lo {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ( $lhs eqv $rhs ),
	title( TPLT_EQV_LO_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

1;

# ex: set textwidth=72 :
