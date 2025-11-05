package main;

use strict;
use warnings;

use Test2::V0;
use Test2::Plugin::BailOnFail;
use Test2::Tools::LoadModule 0.002;	# For all_moutles_tried_ok

load_module_ok 'Syntax::Operator::Eqv';

all_modules_tried_ok;

done_testing;

1;

# ex: set textwidth=72 :
