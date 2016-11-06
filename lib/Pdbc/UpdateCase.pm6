use DBDish::Connection;
use Pdbc::Executable;
use Pdbc::Where;

class UpdateCase {

  has DBDish::Connection $!db;
  has Str $!base_sql;
  has Where $!where;

  submethod BUILD(DBDish::Connection :$!db, Any :$data) {
    $!base_sql = sprintf('UPDATE %s SET %s', $data.WHAT.^name, self!create_update_clause($data));
    $!where = Where.new;
  }

  method where(Where $where) {
    $!where = $where;
    return self;
  }

  method execute {
    Executable.new(:$!db, sql => $!base_sql ~ ' ' ~ $!where.to_clause ).execute;
  }

  method sql {
    return $!base_sql ~ ' ' ~ $!where.to_clause;
  }

  method !create_update_clause(Any $data) {
    my @set;
    for $data.WHAT.^attributes -> $attr {
      (my $name = $attr.name) ~~ s/^\$(\!|\.)?//;
      my $value = $attr.get_value($data);
      push @set, sprintf('%s = %s', $name,  ($value.defined ?? "'$value'" !! 'NULL'));
    }
    return @set.join(', ');
  }
}
