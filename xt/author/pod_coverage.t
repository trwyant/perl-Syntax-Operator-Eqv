package main;

use strict;
use warnings;

use Test2::Tools::LoadModule;

load_module_or_skip_all 'Test::Pod::Coverage', 1.00;

all_pod_coverage_ok( {
	also_private => [
	    qr{^[[:upper:]\d_]+$},
	    qr{^import_into$},
	    qr{^unimport_from$},
	    qr{^apply$},
	],
	coverage_class => 'Pod::Coverage::CountParents'
    },
);

1;

# ex: set textwidth=72 :
