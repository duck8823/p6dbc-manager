use DBIish;
use DBDish::Connection;

use Pdbc::Executable;
use Pdbc::FromCase;
use Pdbc::UpdateCase;

class Manager {

  has DBDish::Connection $!db;

  method new(Str $driver, Str $database, Str :$user?, Str :$password?, Str :$host?, Int :$port?) {
    my $self = self.bless;
    $self!db(DBIish.connect($driver, :$database, :$user, :$password, :$host, :$port));
    return $self;
  }

  method from($entity) {
    return FromCase.new($!db, $entity);
  }

  method drop($entity) {
    return Executable.new($!db, sprintf('DROP TABLE IF EXISTS %s', $entity.^name));
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
    return Executable.new($!db, sprintf('CREATE TABLE %s (%s)', $entity.^name, @column.join(', ')));
  }

  method insert($data) {
    return Executable.new($!db, sprintf('INSERT INTO %s %s', $data.WHAT.^name, self!create_insert_clause($data)));
  }

  method update($data) {
    return UpdateCase.new($!db, $data);
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

  method !db($db) {
    $!db = $db;
  }

}
