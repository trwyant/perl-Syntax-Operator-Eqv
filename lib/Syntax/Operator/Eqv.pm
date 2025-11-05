package Syntax::Operator::Eqv;

use 5.014;

use strict;
use warnings;
use utf8;

use Carp;

use meta 0.003_002;
no warnings 'meta::experimental';	## no critic (ProhibitNoWarnings)

our $VERSION = '0.000_001';

require XSLoader;
XSLoader::load( __PACKAGE__, $VERSION );

sub import {				## no critic (RequireArgUnpacking)
    my $pkg = shift;
    my $caller = caller;
    $pkg->import_into( $caller, @_ );
    return;
}

sub unimport {				## no critic (RequireArgUnpacking)
    my $pkg = shift;
    my $caller = caller;
    $pkg->unimport_from( $caller, @_ );
    return;
}

sub import_into {			## no critic (RequireArgUnpacking)
    shift->__apply( 1, @_ );
    return;
}

sub unimport_from {			## no critic (RequireArgUnpacking)
    shift->__apply( 0, @_ );
    return;
}

my @all_infix = qw{ eqv EQV };

sub __apply {
    my ( $pkg, $on, $caller, @syms ) = @_;
    # state @all_infix = qw( eqv ≍ ); # ≍ is EQUIVALENT TO, U+224D
    @syms or @syms = @all_infix;
    $pkg->XS::Parse::Infix::apply_infix( $on, \@syms, @all_infix );
    my %syms = map { $_ => 1 } @syms;
    my $caller_pkg;
    foreach ( qw( is_eqv ) ) {
	next unless delete $syms{$_};
	$caller_pkg //= meta::package->get( $caller );
	$on ? $caller_pkg->add_symbol( '&'.$_ => \&{$_} )
	    : $caller_pkg->remove_symbol( '&'.$_ );
    }
    croak "Unrecognised import symbols @{[ sort keys %syms ]}" if keys %syms;
    return;
}

1;

__END__

=head1 NAME

Syntax::Operator::Eqv - Implement infix Boolean equivalence operator

=head1 SYNOPSIS

 use Syntax::Operator::Eqv
 
 say '$x and $y are either both true or both false' if $x eqv $y;

=head1 DESCRIPTION

This Perl module implements an infix Boolean equivalence operator, which
returns a true value if the operands are either both true or both false.

=head1 OPERATORS

=head2 eqv

This Boolean operator evaluates to a true value if its operands are
either both true or both false. It is imported by default. See
L<is_eqv()|/is_eqv>, below, for the equivalent function.

The default spelling of this operator is C<'eqv'>. If you would prefer
a different spelling, you can do an explicit import:

 use Syntax::Operator::Eqv eqv => { -as => 'equivalent_to' };

This operator binds equivalently to C<'||'>.

This operator is exported by default.

=head2 EQV

This Boolean operator performs the same function as L<eqv|/eqv>, but
binds more loosely.

This operator binds equivalently to C<'or'>.

This operator is exported by default.

=head1 SUBROUTINES

The following subroutines are exportable on request.

=head2 is_eqv

 say '$x and $y are either both true or both false'
   if is_eqv( $x, $y );

This subroutine returns a true value if its operands are either both
true or both false. It is equivalent to

 sub is_eqv( $x, $y ) { $x && $y || ! $x && ! $y }

B<Note> that this subroutine does B<not> provide scalar context to its
arguments. If you want to test the occupancy of an array, for instance,
you must use C<scalar()> explicitly:

 if ( is_eqv( $empty_p, scalar @array ) ) { ... }

This subroutine is exportable, but it is not exported by default.

=head1 METHODS

=head2 import

This static method imports symbols into the caller's name space. It is
called implicitly by C<use Syntax::Operator::Eqv;>, and would normally
not be called by the user.

=head2 unimport

This static method removes symbols from the caller's name space. It is
called implicitly by C<no Syntax::Operator::Eqv;>, and would normally
not be called by the user.

=head2 import_into

This static method imports symbols into the name space specified by the
first argument. Subsequent arguments are the symbols to import.

=head2 unimport_from

This static method removes symbols from the name space specified by the
first argument. Subsequent arguments are the symbols to remove.

=head1 MOTIVATION

In addition to the usual Boolean operators, Algol 60 had a couple
unconventional ones: C<eqv> and C<imp>. These were logical equivalence
and logical implication respectively.

In terms of the traditional Boolean operators, C<X eqv Y> was C<X && Y
|| ! X && ! Y>. That is, it evaluated true if the operands were both
true or both false. I remember finding this useful, and missed it in
other languages.

On the other hand, C<X imp Y> was C<! X || Y>. That is, it was true
unless the left operand was true and the right operand false. I do not
recall having much use for this.

At some point I realized that pluggable infix operators could give me
C<eqv> in Perl -- plus I had an excuse to play with a new toy.

=head1 SEE ALSO

L<XS::Parse::Keyword|XS::Parse::Keyword>

L<Syntax::Operator::Equ|Syntax::Operator::Equ>

L<EXTENDED ALGOL REFERENCE MANUAL for the Burroughs B5000|https://dn790001.ca.archive.org/0/items/bitsavers_burroughsB12B5000ExtendedAlgolReferenceManualwupd1_4777852/5000-21012_B5000_Extended_Algol_Reference_Manual_w_upd_196308.pdf>. See page 27 (29 in the sidebar) for Boolean operators and their precedence.

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
