use v6;
use NativeCall;
use Test;

use Gnome::Cairo::N-Types;
use Gnome::Cairo::Enums;
use Gnome::Cairo::ImageSurface;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo::ImageSurface $is;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $is .= new( :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128));
  isa-ok $is, Gnome::Cairo::ImageSurface, '.new( :format, :width, :height)';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
