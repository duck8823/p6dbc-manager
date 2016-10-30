use DBDish::Connection;
use Pdbc::Where;
use Pdbc::Executable;

class FromCase {

  has DBDish::Connection $!db;
  has Any $!entity;
  has Where $!where;

  multi method new(DBDish::Connection $db, Any $entity) {
    return self.new($db, $entity, Where.new);
  }

  multi method new(DBDish::Connection $db, Any $entity, Where $where) {
    my $self = self.bless;
    $self!db($db);
    $self!entity($entity);
    $self!where($where);
    return $self;
  }

  method where(Where $where) {
    $!where = $where;
    return self;
  }

  method list {
    my (@column, @result);
    my @attr = $!entity.^attributes;
    for @attr -> $attr {
      (my $name = $attr.name) ~~ s/^\$(\!|\.)?//;
      push @column, $name;
    }
    my $sth = $!db.prepare(sprintf('SELECT %s FROM %s %s', join(', ', @column), $!entity.^name, $!where.to_clause));
    $sth.execute;
    for $sth.allrows -> $row {
      my $entity = $!entity.new;
      loop (my $i = 0; $i < @attr.elems; $i++) {
        @attr[$i].set_value($entity, $row[$i]) with $row[$i];
      }
      push @result, $entity;
    }
    $sth.finish;
    return @result;
  }

  method single_result {
    my @result = self.list();
    @result.elems > 1 and die '結果が一意でありません.';
    return @result[0];
  }

  method delete {
    return Executable.new($!db, sprintf('DELETE FROM %s %s', $!entity.^name, $!where.to_clause));
  }

  method !db(DBDish::Connection $db) {
    $!db = $db;
  }

  method !entity(Any $entity) {
    $!entity = $entity;
  }

  method !where(Where $where) {
    $!where = $where;
  }
}
