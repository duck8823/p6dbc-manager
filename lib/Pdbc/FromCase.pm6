use DBDish::Connection;
use Pdbc::Where;
use Pdbc::Executable;

class FromCase {

  has DBDish::Connection $!db;
  has Any $!entity;
  has Where $!where;

  submethod BUILD(DBDish::Connection :$!db, Any :$!entity, Where :$!where?) {
    $!where = Where.new without $!where;
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
    return Executable.new(:$!db, sql => sprintf('DELETE FROM %s %s', $!entity.^name, $!where.to_clause));
  }
}
