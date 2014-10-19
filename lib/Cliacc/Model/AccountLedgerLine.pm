package Cliacc::Model::AccountLedgerLine;
use Moose;

has id => (
    is          => 'ro',
    isa         => 'Int',
    required    => 1,
);

has ledger => (
    is          => 'ro',
    isa         => 'Cliacc::Model::GeneralLedger',
    required    => 1,
    handles     => [ qw( line ) ],
);

has account => (
    is          => 'ro',
    isa         => 'Cliacc::Model::Account',
    required    => 1,
    handles     => [ qw( type_sign ) ],
);

has reference_number => (
    is          => 'ro',
    isa         => 'Maybe[Str]',
    required    => 1,
);

has description => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has memo => (
    is          => 'ro',
    isa         => 'Maybe[Str]',
    required    => 1,
);

has pennies => (
    is          => 'ro',
    isa         => 'Int',
    required    => 1,
);

has transfer_accounts => (
    is          => 'ro',
    isa         => 'ArrayRef[Cliacc::Model::Account]',
    required    => 1,
    traits      => [ 'Array' ],
    handles     => {
        list_transfer_accounts => 'elements',
    },
);

sub amount { 
    my $self = shift;
    return $self->pennies * .01 * $self->type_sign;
}

sub transfer_name {
    my $self = shift;
    return join ', ', map { $_->name } $self->list_transfer_accounts;
} 

__PACKAGE__->meta->make_immutable;
