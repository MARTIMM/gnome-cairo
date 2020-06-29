use v6;
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
  $p .= new;
  isa-ok $p, Gnome::Cairo::Pattern, '.new()';
  ok $p.is-valid, '.is-valid()';
  $p.clear-object;
  nok $p.is-valid, '.clear-object()';

  $p .= new(:rgb( 1, 0.5, 0.5e0));
  isa-ok $p, Gnome::Cairo::Pattern, '.new(:rgb)';

  $p .= new(:rgba( 1, 0.5, 0.5e0, '0.8'));
  isa-ok $p, Gnome::Cairo::Pattern, '.new(:rgba)';
  $p.clear-object;

  $p .= new(:linear( 1, 5, 0.5e2, '30.4'));
  isa-ok $p, Gnome::Cairo::Pattern, '.new(:linear)';
  $p.clear-object;

  $p .= new(:radial( 1, 1, 5, 10, 10, 5));
  isa-ok $p, Gnome::Cairo::Pattern, '.new(:radial)';
  $p.clear-object;

  $p .= new(:mesh);
  isa-ok $p, Gnome::Cairo::Pattern, '.new(:mesh)';
  $p.clear-object;

  $is .= new( :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128));
  $p .= new( :surface($is));
  isa-ok $p, Gnome::Cairo::Pattern, '.new(:surface)';
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
