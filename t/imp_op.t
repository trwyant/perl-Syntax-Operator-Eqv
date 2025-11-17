package main;

use 5.014;

use strict;
use warnings;

use utf8;

use Test2::V0;
use XS::Parse::Infix;

BEGIN {
    plan skip_all => "No PL_infix_plugin"
	unless XS::Parse::Infix::HAVE_PL_INFIX_PLUGIN;
}

use Syntax::Operator::Eqv ':imp', '==>>' => { -as => '⇒⇒' };

use lib qw{ inc };
use My::Module::Test qw{ :bool };

# Truth table
true  0 ==>> 0, '0 ==>> 0 is true';
true  0 ==>> 1, '0 ==>> 1 is true';
false 1 ==>> 0, '1 ==>> 0 is false';
true  1 ==>> 1, '1 ==>> 1 is true';

true  0 ⇒⇒ 0, '0 ⇒⇒ 0 is true';
true  0 ⇒⇒ 1, '0 ⇒⇒ 1 is true';
false 1 ⇒⇒ 0, '1 ⇒⇒ 0 is false';
true  1 ⇒⇒ 1, '1 ⇒⇒ 1 is true';

true  +( 0 imp 0 ), '0 imp 0 is true';
true  +( 0 imp 1 ), '0 imp 1 is true';
false +( 1 imp 0 ), '1 imp 0 is false';
true  +( 1 imp 1 ), '1 imp 1 is true';

done_testing;

1;

# ex: set textwidth=72 :
