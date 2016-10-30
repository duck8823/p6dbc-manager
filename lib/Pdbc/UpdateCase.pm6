use DBDish::Connection;
use Pdbc::Executable;
use Pdbc::Where;

class UpdateCase is Executable {

  method new(DBDish::Connection $db is rw, Any $data) {
    return self.bless(:$db, sql => sprintf('UPDATE %s SET %s', $data.WHAT.^name, self!create_update_clause($data)));
  }

  method where(Where $where) {
    $.sql ~~ s/\s+WHERE\s.*//;
    $.sql ~= ' ' ~ $where.to_clause;
    return self;
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
