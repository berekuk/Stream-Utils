package StreamApp::Command::pump;

# ABSTRACT: pump command (deprecated, see Yandex::Pumper)

use strict;
use warnings;

use StreamApp -command;

use Stream::Utils 0.8.0 qw(catalog);

=head1 SYNOPSIS

    stream pump PUMPER

Process 10 items using given pumper.

=cut

sub opt_spec {
    ['limit=i', 'number of items to process', { default => 10 }];
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    @$args == 1 or $self->usage_error("Stream name expected") unless @$args == 1;
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $name = shift @$args;
    my $pumper = catalog->pumper($name);
    $pumper->pump({
        limit => $opt->{limit},
    });
    print "ok\n";
}

sub abstract {
    "pump several items using given pumper";
}

1;
