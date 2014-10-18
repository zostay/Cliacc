package Cliacc::Model::Account;
use Moose;

has id => (
    is          => 'rw',
);

has name => (
    is          => 'rw',
    isa         => 'Str',
);

use Moose::Util::TypeConstraints;
has account_type => (
    is          => 'rw',
    isa         => enum([ qw( left right ) ]),
);
no Moose::Util::TypeConstraints;

has balance => (
    is          => 'rw',
    isa         => 'Int',
);

sub balance_amount {
    my $self = shift;

    my $amount  = $self->balance * 0.01;
       $amount *= -1 if $self->account_type eq 'left';

    return $amount;
}

__PACKAGE__->meta->make_immutable;
