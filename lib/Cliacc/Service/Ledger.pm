package Cliacc::Service::Ledger;
use Moose::Role;

requires 'create_ledger';
requires 'list_ledger_lines_by_account';
requires 'list_ledger_lines';

1;
