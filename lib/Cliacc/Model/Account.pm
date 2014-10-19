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

sub is_left   { shift->account_type eq 'left'  }
sub is_right  { shift->account_type eq 'right' }
sub type_sign { shift->is_left ? -1 : 1 }

sub balance_amount {
    my $self = shift;

    my $amount  = $self->balance * 0.01;
       $amount *= $self->type_sign;

    return $amount;
}

__PACKAGE__->meta->make_immutable;
