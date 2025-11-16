package Syntax::Operator::Eqv;

use 5.014;

use strict;
use warnings;
use utf8;

use Carp;
use Encode ();

use meta 0.003_002;
no warnings 'meta::experimental';	## no critic (ProhibitNoWarnings)

our $VERSION = '0.000_001';

require XSLoader;
XSLoader::load( __PACKAGE__, $VERSION );

use constant BOOL_EQV_UNI => "\N{U+224D}" x 2;	# "\N{EQUIVALENT TO}"
use constant BOOL_IMP_UNI => "\N{U+21D2}" x 2;	# "\N{RIGHTWARDS DOUBLE ARROW"
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

sub apply {
    my ( $pkg, $on, $caller, @args ) = @_;

    state $export_infix_ok = [
	qw{ (==) eqv ==>> imp },
	BOOL_EQV_UNI,
	BOOL_IMP_UNI,
    ];
    state $export_ok = [ qw{ equivalent implies } ];
    state $export = [ grep { $_ !~ m/ [^[:ascii:]] /smx } @{
	$export_infix_ok } ];
    state $export_tags = {
	all	=> [ @{ $export_infix_ok }, @{ $export_ok } ],
	dflt	=> $export,
	eqv	=> [ qw{ (==) eqv equivalent } ],
	imp	=> [ qw{ ==>> imp implies } ],
	infix	=> $export_infix_ok,
	unicode	=> [ BOOL_EQV_UNI, BOOL_IMP_UNI ],
	wrapper	=> $export_ok,
    };

    my @syms;
    {
	my %have;
	while ( @args ) {
	    local $_ = shift @args;
	    if ( s/ \A : //smx ) {
		croak "'$_' is not a defined export tag"
		    unless $export_tags->{$_};
		croak "Export tag '$_' may not be followed by options"
		    if ref $args[0] eq REF_HASH;
		foreach ( @{ $export_tags->{$_} } ) {
		    push @syms, $_ unless $have{$_}++;
		}
	    } else {
		push @syms, $_ unless $have{$_}++;
		push @syms, shift @args if ref( $args[0] ) eq REF_HASH;
	    }
	}
    }
    @syms = @{ $export } unless @syms;

    # FIXME At the moment the symbols need to be encoded utf-8, because
    # that is what the .xs file has.
    @syms = _map_args( @syms );
    state $export_infix_ok_encoded = [ _map_args( @{ $export_infix_ok } ) ];

    $pkg->XS::Parse::Infix::apply_infix( $on, \@syms,
	@{ $export_infix_ok_encoded } );

    my $caller_pkg;
    my %xok = map { $_ => 1 } _map_args( @{ $export_ok } );
    my @unrecognized;
    while ( @syms ) {
	my $symbol = shift @syms;
	my %opt;
	%opt = %{ shift @syms } if ref( $syms[0] ) eq REF_HASH;
	my $alias = delete( $opt{ '-as' } ) // $symbol;
	croak 'Unrecognized import options ', join ', ', sort keys %opt
	    if keys %opt;
	if ( $xok{$symbol} ) {
	    $caller_pkg //= meta::package->get( $caller );
	    $on ? $caller_pkg->add_symbol( "&$alias" => \&{$symbol} )
		: $caller_pkg->remove_symbol( "&$alias" );
	} else {
	    # FIXME because we encoded the symbols above, we have to
	    # decode them now.
	    push @unrecognized, Encode::decode( 'UTF-8', $symbol );
	}
    }
    local $" = ', ';
    croak "Unrecognised import symbols @unrecognized" if @unrecognized;
    return;
}

sub _map_args {
    my @arg = @_;
    my @rslt;
    foreach ( @arg ) {
	if ( ref ) {
	    my %opt = %{ $_ };	# Shallow clone
	    push @rslt, \%opt;
	    $opt{-as} = Encode::encode( 'UTF-8', $_->{-as} );
	} else {
	    push @rslt, Encode::encode( 'UTF-8', $_ );
	}
    }
    return @rslt;
}

1;

__END__

=encoding utf-8

=head1 NAME

