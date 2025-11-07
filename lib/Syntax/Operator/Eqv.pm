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

use constant REF_HASH	=> ref {};

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
    shift->apply( 1, @_ );
    return;
}

sub unimport_from {			## no critic (RequireArgUnpacking)
    shift->apply( 0, @_ );
    return;
}

my @all_infix = qw{ <==> eqv ==>> imp };

sub apply {
    my ( $pkg, $on, $caller, @syms ) = @_;
    # state @all_infix = qw( <==> ≍ ); # ≍ is EQUIVALENT TO, U+224D
    @syms or @syms = @all_infix;
    $pkg->XS::Parse::Infix::apply_infix( $on, \@syms, @all_infix );

    my $caller_pkg;
    my %export_ok = map { $_ => 1 } qw{ equivalent implies };
    my @unrecognized;
    while ( @syms ) {
	my $symbol = shift @syms;
	my %opt;
	%opt = %{ shift @syms } if ref( $syms[0] ) eq REF_HASH;
	my $alias = delete( $opt{ '-as' } ) // $symbol;
	croak 'Unrecognized import options ', join ', ', sort keys %opt
	    if keys %opt;
	if ( $export_ok{$symbol} ) {
	    $caller_pkg //= meta::package->get( $caller );
	    $on ? $caller_pkg->add_symbol( "&$alias" => \&{$symbol} )
		: $caller_pkg->remove_symbol( "&$alias" );
	} else {
	    push @unrecognized, $symbol;
	}
    }
    local $" = ', ';
    croak "Unrecognised import symbols @unrecognized" if @unrecognized;
    return;
}

1;

__END__

=head1 NAME

Syntax::Operator::Eqv - Implement infix Boolean equivalence and implication operators

=head1 SYNOPSIS

 use Syntax::Operator::Eqv
 
 say '$x and $y are either both true or both false' if $x <==> $y;
 say 'Either $x is false or $y is true' if $x imp $y;

=head1 DESCRIPTION

This Perl module implements two infix Boolean operators, logical
equivalence and logical implication, which I have previously encountered
only in Algol 60.

In addition this module provides wrapper functions for the operators.

B<Note> that while this module can be installed as far back as Perl
v5.14, the infix operators can not be used until Perl v5.38.

=head1 OPERATORS

All operators are imported by default. If you do not want all of them,
you can specify the ones you do want in the import list. If you do not
like the way I have spelled an operator name you can import it under the
name you prefer by following the original operator name in the import
list with a reference to a hash containing key C<'-as'> whose value is
your preferred name. For example, after

 use Syntax::Operator::Equ '<==>' => { -as => '(=)' };

the Perl compiler will recognize C<'(=)'> as the high-precedence
equivalence operator, not '<==>'.

Operator names are imported lexically. If the above example is done
inside a block, the name of the operator will revert to C<'<==>'> on
block exit.

The following operators are available:

=head2 <==>

This Boolean operator computes logical equivalence.

Truth table:

        Right
       operand
   o
   p    | T | F
 L e  --+---+---
 e r  T | T | F
 f a  --+---+---
 t n  F | F | T
   d

That is, the operator returns a true value if its operands are both true
or both false, and a false value otherwise.

This operator has the same precedence as the Boolean or operator
C<'||'>. In Algol it has a lower precedence than 'or', but as far as I
can tell the Perl operator plug-in mechanism does not allow the addition
of new binding strengths.

=head2 eqv

This Boolean operator performs the same function as L<< <==>|/<==> >>,
but has a lower precedence.

This operator has the same precedence as C<'or'>.

=head2 ==>>

This Boolean operator computes logical implication.

Truth table:

        Right
       operand
   o
   p    | T | F
 L e  --+---+---
 e r  T | T | F
 f a  --+---+---
 t n  F | T | T
   d

That is, the operator returns a true value if its left operand is false
or its right operand is true. This behavior follows from the fact that a
false proposition implies any proposition.

This operator has the same precedence as the Boolean or operator
C<'||'>. In Algol it has a lower precedence than logical equivalence.

=head2 imp

This Boolean operator performs the same function as L<< ==>>|/==>> >>,
but has a lower precedence.

This operator has the same precedence as C<'or'>.

=head1 SUBROUTINES

In addition to infix operators, this package provides equivalent wrapper
functions. These must be explicitly imported. Under suitable conditions
(meaning that the operands are not too complex) the wrapper functions
can be inlined.

You can specify a different name for the wrapper function when you
import it, using the same mechanism as for infix operators.

B<Unlike> the infix operators, wrapper function names are imported into
your name space. For the moment.

The following wrapper functions are available:

=head2 equivalent

 say '$x and $y are either both true or both false'
   if equivalent( $x, $y );

This function wraps L<< <==>|/<==> >> and performs the same computation.

=head2 implies

 say '$x imples $y'
   if implies( $x, $y );

This function wraps L<< ==>>|/==>> >> and performs the same computation.

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
