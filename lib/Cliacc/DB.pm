package Cliacc::DB;
use Moose;

use DBIx::Connector;
use YAML ();

has root => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has db_conf => (
    is          => 'ro',
    isa         => 'HashRef',
    required    => 1,
    lazy        => 1,
    builder     => '_build_db_conf',
);

sub _build_db_conf {
    my $self = shift;
    my $root = $self->root;
    return YAML::LoadFile("$root/conf/db.conf");
}

has db_dsn => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    lazy        => 1,
    default     => sub { shift->db_conf->{dsn} },
);

has db_username => (
    is          => 'ro',
    isa         => 'Maybe[Str]',
    required    => 1,
    lazy        => 1,
    default     => sub { shift->db_conf->{username} },
);

has db_password => (
    is          => 'ro',
    isa         => 'Maybe[Str]',
    required    => 1,
    lazy        => 1,
    default     => sub { shift->db_conf->{password} },
);

has db_parameters => (
    is          => 'ro',
    isa         => 'Maybe[HashRef]',
    required    => 1,
    lazy        => 1,
    default     => sub { shift->db_conf->{parameters} },
);

has connector => (
    is          => 'ro',
    isa         => 'DBIx::Connector',
    required    => 1,
    lazy        => 1,
    builder     => '_build_connector',
);

sub _build_connector {
    my $self = shift;
    return DBIx::Connector->new(
        $self->db_dsn,
        $self->db_username,
        $self->db_password,
        $self->db_parameters,
    );
}

__PACKAGE__->meta->make_immutable;
