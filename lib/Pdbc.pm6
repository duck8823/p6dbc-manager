use Pdbc::Manager;
use Pdbc::Where;
use Pdbc::Operator;

unit module Pdbc:ver<0.0.1>:auth<shunsuke maeda(duck8823@gmail.com)>;

sub connect(Str $driver, Str $database, Str :$user?, Str :$password?, Str :$host?, Int :$port?) is export(:connect) {
  return Manager.new($driver, $database, :$user, :$password, :$host, :$port);
}
