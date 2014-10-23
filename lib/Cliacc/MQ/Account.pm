package Cliacc::MQ::Account;
use Moose;

use Cliacc::Model::Account;

use JSON;
use Readonly;
use ZMQ::LibZMQ3;
use ZMQ::Constants qw( ZMQ_REQ );

Readonly my $MAX_MSG_SIZE => 1024;

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
        service    => 'accounts',
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

sub create_account {
    my ($self, $account) = @_;

    my $response = $self->request(create_account =>
        $self->serialize_account($account)
    );

    if ($response->{success}) {
        $account->id( $response->{result}{id} );
        return $account;
    }
    else {
        die "unable to create account: $response->{message}";
    }
}

sub get_account_by_name {
    my ($self, $name) = @_;

    my $response = $self->request(get_account_by_name => {
        name => $name,
    });

    if ($response->{success}) {
        return unless defined $response->{result}{id};
        return Cliacc::Model::Account->new($response->{result});
    }
    else {
        die "unable to get account by name: $response->{message}";
    }
}

sub get_account_balance {
    my ($self, $account) = @_;

    my $response = $self->request(get_account_balance =>
        $self->serialize_account($account)
    );

    if ($response->{success}) {
        $account->balance($response->{result}{balance});
        return $account;
    }
    else {
        die "unable to get account balance: $response->{message}";
    }
}

sub list_accounts {
    my $self = shift;

    my $response = $self->request(list_accounts => {});

    if ($response->{success}) {
        return map { 
            Cliacc::Model::Account->new($_)
        } @{ $response->{result}{accounts} };
    }
    else {
        die "unable to list accounts: $response->{message}";
    }
}

__PACKAGE__->meta->make_immutable;
