use Pdbc::Operator;

class Where {

  has Str $!column;
  has Any $!value;
  has Operator $!operator;

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
