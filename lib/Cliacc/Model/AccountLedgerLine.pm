package Cliacc::Model::AccountLedgerLine;
use Moose;

has id => (
    is          => 'rw',
    isa         => 'Int',
);

has ledger => (
    is          => 'rw',
    isa         => 'Cliacc::Model::GeneralLedger',
    predicate   => 'has_ledger',
    handles     => [ qw( line ) ],
);

has account => (
    is          => 'rw',
    isa         => 'Cliacc::Model::Account',
    handles     => {
       account_id => 'id',
       name       => 'name',
       type_sign  => 'type_sign',
   },
);

has reference_number => (
    is          => 'rw',
    isa         => 'Maybe[Str]',
);

has description => (
    is          => 'rw',
    isa         => 'Str',
);

has memo => (
    is          => 'rw',
    isa         => 'Maybe[Str]',
);

has pennies => (
    is          => 'rw',
    isa         => 'Int',
);

has transfer_accounts => (
    is          => 'rw',
    isa         => 'ArrayRef[Cliacc::Model::Account]',
    traits      => [ 'Array' ],
    predicate   => 'has_transfer_accounts',
    handles     => {
        list_transfer_accounts => 'elements',
    },
);

sub is_left  { shift->pennies < 0 }
sub is_right { shift->pennies > 0 }

sub left_amount {
    my $self = shift;
    return $self->is_left ? $self->pennies * -.01 : 0;
}

sub right_amount {
    my $self = shift;
    return $self->is_right ? $self->pennies * .01 : 0;
}

sub account_amount { 
    my $self = shift;
    return $self->pennies * .01 * $self->type_sign;
}

sub balance_amount { 
    my $self = shift;
    return $self->pennies * .01;
}

sub transfer_name {
    my $self = shift;
    return join ', ', map { $_->name } $self->list_transfer_accounts;
} 

__PACKAGE__->meta->make_immutable;
