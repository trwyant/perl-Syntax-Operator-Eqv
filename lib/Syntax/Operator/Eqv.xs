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
     * the operator/subroutine name is to pass it in, and even that
     * won't work in the presence of { -as => ... }. And I can't tell
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

static SV *compute_imp( pTHX_ SV *left, SV *right ) {
    bool lv = SvTRUEx( left );
    bool rv = SvTRUEx( right );
    return ! lv || rv ? &PL_sv_yes : &PL_sv_no;
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

/* NOTE that all the pp_eqv* subroutines do the same thing, as do all
 * the pp_imp* subroutines. This duplication is the only way I can
 * figure out to get B::Deparse to select the correct operator.
 */

static OP *pp_eqv_hi( pTHX ) {
    GET_POP_RL;
    SETs( compute_eqv( aTHX_ left, right ) );
    RETURN;
}

static OP *pp_eqv_lo( pTHX ) {
    GET_POP_RL;
    SETs( compute_eqv( aTHX_ left, right ) );
    RETURN;
}

static OP *pp_imp_hi( pTHX ) {
    GET_POP_RL;
    SETs( compute_imp( aTHX_ left, right ) );
    RETURN;
}

static OP *pp_imp_lo( pTHX ) {
    GET_POP_RL;
    SETs( compute_imp( aTHX_ left, right ) );
    RETURN;
}

static const struct XSParseInfixHooks hooks_eqv_hi = {
    .cls		= XPI_CLS_LOGICAL_OR_MISC,
    .wrapper_func_name	= "Syntax::Operator::Eqv::equivalent",
    .ppaddr		= &pp_eqv_hi,
};

static const struct XSParseInfixHooks hooks_eqv_lo = {
    .cls		= XPI_CLS_LOGICAL_OR_LOW_MISC,
    .ppaddr		= &pp_eqv_lo,
};

static const struct XSParseInfixHooks hooks_imp_hi = {
    .cls		= XPI_CLS_LOGICAL_OR_MISC,
    .wrapper_func_name	= "Syntax::Operator::Eqv::implies",
    .ppaddr		= &pp_imp_hi,
};

static const struct XSParseInfixHooks hooks_imp_lo = {
    .cls		= XPI_CLS_LOGICAL_OR_MISC,
    .ppaddr		= &pp_imp_lo,
};

MODULE = Syntax::Operator::Eqv	PACKAGE = Syntax::Operator::Eqv

BOOT:
    boot_xs_parse_infix( 0.44 );

    register_xs_parse_infix( "Syntax::Operator::Eqv::(==)",
	&hooks_eqv_hi, NULL );
    register_xs_parse_infix( "Syntax::Operator::Eqv::eqv",
	&hooks_eqv_lo, NULL );
    register_xs_parse_infix( "Syntax::Operator::Eqv::==>>",
	&hooks_imp_hi, NULL );
    register_xs_parse_infix( "Syntax::Operator::Eqv::imp",
	&hooks_imp_lo, NULL );
