use v6;
#use lib '../gnome-native/lib';
#use NativeCall;
use Test;

use Gnome::Cairo;
use Gnome::Cairo::ImageSurface;
use Gnome::Cairo::Enums;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo $c;
my Gnome::Cairo::ImageSurface $p;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $p .= new( :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128));
  $c .= new(:surface($p));
  isa-ok $c, Gnome::Cairo, '.new(:surface)';
  ok $c.is-valid, '.is-valid()';
  is cairo_status_t($c.cairo-status), CAIRO_STATUS_SUCCESS, '.cairo-status()';
  $c.clear-object;
  nok $c.is-valid, '.clear-object()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
