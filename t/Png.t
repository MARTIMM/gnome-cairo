use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Cairo::Png;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo::Png $p;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $p .= new;
  isa-ok $p, Gnome::Cairo::Png, '.new()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
