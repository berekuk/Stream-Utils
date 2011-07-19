package StreamApp::Command::head;

use strict;
use warnings;

use StreamApp -command;

use Streams qw(catalog process);
use Stream::Simple qw(code_out);
use Data::Dumper;

=head1 SYNOPSIS

    stream head INPUT_STREAM

Print first 10 items from given stream. If items are complex refs, they'll be dumped using Data::Dumper, otherwise - as is.

=cut

sub opt_spec {
    ['limit=i', 'number of items to read', { default => 10 }],
    ['commit', 'commit stream after reading'],
    ['dump-indent', 'indent dumped structures'];
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    @$args == 1 or $self->usage_error("Stream name expected") unless @$args == 1;
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $name = shift @$args;

    process(catalog->in($name) => code_out {
        my $item = shift;
        last unless defined $item;
        if (ref $item) {
            my $dump = Data::Dumper->new([$item]);
            $dump->Terse(1);
            if ($opt->{dump_indent}) {
                $dump->Indent(1);
            }
            else {
                $dump->Indent(0);
            }
            print $dump->Dump, "\n";
        }
        else {
            chomp $item;
            print $item, "\n";
        }
    }, { commit => $opt->{commit}, limit => $opt->{limit} });
}

sub abstract {
    "print several items from given input stream";
}

1;
