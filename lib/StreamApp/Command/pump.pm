package StreamApp::Command::pump;

use strict;
use warnings;

use StreamApp -command;

use Stream::Utils 0.8.0 qw(catalog);
use Data::Dumper;

=head1 SYNOPSIS

    stream head INPUT_STREAM

Print first 10 items from given stream. If items are complex refs, they'll be dumped using Data::Dumper, otherwise - as is.

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


=head1 AUTHOR

Vyacheslav Matjukhin <mmcleric@yandex-team.ru>

=cut

1;

