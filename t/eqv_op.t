package main;

use 5.014;

use strict;
use warnings;
use open qw{ :std :encoding(utf-8) };
use utf8;

use Test2::V0;
use XS::Parse::Infix;

BEGIN {
    plan skip_all => "No PL_infix_plugin"
	unless XS::Parse::Infix::HAVE_PL_INFIX_PLUGIN;
}

use Syntax::Operator::Eqv ':eqv', '(==)' => { -as => '≍≍' };

use lib qw{ inc };
use My::Module::Test qw{ :bool };


# Truth table
true  0 (==) 0, '0 (==) 0 is true';
false 0 (==) 1, '0 (==) 1 is false';
false 1 (==) 0, '1 (==) 0 is false';
true  1 (==) 1, '1 (==) 1 is true';

true  0 ≍≍ 0, '0 ≍≍ 0 is true';
false 0 ≍≍ 1, '0 ≍≍ 1 is false';
false 1 ≍≍ 0, '1 ≍≍ 0 is false';
true  1 ≍≍ 1, '1 ≍≍ 1 is true';

true  +( 0 eqv 0 ), '0 eqv 0 is true';
false +( 0 eqv 1 ), '0 eqv 1 is false';
false +( 1 eqv 0 ), '1 eqv 0 is false';
true  +( 1 eqv 1 ), '1 eqv 1 is true';

# Binding strength
true  0 (==) 0 && 0, '&& binds more tightly than (==)';
false +( 0 (==) 1 and 0 ), 'and binds more loosely than (==)';
true  +( 0 eqv 0 and 0 ), 'and binds more tightly than eqv';
#
# Other stuff
true  0 (==) '', '0 (==) \'\' is true';
true  1 (==) 2, '1 (==) 2 is true';
true  42 (==) 'answer', '42 (==) \'answer\' is true';
true  1 (==) \0, '1 (==) \0 is true';
true  2 (==) [], '2 (==) [] is true';
true  {} (==) \&is_eqv, '{} (==) \&is_eqv is true';
false 0 (==) '0 but true', '0 (==) \'0 but true\' is false';
{
    my @left;
    my @right;
    true  @left (==) @right, 'Empty arrays are equivalent';
    @left = ( 'A' );
    false @left (==) @right, 'Non-empty array not equivalent to empty array';
    @right = qw{ alpha beta };
    true  @left (==) @right, 'Non-empty arrays are equivalent';

}

done_testing;

1;

# ex: set textwidth=72 :
