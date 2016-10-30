# Pdbc::Manager

class でデータベースを簡易操作する

## SYBIOSIS
```perl6
use Pdbc :connect;

# クラスの定義
my class Hoge {
  has Int  $.id;
  has Str  $.name is rw;
  has Bool $.flg is rw;
}

# データベースへの接続
my $manager = connect('SQLite', 'test.db');
# テーブルの作成
$manager.create(Hoge).execute;
# データの挿入
$manager.insert(Hoge.new(id => 1, name => 'name_1', flg => True)).execute;
$manager.insert(Hoge.new(id => 2, name => 'name_2', flg => False)).execute;
# データの取得（リスト）
for $manager.from(Hoge).list -> $row {
  say $row;
}
$manager.from(Hoge).where(Where.new('name', 'name', LIKE)).list;
# データの取得（一意）
my $row = $manager.from(Hoge).where(Where.new('id', 1, EQUAL)).single_result;
say $row;
# データの更新
$row.flg = False;
$manager.update($row).where(Where.new('id', $row.id, EQUAL)).execute;
# データの削除
$manager.from(Hoge).where(Where.new('id', 1, EQUAL)).delete.execute;
# テーブルの削除
$manager.drop(Hoge).execute;
# SQLの取得
my $create_sql = $manager.create(Hoge).sql;
my $insert_sql = $manager.insert(Hoge.new(id => 1, name => 'name_1', flg => True)).sql;
my $update_sql = $manager.update(Hoge.new(id => 1, name => 'name_1', flg => False)).sql;
my $delete_sql = $manager.from(Hoge).where(Where.new('id', 1, EQUAL)).delete.sql;
my $drop_sql = $manager.drop(Hoge).sql;
```
