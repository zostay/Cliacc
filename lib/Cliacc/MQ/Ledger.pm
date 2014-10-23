package Cliacc::MQ::Ledger;
use Moose;

use Cliacc::Model::Account;
use Cliacc::Model::AccountLedgerLine;
use Cliacc::Model::GeneralLedger;

use JSON;
use List::MoreUtils qw( pairwise );
use Readonly;
use ZMQ::LibZMQ3;
use ZMQ::Constants qw( ZMQ_REQ );

Readonly my $MAX_MSG_SIZE => 8192;

has zctx => (
    is          => 'ro',
    lazy        => 1,
    required    => 1,
    builder     => '_build_zctx',
);

sub _build_zctx { zmq_init() }

has zsock => (
    is          => 'ro',
    lazy        => 1,
    required    => 1,
    builder     => '_build_zsock',
);

sub _build_zsock {
    my $self = shift;
    my $zctx = $self->zctx;
    my $zsock = zmq_socket($zctx, ZMQ_REQ);
    zmq_connect($zsock, 'tcp://127.0.0.1:5678');
    return $zsock;
}

sub request {
    my ($self, $action, $options) = @_;

    my $request = {
        service    => 'ledgers',
        action     => $action,
        parameters => $options,
    };

    zmq_send($self->zsock, encode_json($request));

    my $zmessage;
    my $zsize = zmq_recv($self->zsock, $zmessage, $MAX_MSG_SIZE);
    my $json = substr($zmessage, 0, $zsize);

    return decode_json($json);
}

sub serialize_account {
    my ($self, $account) = @_;
    return {
        id           => $account->id,
        name         => $account->name,
        account_type => $account->account_type,
        ($account->has_balance
            ? (balance => $account->balance)
            : ()),
    };
}

sub serialize_ledger_line {
    my ($self, $line) = @_;

    return {
        ($line->has_ledger ? (
            ledger => {
                id   => $line->ledger->id,
                line => $line->ledger->line,
            },
        ) : ()),
        account => {
            id           => $line->account->id,
            name         => $line->account->name,
            account_type => $line->account->account_type,
        },
        reference_number => $line->reference_number,
        description      => $line->description,
        memo             => $line->memo,
        pennies          => $line->pennies,
    };
}

sub marshal_ledger_line {
    my ($self, $line) = @_;

    return Cliacc::Model::AccountLedgerLine->new(
        ledger            => Cliacc::Model::GeneralLedger->new($line->{ledger}),
        account           => Cliacc::Model::Account->new($line->{account}),
        reference_number  => $line->{reference_number},
        description       => $line->{description},
        memo              => $line->{memo},
        (defined $line->{transfer_accounts} ? (
            transfer_accounts => [ map { 
                Cliacc::Model::Account->new($_)
            } @{ $line->{transfer_accounts} } ],
        ) : ()),
        pennies           => $line->{pennies},
    );
}

sub create_ledger {
    my ($self, @ledger_lines) = @_;

    my $response = $self->request(create_ledger => {
        ledger_lines => [
            map { $self->serialize_ledger_line($_) } @ledger_lines
        ],
    });

    if ($response->{success}) {
        my @response_lines = @{ $response->{result}{ledger_lines} };
        return pairwise { 
            $a->id($b->{id}); 
            $a->ledger(
                Cliacc::Model::GeneralLedger->new(
                    id   => $b->{ledger}{id},
                    line => $b->{ledger}{line},
                )
            );
            $a 
        } @ledger_lines, @response_lines;
    }
    else {
        die "unable to create ledger: $response->{message}";
    }
}

sub list_ledger_lines_by_account {
    my ($self, $account) = @_;

    my $response = $self->request(list_ledger_lines_by_account => 
        $self->serialize_account($account)
    );

    if ($response->{success}) {
        return map {
            $self->marshal_ledger_line($_)
        } @{ $response->{result}{ledger_lines} };
    }
    else {
        die "unable to list ledger lines by account: $response->{message}";
    }
}

sub list_ledger_lines {
    my ($self) = @_;

    my $response = $self->request(list_ledger_lines => {});

    if ($response->{success}) {
        return map {
            $self->marshal_ledger_line($_)
        } @{ $response->{result}{ledger_lines} };
    }
    else {
        die "unable to list ledger lines: $response->{message}";
    }
}

__PACKAGE__->meta->make_immutable;
