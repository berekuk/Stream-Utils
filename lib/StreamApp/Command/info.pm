package StreamApp::Command::info;

# ABSTRACT: show info for any stream from catalog

use strict;
use warnings;

use StreamApp -command;

use Stream::Utils 0.9.0 qw(catalog);

use StreamApp::Common;

=head1 SYNOPSIS

    stream info --in IN_STREAM_NAME
    stream info --pumper PUMPER_NAME

Get info about given entity from catalog (input or output stream, or other stream objects).

=cut

sub opt_spec {
    ['mode' => hidden => { one_of => [
        [ in    => 'input stream' ],
        [ out    => 'output stream' ],
        [ filter   => 'filter' ],
        [ pumper   => 'pumper' ],
        [ storage   => 'storage' ],
        [ cursor   => 'cursor' ],
    ] } ];
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    $self->usage_error("Object name expected") unless @$args == 1;
    $self->usage_error("not implemented yet") unless $opt->mode =~ /^(?:in|out|storage)$/;
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $name = shift @$args;

    my $common = StreamApp::Common->new;
    if ($opt->mode eq 'in') {
        my $in = catalog->in($name);
        $common->print_in($in);
    }
    elsif ($opt->mode eq 'out') {
        my $out = catalog->out($name);
        $common->print_out($out);
    }
    elsif ($opt->mode eq 'storage') {
        my $storage = catalog->storage($name);
        $common->print_storage($storage);
    }
    else {
        die "not implemented yet";
    }
}

sub abstract {
    "print info about given stream";
}

1;
