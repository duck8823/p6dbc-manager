use Test;
use lib 'lib';

use Pdbc :connect;

my $manager = connect('SQLite', 'test.db');
isa-ok $manager, Manager;

my class Hoge {
  has Int $.id;
  has Str $.name;
}

is $manager.create(Hoge).sql, 'CREATE TABLE Hoge (id INTEGER, name TEXT)';
$manager.drop(Hoge).execute;
$manager.create(Hoge).execute;

$manager.insert(Hoge.new(id => 1, name => 'name_1')).execute;
$manager.insert(Hoge.new(id => 2, name => 'name_2')).execute;

is-deeply $manager.from(Hoge).where(Where.new('id', 1, EQUAL)).list, [Hoge.new(id => 1, name => 'name_1')];
is-deeply $manager.from(Hoge).where(Where.new('name', 'name', LIKE)).list, [Hoge.new(id => 1, name => 'name_1'), Hoge.new(id => 2, name => 'name_2')];

$manager.from(Hoge).where(Where.new('id', 1, EQUAL)).delete.execute;
is-deeply $manager.from(Hoge).where(Where.new('name', 'name', LIKE)).list, [Hoge.new(id => 2, name => 'name_2')];

$manager.insert(Hoge.new(id => 1, name => Nil)).execute;

is-deeply $manager.from(Hoge).where(Where.new('name', IS_NULL)).list, [Hoge.new(id => 1, name => Nil)];
is-deeply $manager.from(Hoge).where(Where.new('name', IS_NOT_NULL)).list, [Hoge.new(id => 2, name => 'name_2')];

$manager.update(Hoge.new(id => 1, name => 'name_1')).where(Where.new('id', 1, EQUAL)).execute;
is-deeply $manager.from(Hoge).where(Where.new('name', IS_NOT_NULL)).list, [Hoge.new(id => 2, name => 'name_2'), Hoge.new(id => 1, name => 'name_1')];

$manager.drop(Hoge).execute;
$manager.create(Hoge).execute;

$manager.begin;
try {
  $manager.insert(Hoge.new(id => 1, name => 'name_1')).execute;
  $manager.insert(Hoge.new(id => '2', name => 'name_2')).execute;
  CATCH {
    default {
      # ignore
    }
  }
}
my $db := $manager.^attributes[0].get_value($manager);
$db.dispose;

$manager = connect('SQLite', 'test.db');
is-deeply $manager.from(Hoge).list, [];

$manager.begin;

$manager.insert(Hoge.new(id => 1, name => 'name_1')).execute;
$manager.insert(Hoge.new(id => 2, name => 'name_2')).execute;

$manager.rollback;

is-deeply $manager.from(Hoge).list, [];

$manager.begin;

$manager.insert(Hoge.new(id => 1, name => 'name_1')).execute;
$manager.insert(Hoge.new(id => 2, name => 'name_2')).execute;

$manager.commit;

is-deeply $manager.from(Hoge).list, [Hoge.new(id => 1, name => 'name_1'), Hoge.new(id => 2, name => 'name_2')];

my $where = Where.new('name', 'name' , LIKE)
              .or(Where.new('id', IS_NOT_NULL)
                .and(Where.new('flg', IS_NULL)))
              .or(Where.new('id', 1, NOT_EQUAL));
is $where.to_clause, "WHERE ( name LIKE '%name%' OR ( id IS NOT NULL AND flg IS NULL ) OR id <> '1' )"
