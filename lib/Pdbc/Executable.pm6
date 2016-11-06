use DBDish::Connection;

class Executable {

  has DBDish::Connection $!db;
  has Str $!sql;

  submethod BUILD(DBDish::Connection :$!db, Str :$!sql?) {}

  method execute {
    $!db.do($!sql);
  }

  method sql {
    return $!sql;
  }

}
