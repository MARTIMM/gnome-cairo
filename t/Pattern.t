use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Cairo::Pattern;
use Gnome::Cairo::ImageSurface;
use Gnome::Cairo::N-Types;
use Gnome::Cairo::Enums;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo::Pattern $p;
my Gnome::Cairo::ImageSurface $is;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $p .= new( :red(1), :green(0.5), :blue(0.5e0));
  isa-ok $p, Gnome::Cairo::Pattern, '.new( :red, :green, :blue)';
  ok $p.is-valid, '.is-valid()';
  $p.clear-object;
  nok $p.is-valid, '.clear-object()';

  $p .= new( :red(1), :green(0.5), :blue(0.5e0), :alpha('0.8'));
  isa-ok $p, Gnome::Cairo::Pattern, '.new( :red, :green, :blue, :alpha)';
  $p.clear-object;

  $p .= new( :x0(1), :y0(5), :x1(0.5e2), :y1('30.4'));
  isa-ok $p, Gnome::Cairo::Pattern, '.new( :x0, :y0, :x1, :y1)';
  $p.clear-object;

  $p .= new( :cx0(1), :cy0(1), :radius0(5), :cx1(10), :cy1(10), :radius1(5));
  isa-ok $p, Gnome::Cairo::Pattern, '.new( :cx0, :cy0, :radius0, :cx1, :cy1, :radius1)';
  $p.clear-object;

  $p .= new(:mesh);
  isa-ok $p, Gnome::Cairo::Pattern, '.new(:mesh)';
  $p.clear-object;

  $is .= new( :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128));
  $p .= new( :surface($is));
  isa-ok $p, Gnome::Cairo::Pattern, '.new( :surface)';
  $p.clear-object;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $p .= new(:mesh);

  $p.cairo_mesh_pattern_begin_patch;
  $p.cairo_mesh_pattern_move_to( 100e0, 100e0);
  $p.cairo_mesh_pattern_line_to( 130e0, 130e0);
  $p.cairo_mesh_pattern_line_to( 130e0,  70e0);
  $p.cairo_mesh_pattern_set_corner_color_rgb( 0, 1e0, 0e0, 0e0);
  $p.cairo_mesh_pattern_set_corner_color_rgb( 1, 0e0, 1e0, 0e0);
  $p.cairo_mesh_pattern_set_corner_color_rgb( 2, 0e0, 0e0, 1e0);
  $p.cairo_mesh_pattern_end_patch;

  $p.clear-object;
}

#-------------------------------------------------------------------------------
done-testing;
