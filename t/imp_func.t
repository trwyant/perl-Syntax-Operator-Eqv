package main;

use 5.014;

use strict;
use warnings;

use Test2::V0;
use Syntax::Operator::Eqv qw{ implies };

use lib qw{ inc };
use My::Module::Test qw{ :bool };

# Truth table
true  implies( 0, 0 ), 'implies( 0, 0 ) is true';
true  implies( 0, 1 ), 'implies( 0, 1 ) is true';
false implies( 1, 0 ), 'implies( 1, 0 ) is false';
true  implies( 1, 1 ), 'implies( 1, 1 ) is true';

done_testing;

1;

# ex: set textwidth=72 :
