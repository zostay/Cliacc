package Cliacc::Server::Account;
use Moose;

use Cliacc::Model::Account;

has accounts => (
    is           => 'ro',
    does         => 'Cliacc::Service::Account',
    required     => 1,
);

sub serialize_account {
    my ($self, $account) = @_;

    return unless defined $account;

    my $return = {
        id           => $account->id,
        name         => $account->name,
        account_type => $account->account_type,
        ($account->has_balance
            ? (balance => $account->balance)
            : ()),
    };

    return $return;
}

sub create_account {
    my ($self, $options) = @_;

    my $account = Cliacc::Model::Account->new(
        name         => $options->{name},
        account_type => $options->{account_type},
    );

    $self->accounts->create_account($account);

    return $self->serialize_account($account);
}

sub get_account_by_name {
    my ($self, $options) = @_;

    my $account = $self->accounts->get_account_by_name(
        $options->{name},
    );

    return $self->serialize_account($account);
}

sub get_account_balance {
    my ($self, $options) = @_;

    my $account = Cliacc::Model::Account->new(
        id           => $options->{id},
        name         => $options->{name},
        account_type => $options->{account_type},
    );

    $self->accounts->get_account_balance($account);

    return $self->serialize_account($account);
}

sub list_accounts {
    my $self = shift;

    my @accounts = $self->accounts->list_accounts;

    return {
        accounts => [ 
            map {
                $self->serialize_account($_)
            } @accounts
        ],
    };
}

__PACKAGE__->meta->make_immutable;
