use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Cairo::Matrix;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo::Matrix $m;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $m .= new;
  isa-ok $m, Gnome::Cairo::Matrix, '.new()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}
}}

#-------------------------------------------------------------------------------
done-testing;