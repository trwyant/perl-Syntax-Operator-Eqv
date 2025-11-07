package main;

use 5.014;

use strict;
use warnings;

use Test2::V0;
use Syntax::Operator::Eqv qw{ equivalent };

use lib qw{ inc };
use My::Module::Test qw{ title };

use constant TPLT_TRUE	=> 'equivalent( %s, %s ) is true';
use constant TPLT_FALSE	=> 'equivalent( %s, %s ) is false';

sub ok_eqv;
sub not_ok_eqv;

# Truth table
ok_eqv 0, 0;
not_ok_eqv 0, 1;
not_ok_eqv 1, 0;
ok_eqv 1, 1;

# Other stuff
ok_eqv 0, '';
ok_eqv 1, 2;
ok_eqv 42, 'answer';
ok_eqv 1, \0;
ok_eqv 2, [];
ok_eqv {}, \&equivalent;
not_ok_eqv 0, '0 but true';

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
	'Use of uninitialized value' ),
	'Got correct warning';
}

{
    my $warnings = warnings {
	no warnings qw{ uninitialized };
	# NOTE can't use ok_eqv here because the call to equivalent must be
	# in the scope of the 'no warnings ...';
	my ( $lhs, $rhs ) = ( 0 );
	ok equivalent( $lhs, $rhs ), title( TPLT_TRUE, $lhs, $rhs );
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
    my $rslt = $ctx->ok( ! equivalent( $lhs, $rhs ),
	title( TPLT_FALSE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

sub ok_eqv {
    my ( $lhs, $rhs ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( equivalent( $lhs, $rhs ),
	title( TPLT_TRUE, $lhs, $rhs ) );
    $ctx->release();
    return $rslt;
}

1;

# ex: set textwidth=72 :
