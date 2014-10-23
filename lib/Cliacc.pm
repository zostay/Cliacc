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
        class => 'Cliacc::MQ::Account',
        scope => 'singleton',
    );

    artifact ledgers => (
        class => 'Cliacc::MQ::Ledger',
        scope => 'singleton',
    );
};

__PACKAGE__->meta->finish_bag;