Syntax::Operator::Eqv - Implement infix Boolean equivalence and implication operators

=head1 SYNOPSIS

 use Syntax::Operator::Eqv
 
 say '$x and $y are either both true or both false' if $x (==) $y;
 say 'Either $x is false or $y is true' if $x ==>> $y;

=head1 DESCRIPTION

This Perl module implements two infix Boolean operators, logical
equivalence and logical implication, which I have previously encountered
only in Algol 60.

In addition this module provides wrapper functions for the operators.

B<Note> that while this module can be installed as far back as Perl
v5.14, the infix operators can not be used until Perl v5.38.

=head1 OPERATORS

The following operators are available:

=head2 (==)

This Boolean operator computes logical equivalence.

Truth table:

        Right
   o   operand
   p
 L e    | T | F
 e r  --+---+---
 f a  T | T | F
 t n  --+---+---
   d  F | F | T

That is, the operator returns a true value if its operands are both true
or both false, and a false value otherwise.

This operator has the same precedence as the Boolean or operator
C<'||'>. In Algol it has a lower precedence than 'or', but as far as I
can tell the Perl operator plug-in mechanism does not allow the addition
of new binding strengths.

=head2 ≍≍

This is just a different spelling of L<(==)|/(==)>. It is 
C<"\N{U+224D}" x 2>, or equivalently C<"\N{EQUIVALENT TO}" x 2>.

use constant BOOL_IMP_UNI => "\N{U+21D2}" x 2;	# "\N{RIGHTWARDS DOUBLE ARROW"

=head2 eqv

This Boolean operator performs the same function as L<< (==)|/(==) >>,
but has a lower precedence.

This operator has the same precedence as C<'or'>.

=head2 ==>>

This Boolean operator computes logical implication.

Truth table:

        Right
   o   operand
   p
 L e    | T | F
 e r  --+---+---
 f a  T | T | F
 t n  --+---+---
   d  F | T | T

That is, the operator returns a true value if its left operand is false
or its right operand is true. This behavior follows from the fact that a
false proposition implies any proposition.

This operator has the same precedence as the Boolean or operator
C<'||'>. In Algol it has a lower precedence than logical equivalence.

I admit that I had not originally anticipated implementing this
operator. But its asymmetric truth table meant that I could test whether
I had reversed the right and left operands in the F<.xs> code.

=head2 ⇒⇒

This is just a different spelling of L<<< ==>>|/==>> >>>>. It is 
C<"\N{U+2102}" x 2>, or equivalently C<"\N{RIGHTWARDS DOUBLE ARROW}" x 2>.

=head2 imp

This Boolean operator performs the same function as L<< ==>>|/==>> >>,
but has a lower precedence.

This operator has the same precedence as C<'or'>.

=head1 SUBROUTINES

In addition to infix operators, this package provides equivalent wrapper
functions. Under suitable conditions (meaning that the operands are not
too complex) the wrapper functions can be inlined.

The following wrapper functions are available:

=head2 equivalent

 say '$x and $y are either both true or both false'
   if equivalent( $x, $y );

This function wraps L<< (==)|/(==) >> and performs the same computation.

=head2 implies

 say '$x imples $y'
   if implies( $x, $y );

This function wraps L<< ==>>|/==>> >> and performs the same computation.

=head1 EXPORTS

All operators and wrapper functions are exportable. The operators are
exported by default. B<Note> that operator exports are lexical, but
wrapper function exports are global. Both can be explicitly removed
using

 no Syntax::Operator::Eqv ...;

If you do not like the way any export is spelled, you can rename it by
following it with a hash reference of the form C<< { -as => 'newname' } >>.
For example,

 use Syncax::Operator::Eqv eqv { -as => 'is_equivalent_to' }

In addition, export tags are supported. Tags may not be followed by a
hash reference. The supported export tags are:

=head2 :all

Import everything,

=head2 :dflt

Import whatever is exported by default.

=head2 :eqv

Import all logical equivalence operators, plus the wrapper function.

=head2 :imp

Import all logical implication operators, plus the wrapper function.

=head2 :infix

Import all infix operators.

=head2 :wrapper

Import all wrapper functions.

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
