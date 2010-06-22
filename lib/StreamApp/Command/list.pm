package StreamApp::Command::list;

use strict;
use warnings;

use StreamApp -command;

use Stream::Utils 0.8.0 qw(catalog);

use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

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
    STDOUT->autoflush(1);
    for my $name (sort @in) {
        print "\t$name\n";
#        my $in = eval { catalog->in($name) };
#        unless ($in) {
#            chomp $@;
#            print RED $@."\n";
#            next;
#        }
#        print ref($in)."\n";
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

