package Cliacc::Service::Ledger;
use Moose;

use Cliacc::Model::GeneralLedger;
use Cliacc::Model::Account;
use Cliacc::Model::AccountLedgerLine;

has db => (
    is          => 'ro',
    isa         => 'Cliacc::DB',
    required    => 1,
);

sub list_ledger_lines_by_account {
    my ($self, $account) = @_;

    my $ledger_lines = $self->db->connector->run(fixup => sub {
        $_->selectall_arrayref(q[
            SELECT l.id AS line_id, l.line, 
                   e.id AS entry_id, e.reference_number, e.description, e.memo, e.pennies,
                   a2.id AS account_id, a2.name, a2.account_type
              FROM entries e
              JOIN accounts a ON e.account = a.id
              JOIN lines l ON e.ledger = l.id
              JOIN entries e2 ON e2.ledger = l.id AND e2.id != e.id
              JOIN accounts a2 ON e2.account = a2.id
             WHERE a.id = ?
        ], { Slice => {} }, $account->id);
    });

    my (%accounts, %sl_lines, %gl_lines);
    $accounts{ $account->id } = $account;

    for my $ledger_line (@$ledger_lines) {
        my $gl_line = $gl_lines{ $ledger_line->{line_id} } 
                  //= Cliacc::Model::GeneralLedger->new(
                          id   => $ledger_line->{line_id},
                          line => $ledger_line->{line},
                      );

        my $sl_account = $accounts{ $ledger_line->{account_id} }
                      //= Cliacc::Model::Account->new(
                              id           => $ledger_line->{account_id},
                              name         => $ledger_line->{name},
                              account_type => $ledger_line->{account_type},
                       );

        my $sl_line = $sl_lines{ $ledger_line->{entry_id} }
                  //= {
                          id               => $ledger_line->{entry_id},
                          reference_number => $ledger_line->{reference_number},
                          description      => $ledger_line->{description},
                          memo             => $ledger_line->{memo},
                          pennies          => $ledger_line->{pennies},
                          ledger           => $gl_line,
                          account          => $account,
                      };

        push @{ $sl_line->{transfer_accounts} }, $sl_account;
    }

    return 
        map  { Cliacc::Model::AccountLedgerLine->new($_)     } 
        sort { $a->{ledger}->line <=> $b->{ledger}->line } 
        values %sl_lines;
}

__PACKAGE__->meta->make_immutable;
