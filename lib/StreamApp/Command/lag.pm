package StreamApp::Command::lag;

use strict;
use warnings;

use StreamApp -command;
use Stream::Utils qw(catalog);

=head1 SYNOPSIS

    stream lag INPUT_STREAM

Shows lag of given stream if it supports lag method.

=cut

sub opt_spec {
    ['h|human-readable', 'print lag in human readable format (e.g. 1K 234M 2G)'];
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    @$args == 1 or $self->usage_error("Stream name expected") unless @$args == 1;
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $name = shift @$args;
    my $stream = catalog->in($name);
    unless ($stream->does('Stream::In::Role::Lag')) {
        die "'$name' doesn't support lag() method";
    }
    my $lag = $stream->lag;
    if ($opt->h) {
        my @letter = qw( K M G );
        my $next_letter = 0;
        while ($next_letter < @letter - 1 and $lag > 1024) {
            $lag = int($lag / 102.4) / 10;
            $next_letter++;
        }
        if ($next_letter) {
            $lag .= $letter[ $next_letter - 1 ];
        }
    }
    print $lag, "\n";
}

sub abstract {
    "show lag of given input stream";
}

1;
