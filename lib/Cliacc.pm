package Cliacc;
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

bag service => contains {
    artifact accounts => (
        class => 'Cliacc::Service::Account',
        parameters => {
            db => dep('db'),
        },
        scope => 'singleton',
    );

    artifact ledgers => (
        class => 'Cliacc::Service::Ledger',
        parameters => {
            db => dep('db'),
        },
        scope => 'singleton',
    );
};

__PACKAGE__->meta->finish_bag;
