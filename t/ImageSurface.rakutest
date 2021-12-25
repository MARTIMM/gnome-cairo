use v6;
use NativeCall;
use Test;

use Gnome::Cairo::Types;
use Gnome::Cairo::Enums;
use Gnome::Cairo::ImageSurface;
use Gnome::Cairo;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo::ImageSurface $is;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $is .= new( :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128));
  isa-ok $is, Gnome::Cairo::ImageSurface, '.new( :format, :width, :height)';

  $is .= new(:png<t/data/Add.png>);
  isa-ok $is, Gnome::Cairo::ImageSurface, '.new(:png)';
  my Gnome::Cairo $cairo-context .= new(:surface($is));
  is cairo_status_t($cairo-context.cairo-status), CAIRO_STATUS_SUCCESS,
     $cairo-context.cairo-status-to-string($cairo-context.cairo-status);
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
