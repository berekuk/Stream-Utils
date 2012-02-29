package StreamApp::Command::lag;

# ABSTRACT: show lag of given input stream

use strict;
use warnings;

use StreamApp -command;
use Stream::Utils qw(catalog);

use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

=head1 SYNOPSIS

    stream lag INPUT_STREAM

Shows lag of given stream if it supports lag method.

=cut

sub opt_spec {
    ['h|human-readable', 'print lag in human readable format (e.g. 1K 234M 2G)'],
    ['a|all', 'print ALL the lags!'];
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    if ($opt->a) {
        @$args == 0 or $self->usage_error("-a mode doesn't understand parameters");
    }
    else {
        @$args == 1 or $self->usage_error("Stream name expected");
    }
}

sub humanize_lag {
    my $self = shift;
    my ($lag) = @_;

    my @letter = qw( K M G );
    my $next_letter = 0;
    while ($next_letter < @letter - 1 and $lag > 1024) {
        $lag = int($lag / 102.4) / 10;
        $next_letter++;
    }
    if ($next_letter) {
        $lag .= $letter[ $next_letter - 1 ];
    }
    return $lag;
}

sub print_lag {
    my $self = shift;
    my ($opt, $name) = @_;

    my $stream = catalog->in($name);
    unless ($stream->DOES('Stream::In::Role::Lag')) {
        die "'$name' doesn't support lag() method";
    }
    my $lag = $stream->lag;
    $lag = $self->humanize_lag($lag) if $opt->h;
    print $lag, "\n";
}

sub print_all_lags {
    my $self = shift;
    my ($opt) = @_;

    my @in_names = catalog->list_in();

    for my $name (catalog->list_out()) {
        my $storage = eval { catalog->out($name) };
        if ($@) {
            print RED "Failed to load '$name': $@";
            next;
        }
        next unless $storage->DOES('Stream::Storage');
        next unless $storage->DOES('Stream::Storage::Role::ClientList');
        push @in_names, map { "$name\[$_]" } $storage->client_names;
    }

    for my $name (@in_names) {
        my $in = eval { catalog->in($name) };
        if ($@) {
            print RED "Failed to load '$name': $@";
            next;
        }
        next unless $in->DOES('Stream::In::Role::Lag');
        my $lag = eval { $in->lag };
        if ($@) {
            print RED "Failed to get lag for '$name': $@";
            next;
        }
        $lag = $self->humanize_lag($lag) if $opt->h;
        print "$name\t$lag\n";
    }
}

sub execute {
    my ($self, $opt, $args) = @_;

    if ($opt->a) {
        $self->print_all_lags($opt);
    }
    else {
        $self->print_lag($opt, shift @$args);
    }
}

sub abstract {
    "show lag of given input stream";
}

1;
