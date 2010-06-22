package StreamApp::Command::info;

use strict;
use warnings;

use StreamApp -command;

use Stream::Utils 0.8.0 qw(catalog);

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
    $self->usage_error("not implemented yet") unless $opt->mode =~ /^in|out$/;
}

sub print_caps {
    my $obj = shift;
    my $caps = $obj->caps;
    if (%$caps) {
        print "caps: ";
        print join ",", map { "$_ = $caps->{$_}" } keys %{ $caps };
        print "\n";
    }
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $name = shift @$args;
    if ($opt->mode eq 'in') {
        my $in = catalog->in($name);
        print ref($in)."\n" unless ref($in) =~ /^Stream::Catalog::In/;

        print_caps($in);
        if ($in->cap('lag')) {
            print "lag: ".$in->lag."\n";
        }
    }
    elsif ($opt->mode eq 'out') {
        my $out = catalog->out($name);
        print ref($out)."\n" unless ref($out) =~ /^Stream::Catalog::Out/;
        print_caps($out);
    }
    else {
        die "not implemented yet";
    }
}

sub abstract {
    "print info about given stream";
}


=head1 AUTHOR

Vyacheslav Matjukhin <mmcleric@yandex-team.ru>

=cut

1;
