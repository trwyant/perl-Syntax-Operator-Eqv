package My::Module::Test;

use 5.014;

use strict;
use warnings;

use Carp;
use Exporter qw{ import };
use Test2::V0;

our $VERSION = '0.000_001';

our @EXPORT_OK = qw{ false true quote title };

{
    local $@ = undef;
    eval {
	require Sub::Util;
	Sub::Util->VERSION( 1.40 );
	my $subname = Sub::Util->can( 'subname' )
	    or die 'Sub::Util::subname not found';
	*_my_subname = sub {
	    my $n = Sub::Util::subname( $_[0] );
	    return defined $n ? "sub $n { ... }" : 'sub { ... }';
	};
	1;
    } or *_my_subname = sub { 'sub { ... }' };
}

sub false {
    my ( $ok, @info ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( ! $ok, @info );
    $ctx->release();
    return $rslt;
}

sub true {
    my ( $ok, @info ) = @_;
    my $ctx = context;
    my $rslt = $ctx->ok( $ok, @info );
    $ctx->release();
    return $rslt;
}

sub quote {
    my @arg = @_;
    foreach ( @arg ) {
	if ( ! defined ) {
	    $_ = 'undef';
	} elsif ( my $ref = ref ) {
	    if ( $ref eq 'SCALAR' ) {
		$_ = '\\' . quote( $$_ );
	    } elsif ( $ref eq 'CODE' ) {
		$_ = _my_subname( $_ );
	    } else {
		$_ = {
		    ARRAY	=> '[]',
		    HASH	=> '{}',
		}->{ $ref } // "'$ref ref'";
	    }
	} elsif ( m/ [^0-9.+-] /smx ) {
	    s/ ( [\\'] ) /\\$1/smxg;
	    $_ = "'$_'";
	} elsif ( $_ eq '' ) {
	    $_ = q/''/;
	}
    }
    return wantarray ? @arg : $arg[0];
}

sub title {
    my ( $tplt, @argz ) = @_;
    return sprintf $tplt, quote( @argz );
}

1;

__END__

=head1 NAME

My::Module::Test - Test support for Syntax::Operator::Eqv

=head1 SYNOPSIS

 use lib 'inc';
 use My::Module::Test qw{ title };

=head1 DESCRIPTION

This Perl module is B<private> to the C<Syntax-Operator-Eqv>
distribution. It may be modified or retracted without notice.
Documentation is solely for the convenience of the author.

This Perl module contains test support routines for the
C<Syntax-Operator-Eqv> distribution.

=head1 METHODS

This module provides the following subroutines. All are exportable, but
none are exported by default.

=head2 quote

This subroutine quotes its arguments suitably for display in text that
resembles Perl code. If called in scalar context, only the first
argument is returned.

=head2 title

This subroutine formats a test title. It takes as arguments an
C<sprintf()> format, and the left-hand and right-hand operands being
tested.

The return is the result of an C<sprintf()> using the provided template,
and the subsequent arguments modified by the L<quote()|/quote> function.

=head1 SUPPORT

Support is by the author. Please file bug reports at
L<https://rt.cpan.org/Public/Dist/Display.html?Name=Syntax-Operator-Eqv>,
L<https://github.com/trwyant/perl-Syntax-Operator-Eqv/issues/>, or in
electronic mail to the author.

=head1 AUTHOR

Thomas R. Wyant, III F<wyant at cpan dot org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 by Thomas R. Wyant, III

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl 5.10.0. For more details, see the full text
of the licenses in the directory LICENSES.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

# ex: set textwidth=72 :
