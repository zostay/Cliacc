package Cliacc::Service::Account;
use Moose::Role;

requires 'create_account'
requires 'get_account_by_name';
requires 'get_account_balance';
requires 'list_accounts';

1;
