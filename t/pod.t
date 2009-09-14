#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
eval "use Test::Pod 1.00";
if ($@) {
    plan skip_all => "Test::Pod 1.00 required for testing POD";
}

plan tests => 1;
pod_file_ok('bin/stream');

