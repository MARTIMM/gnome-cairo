use v6;
use NativeCall;

# Hijacked project Cairo of Timo

use Gnome::N::X;
use Gnome::N::NativeLib;
#use Gnome::N::N-GObject;
use Gnome::N::TopLevelClassSupport;

use Gnome::Cairo::Surface;
use Gnome::Cairo::Path;
use Gnome::Cairo::Pattern;
use Gnome::Cairo::Matrix;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
class cairo_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Cairo' #`{{ or %options<GtkDrawingArea> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists or %options<widget>:exists { }
    elsif %options<build-id>:exists { }

    else {
      my $no;
      if ? %options<target> {
        $no = %options<target>;
        $no .= get-native-object-no-reffing
          if $no.^can('get-native-object-no-reffing');
        $no = _cairo_create($no);
      }

      #`{{ use this when the module is not made inheritable
      # check if there are unknown options
      if %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }
      }}

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      # create default object
#      else {
#        $no = _gtk_drawing_area_new;
#      }

      self.set-native-object($no);
    }

#    # only after creating the native-object, the gtype is known
#    self.set-class-info('Cairo');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_$native-sub"); };
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

#  self.set-class-name-of-sub('Cairo');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
#TM:0:_cairo_create:
=begin pod
=end pod

sub _cairo_create ( cairo_surface_t $surface --> cairo_t )
  is native(&cairo-lib)
  is symbol('cairo_create')
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_destroy ( )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_new_sub_path ( --> cairo_path_t )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_copy_path ( --> cairo_path_t )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_copy_path_flat ( --> cairo_path_t )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_append_path ( cairo_path_t $path --> cairo_path_t )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_push_group ( )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_pop_group ( --> cairo_pattern_t )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_pop_group_to_source ( )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_get_current_point ( num64 $x is rw, num64 $y is rw )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_line_to ( num64 $x, num64 $y )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_move_to ( num64 $x, num64 $y )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_curve_to (
  num64 $x1, num64 $y1, num64 $x2, num64 $y2, num64 $x3, num64 $y3
) is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_rel_line_to ( num64 $x, num64 $y )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_rel_move_to ( num64 $x, num64 $y )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_rel_curve_to (
 num64 $x1, num64 $y1, num64 $x2, num64 $y2, num64 $x3, num64 $y3
) is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_arc (
  num64 $xc, num64 $yc, num64 $radius, num64 $angle1, num64 $angle2
) is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_arc_negative (
  num64 $xc, num64 $yc, num64 $radius, num64 $angle1, num64 $angle2
) is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_close_path ( )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_new_path ( )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_rectangle ( num64 $x, num64 $y, num64 $w, num64 $h )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_source_rgb ( num64 $r, num64 $g, num64 $b )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_source_rgba ( num64 $r, num64 $g, num64 $b, num64 $a )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_source ( cairo_pattern_t $pat )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_line_cap ( int32 $cap )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_get_line_cap ( --> int32 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_line_join ( int32 $join )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_get_line_join ( --> int32 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_fill_rule ( int32 $cap )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_get_fill_rule ( --> int32 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_line_width ( num64 $width )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_get_line_width ( --> num64 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_dash ( CArray[num64] $dashes, int32 $len, num64 $offset )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_get_operator ( --> int32 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub scairo_et_operator ( int32 $op )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_get_antialias ( --> int32 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_antialias ( int32 $op )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_source_surface ( cairo_surface_t $surface, num64 $x, num64 $y )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_mask ( cairo_pattern_t $pattern )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_mask_surface ( cairo_surface_t $surface, num64 $sx, num64 $sy )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_clip
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_clip_preserve
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_fill
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_stroke
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_fill_preserve
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_stroke_preserve
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_paint
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_paint_with_alpha ( num64 $alpha )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_translate ( num64 $tx, num64 $ty )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_scale ( num64 $sx, num64 $sy )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_rotate ( num64 $angle )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_transform ( cairo_matrix_t $matrix )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_identity_matrix
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_matrix ( cairo_matrix_t $matrix )
  is native(&cairo-lib)
  is symbol('cairo_set_matrix')
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_get_matrix ( cairo_matrix_t $matrix )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_save
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_restore
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_status ( --> int32 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_select_font_face ( Str $family, int32 $slant, int32 $weight )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_font_face ( cairo_font_face_t $font )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_font_size ( num64 $size )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_show_text ( Str $utf8 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_text_path ( Str $utf8 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_text_extents ( Str $utf8, cairo_text_extents_t $extents )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_font_extents ( cairo_font_extents_t $extents )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_tolerance ( num64 $tolerance )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_get_tolerance ( --> num64 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_set_font_options ( cairo_font_options_t $options )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_get_font_options()
  is native(&cairo-lib)
  {*}
