#!/usr/bin/env perl

use Moose;
with 'Yandex::Pumper';

has '+in' => (
    default => 'wd[blah]',
);

has '+out' => (
    default => 'def',
);

__PACKAGE__->run_script;
