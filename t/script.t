#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

use lib 'lib';

$ENV{PERL5LIB} = 'lib';
$ENV{STREAM_DIR} = 't/stream';

ok(scalar(system('./bin/stream >/dev/null 2>/dev/null')), 'script exits with non-zero code when arguments are wrong');

my $result = qx(./bin/stream lag abc);
is($result, "123\n", 'lag command');


