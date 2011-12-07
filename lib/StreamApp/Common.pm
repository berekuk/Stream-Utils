package StreamApp::Common;

# ABSTRACT: common functions for stream app commands

use strict;
use warnings;

use Try::Tiny;

use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

sub new {
    return bless {} => shift;
}

sub print_description {
    my ($self, $object) = @_;

    return unless $object->DOES('Stream::Moose::Role::Description');
    print $object->description, "\n";
}

sub print_in {
    my ($self, $in) = @_;
    print ref($in)."\n" unless ref($in) =~ /^Stream::Catalog::In/;

    $self->print_description($in);

    if (
        $in->DOES('Stream::In::Role::Lag')
        or $in->DOES('Stream::Moose::In::Lag')
    ) {
        print "lag: ".$in->lag."\n";
    }
}

sub print_out {
    my ($self, $out) = @_;

    my $description;
    if (ref($out) =~ /^Stream::Catalog::Out/) {
        $description = 'anonymous';
    }
    else {
        $description = ref($out);
    }
    print $description, "\n";
    $self->print_description($out);
}

sub print_storage {
    my ($self, $storage) = @_;

    my $description;
    if (ref($storage) =~ /^Stream::Catalog::Out/) {
        $description = 'anonymous';
    }
    else {
        $description = ref($storage);
        if ($storage->DOES('Stream::Formatter::Wrapped')) {
            $description = ref($storage->{storage}).' (wrapped)'; # FIXME - evil encapsulation violation!
        }
    }
    print $description, "\n";

    $self->print_description($storage);

    if (
        $storage->DOES('Stream::Storage::Role::ClientList')
        or $storage->DOES('Stream::Moose::Storage::ClientList')
    ) {
        if (my @client_names = $storage->client_names) {
            print "Clients:\n";
            for my $name (@client_names) {
                print "\t$name";

                try {
                    my $in = $storage->stream($name);
                    if (
                        $in->DOES('Stream::In::Role::Lag')
                        or $in->DOES('Stream::Moose::In::Lag')
                    ) {
                        print "\t".$in->lag."\n";
                    }
                    else {
                        print "\n";
                    }
                }
                catch {
                    print RED "\tFailed: $_";
                }
            }
        }
    }
}

1;
