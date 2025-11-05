#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "XSParseInfix.h"

static SV *compute_eqv( pTHX_ SV *lhs, SV *rhs ) {

    /*
     * SvTRUE should do this
    SvGETMAGIC( lhs );
    SvGETMAGIC( rhs );
     */

    /* TODO warn if either os undef. See
     * 'Warning and Dieing' in perldoc perlapi */
    /* FIXME This is really clunky. The only way I can think of to get
     * the operator/subroutine name is to pass it in, and I can't tell
     * whether the undef was literal, a variable, or an expression, so I
     * can't come satisfactorily close to what happens with '&&'. So I
     * think I'm going to abandon the code in place until I can figure
     * out whether the plugin system has support for this.
    if ( ! ( SvOK( lhs ) && SvOK( rhs ) ) ) {
	ck_warner(
	    packWARN( WARN_UNINITIALIZED ),
	    "use of uninitialized value" );
    }
     */

    bool lv = SvTRUEx( lhs );
    bool rv = SvTRUEx( rhs );

    return lv && rv || ! lv && ! rv ? &PL_sv_yes : &PL_sv_no;
}

/* NOTE that pp_eqv() and pp_EQV() do exactly the same thing. I need
 * them both to ensure that B::Deparse picks the right operator name,
 * because the eqv and EQV operators, though they do the same thing,
 * have different precedence. */

static OP *pp_eqv(pTHX) {
    dSP;
    dTARG;
    SV *lhs = TOPs;
    SV *rhs = TOPm1s;

    POPs;
    SETs( compute_eqv( aTHX_ lhs, rhs ) );
    RETURN;
}

static OP *pp_EQV(pTHX) {
    dSP;
    dTARG;
    SV *lhs = TOPs;
    SV *rhs = TOPm1s;

    POPs;
    SETs( compute_eqv( aTHX_ lhs, rhs ) );
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
