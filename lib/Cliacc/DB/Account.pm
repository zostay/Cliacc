package Cliacc::DB::Account;
use Moose;

with 'Cliacc::Service::Account';

use Cliacc::Model::Account;

has db => (
    is          => 'ro',
    isa         => 'Cliacc::DB',
    required    => 1,
);

sub create_account {
    my ($self, $account) = @_;

    my $id = $self->db->connector->run(fixup => sub {
        $_->do(q[
            INSERT INTO accounts(name, account_type)
            VALUES (?, ?)
        ], undef, $account->name, $account->account_type);

        $_->last_insert_id("", "", "", "");
    });

    $account->id($id);

    return $account;
}

sub get_account_by_name {
    my ($self, $name) = @_;

    my ($id, $account_type) = $self->db->connector->run(fixup => sub {
        $_->selectrow_array(q[
            SELECT id, account_type
            FROM accounts
            WHERE name = ?
        ], undef, $name);
    });

    return Cliacc::Model::Account->new(
        id           => $id,
        name         => $name,
        account_type => $account_type,
    );
}

sub get_account_balance {
    my ($self, $account) = @_;

    my ($pennies) = $self->db->connector->run(fixup => sub {
        $_->selectrow_array(q[
            SELECT SUM(pennies)
            FROM entries
            WHERE account = ?
        ], undef, $account->id);
    });

    $account->balance($pennies);

    return $account;
}

sub list_accounts {
    my $self = shift;

    my $accounts = $self->db->connector->run(fixup => sub {
        $_->selectall_arrayref(q[
            SELECT id, name, account_type
            FROM accounts
        ], { Slice => {} });
    });

    return map { 
        Cliacc::Model::Account->new(
            id           => $_->{id},
            name         => $_->{name},
            account_type => $_->{account_type},
        )
    } @$accounts;
}

__PACKAGE__->meta->make_immutable;
