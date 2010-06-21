package StreamApp::Command::list;

use strict;
use warnings;

use StreamApp -command;

use Stream::Utils 0.8.0 qw(catalog);

=head1 SYNOPSIS

    stream list

List all streams.

=cut

sub opt_spec {
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    @$args == 0 or $self->usage_error("Didn't expected any args");
}

sub execute {
    my ($self, $opt, $args) = @_;
    my @in = catalog->list_in();
    print "Input streams:\n";
    for my $name (sort @in) {
        my $in = catalog->in($name);
        print "\t$name (".ref($in).")\n";
    }
    my @out = catalog->list_out();
    print "Output streams:\n";
    for (sort @out) {
        print "\t$_\n";
    }
}

sub abstract {
    "List all streams";
}


=head1 AUTHOR

Vyacheslav Matjukhin <mmcleric@yandex-team.ru>

=cut

1;

