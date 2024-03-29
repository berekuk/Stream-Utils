package StreamApp::Command::help;

# ABSTRACT: help command

use strict;
use warnings;

use parent qw(App::Cmd::Command::help);

sub execute {
    my $self = shift;
    $self->SUPER::execute(@_);
    exit(1);
}
1;

