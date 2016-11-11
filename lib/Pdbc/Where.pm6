use Pdbc::Operator;

class Where {

  has Str $!column;
  has Any $!value;
  has Operator $!operator;
  has Where @!and;
  has Where @!or;

  multi method new {
    return self.bless;
  }

  multi method new(Str $column, Operator $operator) {
    $operator[1] and die 'invalid argument number.';
    my $self = self.bless;
    $self!column($column);
    $self!operator($operator);
    return $self;
  }

  multi method new(Str $column, Any $value, Operator $operator) {
    $operator[1] or die 'invalid argument number.';
    my $self = self.bless;
    $self!column($column);
    $self!value($value);
    $self!operator($operator);
    return $self;
  }

  method and(Where $where) {
    @!and.push($where);
    return self;
  }

  method or(Where $where) {
    @!or.push($where);
    return self;
  }

  method to_clause {
    my $base = self!to_phrase;
    return $base ?? "WHERE $base" !! '';
  }

  method !to_phrase {
    my $base;
    if !defined $!column && !defined $!value && !defined $!operator {
      $base = '';
    } elsif !$!operator[1] {
      $base = sprintf '%s %s', $!column, $!operator[0];
    } else {
      my $value = $!value;
      with $!operator[2] {
        $value = $!operator[2]($value);
      }
      $base = sprintf "%s %s '%s'", $!column, $!operator[0], $value;
    }
    if (@!and.elems > 0) {
      my @and_clause = ();
      for @!and -> $and {
        @and_clause.push($and!to_phrase);
      }
      $base ~= " AND " if $base;
      $base = "( $base" ~ @and_clause.join(' AND ') ~ " )";
    }
    if (@!or.elems > 0) {
      my @or_clause = ();
      for @!or -> $or {
        @or_clause.push($or!to_phrase);
      }
      $base ~= " OR " if $base;
      $base = "( $base" ~ @or_clause.join(' OR ') ~ " )";
    }
    return $base;
  }

  method !column(Str $column) {
    $!column = $column;
  }

  method !value(Any $value) {
    $!value = $value;
  }

  method !operator(Operator $operator) {
    $!operator = $operator;
  }
}
