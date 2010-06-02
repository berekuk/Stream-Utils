package StreamApp::Command::head;

use strict;
use warnings;

use StreamApp -command;

use Stream::Utils qw(catalog);
use Data::Dumper;

=head1 SYNOPSIS

    stream head INPUT_STREAM

Print first 10 items from given stream. If items are complex refs, they'll be dumped using Data::Dumper, otherwise - as is.

=cut

sub opt_spec {
    ['limit=i', 'number of items to read', { default => 10 }];
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    @$args == 1 or $self->usage_error("Stream name expected") unless @$args == 1;
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $name = shift @$args;
    my $stream = catalog->in($name);
    for (1..$opt->{limit}) {
        my $item = $stream->read;
        last unless defined $item;
        if (ref $item) {
            my $dump = Data::Dumper->new([$item]);
            $dump->Terse(1);
            $dump->Indent(0);
            print $dump->Dump, "\n";
        }
        else {
            chomp $item;
            print $item, "\n";
        }
    }
}

sub abstract {
    "print several items from given input stream";
}


=head1 AUTHOR

Vyacheslav Matjukhin <mmcleric@yandex-team.ru>

=cut

1;

