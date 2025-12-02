package My::Module::Test;

use 5.014;

use strict;
use warnings;

use Carp;
use Exporter qw{ import };
use Test2::V0;

our $VERSION = '0.000_003';

our @EXPORT_OK = qw{ false true };
our %EXPORT_TAGS = (
    all	=> \@EXPORT_OK,
    bool	=> [ qw{ false true } ],
);

no if $^V >= v5.20.0, feature => qw{ signatures };

sub false ($;$@) {
    my ( $bool, $name, @diag ) = @_;
    my $ctx = context;
    return $ctx->pass_and_release( $name ) unless $bool;
    return $ctx->fail_and_release( $name, @diag );
}

sub true ($;$@) {
    my ( $bool, $name, @diag ) = @_;
    my $ctx = context;
    return $ctx->pass_and_release( $name ) if $bool;
    return $ctx->fail_and_release( $name, @diag );
}

1;

__END__

=head1 NAME

My::Module::Test - Test support for Syntax::Operator::Eqv

=head1 SYNOPSIS

 use lib 'inc';
 use My::Module::Test qw{ :bool };

=head1 DESCRIPTION

This Perl module is B<private> to the C<Syntax-Operator-Eqv>
distribution. It may be modified or retracted without notice.
Documentation is solely for the convenience of the author.

This Perl module contains test support routines for the
C<Syntax-Operator-Eqv> distribution.

=head1 SUBROUTINE

This module provides the following subroutines. All are exportable, but
none are exported by default.

=head2 false

 false 0 == 1, '0 == 1 is false';

This subroutine implements a test that passes if its first argument is
Boolean false. The second argument is the test title, and the third and
subsequent are diagnostics to be emitted if the test fails.

=head2 true

 true 1 == 1, '1 == 1 is true';

This subroutine implements a test that passes if its first argument is
Boolean true. The second argument is the test title, and the third and
subsequent are diagnostics to be emitted if the test fails.

=head1 EXPORT TAGS

The following export tags are provided:

=head2 :all

This tag exports everything. At the moment it is equivalent to C<:bool>,
but this may not always be the case.

=head2 :bool

This tag exports L<false|/false> and L<true|/true>.

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
of the licenses in the files F<LICENSE-Artistic> and F<LICENSE-GNU>.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

# ex: set textwidth=72 :
