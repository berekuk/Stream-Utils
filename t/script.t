#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use lib 'lib';

BEGIN {
    $ENV{PERL5LIB} = 'lib';
    $ENV{STREAM_DIR} = 't/stream';
}
system('rm -rf tfiles') and die "rm failed: $!";
system('mkdir tfiles') and die "mkdir failed: $!";

ok(scalar(system('./bin/stream >/dev/null 2>/dev/null')), 'script exits with non-zero code when arguments are wrong');

{
    my $result = qx(./bin/stream lag abc);
    is($result, "123\n", 'lag command');
}

{
    my $result = qx(./bin/stream pump --limit=5 abc2def);
    is($result, "ok\n", 'pump command');

    use Streams;
    use Stream::File::Cursor;
    my $file = catalog->storage('def')->stream(Stream::File::Cursor->new('tfiles/pos'));
    is(scalar(@{ $file->read_chunk(100) }), 5, 'pump processed 5 items');
}

