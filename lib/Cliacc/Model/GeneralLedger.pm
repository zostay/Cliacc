package Cliacc::Model::GeneralLedger;
use Moose;

has id => (
    is          => 'rw',
);

has line => (
    is          => 'rw',
    isa         => 'Int',
);

__PACKAGE__->meta->make_immutable;
