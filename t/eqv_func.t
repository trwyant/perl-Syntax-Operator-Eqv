package main;

use 5.014;

use strict;
use warnings;

use utf8;

use Test2::V0;
use Syntax::Operator::Eqv qw{ equivalent },
    equivalent => { -as => 'Φυβαρ' };

use lib qw{ inc };
use My::Module::Test qw{ :bool };

# Truth table
true  equivalent( 0, 0 ), 'equivalent( 0, 0 ) is true';
false equivalent( 0, 1 ), 'equivalent( 0, 1 ) is false';
false equivalent( 1, 0 ), 'equivalent( 1, 0 ) is false';
true  equivalent( 1, 1 ), 'equivalent( 1, 1 ) is true';

SKIP: {
    skip 'Unicode wrapper names require Perl v5.16 or above', 4 if $^V < v5.16;
    true  Φυβαρ( 0, 0 ), 'Φυβαρ( 0, 0 ) is true';
    false Φυβαρ( 0, 1 ), 'Φυβαρ( 0, 1 ) is false';
    false Φυβαρ( 1, 0 ), 'Φυβαρ( 1, 0 ) is false';
    true  Φυβαρ( 1, 1 ), 'Φυβαρ( 1, 1 ) is true';
}

# Other stuff
true  equivalent( 0, '' ), 'equivalent( 0, \'\' ) is true';
true  equivalent( 1, 2 ), 'equivalent( 1, 2 ) is true';
true  equivalent( 42, 'answer' ), 'equivalent( 42, \'answer\' ) is true';
true  equivalent( 1, \0 ), 'equivalent( 1, \\0 ) is true';
true  equivalent( 2, [] ), 'equivalent( 2, [] ) is true';
true  equivalent( {}, \&equivalent ), 'equivalent( {}, \&equivalent ) is true';
false equivalent( 0, '0 but true' ), 'equivalent( 0, \'0 but true\' ) is false';

done_testing;

1;

# ex: set textwidth=72 :
