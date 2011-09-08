package StreamApp::Command::list;

use strict;
use warnings;

use StreamApp -command;

use Stream::Utils 0.8.0 qw(catalog);
use StreamApp::Common;

use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

=head1 SYNOPSIS

    stream list

List all streams.

=cut

sub opt_spec {
    ['verbose|v', "print each storage's info"],
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    @$args == 0 or $self->usage_error("Didn't expected any args");
}

sub execute {
    my ($self, $opt, $args) = @_;
    my @in = catalog->list_in();
    print "==== Input streams ====\n";
    STDOUT->autoflush(1);
    for my $name (sort @in) {
        print "$name\n";
#        my $in = eval { catalog->in($name) };
#        unless ($in) {
#            chomp $@;
#            print RED $@."\n";
#            next;
#        }
#        print ref($in)."\n";
    }
    my @out = catalog->list_out();
    my %out;
    for my $name (@out) {
        my $out = eval {
            catalog->out($name);
        };
        if ($out) {
            $out{$name} = $out;
        }
        else {
            print RED "Failed to load '$name': $@";
        }
    }
    print "\n";

    print "==== Output streams ====\n";
    for (sort keys %out) {
        my $out = $out{$_};
        print "$_\n" unless $out->does('Stream::Storage');
    }
    print "\n";

    my $common = StreamApp::Common->new;
    print "==== Storages ====\n";
    for (sort keys %out) {
        my $out = $out{$_};
        next unless $out->does('Stream::Storage');
        print "$_\n";
        if ($opt->verbose) {
            $common->print_storage($out);
            print "\n";
        }
    }
}

sub abstract {
    "List all streams";
}

1;
