#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "XSParseInfix.h"

static SV *compute_eqv( pTHX_ SV *left, SV *right ) {

    /*
     * SvTRUE should do this
    SvGETMAGIC( left );
    SvGETMAGIC( right );
     */

    /* TODO warn if either os undef. See
     * 'Warning and Dieing' in perldoc perlapi */
    /* FIXME This is really clunky. The only way I can think of to get
     * the operator/subroutine name is to pass it in, and I can't tell
     * whether the undef was literal, a variable, or an expression, so I
     * can't come satisfactorily close to what happens with '&&'. So I
     * think I'm going to abandon the code in place until I can figure
     * out whether the plugin system has support for this.
    if ( ! ( SvOK( left ) && SvOK( right ) ) ) {
	ck_warner(
	    packWARN( WARN_UNINITIALIZED ),
	    "use of uninitialized value" );
    }
     */

    bool lv = SvTRUEx( left );
    bool rv = SvTRUEx( right );

    return lv && rv || ! lv && ! rv ? &PL_sv_yes : &PL_sv_no;
}

/* Get the right and left operands, popping the left one off the stack.
 * The right operand is left on the stack, to be replaced by the result
 * of the operation. This is equivalent to 'dSP' followed by
 * 'dPOPTOPssrl' in pp.h, but the latter is undocumented, though
 * available.
 * NOTE that Syntax::Operator::Equ.xs has a 'dTARG;' after 'dSP;', but
 * this expands to 'SV *targ', which is unused (on my Perl anyway) and
 * undocumented. I suspect that it is only needed if you use any of the
 * TARG macros, and that if you did you might prefer 'dTARGET'. */
#define GET_POP_RL \
    dSP; \
    SV *right = POPs; \
    SV *left  = TOPs

/* NOTE that pp_eqv() and pp_EQV() do exactly the same thing. I need
 * them both to ensure that B::Deparse picks the right operator name,
 * because the eqv and EQV operators, though they do the same thing,
 * have different precedence. */

static OP *pp_eqv(pTHX) {
    GET_POP_RL;
    SETs( compute_eqv( aTHX_ left, right ) );
    RETURN;
}

static OP *pp_EQV(pTHX) {
    GET_POP_RL;
    SETs( compute_eqv( aTHX_ left, right ) );
    RETURN;
}


static const struct XSParseInfixHooks hooks_eqv = {
    .cls		= XPI_CLS_LOGICAL_OR_MISC,
    .wrapper_func_name	= "Syntax::Operator::Eqv::is_eqv",
    .ppaddr		= &pp_eqv,
};

static const struct XSParseInfixHooks hooks_EQV = {
    .cls		= XPI_CLS_LOGICAL_OR_LOW_MISC,
    .ppaddr		= &pp_EQV,
};

MODULE = Syntax::Operator::Eqv	PACKAGE = Syntax::Operator::Eqv

BOOT:
    boot_xs_parse_infix( 0.44 );

    register_xs_parse_infix( "Syntax::Operator::Eqv::eqv", &hooks_eqv, NULL );
    register_xs_parse_infix( "Syntax::Operator::Eqv::EQV", &hooks_EQV, NULL );
