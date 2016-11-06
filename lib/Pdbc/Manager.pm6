use DBIish;
use DBDish::Connection;

use Pdbc::Executable;
use Pdbc::FromCase;
use Pdbc::UpdateCase;

class Manager {

  has DBDish::Connection $!db;
  has Bool $!in_transaction;

  submethod BUILD(Str :$driver!, Str :$database!, Str :$user?, Str :$password?, Str :$host?, Int :$port?) {
    $!db = DBIish.connect($driver, :$database, :$user, :$password, :$host, :$port);
    $!in_transaction = False;
  }

  method from($entity) {
    return FromCase.new(:$!db, :$entity);
  }

  method drop($entity) {
    return Executable.new(:$!db, sql => sprintf('DROP TABLE IF EXISTS %s', $entity.^name));
  }

  method create($entity) {
    my @column;
    for $entity.^attributes -> $attr {
      my $type;
      given $attr.type {
        when Str { $type = 'TEXT' }
        when Int { $type = 'INTEGER' }
        when Bool { $type = 'BOOLEAN' }
        default { die sprintf('次の型は対応していません. :%s', $attr.type) }
      }
      (my $name = $attr.name) ~~ s/^\$(\!|\.)?//;
      push @column, sprintf('%s %s', $name, $type);
    }
    return Executable.new(:$!db, sql => sprintf('CREATE TABLE %s (%s)', $entity.^name, @column.join(', ')));
  }

  method insert($data) {
    return Executable.new(:$!db, sql => sprintf('INSERT INTO %s %s', $data.WHAT.^name, self!create_insert_clause($data)));
  }

  method update($data) {
    return UpdateCase.new(:$!db, :$data);
  }

  method begin {
    if $!in_transaction {
      die 'allready in transaction.'
    }
    $!db.do('BEGIN TRANSACTION');
    $!in_transaction = True;
  }

  method commit {
    unless $!in_transaction {
      die 'not in transaction.'
    }
    $!db.do('COMMIT');
    $!in_transaction = False;
  }

  method rollback {
    unless $!in_transaction {
      die 'not in transaction.'
    }
    $!db.do('ROLLBACK');
    $!in_transaction = False;
  }

  method !create_insert_clause($data) {
    my (@column, @value);
    for $data.^attributes -> $attr {
      (my $name = $attr.name) ~~ s/^\$(\!|\.)?//;
      my $value = $attr.get_value($data);
      push @column, $name;
      push @value, ($value.defined ?? "'$value'" !! 'NULL');
    }
    return sprintf('(%s) VALUES (%s)', @column.join(', '), @value.join(', '))
  }

}
