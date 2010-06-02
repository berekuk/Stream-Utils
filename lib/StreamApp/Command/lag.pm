package StreamApp::Command::lag;

use strict;
use warnings;

use StreamApp -command;
use Stream::Utils qw(catalog);

=head1 SYNOPSIS

    stream lag INPUT_STREAM

Shows lag of given stream if it supports lag method.

=cut

sub validate_args {
    my ($self, $opt, $args) = @_;
    @$args == 1 or $self->usage_error("Stream name expected") unless @$args == 1;
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $name = shift @$args;
    my $stream = catalog->in($name);
    unless ($stream->cap('lag')) {
        die "'$name' doesn't support lag() method";
    }
    print $stream->lag, "\n";
}

sub abstract {
    "show lag of given input stream";
}

=head1 AUTHOR

Vyacheslav Matjukhin <mmcleric@yandex-team.ru>

=cut

1;

