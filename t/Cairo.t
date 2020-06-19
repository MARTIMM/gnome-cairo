use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Cairo;
use Gnome::Cairo::Png;
use Gnome::Cairo::Enums;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo $c;
my Gnome::Cairo::Png $p;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  my Gnome::Cairo::Png $p .= new(
    :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128)
  );
  $c .= new(:surface($p));
  isa-ok $c, Gnome::Cairo, '.new(:surface)';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
