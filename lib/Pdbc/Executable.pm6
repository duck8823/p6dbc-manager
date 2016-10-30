use DBDish::Connection;

class Executable {

  has DBDish::Connection $.db;
  has Str $.sql is rw;

  method new(DBDish::Connection $db is rw, Str $sql) {
    return self.bless(:$db, :$sql);
  }

  method execute {
    $!db.do($.sql);
  }

  method db {
    die 'not accessible.';
  }

}
