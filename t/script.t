#!/usr/bin/perl

use strict;
use warnings;

use base qw(Test::Class);
use Test::More;

use lib 'lib';

BEGIN {
    $ENV{PERL5LIB} = 'lib';
    $ENV{STREAM_DIR} = 't/stream';
}

sub setup :Test(setup) {
    system('rm -rf tfiles') and die "rm failed: $!";
    system('mkdir tfiles') and die "mkdir failed: $!";
}

sub invalid :Test {
    ok(scalar(system('./bin/stream >/dev/null 2>/dev/null')), 'script exits with non-zero code when arguments are wrong');
}

sub lag :Test {
    my $result = qx(./bin/stream lag abc);
    is($result, "123\n", 'lag command');
}

sub human_lag :Test {
    my $result = qx(./bin/stream lag -h big_lag);
    is($result, "97.6K\n", 'lag command');
}

sub pump :Test(2) {
    my $result = qx(./bin/stream pump --limit=5 abc2def);
    is($result, "ok\n", 'pump command');

    use Streams;
    use Stream::File::Cursor;
    my $file = catalog->storage('def')->stream(Stream::File::Cursor->new('tfiles/pos'));
    is(scalar(@{ $file->read_chunk(100) }), 5, 'pump processed 5 items');
}

sub head :Test(3) {
    my $result = qx(./bin/stream head --limit=5 abc);
    is($result, "line1\nline2\nline3\nline4\nline5\n", 'head command');

    $result = qx(./bin/stream head complex);
    is($result, "{'a' => 'A'}\n{'b' => 'B'}\n", 'head command for structured stream');

    $result = qx(./bin/stream head --dump-indent complex);
my $expected = q/{
  'a' => 'A'
}

{
  'b' => 'B'
}

/;
    is($result, $expected, 'head command with --dump-indent option');
}

__PACKAGE__->new->runtests;
1;
