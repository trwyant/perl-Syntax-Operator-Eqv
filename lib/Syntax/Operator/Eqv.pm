package Syntax::Operator::Eqv;

use 5.014;

use strict;
use warnings;
use utf8;

use Carp;
use Encode ();
use XS::Parse::Infix 0.44;

use meta 0.003_002;
no warnings 'meta::experimental';	## no critic (ProhibitNoWarnings)

our $VERSION = '0.000_001';

require XSLoader;
XSLoader::load( __PACKAGE__, $VERSION );

use constant BOOL_EQV_UNI => "\N{U+224D}" x 2; # "\N{EQUIVALENT TO}"
use constant BOOL_IMP_UNI => "\N{U+21D2}" x 2; # "\N{RIGHTWARDS DOUBLE ARROW}"
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
    ];
    state $export_ok = [ qw{ equivalent implies } ];
    state $export = [];
    state $export_tags = {
	all	=> [ @{ $export_infix_ok }, @{ $export_ok } ],
	dflt	=> $export,
	eqv_op	=> [ qw{ (==) eqv } ],
	imp_op	=> [ qw{ ==>> imp } ],
	op	=> $export_infix_ok,
	wrapper	=> $export_ok,
    };

    my @syms;
    while ( @args ) {
	local $_ = shift @args;
	if ( ref ) {
	    push @syms, $_;
	} elsif ( s/ \A : //smx ) {
	    croak "'$_' is not a defined export tag"
		unless $export_tags->{$_};
	    croak "Export tag '$_' may not be followed by options"
		if ref $args[0] eq REF_HASH;
	    push @syms, @{ $export_tags->{$_} };
	} else {
	    push @syms, $_;
	}
    }

    my %i_ok = map { $_ => 1 } @{ $export_infix_ok };
    my %w_ok = map { $_ => 1 } grep { ! $i_ok{$_} } @{ $export_ok };

    unless ( @syms ) {
	@syms = XS::Parse::Infix::HAVE_PL_INFIX_PLUGIN ?
	    @{ $export } :
	    grep { ! $i_ok{$_} } @{ $export };
    }

    my @i_sym;	# Infix operators to import
    my @w_sym;	# Wraooer function symbols to import
    my @u_sym;	# Unknown symbols to croak on.
    while ( @syms ) {
	if ( ref $syms[0] ) {
	    shift @syms;
	} elsif ( $i_ok{$syms[0]} ) {
	    if ( XS::Parse::Infix::HAVE_PL_INFIX_PLUGIN ) {
		# NOTE that the infix operator symbols need to be
		# encoded utf-8 for non-ASCII symbols to work, because
		# that is what they are in the .xs file.
		push @i_sym, Encode::encode( 'UTF-8', shift @syms );
		if ( ref( $syms[0] ) eq REF_HASH ) {
		    my %opt = %{ shift @syms };	# Shallow clone
		    $opt{-as} = Encode::encode( 'UTF-8', $opt{-as} )
			if defined $opt{-as};
		    push @i_sym, \%opt;
		}
	    } elsif ( $on ) {
		croak 'Infix operators require at least Perl v5.38';
	    }
	} elsif ( $w_ok{$syms[0]} ) {
	    push @w_sym, shift @syms;
	    push @w_sym, shift @syms if ref( $syms[0] ) eq REF_HASH;
	} else {
	    push @u_sym, shift @syms;
	    shift @syms if ref $syms[0];
	}
    }

    $pkg->XS::Parse::Infix::apply_infix( $on, \@i_sym,
	map { Encode::encode( 'UTF-8', $_ ) } @{ $export_infix_ok } )
	if @i_sym;

    my $caller_pkg;
    while ( @w_sym ) {
	my $symbol = shift @w_sym;
	my %opt = ref( $w_sym[0] ) eq REF_HASH ? %{ shift @w_sym } : ();
	my $alias = delete( $opt{-as} ) // $symbol;
	croak 'Unrecognized import options ', join ', ', sort keys %opt
	    if keys %opt;
	$caller_pkg //= meta::package->get( $caller );
	$on ? $caller_pkg->add_symbol( "&$alias" => \&{$symbol} )
	    : $caller_pkg->remove_symbol( "&$alias" );
    }

    local $" = ', ';
    croak "Unrecognised import symbols @u_sym" if @u_sym;
    return;
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

B<Note> that the choice of C<(==)> as the spelling of this operator
means that if the left operand is a subroutine call you will probably
need to supply the parentheses around the argument list even if it takes
none. An example I encountered is correctly written C<undef() (==) 0>.
Just C<undef (==) 0> fails to parse.

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
operator. But its truth table is asymmetric around the main diagonal,
which meant that I could test whether I had reversed the right and left
operands in the F<.xs> code.

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

All operators and wrapper functions are exportable. Nothing is
exported by default. B<Note> that operator exports are lexical, but
wrapper function exports are global. Both can be explicitly removed
using

 no Syntax::Operator::Eqv ...;

B<Note> that infix operators are not supported before Perl v5.38. Any
attempt to import infix operators on an earlier Perl is a fatal error.

If you do not like the way any export is spelled, you can rename it by
following it with a hash reference of the form C<< { -as => 'newname' } >>.
For example,

 use Syncax::Operator::Eqv eqv { -as => 'is_equivalent_to' }

Validation of the new name, if any, is provided by the underlying
software. Non-ASCII values of C<-as> appear to require Perl v5.16.

In addition, export tags are supported. Tags may not be followed by a
hash reference. The following export tags are provided:

=head2 :all

Import everything,

=head2 :dflt

Import nothing.

=head2 :eqv_op

Import all logical equivalence operators.

=head2 :imp_op

Import all logical implication operators.

=head2 :op

Import all infix operators.

=head2 :wrapper

Import all wrapper functions.

=head1 UNICODE

All the functions and operators provided by this module have ASCII
names. Names outside the ASCII range can be obtained by the
C<< { -as => $name } >> mechanism described above under
L<EXPORTS|/EXPORTS>.

=head1 SEE ALSO

L<XS::Parse::Keyword|XS::Parse::Keyword> by Paul Evans, which provides
the interface to the operator plug-in system.

L<Syntax::Operator::Equ|Syntax::Operator::Equ> by Paul Evans, which I
consulted heavily while implementing this module.

L<Syntax::Operator::In|Syntax::Operator::In> by Paul Evans, which
implements an operator (C<'∈'> outside the ASCII range.

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
