package Cliacc::Server::Ledger;
use Moose;

use Cliacc::Model::AccountLedgerLine;
use Cliacc::Model::GeneralLedger;

has accounts => (
    is          => 'ro',
    does        => 'Cliacc::Service::Account',
    required    => 1,
);

has ledgers => (
    is         => 'ro',
    does       => 'Cliacc::Service::Ledger',
    required   => 1,
);

sub serialize_ledger_line {
    my ($self, $line) = @_;

    return {
        id     => $line->id,
        ledger => {
            id   => $line->ledger->id,
            line => $line->ledger->line,
        },
        account => {
            id           => $line->account->id,
            name         => $line->account->name,
            account_type => $line->account->account_type,
        },
        reference_number  => $line->reference_number,
        description       => $line->description,
        memo              => $line->memo,
        ($line->has_transfer_accounts ? (
            transfer_accounts => [ map { 
                {
                    id           => $_->id,
                    name         => $_->name,
                    account_type => $_->account_type,
                }
            } $line->list_transfer_accounts ],
        ) : ()),
        pennies           => $line->pennies,
    };
}

sub create_ledger {
    my ($self, $options) = @_;

    my @ledger_lines = map {
        Cliacc::Model::AccountLedgerLine->new(
            account          => Cliacc::Model::Account->new($_->{account}),
            reference_number => $_->{reference_number},
            description      => $_->{description},
            memo             => $_->{memo},
            pennies          => $_->{pennies},
        );
    } @{ $options->{ledger_lines} // [] };

    $self->ledgers->create_ledger(@ledger_lines);

    return {
        ledger_lines => [
            map {
                $self->serialize_ledger_line($_)
            } @ledger_lines
        ],
    };
}

sub list_ledger_lines_by_account {
    my ($self, $options) = @_;

    my $account = Cliacc::Model::Account->new(
        id           => $options->{id},
        name         => $options->{name},
        account_type => $options->{account_type},
    );

    my @ledger_lines = $self->ledgers->list_ledger_lines_by_account($account);

    return {
        ledger_lines => [
            map {
                $self->serialize_ledger_line($_)
            } @ledger_lines
        ],
    };
}

sub list_ledger_lines {
    my ($self) = @_;

    my @ledger_lines = $self->ledgers->list_ledger_lines;

    return {
        ledger_lines => [
            map {
                $self->serialize_ledger_line($_)
            } @ledger_lines
        ],
    };
}

__PACKAGE__->meta->make_immutable;
