package StreamApp::Command::graph;

# ABSTRACT: graph command

use strict;
use warnings;

use StreamApp -command;

use Stream::Utils 0.8.0 qw(catalog);

use Graph::Easy;
use File::Basename;
use Yandex::Propagate::ServiceConfig;

=head1 SYNOPSIS

    stream graph

Show the graph of all streams.

=cut

sub opt_spec {
    [ 'format=s', "print each storage's info", { default => 'ascii' } ],
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    @$args == 0 or $self->usage_error("Didn't expected any args");
}

sub _slurp {
    my $self = shift;
    my ($file) = @_;

    open my $fh, '<', $file or die "Failed to open '$file': $!";
    return do { local $/; <$fh> }
}

sub pumpers {
    my $self = shift;

    my $pumper_dir = $ENV{PUMPER_DIR} || '/usr/bin';
    my @files = glob "$pumper_dir/*.pl"; # TODO - load all pumpers properly from catalog

    my @result;
    for my $file (@files) {
        my $content = $self->_slurp($file);
        next unless $content =~ /Yandex::Pumper/;
        my $script = require $file;
        my $in = $script->meta->get_attribute('in')->default;
        my $out = $script->meta->get_attribute('out')->default;

        push @result, { in => $in, out => $out, name => basename($file) };
    }
    return @result;
}


sub execute {
    my ($self, $opt, $args) = @_;

    my @in = catalog->list_in;
    my @out = catalog->list_out;

    my $graph = Graph::Easy->new;

    my @pumpers = $self->pumpers();

    for my $propagate (@{ Yandex::Propagate::ServiceConfig->new->local_configuration }) {
        push @pumpers, { in => $propagate->{in}, out => "$propagate->{out}\@$propagate->{target_hosts}", name => "propagate.$propagate->{name}" };
    }

    for my $pumper (@pumpers) {
        my ($storage, $client) = $pumper->{in} =~ /(.*)\[(.*)\]$/ or next;

        my $lag = eval { catalog->in($pumper->{in})->lag };
        my $edge = Graph::Easy::Edge->new(
            label => "[$client] ".$pumper->{name},
        );
        if ($lag and $lag > 1024 ** 2) {
            $edge->set_attribute(style => 'dashed');
            $edge->set_attribute(color => 'red');
        }
        # TODO - add lag to edge?
        $graph->add_edge($storage, $pumper->{out}.'', $edge);
    }

    my $print_method = "as_".$opt->format;
    binmode(STDOUT, ':utf8');
    print $graph->$print_method;
}

sub abstract {
    "Show the graph of all streams";
}

1;
