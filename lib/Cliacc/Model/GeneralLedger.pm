package Cliacc::Model::GeneralLedger;
use Moose;

has line => (
    is          => 'ro',
    isa         => 'Int',
    required    => 1,
);

__PACKAGE__->meta->make_immutable;
