package Cliacc::Server;
use Bolts;

use FindBin;

artifact 'root_dir';

artifact db => (
    class => 'Cliacc::DB',
    parameters => {
        root => dep('root_dir'),
    },
    scope => 'singleton',
);

bag model => contains {
    artifact account => (
        class => 'Cliacc::Model::Account',
        infer => 'options',
    );
};

bag service => contains {
    artifact accounts => (
        class => 'Cliacc::DB::Account',
        parameters => {
            db => dep('db'),
        },
        scope => 'singleton',
    );

    artifact ledgers => (
        class => 'Cliacc::DB::Ledger',
        parameters => {
            db => dep('db'),
        },
        scope => 'singleton',
    );
};

bag controller => contains {
    artifact accounts => (
        class => 'Cliacc::Server::Account',
        parameters => {
            accounts => dep(['service', 'accounts']),
        },
    );

    artifact ledgers => (
        class => 'Cliacc::Server::Ledger',
        parameters => {
            accounts => dep(['service', 'accounts']),
            ledgers  => dep(['service', 'ledgers']),
        },
    );
};

__PACKAGE__->meta->finish_bag;
