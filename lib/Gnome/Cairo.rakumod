#TL:1:Gnome::Cairo:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo

The cairo drawing context

=comment ![](images/X.png)

=head1 Description

B<cairo_t> is the main object used when drawing with cairo. To draw with cairo, you create a B<cairo_t>, set the target surface, and drawing options for the B<cairo_t>, create shapes with functions like C<cairo_move_to()> and C<cairo_line_to()>, and then draw shapes with C<cairo_stroke()> or C<cairo_fill()>.
B<cairo_t> 's can be pushed to a stack via C<cairo_save()>. They may then safely be changed, without losing the current state. Use C<cairo_restore()> to restore to the saved state.


=head2 See Also

B<cairo_surface_t>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo;
  also is Gnome::N::TopLevelClassSupport;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

use Gnome::Cairo::Types;
use Gnome::Cairo::Enums;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :surface

Creates a new B<cairo_t> with all graphics state parameters set to default values and with I<target> as a target surface. The target surface should be constructed with a backend-specific function such as C<cairo_image_surface_create()> (or any other C<cairo_B<backend>_surface_create( )> variant).

This function references I<target>, so you can immediately call C<cairo_surface_destroy()> on it if you don't need to maintain a separate reference to it.

The object is cleared with C<clear-object()> when you are done using the B<cairo_t>. This function never returns C<Any>. If memory cannot be allocated, a special B<cairo_t> object will be returned on which C<cairo_status()> returns C<CAIRO_STATUS_NO_MEMORY>. If you attempt to target a surface which does not support writing (such as B<cairo_mime_surface_t>) then a C<CAIRO_STATUS_WRITE_ERROR> will be raised.

You can use this object normally, but no drawing will be done.

  multi method new ( cairo_surface_t :$surface! )

=item cairo_surface_t $surface;


=head3 :native-object

Create a B<Gnome::Cairo> object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

#TM:1:new(:surface):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

#note "o: ", self.^name, ', ', %options;
  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo' #`{{ or %options<Cairo> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    else {
      my $no;
      if %options<surface>:exists {
        $no = %options<surface>;
        $no .= _get-native-object-no-reffing unless $no ~~ cairo_surface_t;
        $no = _cairo_create($no);
      }

#      #`{{ use this when the module is not made inheritable
      # check if there are unknown options
      elsif %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }
#      }}

#      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
#      }}

      #`{{ when there are defaults use this instead
      # create default object
      else {
        $no = cairo_new();
      }
      }}

      self._set-native-object($no);
    }

#    self._set-class-info('Cairo');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

#  self._set-class-name-of-sub('Cairo');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
method native-object-ref ( $no ) {
  _cairo_reference($no)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $no ) {
  _cairo_destroy($no);
}








#-------------------------------------------------------------------------------
#TM:1:append-path:
=begin pod
=head2 append-path

Append the I<$path> onto the current path. Note that C<Gnome::Cairo::Path.status()> must be C<CAIRO_STATUS_SUCCESS>.

  method append-path ( cairo_path_t $path )

=item cairo_path_t $path; a cairo context
=end pod

method append-path ( $path is copy ) {
  $path .= get-native-object-no-reffing unless $path ~~ cairo_path_t;
  cairo_append_path( self._get-native-object-no-reffing, $path);
}

sub cairo_append_path (
  cairo_t $cr, cairo_path_t $path
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:arc:
=begin pod
=head2 arc

Adds a circular arc of the given I<$radius> to the current path. The arc is centered at (I<$xc>, I<$yc>), begins at I<$angle1> and proceeds in the direction of increasing angles to end at I<$angle2>. If I<$angle2> is less than I<$angle1> it will be progressively increased by C<2*M_PI> until it is greater than I<$angle1>.

If there is a current point, an initial line segment will be added to the path to connect the current point to the beginning of the arc. If this initial line is undesired, it can be avoided by calling C<new_sub_path()> before calling C<arc()>.

Angles are measured in radians. An angle of 0.0 is in the direction of the positive X axis (in user space). An angle of C<M_PI/2.0> radians (90 degrees) is in the direction of the positive Y axis (in user space). Angles increase in the direction from the positive X axis toward the positive Y axis. So with the default transformation matrix, angles increase in a clockwise direction.  (To convert from degrees to radians, use C<degrees * (M_PI / 180.)>.)  This function gives the arc in the direction of increasing angles; see C<arc_negative()> to get the arc in the direction of decreasing angles.  The arc is circular in user space. To achieve an elliptical arc, you can scale the current transformation matrix by different amounts in the X and Y directions. For example, to draw an ellipse in the box given by I<$x>, I<$y>, I<$width>, I<$height>:

=begin code
  $cairo.save;
  $cairo.translate( $x + $width / 2, $y + $height / 2);
  $cairo.scale( $width / 2, $height / 2);
  $cairo.arc( 0, 0, 1, 0, 2 * π);
  $cairo.restore;
=end code

=begin code
  method arc (
    Num() $xc, Num() $yc, Num() $radius, Num() $angle1, Num() $angle2
  )
=end code

=item $xc; a cairo context
=item $yc; X position of the center of the arc
=item $radius; Y position of the center of the arc
=item $angle1; the radius of the arc
=item $angle2; the start angle, in radians
=end pod

method arc (
  Num() $xc, Num() $yc, Num() $radius, Num() $angle1, Num() $angle2
) {
  cairo_arc(
    self._get-native-object-no-reffing, $xc, $yc, $radius, $angle1, $angle2
  )
}

sub cairo_arc (
  cairo_t $cr, gdouble $xc, gdouble $yc, gdouble $radius, gdouble $angle1, gdouble $angle2
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:arc-negative:
=begin pod
=head2 arc-negative

Adds a circular arc of the given I<radius> to the current path.  The arc is centered at (I<xc>, I<yc>), begins at I<angle1> and proceeds in the direction of decreasing angles to end at I<angle2>. If I<angle2> is greater than I<angle1> it will be progressively decreased by <literal>2*M_PI</literal> until it is less than I<angle1>.  See C<cairo_arc()> for more details. This function differs only in the direction of the arc between the two angles.

  method arc-negative (
    Num $xc, Num $yc, Num $radius, Num $angle1, Num $angle2
  )

=item $xc; a cairo context
=item $yc; X position of the center of the arc
=item $radius; Y position of the center of the arc
=item $angle1; the radius of the arc
=item $angle2; the start angle, in radians
=end pod

method arc-negative ( Num $xc, Num $yc, Num $radius, Num $angle1, Num $angle2 ) {

  cairo_arc_negative(
    self._get-native-object-no-reffing, $xc, $yc, $radius, $angle1, $angle2
  )
}

sub cairo_arc_negative (
  cairo_t $cr, gdouble $xc, gdouble $yc, gdouble $radius, gdouble $angle1, gdouble $angle2
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:clip:
=begin pod
=head2 clip

Establishes a new clip region by intersecting the current clip region with the current path as it would be filled by C<cairo_fill()> and according to the current fill rule (see C<cairo_set_fill_rule()>).  After C<cairo_clip()>, the current path will be cleared from the cairo context.  The current clip region affects all drawing operations by effectively masking out any changes to the surface that are outside the current clip region.  Calling C<cairo_clip()> can only make the clip region smaller, never larger. But the current clip is part of the graphics state, so a temporary restriction of the clip region can be achieved by calling C<cairo_clip()> within a C<cairo_save()>/C<cairo_restore()> pair. The only other means of increasing the size of the clip region is C<cairo_reset_clip()>.

  method clip ( )

=end pod

method clip ( ) {

  cairo_clip(
    self._get-native-object-no-reffing,
  )
}

sub cairo_clip (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:clip-extents:
=begin pod
=head2 clip-extents

Computes a bounding box in user coordinates covering the area inside the current clip.

  method clip-extents ( Num $x1, Num $y1, Num $x2, Num $y2 )

=item $x1; a cairo context
=item $y1; left of the resulting extents
=item $x2; top of the resulting extents
=item $y2; right of the resulting extents
=end pod

method clip-extents ( Num $x1, Num $y1, Num $x2, Num $y2 ) {

  cairo_clip_extents(
    self._get-native-object-no-reffing, $x1, $y1, $x2, $y2
  )
}

sub cairo_clip_extents (
  cairo_t $cr, gdouble $x1, gdouble $y1, gdouble $x2, gdouble $y2
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:clip-preserve:
=begin pod
=head2 clip-preserve

Establishes a new clip region by intersecting the current clip region with the current path as it would be filled by C<cairo_fill()> and according to the current fill rule (see C<cairo_set_fill_rule()>).  Unlike C<cairo_clip()>, C<cairo_clip_preserve()> preserves the path within the cairo context.  The current clip region affects all drawing operations by effectively masking out any changes to the surface that are outside the current clip region.  Calling C<cairo_clip_preserve()> can only make the clip region smaller, never larger. But the current clip is part of the graphics state, so a temporary restriction of the clip region can be achieved by calling C<cairo_clip_preserve()> within a C<cairo_save()>/C<cairo_restore()> pair. The only other means of increasing the size of the clip region is C<cairo_reset_clip()>.

  method clip-preserve ( )

=end pod

method clip-preserve ( ) {

  cairo_clip_preserve(
    self._get-native-object-no-reffing,
  )
}

sub cairo_clip_preserve (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:close-path:
=begin pod
=head2 close-path

Adds a line segment to the path from the current point to the beginning of the current sub-path, (the most recent point passed to C<cairo_move_to()>), and closes this sub-path. After this call the current point will be at the joined endpoint of the sub-path.  The behavior of C<cairo_close_path()> is distinct from simply calling C<cairo_line_to()> with the equivalent coordinate in the case of stroking. When a closed sub-path is stroked, there are no caps on the ends of the sub-path. Instead, there is a line join connecting the final and initial segments of the sub-path.  If there is no current point before the call to C<cairo_close_path()>, this function will have no effect.  Note: As of cairo version 1.2.4 any call to C<cairo_close_path()> will place an explicit MOVE_TO element into the path immediately after the CLOSE_PATH element, (which can be seen in C<cairo_copy_path()> for example). This can simplify path processing in some cases as it may not be necessary to save the "last move_to point" during processing as the MOVE_TO immediately after the CLOSE_PATH will provide that point.

  method close-path ( )

=end pod

method close-path ( ) {

  cairo_close_path(
    self._get-native-object-no-reffing,
  )
}

sub cairo_close_path (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:copy-clip-rectangle-list:
=begin pod
=head2 copy-clip-rectangle-list

Gets the current clip region as a list of rectangles in user coordinates. Never returns C<Any>.  The status in the list may be C<CAIRO_STATUS_CLIP_NOT_REPRESENTABLE> to indicate that the clip region cannot be represented as a list of user-space rectangles. The status may have other values to indicate other errors.  Returns: the current clip region as a list of rectangles in user coordinates, which should be destroyed using C<cairo_rectangle_list_destroy()>.

  method copy-clip-rectangle-list ( --> cairo_rectangle_list_t )

=end pod

method copy-clip-rectangle-list ( --> cairo_rectangle_list_t ) {

  cairo_copy_clip_rectangle_list(
    self._get-native-object-no-reffing,
  )
}

sub cairo_copy_clip_rectangle_list (
  cairo_t $cr --> cairo_rectangle_list_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:copy-page:
=begin pod
=head2 copy-page

Emits the current page for backends that support multiple pages, but doesn't clear it, so, the contents of the current page will be retained for the next page too.  Use C<cairo_show_page()> if you want to get an empty page after the emission.  This is a convenience function that simply calls C<cairo_surface_copy_page()> on this context's target.

  method copy-page ( )

=end pod

method copy-page ( ) {

  cairo_copy_page(
    self._get-native-object-no-reffing,
  )
}

sub cairo_copy_page (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:copy-path:
=begin pod
=head2 copy-path

Creates a copy of the current path and returns it to the user as a B<cairo_path_t>. See B<cairo_path_data_t> for hints on how to iterate over the returned data structure.

This function will always return a valid pointer, but the result will have no data, if either of the following conditions hold:
=item If there is insufficient memory to copy the path. In this case C<$path.status> will be set to C<CAIRO_STATUS_NO_MEMORY>.
=item If the context is already in an error state. In this case C<$path.status> will contain the same status that would be returned by C<.status()>.

Return value: the copy of the current path. The caller owns the returned object and should call C<clear-object()> when finished with it.

  method copy-path ( --> cairo_path_t )

=end pod

method copy-path ( --> cairo_path_t ) {
  cairo_copy_path(self._get-native-object-no-reffing)
}

sub cairo_copy_path (
  cairo_t $cr --> cairo_path_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:copy-path-flat:
=begin pod
=head2 copy-path-flat

Gets a flattened copy of the current path and returns it to the user as a B<cairo_path_t>. See B<cairo_path_data_t> for hints on how to iterate over the returned data structure.  This function is like C<copy-path()> except that any curves in the path will be approximated with piecewise-linear approximations, (accurate to within the current tolerance value). That is, the result is guaranteed to not have any elements of type C<CAIRO_PATH_CURVE_TO> which will instead be replaced by a series of C<CAIRO_PATH_LINE_TO> elements.

This function will always return a valid pointer, but the result will have no data, if either of the following conditions hold:
=item If there is insufficient memory to copy the path. In this case C<$path.status> will be set to C<CAIRO_STATUS_NO_MEMORY>.
=item If the context is already in an error state. In this case C<$path.status> will contain the same status that would be returned by C<.status()>.

Return value: the copy of the current path. The caller owns the returned object and should call C<clear-object()> when finished with it.

  method copy-path-flat ( --> cairo_path_t )

=end pod

method copy-path-flat ( --> cairo_path_t ) {
  cairo_copy_path_flat(self._get-native-object-no-reffing)
}

sub cairo_copy_path_flat (
  cairo_t $cr --> cairo_path_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_create:
#`{{
=begin pod
=head2 create

Creates a new B<cairo_t> with all graphics state parameters set to default values and with I<target> as a target surface. The target surface should be constructed with a backend-specific function such as C<cairo_image_surface_create()> (or any other C<cairo_B<backend>_surface_create( )> variant).  This function references I<target>, so you can immediately call C<cairo_surface_destroy()> on it if you don't need to maintain a separate reference to it.  Return value: a newly allocated B<cairo_t> with a reference count of 1. The initial reference count should be released with C<cairo_destroy()> when you are done using the B<cairo_t>. This function never returns C<Any>. If memory cannot be allocated, a special B<cairo_t> object will be returned on which C<cairo_status()> returns C<CAIRO_STATUS_NO_MEMORY>. If you attempt to target a surface which does not support writing (such as B<cairo_mime_surface_t>) then a C<CAIRO_STATUS_WRITE_ERROR> will be raised.  You can use this object normally, but no drawing will be done.

  method create ( cairo_surface_t $target --> cairo_t )

=item cairo_surface_t $target;  cairo_create:
=end pod

method create ( cairo_surface_t $target --> cairo_t ) {

  cairo_create(
    self._get-native-object-no-reffing, $target
  )
}
}}

sub _cairo_create (
  cairo_surface_t $target --> cairo_t
) is native(&cairo-lib)
  is symbol('cairo_create')
  { * }

#-------------------------------------------------------------------------------
#TM:0:curve-to:
=begin pod
=head2 curve-to

Adds a cubic Bézier spline to the path from the current point to position (I<x3>, I<y3>) in user-space coordinates, using (I<x1>, I<y1>) and (I<x2>, I<y2>) as the control points. After this call the current point will be (I<x3>, I<y3>).  If there is no current point before the call to C<cairo_curve_to()> this function will behave as if preceded by a call to cairo_move_to(this context, I<x1>, I<y1>).

  method curve-to ( Num $x1, Num $y1, Num $x2, Num $y2, Num $x3, Num $y3 )

=item $x1; a cairo context
=item $y1; the X coordinate of the first control point
=item $x2; the Y coordinate of the first control point
=item $y2; the X coordinate of the second control point
=item $x3; the Y coordinate of the second control point
=item $y3; the X coordinate of the end of the curve
=end pod

method curve-to ( Num $x1, Num $y1, Num $x2, Num $y2, Num $x3, Num $y3 ) {

  cairo_curve_to(
    self._get-native-object-no-reffing, $x1, $y1, $x2, $y2, $x3, $y3
  )
}

sub cairo_curve_to (
  cairo_t $cr, gdouble $x1, gdouble $y1, gdouble $x2, gdouble $y2, gdouble $x3, gdouble $y3
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_destroy:
#`{{
=begin pod
=head2 destroy

Decreases the reference count on this context by one. If the result is zero, then this context and all associated resources are freed. See C<cairo_reference()>.

  method destroy ( )

=end pod

method destroy ( ) {

  cairo_destroy(
    self._get-native-object-no-reffing,
  )
}
}}

sub _cairo_destroy (
  cairo_t $cr
) is native(&cairo-lib)
  is symbol('cairo_destroy')
  { * }

#-------------------------------------------------------------------------------
#TM:0:device-to-user:
=begin pod
=head2 device-to-user

Transform a coordinate from device space to user space by multiplying the given point by the inverse of the current transformation matrix (CTM).

  method device-to-user ( Num $x, Num $y )

=item $x; a cairo
=item $y; X value of coordinate (in/out parameter)
=end pod

method device-to-user ( Num $x, Num $y ) {
  cairo_device_to_user( self._get-native-object-no-reffing, $x, $y)
}

sub cairo_device_to_user (
  cairo_t $cr, gdouble $x, gdouble $y
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:device-to-user-distance:
=begin pod
=head2 device-to-user-distance

Transform a distance vector from device space to user space. This function is similar to C<cairo_device_to_user()> except that the translation components of the inverse CTM will be ignored when transforming (I<dx>,I<dy>).

  method device-to-user-distance ( Num $dx, Num $dy )

=item $dx; a cairo context
=item $dy; X component of a distance vector (in/out parameter)
=end pod

method device-to-user-distance ( Num $dx, Num $dy ) {

  cairo_device_to_user_distance(
    self._get-native-object-no-reffing, $dx, $dy
  )
}

sub cairo_device_to_user_distance (
  cairo_t $cr, gdouble $dx, gdouble $dy
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:fill:
=begin pod
=head2 fill

A drawing operator that fills the current path according to the current fill rule, (each sub-path is implicitly closed before being filled). After C<cairo_fill()>, the current path will be cleared from the cairo context. See C<cairo_set_fill_rule()> and C<cairo_fill_preserve()>.

  method fill ( )

=end pod

method fill ( ) {
  cairo_fill(self._get-native-object-no-reffing)
}

sub cairo_fill (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:fill-extents:
=begin pod
=head2 fill-extents

Computes a bounding box in user coordinates covering the area that would be affected, (the "inked" area), by a C<cairo_fill()> operation given the current path and fill parameters. If the current path is empty, returns an empty rectangle ((0,0), (0,0)). Surface dimensions and clipping are not taken into account.  Contrast with C<cairo_path_extents()>, which is similar, but returns non-zero extents for some paths with no inked area, (such as a simple line segment).  Note that C<cairo_fill_extents()> must necessarily do more work to compute the precise inked areas in light of the fill rule, so C<cairo_path_extents()> may be more desirable for sake of performance if the non-inked path extents are desired.  See C<cairo_fill()>, C<cairo_set_fill_rule()> and C<cairo_fill_preserve()>.

  method fill-extents ( Num() $x1, Num() $y1, Num() $x2, Num() $y2 )

=item $x1; a cairo context
=item $y1; left of the resulting extents
=item $x2; top of the resulting extents
=item $y2; right of the resulting extents
=end pod

method fill-extents ( Num() $x1, Num() $y1, Num() $x2, Num() $y2 ) {
  cairo_fill_extents( self._get-native-object-no-reffing, $x1, $y1, $x2, $y2)
}

sub cairo_fill_extents (
  cairo_t $cr, gdouble $x1, gdouble $y1, gdouble $x2, gdouble $y2
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:fill-preserve:
=begin pod
=head2 fill-preserve

A drawing operator that fills the current path according to the current fill rule, (each sub-path is implicitly closed before being filled). Unlike C<cairo_fill()>, C<cairo_fill_preserve()> preserves the path within the cairo context.  See C<cairo_set_fill_rule()> and C<cairo_fill()>.

  method fill-preserve ( )

=end pod

method fill-preserve ( ) {
  cairo_fill_preserve( self._get-native-object-no-reffing)
}

sub cairo_fill_preserve (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:font-extents:
=begin pod
=head2 font-extents

Gets the font extents for the currently selected font.

  method font-extents ( cairo_font_extents_t $extents )

=item cairo_font_extents_t $extents; a B<cairo_t>
=end pod

method font-extents ( cairo_font_extents_t $extents ) {
  cairo_font_extents( self._get-native-object-no-reffing, $extents)
}

sub cairo_font_extents (
  cairo_t $cr, cairo_font_extents_t $extents
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-antialias:
=begin pod
=head2 get-antialias

Gets the current shape antialiasing mode, as set by C<cairo_set_antialias()>.  Return value: the current shape antialiasing mode.

  method get-antialias ( --> cairo_antialias_t )

=end pod

method get-antialias ( --> cairo_antialias_t ) {
  cairo_antialias_t(cairo_get_antialias(self._get-native-object-no-reffing))
}

sub cairo_get_antialias (
  cairo_t $cr --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-current-point:
=begin pod
=head2 get-current-point

Gets the current point of the current path, which is conceptually the final point reached by the path so far.  The current point is returned in the user-space coordinate system. If there is no defined current point or if this object is not valid, I<$x> and I<$y> will both be set to 0.0. It is possible to check this in advance with C<has_current_point()>.  Most path construction functions alter the current point.

See the following for details on how they affect the current point: C<new_path()>, C<new_sub_path()>, C<append_path()>, C<close_path()>, C<move_to()>, C<line_to()>, C<curve_to()>, C<rel_move_to()>, C<rel_line_to()>, C<rel_curve_to()>, C<arc()>, C<arc_negative()>, C<rectangle()>, C<text_path()>, C<glyph_path()>, C<stroke_to_path()>.

Some functions use and alter the current point but do not otherwise change current path: C<show_text()>.  Some functions unset the current path and as a result, current point: C<fill()>, C<stroke()>.

  method get-current-point ( --> List )

The returned list has;
=item $x; a cairo context
=item $y; return value for X coordinate of the current point
=end pod

method get-current-point ( --> List ) {
  my gdouble $x_ret;
  my gdouble $y_ret;
  cairo_get_current_point(
    self._get-native-object-no-reffing, $x_ret, $y_ret
  );

  ( $x_ret, $y_ret);
}

sub cairo_get_current_point (
  cairo_t $cr, gdouble $x_ret is rw, gdouble $y_ret is rw
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-dash:
=begin pod
=head2 get-dash

Gets the current dash array.  If not C<Any>, I<dashes> should be big enough to hold at least the number of values returned by C<cairo_get_dash_count()>.

  method get-dash ( Num $dashes, Num $offset )

=item $dashes; a B<cairo_t>
=item $offset; return value for the dash array, or C<Any>
=end pod

method get-dash ( Num $dashes, Num $offset ) {

  cairo_get_dash(
    self._get-native-object-no-reffing, $dashes, $offset
  )
}

sub cairo_get_dash (
  cairo_t $cr, gdouble $dashes, gdouble $offset
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-dash-count:
=begin pod
=head2 get-dash-count

This function returns the length of the dash array in this context (0 if dashing is not currently in effect).  See also C<cairo_set_dash()> and C<cairo_get_dash()>.  Return value: the length of the dash array, or 0 if no dash array set.

  method get-dash-count ( --> Int )

=end pod

method get-dash-count ( --> Int ) {

  cairo_get_dash_count(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_dash_count (
  cairo_t $cr --> int32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-fill-rule:
=begin pod
=head2 get-fill-rule

Gets the current fill rule, as set by C<cairo_set_fill_rule()>.  Return value: the current fill rule.

  method get-fill-rule ( --> Int )

=end pod

method get-fill-rule ( --> Int ) {

  cairo_get_fill_rule(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_fill_rule (
  cairo_t $cr --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-font-face:
=begin pod
=head2 get-font-face

Gets the current font face for a B<cairo_t>.  Return value: the current font face.  This object is owned by cairo. To keep a reference to it, you must call C<cairo_font_face_reference()>.  This function never returns C<Any>. If memory cannot be allocated, a special "nil" B<cairo_font_face_t> object will be returned on which C<cairo_font_face_status()> returns C<CAIRO_STATUS_NO_MEMORY>. Using this nil object will cause its error state to propagate to other objects it is passed to, (for example, calling C<cairo_set_font_face()> with a nil font will trigger an error that will shutdown the B<cairo_t> object).

  method get-font-face ( --> cairo_font_face_t )

=end pod

method get-font-face ( --> cairo_font_face_t ) {

  cairo_get_font_face(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_font_face (
  cairo_t $cr --> cairo_font_face_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-font-matrix:
=begin pod
=head2 get-font-matrix

Stores the current font matrix into I<matrix>. See C<cairo_set_font_matrix()>.

  method get-font-matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a B<cairo_t>
=end pod

method get-font-matrix ( cairo_matrix_t $matrix ) {

  cairo_get_font_matrix(
    self._get-native-object-no-reffing, $matrix
  )
}

sub cairo_get_font_matrix (
  cairo_t $cr, cairo_matrix_t $matrix
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-font-options:
=begin pod
=head2 get-font-options

Retrieves font rendering options set via B<cairo_set_font_options>. Note that the returned options do not include any options derived from the underlying surface; they are literally the options passed to C<cairo_set_font_options()>.

  method get-font-options ( cairo_font_options_t $options )

=item cairo_font_options_t $options; a B<cairo_t>
=end pod

method get-font-options ( cairo_font_options_t $options ) {

  cairo_get_font_options(
    self._get-native-object-no-reffing, $options
  )
}

sub cairo_get_font_options (
  cairo_t $cr, cairo_font_options_t $options
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-group-target:
=begin pod
=head2 get-group-target

Gets the current destination surface for the context. This is either the original target surface as passed to C<cairo_create()> or the target surface for the current group as started by the most recent call to C<cairo_push_group()> or C<cairo_push_group_with_content()>.  This function will always return a valid pointer, but the result can be a "nil" surface if this context is already in an error state, (ie. C<cairo_status()> <literal>!=</literal> C<CAIRO_STATUS_SUCCESS>). A nil surface is indicated by C<cairo_surface_status()> <literal>!=</literal> C<CAIRO_STATUS_SUCCESS>.  Return value: the target surface. This object is owned by cairo. To keep a reference to it, you must call C<cairo_surface_reference()>.

  method get-group-target ( --> cairo_surface_t )

=end pod

method get-group-target ( --> cairo_surface_t ) {

  cairo_get_group_target(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_group_target (
  cairo_t $cr --> cairo_surface_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-line-cap:
=begin pod
=head2 get-line-cap

Gets the current line cap style, as set by C<cairo_set_line_cap()>.  Return value: the current line cap style.

  method get-line-cap ( --> Int )

=end pod

method get-line-cap ( --> Int ) {
  cairo_get_line_cap(self._get-native-object-no-reffing)
}

sub cairo_get_line_cap (
  cairo_t $cr --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-line-join:
=begin pod
=head2 get-line-join

Gets the current line join style, as set by C<cairo_set_line_join()>.  Return value: the current line join style.

  method get-line-join ( --> Int )

=end pod

method get-line-join ( --> Int ) {

  cairo_get_line_join(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_line_join (
  cairo_t $cr --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-line-width:
=begin pod
=head2 get-line-width

This function returns the current line width value exactly as set by C<cairo_set_line_width()>. Note that the value is unchanged even if the CTM has changed between the calls to C<cairo_set_line_width()> and C<cairo_get_line_width()>.  Return value: the current line width.

  method get-line-width ( --> Num )

=end pod

method get-line-width ( --> Num ) {

  cairo_get_line_width(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_line_width (
  cairo_t $cr --> gdouble
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-matrix:
=begin pod
=head2 get-matrix

Stores the current transformation matrix (CTM) into I<matrix>.

  method get-matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a cairo context
=end pod

method get-matrix ( cairo_matrix_t $matrix ) {

  cairo_get_matrix(
    self._get-native-object-no-reffing, $matrix
  )
}

sub cairo_get_matrix (
  cairo_t $cr, cairo_matrix_t $matrix
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-miter-limit:
=begin pod
=head2 get-miter-limit

Gets the current miter limit, as set by C<cairo_set_miter_limit()>.  Return value: the current miter limit.

  method get-miter-limit ( --> Num )

=end pod

method get-miter-limit ( --> Num ) {

  cairo_get_miter_limit(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_miter_limit (
  cairo_t $cr --> gdouble
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-opacity:
=begin pod
=head2 get-opacity

Gets the current compositing opacity for a cairo context.  Return value: the current compositing opacity.  Since: TBD

  method get-opacity ( --> Num )

=end pod

method get-opacity ( --> Num ) {

  cairo_get_opacity(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_opacity (
  cairo_t $cr --> gdouble
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-operator:
=begin pod
=head2 get-operator

Gets the current compositing operator for a cairo context.  Return value: the current compositing operator.

  method get-operator ( --> Int )

=end pod

method get-operator ( --> Int ) {

  cairo_get_operator(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_operator (
  cairo_t $cr --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-reference-count:
=begin pod
=head2 get-reference-count

Returns the current reference count of this context.  Return value: the current reference count of this context.  If the object is a nil object, 0 will be returned.

  method get-reference-count ( --> Int )

=end pod

method get-reference-count ( --> Int ) {

  cairo_get_reference_count(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_reference_count (
  cairo_t $cr --> guint
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-scaled-font:
=begin pod
=head2 get-scaled-font

Gets the current scaled font for a B<cairo_t>.  Return value: the current scaled font. This object is owned by cairo. To keep a reference to it, you must call C<cairo_scaled_font_reference()>.  This function never returns C<Any>. If memory cannot be allocated, a special "nil" B<cairo_scaled_font_t> object will be returned on which C<cairo_scaled_font_status()> returns C<CAIRO_STATUS_NO_MEMORY>. Using this nil object will cause its error state to propagate to other objects it is passed to, (for example, calling C<cairo_set_scaled_font()> with a nil font will trigger an error that will shutdown the B<cairo_t> object).

  method get-scaled-font ( --> cairo_scaled_font_t )

=end pod

method get-scaled-font ( --> cairo_scaled_font_t ) {

  cairo_get_scaled_font(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_scaled_font (
  cairo_t $cr --> cairo_scaled_font_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-source:
=begin pod
=head2 get-source

Gets the current source pattern for this context.  Return value: the current source pattern. This object is owned by cairo. To keep a reference to it, you must call C<cairo_pattern_reference()>.

  method get-source ( --> cairo_pattern_t )

=end pod

method get-source ( --> cairo_pattern_t ) {

  cairo_get_source(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_source (
  cairo_t $cr --> cairo_pattern_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-target:
=begin pod
=head2 get-target

Gets the target surface for the cairo context as passed to C<cairo_create()>.  This function will always return a valid pointer, but the result can be a "nil" surface if this context is already in an error state, (ie. C<cairo_status()> <literal>!=</literal> C<CAIRO_STATUS_SUCCESS>). A nil surface is indicated by C<cairo_surface_status()> <literal>!=</literal> C<CAIRO_STATUS_SUCCESS>.  Return value: the target surface. This object is owned by cairo. To keep a reference to it, you must call C<cairo_surface_reference()>.

  method get-target ( --> cairo_surface_t )

=end pod

method get-target ( --> cairo_surface_t ) {

  cairo_get_target(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_target (
  cairo_t $cr --> cairo_surface_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-tolerance:
=begin pod
=head2 get-tolerance

Gets the current tolerance value, as set by C<cairo_set_tolerance()>.  Return value: the current tolerance value.

  method get-tolerance ( --> Num )

=end pod

method get-tolerance ( --> Num ) {

  cairo_get_tolerance(
    self._get-native-object-no-reffing,
  )
}

sub cairo_get_tolerance (
  cairo_t $cr --> gdouble
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:get-user-data:
=begin pod
=head2 get-user-data

Return user data previously attached to this context using the specified key.  If no user data has been attached with the given key this function returns C<Any>.  Return value: the user data previously attached or C<Any>.

  method get-user-data ( cairo_user_data_key_t $key )

=item cairo_user_data_key_t $key; a B<cairo_t>
=end pod

method get-user-data ( cairo_user_data_key_t $key ) {

  cairo_get_user_data(
    self._get-native-object-no-reffing, $key
  )
}

sub cairo_get_user_data (
  cairo_t $cr, cairo_user_data_key_t $key
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:glyph-extents:
=begin pod
=head2 glyph-extents

Gets the extents for an array of glyphs. The extents describe a user-space rectangle that encloses the "inked" portion of the glyphs, (as they would be drawn by C<cairo_show_glyphs()>). Additionally, the x_advance and y_advance values indicate the amount by which the current point would be advanced by C<cairo_show_glyphs()>.  Note that whitespace glyphs do not contribute to the size of the rectangle (extents.width and extents.height).

  method glyph-extents ( cairo_glyph_t $glyphs, Int $num_glyphs, cairo_text_extents_t $extents )

=item cairo_glyph_t $glyphs; a B<cairo_t>
=item $num_glyphs; an array of B<cairo_glyph_t> objects
=item cairo_text_extents_t $extents; the number of elements in I<glyphs>
=end pod

method glyph-extents ( cairo_glyph_t $glyphs, Int $num_glyphs, cairo_text_extents_t $extents ) {

  cairo_glyph_extents(
    self._get-native-object-no-reffing, $glyphs, $num_glyphs, $extents
  )
}

sub cairo_glyph_extents (
  cairo_t $cr, cairo_glyph_t $glyphs, int32 $num_glyphs, cairo_text_extents_t $extents
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:glyph-path:
=begin pod
=head2 glyph-path

Adds closed paths for the glyphs to the current path.  The generated path if filled, achieves an effect similar to that of C<cairo_show_glyphs()>.

  method glyph-path ( cairo_glyph_t $glyphs, Int $num_glyphs )

=item cairo_glyph_t $glyphs; a cairo context
=item $num_glyphs; array of glyphs to show
=end pod

method glyph-path ( cairo_glyph_t $glyphs, Int $num_glyphs ) {

  cairo_glyph_path(
    self._get-native-object-no-reffing, $glyphs, $num_glyphs
  )
}

sub cairo_glyph_path (
  cairo_t $cr, cairo_glyph_t $glyphs, int32 $num_glyphs
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:has-current-point:
=begin pod
=head2 has-current-point

Returns whether a current point is defined on the current path. See C<cairo_get_current_point()> for details on the current point.  Return value: whether a current point is defined.

  method has-current-point ( --> Int )

=end pod

method has-current-point ( --> Int ) {

  cairo_has_current_point(
    self._get-native-object-no-reffing,
  )
}

sub cairo_has_current_point (
  cairo_t $cr --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:identity-matrix:
=begin pod
=head2 identity-matrix

Resets the current transformation matrix (CTM) by setting it equal to the identity matrix. That is, the user-space and device-space axes will be aligned and one user-space unit will transform to one device-space unit.

  method identity-matrix ( )

=end pod

method identity-matrix ( ) {

  cairo_identity_matrix(
    self._get-native-object-no-reffing,
  )
}

sub cairo_identity_matrix (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:in-clip:
=begin pod
=head2 in-clip

Tests whether the given point is inside the area that would be visible through the current clip, i.e. the area that would be filled by a C<cairo_paint()> operation.  See C<cairo_clip()>, and C<cairo_clip_preserve()>.  Return value: A non-zero value if the point is inside, or zero if outside.

  method in-clip ( Num $x, Num $y --> Int )

=item $x; a cairo context
=item $y; X coordinate of the point to test
=end pod

method in-clip ( Num $x, Num $y --> Int ) {

  cairo_in_clip(
    self._get-native-object-no-reffing, $x, $y
  )
}

sub cairo_in_clip (
  cairo_t $cr, gdouble $x, gdouble $y --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:in-fill:
=begin pod
=head2 in-fill

Tests whether the given point is inside the area that would be affected by a C<cairo_fill()> operation given the current path and filling parameters. Surface dimensions and clipping are not taken into account.  See C<cairo_fill()>, C<cairo_set_fill_rule()> and C<cairo_fill_preserve()>.  Return value: A non-zero value if the point is inside, or zero if outside.

  method in-fill ( Num $x, Num $y --> Int )

=item $x; a cairo context
=item $y; X coordinate of the point to test
=end pod

method in-fill ( Num $x, Num $y --> Int ) {

  cairo_in_fill(
    self._get-native-object-no-reffing, $x, $y
  )
}

sub cairo_in_fill (
  cairo_t $cr, gdouble $x, gdouble $y --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:in-stroke:
=begin pod
=head2 in-stroke

Tests whether the given point is inside the area that would be affected by a C<cairo_stroke()> operation given the current path and stroking parameters. Surface dimensions and clipping are not taken into account.  See C<cairo_stroke()>, C<cairo_set_line_width()>, C<cairo_set_line_join()>, C<cairo_set_line_cap()>, C<cairo_set_dash()>, and C<cairo_stroke_preserve()>.  Return value: A non-zero value if the point is inside, or zero if outside.

  method in-stroke ( Num $x, Num $y --> Int )

=item $x; a cairo context
=item $y; X coordinate of the point to test
=end pod

method in-stroke ( Num $x, Num $y --> Int ) {
  cairo_in_stroke( self._get-native-object-no-reffing, $x, $y)
}

sub cairo_in_stroke (
  cairo_t $cr, gdouble $x, gdouble $y --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:line-to:
=begin pod
=head2 line-to

Adds a line to the path from the current point to position (I<x>, I<y>) in user-space coordinates. After this call the current point will be (I<x>, I<y>).  If there is no current point before the call to C<cairo_line_to()> this function will behave as cairo_move_to(this context, I<x>, I<y>).

  method line-to ( Num() $x, Num() $y )

=item $x; a cairo context
=item $y; the X coordinate of the end of the new line
=end pod

method line-to ( Num() $x, Num() $y ) {
  cairo_line_to( self._get-native-object-no-reffing, $x, $y)
}

sub cairo_line_to (
  cairo_t $cr, gdouble $x, gdouble $y
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:mask:
=begin pod
=head2 mask

A drawing operator that paints the current source using the alpha channel of I<pattern> as a mask. (Opaque areas of I<pattern> are painted with the source, transparent areas are not painted.)

  method mask ( cairo_pattern_t $pattern )

=item cairo_pattern_t $pattern; a cairo context
=end pod

method mask ( $pattern is copy ) {
  $pattern .= get-native-object-no-reffing unless $pattern ~~ cairo_pattern_t;
  cairo_mask( self._get-native-object-no-reffing, $pattern)
}

sub cairo_mask (
  cairo_t $cr, cairo_pattern_t $pattern
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mask-surface:
=begin pod
=head2 mask-surface

A drawing operator that paints the current source using the alpha channel of I<surface> as a mask. (Opaque areas of I<surface> are painted with the source, transparent areas are not painted.)

  method mask-surface ( cairo_surface_t $surface, Num $surface_x, Num $surface_y )

=item cairo_surface_t $surface; a cairo context
=item $surface_x; a B<cairo_surface_t>
=item $surface_y; X coordinate at which to place the origin of I<surface>
=end pod

method mask-surface (
  cairo_surface_t $surface, Num() $surface_x, Num() $surface_y
) {
  cairo_mask_surface(
    self._get-native-object-no-reffing, $surface, $surface_x, $surface_y
  )
}

sub cairo_mask_surface (
  cairo_t $cr, cairo_surface_t $surface, gdouble $surface_x, gdouble $surface_y
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:move-to:
=begin pod
=head2 move-to

Begin a new sub-path. After this call the current point will be (I<x>, I<y>).

  method move-to ( Num() $x, Num() $y )

=item $x; a cairo context
=item $y; the X coordinate of the new position
=end pod

method move-to ( Num() $x, Num() $y ) {
  cairo_move_to( self._get-native-object-no-reffing, $x, $y)
}

sub cairo_move_to (
  cairo_t $cr, gdouble $x, gdouble $y
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:new-path:
=begin pod
=head2 new-path

Clears the current path. After this call there will be no path and no current point.

  method new-path ( )

=end pod

method new-path ( ) {
  cairo_new_path(self._get-native-object-no-reffing)
}

sub cairo_new_path (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:new-sub-path:
=begin pod
=head2 new-sub-path

Begin a new sub-path. Note that the existing path is not affected. After this call there will be no current point.  In many cases, this call is not needed since new sub-paths are frequently started with C<cairo_move_to()>.  A call to C<cairo_new_sub_path()> is particularly useful when beginning a new sub-path with one of the C<cairo_arc()> calls. This makes things easier as it is no longer necessary to manually compute the arc's initial coordinates for a call to C<cairo_move_to()>.

  method new-sub-path ( )

=end pod

method new-sub-path ( ) {

  cairo_new_sub_path(
    self._get-native-object-no-reffing,
  )
}

sub cairo_new_sub_path (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:paint:
=begin pod
=head2 paint

A drawing operator that paints the current source everywhere within the current clip region.

  method paint ( )

=end pod

method paint ( ) {
  cairo_paint(self._get-native-object-no-reffing)
}

sub cairo_paint (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:paint-with-alpha:
=begin pod
=head2 paint-with-alpha

A drawing operator that paints the current source everywhere within the current clip region using a mask of constant alpha value I<$alpha>. The effect is similar to C<paint()>, but the drawing is faded out using the alpha value.

  method paint-with-alpha ( Num() $alpha )

=item $alpha; a cairo context
=end pod

method paint-with-alpha ( Num() $alpha ) {
  cairo_paint_with_alpha( self._get-native-object-no-reffing, $alpha)
}

sub cairo_paint_with_alpha (
  cairo_t $cr, gdouble $alpha
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:path-extents:
=begin pod
=head2 path-extents

Computes a bounding box in user-space coordinates covering the points on the current path. If the current path is empty, returns an empty rectangle ((0,0), (0,0)). Stroke parameters, fill rule, surface dimensions and clipping are not taken into account.  Contrast with C<cairo_fill_extents()> and C<cairo_stroke_extents()> which return the extents of only the area that would be "inked" by the corresponding drawing operations.  The result of C<cairo_path_extents()> is defined as equivalent to the limit of C<cairo_stroke_extents()> with C<CAIRO_LINE_CAP_ROUND> as the line width approaches 0.0, (but never reaching the empty-rectangle returned by C<cairo_stroke_extents()> for a line width of 0.0).  Specifically, this means that zero-area sub-paths such as C<cairo_move_to()>;C<cairo_line_to()> segments, (even degenerate cases where the coordinates to both calls are identical), will be considered as contributing to the extents. However, a lone C<cairo_move_to()> will not contribute to the results of C<cairo_path_extents()>.

  method path-extents ( Num $x1, Num $y1, Num $x2, Num $y2 )

=item $x1; a cairo context
=item $y1; left of the resulting extents
=item $x2; top of the resulting extents
=item $y2; right of the resulting extents
=end pod

method path-extents ( Num $x1, Num $y1, Num $x2, Num $y2 ) {

  cairo_path_extents(
    self._get-native-object-no-reffing, $x1, $y1, $x2, $y2
  )
}

sub cairo_path_extents (
  cairo_t $cr, gdouble $x1, gdouble $y1, gdouble $x2, gdouble $y2
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:pop-group:
=begin pod
=head2 pop-group

Terminates the redirection begun by a call to C<cairo_push_group()> or C<cairo_push_group_with_content()> and returns a new pattern containing the results of all drawing operations performed to the group.  The C<cairo_pop_group()> function calls C<cairo_restore()>, (balancing a call to C<cairo_save()> by the push_group function), so that any changes to the graphics state will not be visible outside the group.  Return value: a newly created (surface) pattern containing the results of all drawing operations performed to the group. The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.

  method pop-group ( --> cairo_pattern_t )

=end pod

method pop-group ( --> cairo_pattern_t ) {

  cairo_pop_group(
    self._get-native-object-no-reffing,
  )
}

sub cairo_pop_group (
  cairo_t $cr --> cairo_pattern_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:pop-group-to-source:
=begin pod
=head2 pop-group-to-source

Terminates the redirection begun by a call to C<cairo_push_group()> or C<cairo_push_group_with_content()> and installs the resulting pattern as the source pattern in the given cairo context.  The behavior of this function is equivalent to the sequence of operations:

 cairo_pattern_t *group = cairo_pop_group (cr); cairo_set_source (cr, group); cairo_pattern_destroy (group);

   but is more convenient as their is no need for a variable to store the short-lived pointer to the pattern.  The C<cairo_pop_group()> function calls C<cairo_restore()>, (balancing a call to C<cairo_save()> by the push_group function), so that any changes to the graphics state will not be visible outside the group.

  method pop-group-to-source ( )

=end pod

method pop-group-to-source ( ) {

  cairo_pop_group_to_source(
    self._get-native-object-no-reffing,
  )
}

sub cairo_pop_group_to_source (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:push-group:
=begin pod
=head2 push-group

Temporarily redirects drawing to an intermediate surface known as a group. The redirection lasts until the group is completed by a call to C<cairo_pop_group()> or C<cairo_pop_group_to_source()>. These calls provide the result of any drawing to the group as a pattern, (either as an explicit object, or set as the source pattern).  This group functionality can be convenient for performing intermediate compositing. One common use of a group is to render objects as opaque within the group, (so that they occlude each other), and then blend the result with translucence onto the destination.  Groups can be nested arbitrarily deep by making balanced calls to C<cairo_push_group()>/C<cairo_pop_group()>. Each call pushes/pops the new target group onto/from a stack.  The C<cairo_push_group()> function calls C<cairo_save()> so that any changes to the graphics state will not be visible outside the group, (the pop_group functions call C<cairo_restore()>).  By default the intermediate group will have a content type of C<CAIRO_CONTENT_COLOR_ALPHA>. Other content types can be chosen for the group by using C<cairo_push_group_with_content()> instead.  As an example, here is how one might fill and stroke a path with translucence, but without any portion of the fill being visible under the stroke:

 cairo_push_group (cr); cairo_set_source (cr, fill_pattern); cairo_fill_preserve (cr); cairo_set_source (cr, stroke_pattern); cairo_stroke (cr); cairo_pop_group_to_source (cr); cairo_paint_with_alpha (cr, alpha);



  method push-group ( )

=end pod

method push-group ( ) {

  cairo_push_group(
    self._get-native-object-no-reffing,
  )
}

sub cairo_push_group (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:push-group-with-content:
=begin pod
=head2 push-group-with-content

Temporarily redirects drawing to an intermediate surface known as a group. The redirection lasts until the group is completed by a call to C<cairo_pop_group()> or C<cairo_pop_group_to_source()>. These calls provide the result of any drawing to the group as a pattern, (either as an explicit object, or set as the source pattern).  The group will have a content type of I<content>. The ability to control this content type is the only distinction between this function and C<cairo_push_group()> which you should see for a more detailed description of group rendering.

  method push-group-with-content ( Int $content )

=item $content; a cairo context
=end pod

method push-group-with-content ( Int $content ) {

  cairo_push_group_with_content(
    self._get-native-object-no-reffing, $content
  )
}

sub cairo_push_group_with_content (
  cairo_t $cr, gint32 $content
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:rectangle:
=begin pod
=head2 rectangle

Adds a closed sub-path rectangle of the given size to the current path at position (I<$x>, I<$y>) in user-space coordinates. This method is logically equivalent to:

=begin code
  $cairo.move-to( $x, $y);
  $cairo.rel-line-to( $width, 0);
  $cairo.rel-line-to( 0, $height);
  $cairo.rel-line-to( -$width, 0);
  $cairo.close.path;
=end code

=begin code
  method rectangle ( Num() $x, Num() $y, Num() $width, Num() $height )
=end code

=item $x; a cairo context
=item $y; the X coordinate of the top left corner of the rectangle
=item $width; the Y coordinate to the top left corner of the rectangle
=item $height; the width of the rectangle
=end pod

method rectangle ( Num() $x, Num() $y, Num() $width, Num() $height ) {
  cairo_rectangle(
    self._get-native-object-no-reffing, $x, $y, $width, $height
  )
}

sub cairo_rectangle (
  cairo_t $cr, gdouble $x, gdouble $y, gdouble $width, gdouble $height
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_reference:
#`{{
=begin pod
=head2 reference

Increases the reference count on this context by one. This prevents this context from being destroyed until a matching call to C<cairo_destroy()> is made.  Use C<cairo_get_reference_count()> to get the number of references to a B<cairo_t>.  Return value: the referenced B<cairo_t>.

  method reference ( --> cairo_t )

=end pod

method reference ( --> cairo_t ) {

  cairo_reference(
    self._get-native-object-no-reffing,
  )
}
}}

sub _cairo_reference (
  cairo_t $cr --> cairo_t
) is native(&cairo-lib)
  is symbol('cairo_reference')
  { * }

#-------------------------------------------------------------------------------
#TM:0:rel-curve-to:
=begin pod
=head2 rel-curve-to

Relative-coordinate version of C<cairo_curve_to()>. All offsets are relative to the current point. Adds a cubic Bézier spline to the path from the current point to a point offset from the current point by (I<dx3>, I<dy3>), using points offset by (I<dx1>, I<dy1>) and (I<dx2>, I<dy2>) as the control points. After this call the current point will be offset by (I<dx3>, I<dy3>).  Given a current point of (x, y), cairo_rel_curve_to(this context, I<dx1>, I<dy1>, I<dx2>, I<dy2>, I<dx3>, I<dy3>) is logically equivalent to cairo_curve_to(this context, x+I<dx1>, y+I<dy1>, x+I<dx2>, y+I<dy2>, x+I<dx3>, y+I<dy3>).  It is an error to call this function with no current point. Doing so will cause this context to shutdown with a status of C<CAIRO_STATUS_NO_CURRENT_POINT>.

  method rel-curve-to ( Num $dx1, Num $dy1, Num $dx2, Num $dy2, Num $dx3, Num $dy3 )

=item $dx1; a cairo context
=item $dy1; the X offset to the first control point
=item $dx2; the Y offset to the first control point
=item $dy2; the X offset to the second control point
=item $dx3; the Y offset to the second control point
=item $dy3; the X offset to the end of the curve
=end pod

method rel-curve-to ( Num $dx1, Num $dy1, Num $dx2, Num $dy2, Num $dx3, Num $dy3 ) {

  cairo_rel_curve_to(
    self._get-native-object-no-reffing, $dx1, $dy1, $dx2, $dy2, $dx3, $dy3
  )
}

sub cairo_rel_curve_to (
  cairo_t $cr, gdouble $dx1, gdouble $dy1, gdouble $dx2, gdouble $dy2, gdouble $dx3, gdouble $dy3
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:rel-line-to:
=begin pod
=head2 rel-line-to

Relative-coordinate version of C<line_to()>. Adds a line to the path from the current point to a point that is offset from the current point by (I<$dx>, I<$dy>) in user space. After this call the current point will be offset by (I<$dx>, I<$dy>).
Given a current point of (x, y), cairo_rel_line_to(this context, I<$dx>, I<$dy>) is logically equivalent to cairo_line_to(this context, x + I<$dx>, y + I<$dy>).
It is an error to call this function with no current point. Doing so will cause this context to shutdown with a status of C<CAIRO_STATUS_NO_CURRENT_POINT>.

  method rel-line-to ( Num() $dx, Num() $dy )

=item $dx; a cairo context
=item $dy; the X offset to the end of the new line
=end pod

method rel-line-to ( Num() $dx, Num() $dy ) {
  cairo_rel_line_to( self._get-native-object-no-reffing, $dx, $dy)
}

sub cairo_rel_line_to (
  cairo_t $cr, gdouble $dx, gdouble $dy
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:rel-move-to:
=begin pod
=head2 rel-move-to

Begin a new sub-path. After this call the current point will offset by (I<x>, I<y>).  Given a current point of (x, y), cairo_rel_move_to(this context, I<dx>, I<dy>) is logically equivalent to cairo_move_to(this context, x + I<dx>, y + I<dy>).  It is an error to call this function with no current point. Doing so will cause this context to shutdown with a status of C<CAIRO_STATUS_NO_CURRENT_POINT>.

  method rel-move-to ( Num $dx, Num $dy )

=item $dx; a cairo context
=item $dy; the X offset
=end pod

method rel-move-to ( Num $dx, Num $dy ) {

  cairo_rel_move_to(
    self._get-native-object-no-reffing, $dx, $dy
  )
}

sub cairo_rel_move_to (
  cairo_t $cr, gdouble $dx, gdouble $dy
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:reset-clip:
=begin pod
=head2 reset-clip

Reset the current clip region to its original, unrestricted state. That is, set the clip region to an infinitely large shape containing the target surface. Equivalently, if infinity is too hard to grasp, one can imagine the clip region being reset to the exact bounds of the target surface.  Note that code meant to be reusable should not call C<cairo_reset_clip()> as it will cause results unexpected by higher-level code which calls C<cairo_clip()>. Consider using C<cairo_save()> and C<cairo_restore()> around C<cairo_clip()> as a more robust means of temporarily restricting the clip region.

  method reset-clip ( )

=end pod

method reset-clip ( ) {

  cairo_reset_clip(
    self._get-native-object-no-reffing,
  )
}

sub cairo_reset_clip (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:restore:
=begin pod
=head2 restore

Restores this context to the state saved by a preceding call to C<cairo_save()> and removes that state from the stack of saved states.

  method restore ( )

=end pod

method restore ( ) {

  cairo_restore(
    self._get-native-object-no-reffing,
  )
}

sub cairo_restore (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:rotate:
=begin pod
=head2 rotate

Modifies the current transformation matrix (CTM) by rotating the user-space axes by I<angle> radians. The rotation of the axes takes places after any existing transformation of user space. The rotation direction for positive angles is from the positive X axis toward the positive Y axis.

  method rotate ( Num $angle )

=item $angle; a cairo context
=end pod

method rotate ( Num $angle ) {

  cairo_rotate(
    self._get-native-object-no-reffing, $angle
  )
}

sub cairo_rotate (
  cairo_t $cr, gdouble $angle
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:save:
=begin pod
=head2 save

Makes a copy of the current state of this context and saves it on an internal stack of saved states for this context. When C<cairo_restore()> is called, this context will be restored to the saved state. Multiple calls to C<cairo_save()> and C<cairo_restore()> can be nested; each call to C<cairo_restore()> restores the state from the matching paired C<cairo_save()>.  It isn't necessary to clear all saved states before a B<cairo_t> is freed. If the reference count of a B<cairo_t> drops to zero in response to a call to C<cairo_destroy()>, any saved states will be freed along with the B<cairo_t>.

  method save ( )

=end pod

method save ( ) {

  cairo_save(
    self._get-native-object-no-reffing,
  )
}

sub cairo_save (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:scale:
=begin pod
=head2 scale

Modifies the current transformation matrix (CTM) by scaling the X and Y user-space axes by I<sx> and I<sy> respectively. The scaling of the axes takes place after any existing transformation of user space.

  method scale ( Num $sx, Num $sy )

=item $sx; a cairo context
=item $sy; scale factor for the X dimension
=end pod

method scale ( Num $sx, Num $sy ) {

  cairo_scale(
    self._get-native-object-no-reffing, $sx, $sy
  )
}

sub cairo_scale (
  cairo_t $cr, gdouble $sx, gdouble $sy
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:select-font-face:
=begin pod
=head2 select-font-face

Note: The C<select-font-face()> function call is part of what the cairo designers call the "toy" text API. It is convenient for short demos and simple programs, but it is not expected to be adequate for serious text-using applications.

Selects a family and style of font from a simplified description as a family name, slant and weight. Cairo provides no operation to list available family names on the system (this is a "toy", remember), but the standard CSS2 generic family names, ("serif", "sans-serif", "cursive", "fantasy", "monospace"), are likely to work as expected.

If I<$family> starts with the string "C<cairo:>", or if no native font backends are compiled in, cairo will use an internal font family. The internal font family recognizes many modifiers in the I<$family> string, most notably, it recognizes the string "monospace". That is, the family name "I<cairo>:monospace" will use the monospace version of the internal font family.

=comment For "real" font selection, see the font-backend-specific font_face_create functions for the font backend you are using.
=comment (For example, if you are using the freetype-based cairo-ft font backend, see C<cairo_ft_font_face_create_for_ft_face()> or C<cairo_ft_font_face_create_for_pattern()>.) The resulting font face could then be used with C<cairo_scaled_font_create()> and C<cairo_set_scaled_font()>.

=comment Similarly, when using the "real" font support, you can call directly into the underlying font system, (such as fontconfig or freetype), for operations such as listing available fonts, etc.

It is expected that most applications will need to use a more comprehensive font handling and text layout library, (for example, pango), in conjunction with cairo.

If text is drawn without a call to C<select-font-face()>, (nor C<set-font-face()> nor C<set-scaled-font()>), the default family is platform-specific, but is essentially "sans-serif". Default slant is C<CAIRO_FONT_SLANT_NORMAL>, and default weight is C<CAIRO_FONT_WEIGHT_NORMAL>.

=comment This function is equivalent to a call to C<toy_font_face_create()> followed by C<set_font_face()>.

  method select-font-face (
    Str $family, cairo_font_slant_t $slant,
    cairo_font_weight_t $weight
  )

=item $family; a B<cairo_t>
=item $slant; a font family name
=item $weight; the slant for the font
=end pod

method select-font-face ( Str $family, Int $slant, Int $weight ) {
  cairo_select_font_face(
    self._get-native-object-no-reffing, $family, $slant, $weight
  )
}

sub cairo_select_font_face (
  cairo_t $cr, gchar-ptr $family, GEnum $slant, GEnum $weight
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-antialias:
=begin pod
=head2 set-antialias

Set the antialiasing mode of the rasterizer used for drawing shapes. This value is a hint, and a particular backend may or may not support a particular value.  At the current time, no backend supports C<CAIRO_ANTIALIAS_SUBPIXEL> when drawing shapes.  Note that this option does not affect text rendering, instead see C<cairo_font_options_set_antialias()>.

  method set-antialias ( Int $antialias )

=item $antialias; a B<cairo_t>
=end pod

method set-antialias ( Int $antialias ) {
  cairo_set_antialias( self._get-native-object-no-reffing, $antialias)
}

sub cairo_set_antialias (
  cairo_t $cr, gint32 $antialias
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-dash:
=begin pod
=head2 set-dash

Sets the dash pattern to be used by C<cairo_stroke()>. A dash pattern is specified by I<dashes>, an array of positive values. Each value provides the length of alternate "on" and "off" portions of the stroke. The I<offset> specifies an offset into the pattern at which the stroke begins.  Each "on" segment will have caps applied as if the segment were a separate sub-path. In particular, it is valid to use an "on" length of 0.0 with C<CAIRO_LINE_CAP_ROUND> or C<CAIRO_LINE_CAP_SQUARE> in order to distributed dots or squares along a path.  Note: The length values are in user-space units as evaluated at the time of stroking. This is not necessarily the same as the user space at the time of C<cairo_set_dash()>.  If I<num_dashes> is 0 dashing is disabled.  If I<num_dashes> is 1 a symmetric pattern is assumed with alternating on and off portions of the size specified by the single value in I<dashes>.  If any value in I<dashes> is negative, or if all values are 0, then this context will be put into an error state with a status of C<CAIRO_STATUS_INVALID_DASH>.

  method set-dash ( Num $dashes, Int $num_dashes, Num $offset )

=item $dashes; a cairo context
=item $num_dashes; an array specifying alternate lengths of on and off stroke portions
=item $offset; the length of the dashes array
=end pod

method set-dash ( Num $dashes, Int $num_dashes, Num $offset ) {

  cairo_set_dash(
    self._get-native-object-no-reffing, $dashes, $num_dashes, $offset
  )
}

sub cairo_set_dash (
  cairo_t $cr, gdouble $dashes, int32 $num_dashes, gdouble $offset
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-fill-rule:
=begin pod
=head2 set-fill-rule

Set the current fill rule within the cairo context. The fill rule is used to determine which regions are inside or outside a complex (potentially self-intersecting) path. The current fill rule affects both C<cairo_fill()> and C<cairo_clip()>. See B<cairo_fill_rule_t> for details on the semantics of each available fill rule.  The default fill rule is C<CAIRO_FILL_RULE_WINDING>.

  method set-fill-rule ( Int $fill_rule )

=item $fill_rule; a B<cairo_t>
=end pod

method set-fill-rule ( Int $fill_rule ) {

  cairo_set_fill_rule(
    self._get-native-object-no-reffing, $fill_rule
  )
}

sub cairo_set_fill_rule (
  cairo_t $cr, gint32 $fill_rule
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-font-face:
=begin pod
=head2 set-font-face

Replaces the current B<cairo_font_face_t> object in the B<cairo_t> with I<font_face>. The replaced font face in the B<cairo_t> will be destroyed if there are no other references to it.

  method set-font-face ( cairo_font_face_t $font_face )

=item cairo_font_face_t $font_face; a B<cairo_t>
=end pod

method set-font-face ( cairo_font_face_t $font_face ) {

  cairo_set_font_face(
    self._get-native-object-no-reffing, $font_face
  )
}

sub cairo_set_font_face (
  cairo_t $cr, cairo_font_face_t $font_face
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-font-matrix:
=begin pod
=head2 set-font-matrix

Sets the current font matrix to I<matrix>. The font matrix gives a transformation from the design space of the font (in this space, the em-square is 1 unit by 1 unit) to user space. Normally, a simple scale is used (see C<set-font-size()>), but a more complex font matrix can be used to shear the font or stretch it unequally along the two axes

  method set-font-matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a B<cairo_t>
=end pod

method set-font-matrix ( cairo_matrix_t $matrix ) {

  cairo_set_font_matrix(
    self._get-native-object-no-reffing, $matrix
  )
}

sub cairo_set_font_matrix (
  cairo_t $cr, cairo_matrix_t $matrix
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-font-options:
=begin pod
=head2 set-font-options

Sets a set of custom font rendering options for the B<cairo_t>. Rendering options are derived by merging these options with the options derived from underlying surface; if the value in I<options> has a default value (like C<CAIRO_ANTIALIAS_DEFAULT>), then the value from the surface is used.

  method set-font-options ( cairo_font_options_t $options )

=item cairo_font_options_t $options; a B<cairo_t>
=end pod

method set-font-options ( cairo_font_options_t $options ) {

  cairo_set_font_options(
    self._get-native-object-no-reffing, $options
  )
}

sub cairo_set_font_options (
  cairo_t $cr, cairo_font_options_t $options
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:set-font-size:
=begin pod
=head2 set-font-size

Sets the current font matrix to a scale by a factor of I<size>, replacing any font matrix previously set with C<set-font-size()> or C<set-font-matrix()>. This results in a font size of I<size> user space units. (More precisely, this matrix will result in the font's em-square being a I<$size> by I<$size> square in user space.)

If text is drawn without a call to C<set-font-size()>, (nor C<set-font-matrix()> nor C<cset-scaled-font()>), the default font size is 10.0.

  method set-font-size ( Num() $size )

=item $size; The size of the current font
=end pod

method set-font-size ( Num() $size ) {
  cairo_set_font_size( self._get-native-object-no-reffing, $size)
}

sub cairo_set_font_size (
  cairo_t $cr, gdouble $size
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-line-cap:
=begin pod
=head2 set-line-cap

Sets the current line cap style within the cairo context. See B<cairo_line_cap_t> for details about how the available line cap styles are drawn.  As with the other stroke parameters, the current line cap style is examined by C<cairo_stroke()>, C<cairo_stroke_extents()>, and C<cairo_stroke_to_path()>, but does not have any effect during path construction.  The default line cap style is C<CAIRO_LINE_CAP_BUTT>.

  method set-line-cap ( Int $line_cap )

=item $line_cap; a cairo context
=end pod

method set-line-cap ( Int $line_cap ) {

  cairo_set_line_cap(
    self._get-native-object-no-reffing, $line_cap
  )
}

sub cairo_set_line_cap (
  cairo_t $cr, gint32 $line_cap
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-line-join:
=begin pod
=head2 set-line-join

Sets the current line join style within the cairo context. See B<cairo_line_join_t> for details about how the available line join styles are drawn.  As with the other stroke parameters, the current line join style is examined by C<cairo_stroke()>, C<cairo_stroke_extents()>, and C<cairo_stroke_to_path()>, but does not have any effect during path construction.  The default line join style is C<CAIRO_LINE_JOIN_MITER>.

  method set-line-join ( Int $line_join )

=item $line_join; a cairo context
=end pod

method set-line-join ( Int $line_join ) {

  cairo_set_line_join(
    self._get-native-object-no-reffing, $line_join
  )
}

sub cairo_set_line_join (
  cairo_t $cr, gint32 $line_join
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:set-line-width:
=begin pod
=head2 set-line-width

Sets the current line width within the cairo context. The line width value specifies the diameter of a pen that is circular in user space, (though device-space pen may be an ellipse in general due to scaling/shear/rotation of the CTM).
Note: When the description above refers to user space and CTM it refers to the user space and CTM in effect at the time of the stroking operation, not the user space and CTM in effect at the time of the call to C<set-line-width()>. The simplest usage makes both of these spaces identical. That is, if there is no change to the CTM between a call to C<set-line-width()> and the stroking operation, then one can just pass user-space values to C<set-line-width()> and ignore this note.
As with the other stroke parameters, the current line width is examined by C<stroke()>, C<stroke-extents()>, and C<stroke-to-path()>, but does not have any effect during path construction.
The default line width value is 2.0.

  method set-line-width ( Num() $width )

=item $width; a B<cairo_t>
=end pod

method set-line-width ( Num() $width ) {
  cairo_set_line_width( self._get-native-object-no-reffing, $width)
}

sub cairo_set_line_width (
  cairo_t $cr, gdouble $width
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-matrix:
=begin pod
=head2 set-matrix

Modifies the current transformation matrix (CTM) by setting it equal to I<matrix>.

  method set-matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a cairo context
=end pod

method set-matrix ( cairo_matrix_t $matrix ) {

  cairo_set_matrix(
    self._get-native-object-no-reffing, $matrix
  )
}

sub cairo_set_matrix (
  cairo_t $cr, cairo_matrix_t $matrix
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-miter-limit:
=begin pod
=head2 set-miter-limit

Sets the current miter limit within the cairo context.  If the current line join style is set to C<CAIRO_LINE_JOIN_MITER> (see C<cairo_set_line_join()>), the miter limit is used to determine whether the lines should be joined with a bevel instead of a miter. Cairo divides the length of the miter by the line width. If the result is greater than the miter limit, the style is converted to a bevel.  As with the other stroke parameters, the current line miter limit is examined by C<cairo_stroke()>, C<cairo_stroke_extents()>, and C<cairo_stroke_to_path()>, but does not have any effect during path construction.  The default miter limit value is 10.0, which will convert joins with interior angles less than 11 degrees to bevels instead of miters. For reference, a miter limit of 2.0 makes the miter cutoff at 60 degrees, and a miter limit of 1.414 makes the cutoff at 90 degrees.  A miter limit for a desired angle can be computed as: miter limit = 1/sin(angle/2)

  method set-miter-limit ( Num $limit )

=item $limit; a cairo context
=end pod

method set-miter-limit ( Num $limit ) {

  cairo_set_miter_limit(
    self._get-native-object-no-reffing, $limit
  )
}

sub cairo_set_miter_limit (
  cairo_t $cr, gdouble $limit
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-operator:
=begin pod
=head2 set-operator

Sets the compositing operator to be used for all drawing operations. See B<cairo_operator_t> for details on the semantics of each available compositing operator.  The default operator is C<CAIRO_OPERATOR_OVER>.

  method set-operator ( Int $op )

=item $op; a B<cairo_t>
=end pod

method set-operator ( Int $op ) {

  cairo_set_operator(
    self._get-native-object-no-reffing, $op
  )
}

sub cairo_set_operator (
  cairo_t $cr, gint32 $op
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-scaled-font:
=begin pod
=head2 set-scaled-font

Replaces the current font face, font matrix, and font options in the B<cairo_t> with those of the B<cairo_scaled_font_t>.  Except for some translation, the current CTM of the B<cairo_t> should be the same as that of the B<cairo_scaled_font_t>, which can be accessed using C<cairo_scaled_font_get_ctm()>.

  method set-scaled-font ( cairo_scaled_font_t $scaled_font )

=item cairo_scaled_font_t $scaled_font; a B<cairo_t>
=end pod

method set-scaled-font ( cairo_scaled_font_t $scaled_font ) {

  cairo_set_scaled_font(
    self._get-native-object-no-reffing, $scaled_font
  )
}

sub cairo_set_scaled_font (
  cairo_t $cr, cairo_scaled_font_t $scaled_font
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:set-source:
=begin pod
=head2 set-source

Sets the source pattern within this context to I<source>. This pattern will then be used for any subsequent drawing operation until a new source pattern is set.  Note: The pattern's transformation matrix will be locked to the user space in effect at the time of C<set-source()>. This means that further modifications of the current transformation matrix will not affect the source pattern. See C<pattern-set-matrix()>.  The default source pattern is a solid pattern that is opaque black, (that is, it is equivalent to C<set-source-rgb( 0.0, 0.0, 0.0))>.

  method set-source ( cairo_pattern_t $source )

=item cairo_pattern_t $source; a cairo context
=end pod

method set-source ( $source is copy ) {
  $source .= get-native-object-no-reffing unless $source ~~ cairo_pattern_t;
  cairo_set_source( self._get-native-object-no-reffing, $source)
}

sub cairo_set_source (
  cairo_t $cr, cairo_pattern_t $source
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:set-source-rgb:
=begin pod
=head2 set-source-rgb

Sets the source pattern within this context to an opaque color. This opaque color will then be used for any subsequent drawing operation until a new source pattern is set.
The color components are floating point numbers in the range 0 to 1. If the values passed in are outside that range, they will be clamped.
The default source pattern is opaque black, (that is, it is equivalent to C<set_source_rgb( 0.0, 0.0, 0.0)>).

  method set-source-rgb ( Num() $red, Num() $green, Num() $blue )

=item $red; a cairo context
=item $green; red component of color
=item $blue; green component of color
=end pod

method set-source-rgb ( Num() $red, Num() $green, Num() $blue ) {
  cairo_set_source_rgb(
    self._get-native-object-no-reffing, $red, $green, $blue
  )
}

sub cairo_set_source_rgb (
  cairo_t $cr, gdouble $red, gdouble $green, gdouble $blue
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:set-source-rgba:
=begin pod
=head2 set-source-rgba

Sets the source pattern within this context to a translucent color. This color will then be used for any subsequent drawing operation until a new source pattern is set.  The color and alpha components are floating point numbers in the range 0 to 1. If the values passed in are outside that range, they will be clamped.  The default source pattern is opaque black, (that is, it is equivalent to C<set_source_rgba( 0.0, 0.0, 0.0, 1.0))>.

  method set-source-rgba (
    Num() $red, Num() $green, Num() $blue, Num() $alpha
  )

=item $red; a cairo context
=item $green; red component of color
=item $blue; green component of color
=item $alpha; blue component of color
=end pod

method set-source-rgba ( Num() $red, Num() $green, Num() $blue, Num() $alpha ) {
  cairo_set_source_rgba(
    self._get-native-object-no-reffing, $red, $green, $blue, $alpha
  )
}

sub cairo_set_source_rgba (
  cairo_t $cr, gdouble $red, gdouble $green, gdouble $blue, gdouble $alpha
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-source-surface:
=begin pod
=head2 set-source-surface

This is a convenience function for creating a pattern from I<surface> and setting it as the source in this context with C<cairo_set_source()>.  The I<x> and I<y> parameters give the user-space coordinate at which the surface origin should appear. (The surface origin is its upper-left corner before any transformation has been applied.) The I<x> and I<y> parameters are negated and then set as translation values in the pattern matrix.  Other than the initial translation pattern matrix, as described above, all other pattern attributes, (such as its extend mode), are set to the default values as in C<cairo_pattern_create_for_surface()>. The resulting pattern can be queried with C<cairo_get_source()> so that these attributes can be modified if desired, (eg. to create a repeating pattern with C<cairo_pattern_set_extend()>).

  method set-source-surface ( cairo_surface_t $surface, Num $x, Num $y )

=item cairo_surface_t $surface; a cairo context
=item $x; a surface to be used to set the source pattern
=item $y; User-space X coordinate for surface origin
=end pod

method set-source-surface ( cairo_surface_t $surface, Num $x, Num $y ) {

  cairo_set_source_surface(
    self._get-native-object-no-reffing, $surface, $x, $y
  )
}

sub cairo_set_source_surface (
  cairo_t $cr, cairo_surface_t $surface, gdouble $x, gdouble $y
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-tolerance:
=begin pod
=head2 set-tolerance

Sets the tolerance used when converting paths into trapezoids. Curved segments of the path will be subdivided until the maximum deviation between the original path and the polygonal approximation is less than I<tolerance>. The default value is 0.1. A larger value will give better performance, a smaller value, better appearance. (Reducing the value from the default value of 0.1 is unlikely to improve appearance significantly.)  The accuracy of paths within Cairo is limited by the precision of its internal arithmetic, and the prescribed I<tolerance> is restricted to the smallest representable internal value.

  method set-tolerance ( Num $tolerance )

=item $tolerance; a B<cairo_t>
=end pod

method set-tolerance ( Num $tolerance ) {

  cairo_set_tolerance(
    self._get-native-object-no-reffing, $tolerance
  )
}

sub cairo_set_tolerance (
  cairo_t $cr, gdouble $tolerance
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:set-user-data:
=begin pod
=head2 set-user-data

Attach user data to this context.  To remove user data from a surface, call this function with the key that was used to set it and C<Any> for I<data>.  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY> if a slot could not be allocated for the user data.

  method set-user-data ( cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> Int )

=item cairo_user_data_key_t $key; a B<cairo_t>
=item void-ptr $user_data; the address of a B<cairo_user_data_key_t> to attach the user data to
=item cairo_destroy_func_t $destroy; the user data to attach to the B<cairo_t>
=end pod

method set-user-data ( cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> Int ) {

  cairo_set_user_data(
    self._get-native-object-no-reffing, $key, $user_data, $destroy
  )
}

sub cairo_set_user_data (
  cairo_t $cr, cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> gint32
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:show-glyphs:
=begin pod
=head2 show-glyphs

A drawing operator that generates the shape from an array of glyphs, rendered according to the current font face, font size (font matrix), and font options.

  method show-glyphs ( cairo_glyph_t $glyphs, Int $num_glyphs )

=item cairo_glyph_t $glyphs; a cairo context
=item $num_glyphs; array of glyphs to show
=end pod

method show-glyphs ( cairo_glyph_t $glyphs, Int $num_glyphs ) {

  cairo_show_glyphs(
    self._get-native-object-no-reffing, $glyphs, $num_glyphs
  )
}

sub cairo_show_glyphs (
  cairo_t $cr, cairo_glyph_t $glyphs, int32 $num_glyphs
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:show-page:
=begin pod
=head2 show-page

Emits and clears the current page for backends that support multiple pages.  Use C<cairo_copy_page()> if you don't want to clear the page.  This is a convenience function that simply calls C<cairo_surface_show_page()> on this context's target.

  method show-page ( )

=end pod

method show-page ( ) {

  cairo_show_page(
    self._get-native-object-no-reffing,
  )
}

sub cairo_show_page (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:show-text:
=begin pod
=head2 show-text

A drawing operator that generates the shape from a string of UTF-8 characters, rendered according to the current font_face, font_size (font_matrix), and font_options.

This function first computes a set of glyphs for the string of text. The first glyph is placed so that its origin is at the current point. The origin of each subsequent glyph is offset from that of the previous glyph by the advance values of the previous glyph.

After this call the current point is moved to the origin of where the next glyph would be placed in this same progression. That is, the current point will be at the origin of the final glyph offset by its advance values. This allows for easy display of a single logical string with multiple calls to C<show-text()>.

Note: The C<show-text()> function call is part of what the cairo designers call the "toy" text API. It is convenient for short demos and simple programs, but it is not expected to be adequate for serious text-using applications. See C<show-glyphs()> for the "real" text display API in cairo.

  method show-text ( Str $utf8-string )

=item $utf8-string; a string to show
=end pod

method show-text ( Str $utf8-string ) {
  cairo_show_text( self._get-native-object-no-reffing, $utf8-string)
}

sub cairo_show_text (
  cairo_t $cr, gchar-ptr $utf8-string
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:show-text-glyphs:
=begin pod
=head2 show-text-glyphs

This operation has rendering effects similar to C<cairo_show_glyphs()> but, if the target surface supports it, uses the provided text and cluster mapping to embed the text for the glyphs shown in the output. If the target does not support the extended attributes, this function acts like the basic C<cairo_show_glyphs()> as if it had been passed I<glyphs> and I<num_glyphs>.  The mapping between I<utf8> and I<glyphs> is provided by an array of I<clusters>.  Each cluster covers a number of text bytes and glyphs, and neighboring clusters cover neighboring areas of I<utf8> and I<glyphs>.  The clusters should collectively cover I<utf8> and I<glyphs> in entirety.  The first cluster always covers bytes from the beginning of I<utf8>. If I<cluster_flags> do not have the C<CAIRO_TEXT_CLUSTER_FLAG_BACKWARD> set, the first cluster also covers the beginning of I<glyphs>, otherwise it covers the end of the I<glyphs> array and following clusters move backward.  See B<cairo_text_cluster_t> for constraints on valid clusters.

  method show-text-glyphs ( Int $utf8_len, cairo_glyph_t $glyphs, Int $num_glyphs, cairo_text_cluster_t $clusters, Int $num_clusters, Int $cluster_flags )

=item $utf8; a cairo context
=item $utf8_len; a string of text encoded in UTF-8
=item cairo_glyph_t $glyphs; length of I<utf8> in bytes, or -1 if it is NUL-terminated
=item $num_glyphs; array of glyphs to show
=item cairo_text_cluster_t $clusters; number of glyphs to show
=item $num_clusters; array of cluster mapping information
=item $cluster_flags; number of clusters in the mapping
=end pod

method show-text-glyphs ( Int $utf8_len, cairo_glyph_t $glyphs, Int $num_glyphs, cairo_text_cluster_t $clusters, Int $num_clusters, Int $cluster_flags ) {

  cairo_show_text_glyphs(
    self._get-native-object-no-reffing, my gint $utf8, $utf8_len, $glyphs, $num_glyphs, $clusters, $num_clusters, $cluster_flags
  )
}

sub cairo_show_text_glyphs (
  cairo_t $cr, gchar-ptr $utf8, int32 $utf8_len, cairo_glyph_t $glyphs, int32 $num_glyphs, cairo_text_cluster_t $clusters, int32 $num_clusters, gint32 $cluster_flags
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:status:
=begin pod
=head2 status

Checks whether an error has previously occurred for this context.  Returns: the current status of this context, see B<cairo_status_t>

  method status ( --> cairo_status_t )

=end pod

method status ( --> cairo_status_t ) {
  cairo_status_t(cairo_status(self._get-native-object-no-reffing))
}

sub cairo_status (
  cairo_t $cr --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:status-to-string:
=begin pod
=head2 status-to-string

Provides a human-readable description of a cairo_status_t.

  method status-to-string ( cairo_status_t $status --> Str )

=end pod

method status-to-string ( cairo_status_t $status --> Str ) {
  cairo_status_to_string($status.value)
}

sub cairo_status_to_string ( int32 $status --> Str )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:stroke:
=begin pod
=head2 stroke

A drawing operator that strokes the current path according to the current line width, line join, line cap, and dash settings. After C<stroke()>, the current path will be cleared from the cairo context. See C<set_line_width()>, C<set_line_join()>, C<cset_line_cap()>, C<set_dash()>, and C<stroke_preserve()>.

Note: Degenerate segments and sub-paths are treated specially and provide a useful result. These can result in two different situations:
=item Zero-length "on" segments set in C<set_dash()>. If the cap style is C<CAIRO_LINE_CAP_ROUND> or C<CAIRO_LINE_CAP_SQUARE> then these segments will be drawn as circular dots or squares respectively. In the case of C<CAIRO_LINE_CAP_SQUARE>, the orientation of the squares is determined by the direction of the underlying path.
=item A sub-path created by C<cairo_move_to()> followed by either a C<cairo_close_path()> or one or more calls to C<cairo_line_to()> to the same coordinate as the C<cairo_move_to()>. If the cap style is C<CAIRO_LINE_CAP_ROUND> then these sub-paths will be drawn as circular dots.

Note that in the case of C<CAIRO_LINE_CAP_SQUARE> a degenerate sub-path will not be drawn at all, (since the correct orientation is indeterminate).  In no case will a cap style of C<CAIRO_LINE_CAP_BUTT> cause anything to be drawn in the case of either degenerate segments or sub-paths.

  method stroke ( )

=end pod

method stroke ( ) {

  cairo_stroke(
    self._get-native-object-no-reffing,
  )
}

sub cairo_stroke (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:stroke-extents:
=begin pod
=head2 stroke-extents

Computes a bounding box in user coordinates covering the area that would be affected, (the "inked" area), by a C<cairo_stroke()> operation given the current path and stroke parameters. If the current path is empty, returns an empty rectangle ((0,0), (0,0)). Surface dimensions and clipping are not taken into account.  Note that if the line width is set to exactly zero, then C<cairo_stroke_extents()> will return an empty rectangle. Contrast with C<cairo_path_extents()> which can be used to compute the non-empty bounds as the line width approaches zero.  Note that C<cairo_stroke_extents()> must necessarily do more work to compute the precise inked areas in light of the stroke parameters, so C<cairo_path_extents()> may be more desirable for sake of performance if non-inked path extents are desired.  See C<cairo_stroke()>, C<cairo_set_line_width()>, C<cairo_set_line_join()>, C<cairo_set_line_cap()>, C<cairo_set_dash()>, and C<cairo_stroke_preserve()>.

  method stroke-extents ( Num $x1, Num $y1, Num $x2, Num $y2 )

=item $x1; a cairo context
=item $y1; left of the resulting extents
=item $x2; top of the resulting extents
=item $y2; right of the resulting extents
=end pod

method stroke-extents ( Num $x1, Num $y1, Num $x2, Num $y2 ) {

  cairo_stroke_extents(
    self._get-native-object-no-reffing, $x1, $y1, $x2, $y2
  )
}

sub cairo_stroke_extents (
  cairo_t $cr, gdouble $x1, gdouble $y1, gdouble $x2, gdouble $y2
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:stroke-preserve:
=begin pod
=head2 stroke-preserve

A drawing operator that strokes the current path according to the current line width, line join, line cap, and dash settings. Unlike C<cairo_stroke()>, C<cairo_stroke_preserve()> preserves the path within the cairo context.  See C<cairo_set_line_width()>, C<cairo_set_line_join()>, C<cairo_set_line_cap()>, C<cairo_set_dash()>, and C<cairo_stroke_preserve()>.

  method stroke-preserve ( )

=end pod

method stroke-preserve ( ) {

  cairo_stroke_preserve(
    self._get-native-object-no-reffing,
  )
}

sub cairo_stroke_preserve (
  cairo_t $cr
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:tag-begin:
=begin pod
=head2 tag-begin

Create a destination for a hyperlink. Destination tag attributes are detailed at [Destinations][dests].   CAIRO_TAG_LINK:  Create hyperlink. Link tag attributes are detailed at [Links][links].  Since: 1.16 cairo_tag_begin:  Marks the beginning of the I<tag_name> structure. Call C<cairo_tag_end()> with the same I<tag_name> to mark the end of the structure.  The attributes string is of the form "key1=value2 key2=value2 ...". Values may be boolean (true/false or 1/0), integer, float, string, or an array.  String values are enclosed in single quotes ('). Single quotes and backslashes inside the string should be escaped with a backslash.  Boolean values may be set to true by only specifying the key. eg the attribute string "key" is the equivalent to "key=true".  Arrays are enclosed in '[]'. eg "rect=[1.2 4.3 2.0 3.0]".  If no attributes are required, I<attributes> can be an empty string or NULL.  See [Tags and Links Description][cairo-Tags-and-Links.description] for the list of tags and attributes.  Invalid nesting of tags or invalid attributes will cause this context to shutdown with a status of C<CAIRO_STATUS_TAG_ERROR>.  See C<cairo_tag_end()>.  Since: 1.16

  method tag-begin ( )

=item $tag_name;
=item $attributes;
=end pod

method tag-begin ( ) {

  cairo_tag_begin(
    self._get-native-object-no-reffing, my gint $tag_name, my gint $attributes
  )
}

sub cairo_tag_begin (
  cairo_t $cr, gchar-ptr $tag_name, gchar-ptr $attributes
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:tag-end:
=begin pod
=head2 tag-end

Marks the end of the I<tag_name> structure.  Invalid nesting of tags will cause this context to shutdown with a status of C<CAIRO_STATUS_TAG_ERROR>.  See C<cairo_tag_begin()>.

  method tag-end ( )

=item $tag_name; a cairo context
=end pod

method tag-end ( ) {

  cairo_tag_end(
    self._get-native-object-no-reffing, my gint $tag_name
  )
}

sub cairo_tag_end (
  cairo_t $cr, gchar-ptr $tag_name
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:text-extents:
=begin pod
=head2 text-extents

Gets the extents for a string of text. The extents describe a user-space rectangle that encloses the "inked" portion of the text, (as it would be drawn by C<show-text()>). Additionally, the x_advance and y_advance values indicate the amount by which the current point would be advanced by C<show-text()>.

Note that whitespace characters do not directly contribute to the size of the rectangle (extents.width and extents.height). They do contribute indirectly by changing the position of non-whitespace characters. In particular, trailing whitespace characters are likely to not affect the size of the rectangle, though they will affect the x_advance and y_advance values.

  method text-extents ( Str $utf-string --> cairo_text_extents_t )

=item $utf8; a B<cairo_t>
=item cairo_text_extents_t $extents; a NUL-terminated string of text encoded in UTF-8, or C<Any>
=end pod

method text-extents ( Str $utf-string --> cairo_text_extents_t ) {
  my cairo_text_extents_t $extents .= new;
  cairo_text_extents(
    self._get-native-object-no-reffing, $utf-string, $extents
  );

  $extents
}

sub cairo_text_extents (
  cairo_t $cr, gchar-ptr $utf-string, cairo_text_extents_t $extents is rw
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:text-path:
=begin pod
=head2 text-path

Adds closed paths for text to the current path.  The generated path if filled, achieves an effect similar to that of C<cairo_show_text()>.  Text conversion and positioning is done similar to C<cairo_show_text()>.  Like C<cairo_show_text()>, After this call the current point is moved to the origin of where the next glyph would be placed in this same progression.  That is, the current point will be at the origin of the final glyph offset by its advance values. This allows for chaining multiple calls to to C<cairo_text_path()> without having to set current point in between.  Note: The C<cairo_text_path()> function call is part of what the cairo designers call the "toy" text API. It is convenient for short demos and simple programs, but it is not expected to be adequate for serious text-using applications. See C<cairo_glyph_path()> for the "real" text path API in cairo.

  method text-path ( )

=item $utf8; a cairo context
=end pod

method text-path ( ) {

  cairo_text_path(
    self._get-native-object-no-reffing, my gint $utf8
  )
}

sub cairo_text_path (
  cairo_t $cr, gchar-ptr $utf8
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:transform:
=begin pod
=head2 transform

Modifies the current transformation matrix (CTM) by applying I<matrix> as an additional transformation. The new transformation of user space takes place after any existing transformation.

  method transform ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a cairo context
=end pod

method transform ( cairo_matrix_t $matrix ) {

  cairo_transform(
    self._get-native-object-no-reffing, $matrix
  )
}

sub cairo_transform (
  cairo_t $cr, cairo_matrix_t $matrix
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:translate:
=begin pod
=head2 translate

Modifies the current transformation matrix (CTM) by translating the user-space origin by (I<tx>, I<ty>). This offset is interpreted as a user-space coordinate according to the CTM in place before the new call to C<cairo_translate()>. In other words, the translation of the user-space origin takes place after any existing transformation.

  method translate ( Num $tx, Num $ty )

=item $tx; a cairo context
=item $ty; amount to translate in the X direction
=end pod

method translate ( Num $tx, Num $ty ) {

  cairo_translate(
    self._get-native-object-no-reffing, $tx, $ty
  )
}

sub cairo_translate (
  cairo_t $cr, gdouble $tx, gdouble $ty
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:user-to-device:
=begin pod
=head2 user-to-device

Transform a coordinate from user space to device space by multiplying the given point by the current transformation matrix (CTM).

  method user-to-device ( Num $x, Num $y )

=item $x; a cairo context
=item $y; X value of coordinate (in/out parameter)
=end pod

method user-to-device ( Num $x, Num $y ) {

  cairo_user_to_device(
    self._get-native-object-no-reffing, $x, $y
  )
}

sub cairo_user_to_device (
  cairo_t $cr, gdouble $x, gdouble $y
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:user-to-device-distance:
=begin pod
=head2 user-to-device-distance

Transform a distance vector from user space to device space. This function is similar to C<cairo_user_to_device()> except that the translation components of the CTM will be ignored when transforming (I<dx>,I<dy>).

  method user-to-device-distance ( Num $dx, Num $dy )

=item $dx; a cairo context
=item $dy; X component of a distance vector (in/out parameter)
=end pod

method user-to-device-distance ( Num $dx, Num $dy ) {

  cairo_user_to_device_distance(
    self._get-native-object-no-reffing, $dx, $dy
  )
}

sub cairo_user_to_device_distance (
  cairo_t $cr, gdouble $dx, gdouble $dy
) is native(&cairo-lib)
  { * }











































=finish
#-------------------------------------------------------------------------------
#TM:1:_cairo_create:new
#`{{
=begin pod
=head2 cairo_create

Creates a new B<cairo_t> with all graphics state parameters set to default values and with I<target> as a target surface. The target surface should be constructed with a backend-specific function such as C<cairo_image_surface_create()> (or any other C<cairo_B<backend>_surface_create( )> variant).

This function references I<target>, so you can immediately call C<cairo_surface_destroy()> on it if you don't need to maintain a separate reference to it.  Return value: a newly allocated B<cairo_t> with a reference count of 1. The initial reference count should be released with C<cairo_destroy()> when you are done using the B<cairo_t>. This function never returns C<Any>. If memory cannot be allocated, a special B<cairo_t> object will be returned on which C<cairo_status()> returns C<CAIRO_STATUS_NO_MEMORY>. If you attempt to target a surface which does not support writing (such as B<cairo_mime_surface_t>) then a C<CAIRO_STATUS_WRITE_ERROR> will be raised.  You can use this object normally, but no drawing will be done.

  method cairo_create ( cairo_surface_t $target --> cairo_t )

=item cairo_surface_t $target;  cairo_create:

=end pod
}}

sub _cairo_create ( cairo_surface_t $target --> cairo_t )
  is native(&cairo-lib)
  is symbol('cairo_create')
  { * }

#-------------------------------------------------------------------------------
#TM:0:_cairo_reference:
#`{{
=begin pod
=head2 cairo_reference

Increases the reference count on this context by one. This prevents this context from being destroyed until a matching call to C<cairo_destroy()> is made.  Use C<cairo_get_reference_count()> to get the number of references to a B<cairo_t>.  Return value: the referenced B<cairo_t>.

  method cairo_reference ( --> cairo_t )


=end pod
}}

sub _cairo_reference ( cairo_t $cr --> cairo_t )
  is native(&cairo-lib)
  is symbol('cairo_reference')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_destroy:
#`{{
=begin pod
=head2 cairo_destroy

Decreases the reference count on this context by one. If the result is zero, then this context and all associated resources are freed. See C<cairo_reference()>.

  method cairo_destroy ( )

=end pod
}}

sub _cairo_destroy ( cairo_t $cr )
  is native(&cairo-lib)
  is symbol('cairo_destroy')
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:cairo_get_user_data:
=begin pod
=head2 [cairo_] get_user_data

Return user data previously attached to this context using the specified key.  If no user data has been attached with the given key this function returns C<Any>.  Return value: the user data previously attached or C<Any>.

  method cairo_get_user_data ( cairo_user_data_key_t $key --> OpaquePointer )

=item cairo_user_data_key_t $key; a B<cairo_t>

=end pod

sub cairo_get_user_data ( cairo_t $cr, cairo_user_data_key_t $key --> OpaquePointer )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_user_data:
=begin pod
=head2 [cairo_] set_user_data

Attach user data to this context.  To remove user data from a surface, call this function with the key that was used to set it and C<Any> for I<data>.  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY> if a slot could not be allocated for the user data.

  method cairo_set_user_data ( cairo_user_data_key_t $key, OpaquePointer $user_data, cairo_destroy_func_t $destroy --> Int )

=item cairo_user_data_key_t $key; a B<cairo_t>
=item OpaquePointer $user_data; the address of a B<cairo_user_data_key_t> to attach the user data to
=item cairo_destroy_func_t $destroy; the user data to attach to the B<cairo_t>

=end pod

sub cairo_set_user_data ( cairo_t $cr, cairo_user_data_key_t $key, OpaquePointer $user_data, cairo_destroy_func_t $destroy --> int32 )
  is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:cairo_get_reference_count:
=begin pod
=head2 [cairo_] get_reference_count

Returns the current reference count of this context.  Return value: the current reference count of this context.  If the object is a nil object, 0 will be returned.

  method cairo_get_reference_count ( --> UInt )


=end pod

sub cairo_get_reference_count ( cairo_t $cr --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_save:
=begin pod
=head2 cairo_save

Makes a copy of the current state of this context and saves it on an internal stack of saved states for this context. When C<cairo_restore()> is called, this context will be restored to the saved state. Multiple calls to C<cairo_save()> and C<cairo_restore()> can be nested; each call to C<cairo_restore()> restores the state from the matching paired C<cairo_save()>.  It isn't necessary to clear all saved states before a B<cairo_t> is freed. If the reference count of a B<cairo_t> drops to zero in response to a call to C<cairo_destroy()>, any saved states will be freed along with the B<cairo_t>.

  method cairo_save ( )


=end pod

sub cairo_save ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_restore:
=begin pod
=head2 cairo_restore

Restores this context to the state saved by a preceding call to C<cairo_save()> and removes that state from the stack of saved states.

  method cairo_restore ( )


=end pod

sub cairo_restore ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_push_group:
=begin pod
=head2 [cairo_] push_group

Temporarily redirects drawing to an intermediate surface known as a group. The redirection lasts until the group is completed by a call to C<cairo_pop_group()> or C<cairo_pop_group_to_source()>. These calls provide the result of any drawing to the group as a pattern, (either as an explicit object, or set as the source pattern).  This group functionality can be convenient for performing intermediate compositing. One common use of a group is to render objects as opaque within the group, (so that they occlude each other), and then blend the result with translucence onto the destination.  Groups can be nested arbitrarily deep by making balanced calls to C<cairo_push_group()>/C<cairo_pop_group()>. Each call pushes/pops the new target group onto/from a stack.  The C<cairo_push_group()> function calls C<cairo_save()> so that any changes to the graphics state will not be visible outside the group, (the pop_group functions call C<cairo_restore()>).  By default the intermediate group will have a content type of C<CAIRO_CONTENT_COLOR_ALPHA>. Other content types can be chosen for the group by using C<cairo_push_group_with_content()> instead.  As an example, here is how one might fill and stroke a path with translucence, but without any portion of the fill being visible under the stroke:

 cairo_push_group (cr); cairo_set_source (cr, fill_pattern); cairo_fill_preserve (cr); cairo_set_source (cr, stroke_pattern); cairo_stroke (cr); cairo_pop_group_to_source (cr); cairo_paint_with_alpha (cr, alpha);



  method cairo_push_group ( )


=end pod

sub cairo_push_group ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_push_group_with_content:
=begin pod
=head2 [cairo_] push_group_with_content

Temporarily redirects drawing to an intermediate surface known as a group. The redirection lasts until the group is completed by a call to C<cairo_pop_group()> or C<cairo_pop_group_to_source()>. These calls provide the result of any drawing to the group as a pattern, (either as an explicit object, or set as the source pattern).  The group will have a content type of I<content>. The ability to control this content type is the only distinction between this function and C<cairo_push_group()> which you should see for a more detailed description of group rendering.

  method cairo_push_group_with_content ( Int $content )

=item $content; a cairo context

=end pod

sub cairo_push_group_with_content ( cairo_t $cr, int32 $content )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pop_group:
=begin pod
=head2 [cairo_] pop_group

Terminates the redirection begun by a call to C<cairo_push_group()> or C<cairo_push_group_with_content()> and returns a new pattern containing the results of all drawing operations performed to the group.  The C<cairo_pop_group()> function calls C<cairo_restore()>, (balancing a call to C<cairo_save()> by the push_group function), so that any changes to the graphics state will not be visible outside the group.  Return value: a newly created (surface) pattern containing the results of all drawing operations performed to the group. The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.

  method cairo_pop_group ( --> cairo_pattern_t )


=end pod

sub cairo_pop_group ( cairo_t $cr --> cairo_pattern_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pop_group_to_source:
=begin pod
=head2 [cairo_] pop_group_to_source

Terminates the redirection begun by a call to C<cairo_push_group()> or C<cairo_push_group_with_content()> and installs the resulting pattern as the source pattern in the given cairo context.  The behavior of this function is equivalent to the sequence of operations:

 cairo_pattern_t *group = cairo_pop_group (cr); cairo_set_source (cr, group); cairo_pattern_destroy (group);

   but is more convenient as their is no need for a variable to store the short-lived pointer to the pattern.  The C<cairo_pop_group()> function calls C<cairo_restore()>, (balancing a call to C<cairo_save()> by the push_group function), so that any changes to the graphics state will not be visible outside the group.

  method cairo_pop_group_to_source ( )


=end pod

sub cairo_pop_group_to_source ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_operator:
=begin pod
=head2 [cairo_] set_operator

Sets the compositing operator to be used for all drawing operations. See B<cairo_operator_t> for details on the semantics of each available compositing operator.  The default operator is C<CAIRO_OPERATOR_OVER>.

  method cairo_set_operator ( Int $op )

=item $op; a B<cairo_t>

=end pod

sub cairo_set_operator ( cairo_t $cr, int32 $op )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:cairo_set_source_rgb:xt/c1.pl6
=begin pod
=head2 [cairo_] set_source_rgb

Sets the source pattern within this context to an opaque color. This opaque color will then be used for any subsequent drawing operation until a new source pattern is set.  The color components are floating point numbers in the range 0 to 1. If the values passed in are outside that range, they will be clamped.  The default source pattern is opaque black, (that is, it is equivalent to cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)).

  method cairo_set_source_rgb ( Num $red, Num $green, Num $blue )

=item $red; a cairo context
=item $green; red component of color
=item $blue; green component of color

=end pod

sub cairo_set_source_rgb (
  cairo_t $cr, num64 $red, num64 $green, num64 $blue
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:cairo_set_source_rgba:xt/c1.pl6
=begin pod
=head2 [cairo_] set_source_rgba

Sets the source pattern within this context to a translucent color. This color will then be used for any subsequent drawing operation until a new source pattern is set.  The color and alpha components are floating point numbers in the range 0 to 1. If the values passed in are outside that range, they will be clamped.  The default source pattern is opaque black, (that is, it is equivalent to cairo_set_source_rgba(cr, 0.0, 0.0, 0.0, 1.0)).

  method cairo_set_source_rgba ( Num $red, Num $green, Num $blue, Num $alpha )

=item $red; a cairo context
=item $green; red component of color
=item $blue; green component of color
=item $alpha; blue component of color

=end pod

sub cairo_set_source_rgba ( cairo_t $cr, num64 $red, num64 $green, num64 $blue, num64 $alpha )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_source_surface:
=begin pod
=head2 [cairo_] set_source_surface

This is a convenience function for creating a pattern from I<surface> and setting it as the source in this context with C<cairo_set_source()>.

The I<x> and I<y> parameters give the user-space coordinate at which the surface origin should appear. (The surface origin is its upper-left corner before any transformation has been applied.) The I<x> and I<y> parameters are negated and then set as translation values in the pattern matrix.

Other than the initial translation pattern matrix, as described above, all other pattern attributes, (such as its extend mode), are set to the default values as in C<cairo_pattern_create_for_surface()>. The resulting pattern can be queried with C<cairo_get_source()> so that these attributes can be modified if desired, (eg. to create a repeating pattern with C<cairo_pattern_set_extend()>).

  method cairo_set_source_surface ( cairo_surface_t $surface, Num $x, Num $y )

=item cairo_surface_t $surface; a cairo context
=item $x; a surface to be used to set the source pattern
=item $y; User-space X coordinate for surface origin

=end pod

sub cairo_set_source_surface ( cairo_t $cr, cairo_surface_t $surface, num64 $x, num64 $y )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_source:
=begin pod
=head2 [cairo_] set_source

Sets the source pattern within this context to I<source>. This pattern will then be used for any subsequent drawing operation until a new source pattern is set.

Note: The pattern's transformation matrix will be locked to the user space in effect at the time of C<cairo_set_source()>. This means that further modifications of the current transformation matrix will not affect the source pattern. See C<cairo_pattern_set_matrix()>.

The default source pattern is a solid pattern that is opaque black, (that is, it is equivalent to cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)).

  method cairo_set_source ( cairo_pattern_t $source )

=item cairo_pattern_t $source; a cairo context

=end pod

sub cairo_set_source ( cairo_t $cr, cairo_pattern_t $source )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_source:
=begin pod
=head2 [cairo_] get_source

Gets the current source pattern for this context.  Return value: the current source pattern. This object is owned by cairo. To keep a reference to it, you must call C<cairo_pattern_reference()>.

  method cairo_get_source ( --> cairo_pattern_t )


=end pod

sub cairo_get_source ( cairo_t $cr --> cairo_pattern_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_tolerance:
=begin pod
=head2 [cairo_] set_tolerance

Sets the tolerance used when converting paths into trapezoids. Curved segments of the path will be subdivided until the maximum deviation between the original path and the polygonal approximation is less than I<tolerance>. The default value is 0.1. A larger value will give better performance, a smaller value, better appearance. (Reducing the value from the default value of 0.1 is unlikely to improve appearance significantly.)  The accuracy of paths within Cairo is limited by the precision of its internal arithmetic, and the prescribed I<tolerance> is restricted to the smallest representable internal value.

  method cairo_set_tolerance ( Num $tolerance )

=item $tolerance; a B<cairo_t>

=end pod

sub cairo_set_tolerance ( cairo_t $cr, num64 $tolerance )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_antialias:
=begin pod
=head2 [cairo_] set_antialias

Set the antialiasing mode of the rasterizer used for drawing shapes. This value is a hint, and a particular backend may or may not support a particular value.  At the current time, no backend supports C<CAIRO_ANTIALIAS_SUBPIXEL> when drawing shapes.  Note that this option does not affect text rendering, instead see C<cairo_font_options_set_antialias()>.

  method cairo_set_antialias ( Int $antialias )

=item $antialias; a B<cairo_t>

=end pod

sub cairo_set_antialias ( cairo_t $cr, int32 $antialias )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_fill_rule:
=begin pod
=head2 [cairo_] set_fill_rule

Set the current fill rule within the cairo context. The fill rule is used to determine which regions are inside or outside a complex (potentially self-intersecting) path. The current fill rule affects both C<cairo_fill()> and C<cairo_clip()>. See B<cairo_fill_rule_t> for details on the semantics of each available fill rule.  The default fill rule is C<CAIRO_FILL_RULE_WINDING>.

  method cairo_set_fill_rule ( Int $fill_rule )

=item $fill_rule; a B<cairo_t>

=end pod

sub cairo_set_fill_rule ( cairo_t $cr, int32 $fill_rule )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:cairo_set_line_width:xt/c1.pl6
=begin pod
=head2 [cairo_] set_line_width

Sets the current line width within the cairo context. The line width value specifies the diameter of a pen that is circular in user space, (though device-space pen may be an ellipse in general due to scaling/shear/rotation of the CTM).

Note: When the description above refers to user space and CTM it refers to the user space and CTM in effect at the time of the stroking operation, not the user space and CTM in effect at the time of the call to C<cairo_set_line_width()>. The simplest usage makes both of these spaces identical. That is, if there is no change to the CTM between a call to C<cairo_set_line_width()> and the stroking operation, then one can just pass user-space values to C<cairo_set_line_width()> and ignore this note.  As with the other stroke parameters, the current line width is examined by C<cairo_stroke()>, C<cairo_stroke_extents()>, and C<cairo_stroke_to_path()>, but does not have any effect during path construction.

The default line width value is 2.0.

  method cairo_set_line_width ( Num $width )

=item $width; a B<cairo_t>

=end pod

sub cairo_set_line_width ( cairo_t $cr, num64 $width )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:cairo_set_line_cap:xt/c1.pl6
=begin pod
=head2 [cairo_] set_line_cap

Sets the current line cap style within the cairo context. See B<cairo_line_cap_t> for details about how the available line cap styles are drawn.  As with the other stroke parameters, the current line cap style is examined by C<cairo_stroke()>, C<cairo_stroke_extents()>, and C<cairo_stroke_to_path()>, but does not have any effect during path construction.  The default line cap style is C<CAIRO_LINE_CAP_BUTT>.

  method cairo_set_line_cap ( Int $line_cap )

=item $line_cap; a cairo context

=end pod

sub cairo_set_line_cap ( cairo_t $cr, int32 $line_cap )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:cairo_set_line_join:xt/c1.pl6
=begin pod
=head2 [cairo_] set_line_join

Sets the current line join style within the cairo context. See B<cairo_line_join_t> for details about how the available line join styles are drawn.  As with the other stroke parameters, the current line join style is examined by C<cairo_stroke()>, C<cairo_stroke_extents()>, and C<cairo_stroke_to_path()>, but does not have any effect during path construction.  The default line join style is C<CAIRO_LINE_JOIN_MITER>.

  method cairo_set_line_join ( Int $line_join )

=item $line_join; a cairo context

=end pod

sub cairo_set_line_join ( cairo_t $cr, int32 $line_join )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:cairo_set_dash:xt/c1.pl6
=begin pod
=head2 [cairo_] set_dash

Sets the dash pattern to be used by C<cairo_stroke()>. A dash pattern is specified by I<dashes>, an array of positive values. Each value provides the length of alternate "on" and "off" portions of the stroke. The I<offset> specifies an offset into the pattern at which the stroke begins.  Each "on" segment will have caps applied as if the segment were a separate sub-path. In particular, it is valid to use an "on" length of 0.0 with C<CAIRO_LINE_CAP_ROUND> or C<CAIRO_LINE_CAP_SQUARE> in order to distributed dots or squares along a path.  Note: The length values are in user-space units as evaluated at the time of stroking. This is not necessarily the same as the user space at the time of C<cairo_set_dash()>.

If I<num_dashes> is 0 dashing is disabled.  If I<num_dashes> is 1 a symmetric pattern is assumed with alternating on and off portions of the size specified by the single value in I<dashes>.  If any value in I<dashes> is negative, or if all values are 0, then this context will be put into an error state with a status of C<CAIRO_STATUS_INVALID_DASH>.

  method cairo_set_dash ( Num $dashes, Int $num_dashes, Num $offset )

=item $dashes; a cairo context
=item $num_dashes; an array specifying alternate lengths of on and off stroke portions
=item $offset; the length of the dashes array

=end pod

sub cairo_set_dash (
  cairo_t $cr, Array $dashes, int32 $num_dashes, num64 $offset
) {
  my CArray[num64] $ds .= new(@$dashes>>.Num);
  _cairo_set_dash( $cr, $ds, $num_dashes, $offset);
}

sub _cairo_set_dash (
  cairo_t $cr, CArray[num64] $dashes, int32 $num_dashes, num64 $offset
) is native(&cairo-lib)
  is symbol('cairo_set_dash')
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_dash_count:
=begin pod
=head2 [cairo_] get_dash_count

This function returns the length of the dash array in this context (0 if dashing is not currently in effect).  See also C<cairo_set_dash()> and C<cairo_get_dash()>.  Return value: the length of the dash array, or 0 if no dash array set.

  method cairo_get_dash_count ( --> Int )


=end pod

sub cairo_get_dash_count ( cairo_t $cr --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_dash:
=begin pod
=head2 [cairo_] get_dash

Gets the current dash array.  If not C<Any>, I<dashes> should be big enough to hold at least the number of values returned by C<cairo_get_dash_count()>.

  method cairo_get_dash ( Num $dashes, Num $offset )

=item $dashes; a B<cairo_t>
=item $offset; return value for the dash array, or C<Any>

=end pod

sub cairo_get_dash ( cairo_t $cr, num64 $dashes, num64 $offset )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_miter_limit:
=begin pod
=head2 [cairo_] set_miter_limit

Sets the current miter limit within the cairo context.  If the current line join style is set to C<CAIRO_LINE_JOIN_MITER> (see C<cairo_set_line_join()>), the miter limit is used to determine whether the lines should be joined with a bevel instead of a miter. Cairo divides the length of the miter by the line width. If the result is greater than the miter limit, the style is converted to a bevel.  As with the other stroke parameters, the current line miter limit is examined by C<cairo_stroke()>, C<cairo_stroke_extents()>, and C<cairo_stroke_to_path()>, but does not have any effect during path construction.  The default miter limit value is 10.0, which will convert joins with interior angles less than 11 degrees to bevels instead of miters. For reference, a miter limit of 2.0 makes the miter cutoff at 60 degrees, and a miter limit of 1.414 makes the cutoff at 90 degrees.  A miter limit for a desired angle can be computed as: miter limit = 1/sin(angle/2)

  method cairo_set_miter_limit ( Num $limit )

=item $limit; a cairo context

=end pod

sub cairo_set_miter_limit ( cairo_t $cr, num64 $limit )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_translate:
=begin pod
=head2 cairo_translate

Modifies the current transformation matrix (CTM) by translating the user-space origin by (I<tx>, I<ty>). This offset is interpreted as a user-space coordinate according to the CTM in place before the new call to C<cairo_translate()>. In other words, the translation of the user-space origin takes place after any existing transformation.

  method cairo_translate ( Num $tx, Num $ty )

=item $tx; a cairo context
=item $ty; amount to translate in the X direction

=end pod

sub cairo_translate ( cairo_t $cr, num64 $tx, num64 $ty )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scale:
=begin pod
=head2 cairo_scale

Modifies the current transformation matrix (CTM) by scaling the X and Y user-space axes by I<$sx> and I<$sy> respectively. The scaling of the axes takes place after any existing transformation of user space.

  method cairo_scale ( Num $sx, Num $sy )

=item $sx; a cairo context
=item $sy; scale factor for the X dimension

=end pod

sub cairo_scale ( cairo_t $cr, num64 $sx, num64 $sy )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_rotate:
=begin pod
=head2 cairo_rotate

Modifies the current transformation matrix (CTM) by rotating the user-space axes by I<angle> radians. The rotation of the axes takes places after any existing transformation of user space. The rotation direction for positive angles is from the positive X axis toward the positive Y axis.

  method cairo_rotate ( Num $angle )

=item $angle; a cairo context

=end pod

sub cairo_rotate ( cairo_t $cr, num64 $angle )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_transform:
=begin pod
=head2 cairo_transform

Modifies the current transformation matrix (CTM) by applying I<matrix> as an additional transformation. The new transformation of user space takes place after any existing transformation.

  method cairo_transform ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a cairo context

=end pod

sub cairo_transform ( cairo_t $cr, cairo_matrix_t $matrix )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_matrix:
=begin pod
=head2 [cairo_] set_matrix

Modifies the current transformation matrix (CTM) by setting it equal to I<matrix>.

  method cairo_set_matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a cairo context

=end pod

sub cairo_set_matrix ( cairo_t $cr, cairo_matrix_t $matrix )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_identity_matrix:
=begin pod
=head2 [cairo_] identity_matrix

Resets the current transformation matrix (CTM) by setting it equal to the identity matrix. That is, the user-space and device-space axes will be aligned and one user-space unit will transform to one device-space unit.

  method cairo_identity_matrix ( )


=end pod

sub cairo_identity_matrix ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_user_to_device:
=begin pod
=head2 [cairo_] user_to_device

Transform a coordinate from user space to device space by multiplying the given point by the current transformation matrix (CTM).

  method cairo_user_to_device ( Num $x, Num $y )

=item $x; a cairo context
=item $y; X value of coordinate (in/out parameter)

=end pod

sub cairo_user_to_device ( cairo_t $cr, num64 $x, num64 $y )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_user_to_device_distance:
=begin pod
=head2 [cairo_] user_to_device_distance

Transform a distance vector from user space to device space. This function is similar to C<cairo_user_to_device()> except that the translation components of the CTM will be ignored when transforming (I<dx>,I<dy>).

  method cairo_user_to_device_distance ( Num $dx, Num $dy )

=item $dx; X component of a distance vector (in/out parameter)
=item $dy; y component of a distance vector (in/out parameter)

=end pod

sub cairo_user_to_device_distance ( cairo_t $cr, num64 $dx, num64 $dy )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_device_to_user:
=begin pod
=head2 [cairo_] device_to_user

Transform a coordinate from device space to user space by multiplying the given point by the inverse of the current transformation matrix (CTM).

  method cairo_device_to_user ( Num $x, Num $y )

=item $x; X value of coordinate (in/out parameter)
=item $y; y value of coordinate (in/out parameter)

=end pod

sub cairo_device_to_user ( cairo_t $cr, num64 $x is rw, num64 $y is rw )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_device_to_user_distance:
=begin pod
=head2 [cairo_] device_to_user_distance

Transform a distance vector from device space to user space. This function is similar to C<cairo_device_to_user()> except that the translation components of the inverse CTM will be ignored when transforming (I<dx>,I<dy>).

  method cairo_device_to_user_distance ( Num $dx, Num $dy )

=item $dx; X component of a distance vector (in/out parameter)
=item $dy; y component of a distance vector (in/out parameter)

=end pod

sub cairo_device_to_user_distance (
  cairo_t $cr, num64 $dx is rw, num64 $dy is rw
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_new_path:
=begin pod
=head2 [cairo_] new_path

Clears the current path. After this call there will be no path and no current point.

  method cairo_new_path ( )


=end pod

sub cairo_new_path ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_new_sub_path:
=begin pod
=head2 [cairo_] new_sub_path

Begin a new sub-path. Note that the existing path is not affected. After this call there will be no current point.  In many cases, this call is not needed since new sub-paths are frequently started with C<cairo_move_to()>.  A call to C<cairo_new_sub_path()> is particularly useful when beginning a new sub-path with one of the C<cairo_arc()> calls. This makes things easier as it is no longer necessary to manually compute the arc's initial coordinates for a call to C<cairo_move_to()>.

  method cairo_new_sub_path ( )


=end pod

sub cairo_new_sub_path ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:cairo_move_to:xt/c1.pl6
=begin pod
=head2 [cairo_] move_to

Begin a new sub-path. After this call the current point will be (I<x>, I<y>).

  method cairo_move_to ( Num $x, Num $y )

=item $x; the X coordinate of the new position
=item $y; the y coordinate of the new position

=end pod

sub cairo_move_to ( cairo_t $cr, num64 $x, num64 $y )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_line_to:
=begin pod
=head2 [cairo_] line_to

Adds a line to the path from the current point to position (I<x>, I<y>) in user-space coordinates. After this call the current point will be (I<x>, I<y>).  If there is no current point before the call to C<cairo_line_to()> this function will behave as cairo_move_to(this context, I<x>, I<y>).

  method cairo_line_to ( Num $x, Num $y )

=item $x; the x coordinate of the end of the new line
=item $y; the y coordinate of the end of the new line

=end pod

sub cairo_line_to ( cairo_t $cr, num64 $x, num64 $y )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:cairo_curve_to:xt/c1.pl6
=begin pod
=head2 [cairo_] curve_to

Adds a cubic Bézier spline to the path from the current point to position (I<x3>, I<y3>) in user-space coordinates, using (I<x1>, I<y1>) and (I<x2>, I<y2>) as the control points. After this call the current point will be (I<x3>, I<y3>).  If there is no current point before the call to C<cairo_curve_to()> this function will behave as if preceded by a call to cairo_move_to(this context, I<x1>, I<y1>).

  method cairo_curve_to ( Num $x1, Num $y1, Num $x2, Num $y2, Num $x3, Num $y3 )

=item $x1; the x coordinate of the first control point
=item $y1; the y coordinate of the first control point
=item $x2; the x coordinate of the second control point
=item $y2; the y coordinate of the second control point
=item $x3; the x coordinate of the end of the curve
=item $y3; the y coordinate of the end of the curve

=end pod

sub cairo_curve_to ( cairo_t $cr, num64 $x1, num64 $y1, num64 $x2, num64 $y2, num64 $x3, num64 $y3 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_arc:
=begin pod
=head2 cairo_arc

Adds a circular arc of the given I<radius> to the current path.  The arc is centered at (I<xc>, I<yc>), begins at I<angle1> and proceeds in the direction of increasing angles to end at I<angle2>. If I<angle2> is less than I<angle1> it will be progressively increased by <literal>2*M_PI</literal> until it is greater than I<angle1>.  If there is a current point, an initial line segment will be added to the path to connect the current point to the beginning of the arc. If this initial line is undesired, it can be avoided by calling C<cairo_new_sub_path()> before calling C<cairo_arc()>.  Angles are measured in radians. An angle of 0.0 is in the direction of the positive X axis (in user space). An angle of <literal>M_PI/2.0</literal> radians (90 degrees) is in the direction of the positive Y axis (in user space). Angles increase in the direction from the positive X axis toward the positive Y axis. So with the default transformation matrix, angles increase in a clockwise direction.  (To convert from degrees to radians, use <literal>degrees * (M_PI / 180.)</literal>.)  This function gives the arc in the direction of increasing angles; see C<cairo_arc_negative()> to get the arc in the direction of decreasing angles.  The arc is circular in user space. To achieve an elliptical arc, you can scale the current transformation matrix by different amounts in the X and Y directions. For example, to draw an ellipse in the box given by I<x>, I<y>, I<width>, I<height>:

 cairo_save (cr); cairo_translate (cr, x + width / 2., y + height / 2.); cairo_scale (cr, width / 2., height / 2.); cairo_arc (cr, 0., 0., 1., 0., 2 * M_PI); cairo_restore (cr);



  method cairo_arc ( Num $xc, Num $yc, Num $radius, Num $angle1, Num $angle2 )

=item $xc; a cairo context
=item $yc; X position of the center of the arc
=item $radius; Y position of the center of the arc
=item $angle1; the radius of the arc
=item $angle2; the start angle, in radians

=end pod

sub cairo_arc ( cairo_t $cr, num64 $xc, num64 $yc, num64 $radius, num64 $angle1, num64 $angle2 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_arc_negative:
=begin pod
=head2 [cairo_] arc_negative

Adds a circular arc of the given I<radius> to the current path.  The arc is centered at (I<xc>, I<yc>), begins at I<angle1> and proceeds in the direction of decreasing angles to end at I<angle2>. If I<angle2> is greater than I<angle1> it will be progressively decreased by <literal>2*M_PI</literal> until it is less than I<angle1>.  See C<cairo_arc()> for more details. This function differs only in the direction of the arc between the two angles.

  method cairo_arc_negative ( Num $xc, Num $yc, Num $radius, Num $angle1, Num $angle2 )

=item $xc; a cairo context
=item $yc; X position of the center of the arc
=item $radius; Y position of the center of the arc
=item $angle1; the radius of the arc
=item $angle2; the start angle, in radians

=end pod

sub cairo_arc_negative ( cairo_t $cr, num64 $xc, num64 $yc, num64 $radius, num64 $angle1, num64 $angle2 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_rel_move_to:
=begin pod
=head2 [cairo_] rel_move_to

Begin a new sub-path. After this call the current point will offset by (I<x>, I<y>).  Given a current point of (x, y), cairo_rel_move_to(this context, I<dx>, I<dy>) is logically equivalent to cairo_move_to(this context, x + I<dx>, y + I<dy>).  It is an error to call this function with no current point. Doing so will cause this context to shutdown with a status of C<CAIRO_STATUS_NO_CURRENT_POINT>.

  method cairo_rel_move_to ( Num $dx, Num $dy )

=item $dx; a cairo context
=item $dy; the X offset

=end pod

sub cairo_rel_move_to ( cairo_t $cr, num64 $dx, num64 $dy )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_rel_line_to:
=begin pod
=head2 [cairo_] rel_line_to

Relative-coordinate version of C<cairo_line_to()>. Adds a line to the path from the current point to a point that is offset from the current point by (I<dx>, I<dy>) in user space. After this call the current point will be offset by (I<dx>, I<dy>).  Given a current point of (x, y), cairo_rel_line_to(this context, I<dx>, I<dy>) is logically equivalent to cairo_line_to(this context, x + I<dx>, y + I<dy>).  It is an error to call this function with no current point. Doing so will cause this context to shutdown with a status of C<CAIRO_STATUS_NO_CURRENT_POINT>.

  method cairo_rel_line_to ( Num $dx, Num $dy )

=item $dx; a cairo context
=item $dy; the X offset to the end of the new line

=end pod

sub cairo_rel_line_to ( cairo_t $cr, num64 $dx, num64 $dy )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_rel_curve_to:
=begin pod
=head2 [cairo_] rel_curve_to

Relative-coordinate version of C<cairo_curve_to()>. All offsets are relative to the current point. Adds a cubic Bézier spline to the path from the current point to a point offset from the current point by (I<dx3>, I<dy3>), using points offset by (I<dx1>, I<dy1>) and (I<dx2>, I<dy2>) as the control points. After this call the current point will be offset by (I<dx3>, I<dy3>).  Given a current point of (x, y), cairo_rel_curve_to(this context, I<dx1>, I<dy1>, I<dx2>, I<dy2>, I<dx3>, I<dy3>) is logically equivalent to cairo_curve_to(this context, x+I<dx1>, y+I<dy1>, x+I<dx2>, y+I<dy2>, x+I<dx3>, y+I<dy3>).  It is an error to call this function with no current point. Doing so will cause this context to shutdown with a status of C<CAIRO_STATUS_NO_CURRENT_POINT>.

  method cairo_rel_curve_to ( Num $dx1, Num $dy1, Num $dx2, Num $dy2, Num $dx3, Num $dy3 )

=item $dx1; a cairo context
=item $dy1; the X offset to the first control point
=item $dx2; the Y offset to the first control point
=item $dy2; the X offset to the second control point
=item $dx3; the Y offset to the second control point
=item $dy3; the X offset to the end of the curve

=end pod

sub cairo_rel_curve_to ( cairo_t $cr, num64 $dx1, num64 $dy1, num64 $dx2, num64 $dy2, num64 $dx3, num64 $dy3 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_rectangle:
=begin pod
=head2 cairo_rectangle

Adds a closed sub-path rectangle of the given size to the current path at position (I<$x>, I<$y>) in user-space coordinates. This function is logically equivalent to:

  $cairo.move-to( $x, $y);
  $cairo.rel-line-to( $width, 0);
  $cairo.rel-line-to( 0, $height);
  $cairo.rel-line-to( -$width, 0);
  $cairo.close.path;

  method cairo_rectangle ( Num $x, Num $y, Num $width, Num $height )

=item $x; a cairo context
=item $y; the X coordinate of the top left corner of the rectangle
=item $width; the Y coordinate to the top left corner of the rectangle
=item $height; the width of the rectangle

=end pod

sub cairo_rectangle ( cairo_t $cr, num64 $x, num64 $y, num64 $width, num64 $height )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_close_path:
=begin pod
=head2 [cairo_] close_path

Adds a line segment to the path from the current point to the beginning of the current sub-path, (the most recent point passed to C<cairo_move_to()>), and closes this sub-path. After this call the current point will be at the joined endpoint of the sub-path.  The behavior of C<cairo_close_path()> is distinct from simply calling C<cairo_line_to()> with the equivalent coordinate in the case of stroking. When a closed sub-path is stroked, there are no caps on the ends of the sub-path. Instead, there is a line join connecting the final and initial segments of the sub-path.  If there is no current point before the call to C<cairo_close_path()>, this function will have no effect.  Note: As of cairo version 1.2.4 any call to C<cairo_close_path()> will place an explicit MOVE_TO element into the path immediately after the CLOSE_PATH element, (which can be seen in C<cairo_copy_path()> for example). This can simplify path processing in some cases as it may not be necessary to save the "last move_to point" during processing as the MOVE_TO immediately after the CLOSE_PATH will provide that point.

  method cairo_close_path ( )


=end pod

sub cairo_close_path ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_path_extents:
=begin pod
=head2 [cairo_] path_extents

Computes a bounding box in user-space coordinates covering the points on the current path. If the current path is empty, returns an empty rectangle ((0,0), (0,0)). Stroke parameters, fill rule, surface dimensions and clipping are not taken into account.  Contrast with C<cairo_fill_extents()> and C<cairo_stroke_extents()> which return the extents of only the area that would be "inked" by the corresponding drawing operations.  The result of C<cairo_path_extents()> is defined as equivalent to the limit of C<cairo_stroke_extents()> with C<CAIRO_LINE_CAP_ROUND> as the line width approaches 0.0, (but never reaching the empty-rectangle returned by C<cairo_stroke_extents()> for a line width of 0.0).  Specifically, this means that zero-area sub-paths such as C<cairo_move_to()>;C<cairo_line_to()> segments, (even degenerate cases where the coordinates to both calls are identical), will be considered as contributing to the extents. However, a lone C<cairo_move_to()> will not contribute to the results of C<cairo_path_extents()>.

  method cairo_path_extents ( Num $x1, Num $y1, Num $x2, Num $y2 )

=item $x1; a cairo context
=item $y1; left of the resulting extents
=item $x2; top of the resulting extents
=item $y2; right of the resulting extents

=end pod

sub cairo_path_extents ( cairo_t $cr, num64 $x1, num64 $y1, num64 $x2, num64 $y2 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_paint:
=begin pod
=head2 cairo_paint

A drawing operator that paints the current source everywhere within the current clip region.

  method cairo_paint ( )


=end pod

sub cairo_paint ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_paint_with_alpha:
=begin pod
=head2 [cairo_] paint_with_alpha

A drawing operator that paints the current source everywhere within the current clip region using a mask of constant alpha value I<alpha>. The effect is similar to C<cairo_paint()>, but the drawing is faded out using the alpha value.

  method cairo_paint_with_alpha ( Num $alpha )

=item $alpha; a cairo context

=end pod

sub cairo_paint_with_alpha ( cairo_t $cr, num64 $alpha )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mask:
=begin pod
=head2 cairo_mask

A drawing operator that paints the current source using the alpha channel of I<pattern> as a mask. (Opaque areas of I<pattern> are painted with the source, transparent areas are not painted.)

  method cairo_mask ( cairo_pattern_t $pattern )

=item cairo_pattern_t $pattern; a cairo context

=end pod

sub cairo_mask ( cairo_t $cr, cairo_pattern_t $pattern )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mask_surface:
=begin pod
=head2 [cairo_] mask_surface

A drawing operator that paints the current source using the alpha channel of I<surface> as a mask. (Opaque areas of I<surface> are painted with the source, transparent areas are not painted.)

  method cairo_mask_surface ( cairo_surface_t $surface, Num $surface_x, Num $surface_y )

=item cairo_surface_t $surface; a cairo context
=item $surface_x; a B<cairo_surface_t>
=item $surface_y; X coordinate at which to place the origin of I<surface>

=end pod

sub cairo_mask_surface ( cairo_t $cr, cairo_surface_t $surface, num64 $surface_x, num64 $surface_y )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_stroke:
=begin pod
=head2 cairo_stroke

A drawing operator that strokes the current path according to the current line width, line join, line cap, and dash settings. After C<cairo_stroke()>, the current path will be cleared from the cairo context. See C<cairo_set_line_width()>, C<cairo_set_line_join()>, C<cairo_set_line_cap()>, C<cairo_set_dash()>, and C<cairo_stroke_preserve()>.

Note: Degenerate segments and sub-paths are treated specially and provide a useful result. These can result in two different situations:

=item Zero-length "on" segments set in C<cairo_set_dash()>. If the cap style is C<CAIRO_LINE_CAP_ROUND> or C<CAIRO_LINE_CAP_SQUARE> then these segments will be drawn as circular dots or squares respectively. In the case of C<CAIRO_LINE_CAP_SQUARE>, the orientation of the squares is determined by the direction of the underlying path.

=item A sub-path created by C<cairo_move_to()> followed by either a C<cairo_close_path()> or one or more calls to C<cairo_line_to()> to the same coordinate as the C<cairo_move_to()>. If the cap style is C<CAIRO_LINE_CAP_ROUND> then these sub-paths will be drawn as circular dots. Note that in the case of C<CAIRO_LINE_CAP_SQUARE> a degenerate sub-path will not be drawn at all, (since the correct orientation is indeterminate).  In no case will a cap style of C<CAIRO_LINE_CAP_BUTT> cause anything to be drawn in the case of either degenerate segments or sub-paths.

  method cairo_stroke ( )


=end pod

sub cairo_stroke ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_stroke_preserve:
=begin pod
=head2 [cairo_] stroke_preserve

A drawing operator that strokes the current path according to the current line width, line join, line cap, and dash settings. Unlike C<cairo_stroke()>, C<cairo_stroke_preserve()> preserves the path within the cairo context.  See C<cairo_set_line_width()>, C<cairo_set_line_join()>, C<cairo_set_line_cap()>, C<cairo_set_dash()>, and C<cairo_stroke_preserve()>.

  method cairo_stroke_preserve ( )


=end pod

sub cairo_stroke_preserve ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_fill:
=begin pod
=head2 cairo_fill

A drawing operator that fills the current path according to the current fill rule, (each sub-path is implicitly closed before being filled). After C<cairo_fill()>, the current path will be cleared from the cairo context. See C<cairo_set_fill_rule()> and C<cairo_fill_preserve()>.

  method cairo_fill ( )


=end pod

sub cairo_fill ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_fill_preserve:
=begin pod
=head2 [cairo_] fill_preserve

A drawing operator that fills the current path according to the current fill rule, (each sub-path is implicitly closed before being filled). Unlike C<cairo_fill()>, C<cairo_fill_preserve()> preserves the path within the cairo context.  See C<cairo_set_fill_rule()> and C<cairo_fill()>.

  method cairo_fill_preserve ( )


=end pod

sub cairo_fill_preserve ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_copy_page:
=begin pod
=head2 [cairo_] copy_page

Emits the current page for backends that support multiple pages, but doesn't clear it, so, the contents of the current page will be retained for the next page too.  Use C<cairo_show_page()> if you want to get an empty page after the emission.  This is a convenience function that simply calls C<cairo_surface_copy_page()> on this context's target.

  method cairo_copy_page ( )


=end pod

sub cairo_copy_page ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_show_page:
=begin pod
=head2 [cairo_] show_page

Emits and clears the current page for backends that support multiple pages.  Use C<cairo_copy_page()> if you don't want to clear the page.  This is a convenience function that simply calls C<cairo_surface_show_page()> on this context's target.

  method cairo_show_page ( )


=end pod

sub cairo_show_page ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_in_stroke:
=begin pod
=head2 [cairo_] in_stroke

Tests whether the given point is inside the area that would be affected by a C<cairo_stroke()> operation given the current path and stroking parameters. Surface dimensions and clipping are not taken into account.  See C<cairo_stroke()>, C<cairo_set_line_width()>, C<cairo_set_line_join()>, C<cairo_set_line_cap()>, C<cairo_set_dash()>, and C<cairo_stroke_preserve()>.  Return value: A non-zero value if the point is inside, or zero if outside.

  method cairo_in_stroke ( Num $x, Num $y --> Int )

=item $x; a cairo context
=item $y; X coordinate of the point to test

=end pod

sub cairo_in_stroke ( cairo_t $cr, num64 $x, num64 $y --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_in_fill:
=begin pod
=head2 [cairo_] in_fill

Tests whether the given point is inside the area that would be affected by a C<cairo_fill()> operation given the current path and filling parameters. Surface dimensions and clipping are not taken into account.  See C<cairo_fill()>, C<cairo_set_fill_rule()> and C<cairo_fill_preserve()>.  Return value: A non-zero value if the point is inside, or zero if outside.

  method cairo_in_fill ( Num $x, Num $y --> Int )

=item $x; a cairo context
=item $y; X coordinate of the point to test

=end pod

sub cairo_in_fill ( cairo_t $cr, num64 $x, num64 $y --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_stroke_extents:
=begin pod
=head2 [cairo_] stroke_extents

Computes a bounding box in user coordinates covering the area that would be affected, (the "inked" area), by a C<cairo_stroke()> operation given the current path and stroke parameters. If the current path is empty, returns an empty rectangle ((0,0), (0,0)). Surface dimensions and clipping are not taken into account.  Note that if the line width is set to exactly zero, then C<cairo_stroke_extents()> will return an empty rectangle. Contrast with C<cairo_path_extents()> which can be used to compute the non-empty bounds as the line width approaches zero.  Note that C<cairo_stroke_extents()> must necessarily do more work to compute the precise inked areas in light of the stroke parameters, so C<cairo_path_extents()> may be more desirable for sake of performance if non-inked path extents are desired.  See C<cairo_stroke()>, C<cairo_set_line_width()>, C<cairo_set_line_join()>, C<cairo_set_line_cap()>, C<cairo_set_dash()>, and C<cairo_stroke_preserve()>.

  method cairo_stroke_extents ( Num $x1, Num $y1, Num $x2, Num $y2 )

=item $x1; a cairo context
=item $y1; left of the resulting extents
=item $x2; top of the resulting extents
=item $y2; right of the resulting extents

=end pod

sub cairo_stroke_extents ( cairo_t $cr, num64 $x1, num64 $y1, num64 $x2, num64 $y2 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_fill_extents:
=begin pod
=head2 [cairo_] fill_extents

Computes a bounding box in user coordinates covering the area that would be affected, (the "inked" area), by a C<cairo_fill()> operation given the current path and fill parameters. If the current path is empty, returns an empty rectangle ((0,0), (0,0)). Surface dimensions and clipping are not taken into account.  Contrast with C<cairo_path_extents()>, which is similar, but returns non-zero extents for some paths with no inked area, (such as a simple line segment).  Note that C<cairo_fill_extents()> must necessarily do more work to compute the precise inked areas in light of the fill rule, so C<cairo_path_extents()> may be more desirable for sake of performance if the non-inked path extents are desired.  See C<cairo_fill()>, C<cairo_set_fill_rule()> and C<cairo_fill_preserve()>.

  method cairo_fill_extents ( Num $x1, Num $y1, Num $x2, Num $y2 )

=item $x1; a cairo context
=item $y1; left of the resulting extents
=item $x2; top of the resulting extents
=item $y2; right of the resulting extents

=end pod

sub cairo_fill_extents ( cairo_t $cr, num64 $x1, num64 $y1, num64 $x2, num64 $y2 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_clip:
=begin pod
=head2 cairo_clip

Establishes a new clip region by intersecting the current clip region with the current path as it would be filled by C<cairo_fill()> and according to the current fill rule (see C<cairo_set_fill_rule()>).  After C<cairo_clip()>, the current path will be cleared from the cairo context.  The current clip region affects all drawing operations by effectively masking out any changes to the surface that are outside the current clip region.  Calling C<cairo_clip()> can only make the clip region smaller, never larger. But the current clip is part of the graphics state, so a temporary restriction of the clip region can be achieved by calling C<cairo_clip()> within a C<cairo_save()>/C<cairo_restore()> pair. The only other means of increasing the size of the clip region is C<cairo_reset_clip()>.

  method cairo_clip ( )


=end pod

sub cairo_clip ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_clip_preserve:
=begin pod
=head2 [cairo_] clip_preserve

Establishes a new clip region by intersecting the current clip region with the current path as it would be filled by C<cairo_fill()> and according to the current fill rule (see C<cairo_set_fill_rule()>).  Unlike C<cairo_clip()>, C<cairo_clip_preserve()> preserves the path within the cairo context.  The current clip region affects all drawing operations by effectively masking out any changes to the surface that are outside the current clip region.  Calling C<cairo_clip_preserve()> can only make the clip region smaller, never larger. But the current clip is part of the graphics state, so a temporary restriction of the clip region can be achieved by calling C<cairo_clip_preserve()> within a C<cairo_save()>/C<cairo_restore()> pair. The only other means of increasing the size of the clip region is C<cairo_reset_clip()>.

  method cairo_clip_preserve ( )


=end pod

sub cairo_clip_preserve ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_reset_clip:
=begin pod
=head2 [cairo_] reset_clip

Reset the current clip region to its original, unrestricted state. That is, set the clip region to an infinitely large shape containing the target surface. Equivalently, if infinity is too hard to grasp, one can imagine the clip region being reset to the exact bounds of the target surface.  Note that code meant to be reusable should not call C<cairo_reset_clip()> as it will cause results unexpected by higher-level code which calls C<cairo_clip()>. Consider using C<cairo_save()> and C<cairo_restore()> around C<cairo_clip()> as a more robust means of temporarily restricting the clip region.

  method cairo_reset_clip ( )


=end pod

sub cairo_reset_clip ( cairo_t $cr )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_clip_extents:
=begin pod
=head2 [cairo_] clip_extents

Computes a bounding box in user coordinates covering the area inside the current clip.

  method cairo_clip_extents ( Num $x1, Num $y1, Num $x2, Num $y2 )

=item $x1; a cairo context
=item $y1; left of the resulting extents
=item $x2; top of the resulting extents
=item $y2; right of the resulting extents

=end pod

sub cairo_clip_extents ( cairo_t $cr, num64 $x1, num64 $y1, num64 $x2, num64 $y2 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_in_clip:
=begin pod
=head2 [cairo_] in_clip

Tests whether the given point is inside the area that would be visible through the current clip, i.e. the area that would be filled by a C<cairo_paint()> operation.  See C<cairo_clip()>, and C<cairo_clip_preserve()>.  Return value: A non-zero value if the point is inside, or zero if outside.

  method cairo_in_clip ( Num $x, Num $y --> Int )

=item $x; a cairo context
=item $y; X coordinate of the point to test

=end pod

sub cairo_in_clip ( cairo_t $cr, num64 $x, num64 $y --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_copy_clip_rectangle_list:
=begin pod
=head2 [cairo_] copy_clip_rectangle_list

Gets the current clip region as a list of rectangles in user coordinates. Never returns C<Any>.  The status in the list may be C<CAIRO_STATUS_CLIP_NOT_REPRESENTABLE> to indicate that the clip region cannot be represented as a list of user-space rectangles. The status may have other values to indicate other errors.  Returns: the current clip region as a list of rectangles in user coordinates, which should be destroyed using C<cairo_rectangle_list_destroy()>.

  method cairo_copy_clip_rectangle_list ( --> cairo_rectangle_list_t )


=end pod

sub cairo_copy_clip_rectangle_list ( cairo_t $cr --> cairo_rectangle_list_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_tag_begin:
=begin pod
=head2 [cairo_] tag_begin

Create a destination for a hyperlink. Destination tag attributes are detailed at [Destinations][dests].   CAIRO_TAG_LINK:  Create hyperlink. Link tag attributes are detailed at [Links][links].  Since: 1.16 cairo_tag_begin:  Marks the beginning of the I<tag_name> structure. Call C<cairo_tag_end()> with the same I<tag_name> to mark the end of the structure.  The attributes string is of the form "key1=value2 key2=value2 ...". Values may be boolean (true/false or 1/0), integer, float, string, or an array.  String values are enclosed in single quotes ('). Single quotes and backslashes inside the string should be escaped with a backslash.  Boolean values may be set to true by only specifying the key. eg the attribute string "key" is the equivalent to "key=true".  Arrays are enclosed in '[]'. eg "rect=[1.2 4.3 2.0 3.0]".  If no attributes are required, I<attributes> can be an empty string or NULL.  See [Tags and Links Description][cairo-Tags-and-Links.description] for the list of tags and attributes.  Invalid nesting of tags or invalid attributes will cause this context to shutdown with a status of C<CAIRO_STATUS_TAG_ERROR>.  See C<cairo_tag_end()>.  Since: 1.16

  method cairo_tag_begin ( Str $tag_name, Str $attributes )

=item Str $tag_name;
=item Str $attributes;

=end pod

sub cairo_tag_begin ( cairo_t $cr, Str $tag_name, Str $attributes )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_tag_end:
=begin pod
=head2 [cairo_] tag_end

Marks the end of the I<tag_name> structure.  Invalid nesting of tags will cause this context to shutdown with a status of C<CAIRO_STATUS_TAG_ERROR>.  See C<cairo_tag_begin()>.

  method cairo_tag_end ( Str $tag_name )

=item Str $tag_name; a cairo context

=end pod

sub cairo_tag_end ( cairo_t $cr, Str $tag_name )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_select_font_face:
=begin pod
=head2 [cairo_] select_font_face

Note: The C<cairo_select_font_face()> function call is part of what the cairo designers call the "toy" text API. It is convenient for short demos and simple programs, but it is not expected to be adequate for serious text-using applications.  Selects a family and style of font from a simplified description as a family name, slant and weight. Cairo provides no operation to list available family names on the system (this is a "toy", remember), but the standard CSS2 generic family names, ("serif", "sans-serif", "cursive", "fantasy", "monospace"), are likely to work as expected.  If I<family> starts with the string "I<cairo>:", or if no native font backends are compiled in, cairo will use an internal font family. The internal font family recognizes many modifiers in the I<family> string, most notably, it recognizes the string "monospace".  That is, the family name "I<cairo>:monospace" will use the monospace version of the internal font family.  For "real" font selection, see the font-backend-specific font_face_create functions for the font backend you are using. (For example, if you are using the freetype-based cairo-ft font backend, see C<cairo_ft_font_face_create_for_ft_face()> or C<cairo_ft_font_face_create_for_pattern()>.) The resulting font face could then be used with C<cairo_scaled_font_create()> and C<cairo_set_scaled_font()>.  Similarly, when using the "real" font support, you can call directly into the underlying font system, (such as fontconfig or freetype), for operations such as listing available fonts, etc.  It is expected that most applications will need to use a more comprehensive font handling and text layout library, (for example, pango), in conjunction with cairo.  If text is drawn without a call to C<cairo_select_font_face()>, (nor C<cairo_set_font_face()> nor C<cairo_set_scaled_font()>), the default family is platform-specific, but is essentially "sans-serif". Default slant is C<CAIRO_FONT_SLANT_NORMAL>, and default weight is C<CAIRO_FONT_WEIGHT_NORMAL>.  This function is equivalent to a call to C<cairo_toy_font_face_create()> followed by C<cairo_set_font_face()>.

  method cairo_select_font_face ( Str $family, Int $slant, Int $weight )

=item Str $family; a B<cairo_t>
=item $slant; a font family name, encoded in UTF-8
=item $weight; the slant for the font

=end pod

sub cairo_select_font_face ( cairo_t $cr, Str $family, int32 $slant, int32 $weight )
  is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:cairo_font_extents:
=begin pod
=head2 [cairo_] font_extents

Gets the font extents for the currently selected font.

  method cairo_font_extents ( cairo_font_extents_t $extents )

=item cairo_font_extents_t $extents; a B<cairo_t>

=end pod

sub cairo_font_extents ( cairo_t $cr, cairo_font_extents_t $extents )
  is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:cairo_set_font_face:
=begin pod
=head2 [cairo_] set_font_face

Replaces the current B<cairo_font_face_t> object in the B<cairo_t> with I<font_face>. The replaced font face in the B<cairo_t> will be destroyed if there are no other references to it.

  method cairo_set_font_face ( cairo_font_face_t $font_face )

=item cairo_font_face_t $font_face; a B<cairo_t>

=end pod

sub cairo_set_font_face ( cairo_t $cr, cairo_font_face_t $font_face )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_font_face:
=begin pod
=head2 [cairo_] get_font_face

Gets the current font face for a B<cairo_t>.  Return value: the current font face.  This object is owned by cairo. To keep a reference to it, you must call C<cairo_font_face_reference()>.  This function never returns C<Any>. If memory cannot be allocated, a special "nil" B<cairo_font_face_t> object will be returned on which C<cairo_font_face_status()> returns C<CAIRO_STATUS_NO_MEMORY>. Using this nil object will cause its error state to propagate to other objects it is passed to, (for example, calling C<cairo_set_font_face()> with a nil font will trigger an error that will shutdown the B<cairo_t> object).

  method cairo_get_font_face ( --> cairo_font_face_t )


=end pod

sub cairo_get_font_face ( cairo_t $cr --> cairo_font_face_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_font_size:
=begin pod
=head2 [cairo_] set_font_size

Sets the current font matrix to a scale by a factor of I<size>, replacing any font matrix previously set with C<cairo_set_font_size()> or C<cairo_set_font_matrix()>. This results in a font size of I<size> user space units. (More precisely, this matrix will result in the font's em-square being a I<size> by I<size> square in user space.)  If text is drawn without a call to C<cairo_set_font_size()>, (nor C<cairo_set_font_matrix()> nor C<cairo_set_scaled_font()>), the default font size is 10.0.

  method cairo_set_font_size ( Num $size )

=item $size; a B<cairo_t>

=end pod

sub cairo_set_font_size ( cairo_t $cr, num64 $size )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_font_matrix:
=begin pod
=head2 [cairo_] set_font_matrix

Sets the current font matrix to I<matrix>. The font matrix gives a transformation from the design space of the font (in this space, the em-square is 1 unit by 1 unit) to user space. Normally, a simple scale is used (see C<cairo_set_font_size()>), but a more complex font matrix can be used to shear the font or stretch it unequally along the two axes

  method cairo_set_font_matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a B<cairo_t>

=end pod

sub cairo_set_font_matrix ( cairo_t $cr, cairo_matrix_t $matrix )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_font_matrix:
=begin pod
=head2 [cairo_] get_font_matrix

Stores the current font matrix into I<matrix>. See C<cairo_set_font_matrix()>.

  method cairo_get_font_matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a B<cairo_t>

=end pod

sub cairo_get_font_matrix ( cairo_t $cr, cairo_matrix_t $matrix )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_font_options:
=begin pod
=head2 [cairo_] set_font_options

Sets a set of custom font rendering options for the B<cairo_t>. Rendering options are derived by merging these options with the options derived from underlying surface; if the value in I<options> has a default value (like C<CAIRO_ANTIALIAS_DEFAULT>), then the value from the surface is used.

  method cairo_set_font_options ( cairo_font_options_t $options )

=item cairo_font_options_t $options; a B<cairo_t>

=end pod

sub cairo_set_font_options ( cairo_t $cr, cairo_font_options_t $options )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_font_options:
=begin pod
=head2 [cairo_] get_font_options

Retrieves font rendering options set via B<cairo_set_font_options>. Note that the returned options do not include any options derived from the underlying surface; they are literally the options passed to C<cairo_set_font_options()>.

  method cairo_get_font_options ( cairo_font_options_t $options )

=item cairo_font_options_t $options; a B<cairo_t>

=end pod

sub cairo_get_font_options ( cairo_t $cr, cairo_font_options_t $options )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_set_scaled_font:
=begin pod
=head2 [cairo_] set_scaled_font

Replaces the current font face, font matrix, and font options in the B<cairo_t> with those of the B<cairo_scaled_font_t>.  Except for some translation, the current CTM of the B<cairo_t> should be the same as that of the B<cairo_scaled_font_t>, which can be accessed using C<cairo_scaled_font_get_ctm()>.

  method cairo_set_scaled_font ( cairo_scaled_font_t $scaled_font )

=item cairo_scaled_font_t $scaled_font; a B<cairo_t>

=end pod

sub cairo_set_scaled_font ( cairo_t $cr, cairo_scaled_font_t $scaled_font )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_scaled_font:
=begin pod
=head2 [cairo_] get_scaled_font

Gets the current scaled font for a B<cairo_t>.  Return value: the current scaled font. This object is owned by cairo. To keep a reference to it, you must call C<cairo_scaled_font_reference()>.  This function never returns C<Any>. If memory cannot be allocated, a special "nil" B<cairo_scaled_font_t> object will be returned on which C<cairo_scaled_font_status()> returns C<CAIRO_STATUS_NO_MEMORY>. Using this nil object will cause its error state to propagate to other objects it is passed to, (for example, calling C<cairo_set_scaled_font()> with a nil font will trigger an error that will shutdown the B<cairo_t> object).

  method cairo_get_scaled_font ( --> cairo_scaled_font_t )


=end pod

sub cairo_get_scaled_font ( cairo_t $cr --> cairo_scaled_font_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_text_extents:
=begin pod
=head2 [cairo_] text_extents

Gets the extents for a string of text. The extents describe a user-space rectangle that encloses the "inked" portion of the text, (as it would be drawn by C<cairo_show_text()>). Additionally, the x_advance and y_advance values indicate the amount by which the current point would be advanced by C<cairo_show_text()>.  Note that whitespace characters do not directly contribute to the size of the rectangle (extents.width and extents.height). They do contribute indirectly by changing the position of non-whitespace characters. In particular, trailing whitespace characters are likely to not affect the size of the rectangle, though they will affect the x_advance and y_advance values.

  method cairo_text_extents ( Str $utf8 --> cairo_text_extents_t )

=item Str $utf8; a B<cairo_t>

Returns cairo_text_extents_t; a string of text encoded in UTF-8, or undefined

=end pod

sub cairo_text_extents ( cairo_t $cr, Str $utf8 --> cairo_text_extents_t ) {
  my cairo_text_extents_t $te .= new;
  _cairo_text_extents( $cr, $utf8, $te);
  $te
}

sub _cairo_text_extents (
  cairo_t $cr, Str $utf8, cairo_text_extents_t $extents is rw
) is native(&cairo-lib)
  is symbol('cairo_text_extents')
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_glyph_extents:
=begin pod
=head2 [cairo_] glyph_extents

Gets the extents for an array of glyphs. The extents describe a user-space rectangle that encloses the "inked" portion of the glyphs, (as they would be drawn by C<cairo_show_glyphs()>). Additionally, the x_advance and y_advance values indicate the amount by which the current point would be advanced by C<cairo_show_glyphs()>.  Note that whitespace glyphs do not contribute to the size of the rectangle (extents.width and extents.height).

  method cairo_glyph_extents ( cairo_glyph_t $glyphs, Int $num_glyphs, cairo_text_extents_t $extents )

=item cairo_glyph_t $glyphs; a B<cairo_t>
=item $num_glyphs; an array of B<cairo_glyph_t> objects
=item cairo_text_extents_t $extents; the number of elements in I<glyphs>

=end pod

sub cairo_glyph_extents ( cairo_t $cr, cairo_glyph_t $glyphs, int32 $num_glyphs, cairo_text_extents_t $extents )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_show_text:
=begin pod
=head2 [cairo_] show_text

A drawing operator that generates the shape from a string of UTF-8 characters, rendered according to the current font_face, font_size (font_matrix), and font_options.  This function first computes a set of glyphs for the string of text. The first glyph is placed so that its origin is at the current point. The origin of each subsequent glyph is offset from that of the previous glyph by the advance values of the previous glyph.  After this call the current point is moved to the origin of where the next glyph would be placed in this same progression. That is, the current point will be at the origin of the final glyph offset by its advance values. This allows for easy display of a single logical string with multiple calls to C<cairo_show_text()>.  Note: The C<cairo_show_text()> function call is part of what the cairo designers call the "toy" text API. It is convenient for short demos and simple programs, but it is not expected to be adequate for serious text-using applications. See C<cairo_show_glyphs()> for the "real" text display API in cairo.

  method cairo_show_text ( Str $utf8 )

=item Str $utf8; a cairo context

=end pod

sub cairo_show_text ( cairo_t $cr, Str $utf8 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_show_glyphs:
=begin pod
=head2 [cairo_] show_glyphs

A drawing operator that generates the shape from an array of glyphs, rendered according to the current font face, font size (font matrix), and font options.

  method cairo_show_glyphs ( cairo_glyph_t $glyphs, Int $num_glyphs )

=item cairo_glyph_t $glyphs; a cairo context
=item $num_glyphs; array of glyphs to show

=end pod

sub cairo_show_glyphs ( cairo_t $cr, cairo_glyph_t $glyphs, int32 $num_glyphs )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_show_text_glyphs:
=begin pod
=head2 [cairo_] show_text_glyphs

This operation has rendering effects similar to C<cairo_show_glyphs()> but, if the target surface supports it, uses the provided text and cluster mapping to embed the text for the glyphs shown in the output. If the target does not support the extended attributes, this function acts like the basic C<cairo_show_glyphs()> as if it had been passed I<glyphs> and I<num_glyphs>.  The mapping between I<utf8> and I<glyphs> is provided by an array of I<clusters>.  Each cluster covers a number of text bytes and glyphs, and neighboring clusters cover neighboring areas of I<utf8> and I<glyphs>.  The clusters should collectively cover I<utf8> and I<glyphs> in entirety.  The first cluster always covers bytes from the beginning of I<utf8>. If I<cluster_flags> do not have the C<CAIRO_TEXT_CLUSTER_FLAG_BACKWARD> set, the first cluster also covers the beginning of I<glyphs>, otherwise it covers the end of the I<glyphs> array and following clusters move backward.  See B<cairo_text_cluster_t> for constraints on valid clusters.

  method cairo_show_text_glyphs ( Str $utf8, Int $utf8_len, cairo_glyph_t $glyphs, Int $num_glyphs, cairo_text_cluster_t $clusters, Int $num_clusters, Int $cluster_flags )

=item Str $utf8; a cairo context
=item $utf8_len; a string of text encoded in UTF-8
=item cairo_glyph_t $glyphs; length of I<utf8> in bytes, or -1 if it is NUL-terminated
=item $num_glyphs; array of glyphs to show
=item cairo_text_cluster_t $clusters; number of glyphs to show
=item $num_clusters; array of cluster mapping information
=item $cluster_flags; number of clusters in the mapping

=end pod

sub cairo_show_text_glyphs ( cairo_t $cr, Str $utf8, int32 $utf8_len, cairo_glyph_t $glyphs, int32 $num_glyphs, cairo_text_cluster_t $clusters, int32 $num_clusters, int32 $cluster_flags )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_text_path:
=begin pod
=head2 [cairo_] text_path

Adds closed paths for text to the current path.  The generated path if filled, achieves an effect similar to that of C<cairo_show_text()>.  Text conversion and positioning is done similar to C<cairo_show_text()>.  Like C<cairo_show_text()>, After this call the current point is moved to the origin of where the next glyph would be placed in this same progression.  That is, the current point will be at the origin of the final glyph offset by its advance values. This allows for chaining multiple calls to to C<cairo_text_path()> without having to set current point in between.  Note: The C<cairo_text_path()> function call is part of what the cairo designers call the "toy" text API. It is convenient for short demos and simple programs, but it is not expected to be adequate for serious text-using applications. See C<cairo_glyph_path()> for the "real" text path API in cairo.

  method cairo_text_path ( Str $utf8 )

=item Str $utf8; a cairo context

=end pod

sub cairo_text_path ( cairo_t $cr, Str $utf8 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_glyph_path:
=begin pod
=head2 [cairo_] glyph_path

Adds closed paths for the glyphs to the current path.  The generated path if filled, achieves an effect similar to that of C<cairo_show_glyphs()>.

  method cairo_glyph_path ( cairo_glyph_t $glyphs, Int $num_glyphs )

=item cairo_glyph_t $glyphs; a cairo context
=item $num_glyphs; array of glyphs to show

=end pod

sub cairo_glyph_path ( cairo_t $cr, cairo_glyph_t $glyphs, int32 $num_glyphs )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_operator:
=begin pod
=head2 [cairo_] get_operator

Gets the current compositing operator for a cairo context.  Return value: the current compositing operator.

  method cairo_get_operator ( --> Int )


=end pod

sub cairo_get_operator ( cairo_t $cr --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_opacity:
=begin pod
=head2 [cairo_] get_opacity

Gets the current compositing opacity for a cairo context.  Return value: the current compositing opacity.  Since: TBD

  method cairo_get_opacity ( --> Num )


=end pod

sub cairo_get_opacity ( cairo_t $cr --> num64 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_tolerance:
=begin pod
=head2 [cairo_] get_tolerance

Gets the current tolerance value, as set by C<cairo_set_tolerance()>.  Return value: the current tolerance value.

  method cairo_get_tolerance ( --> Num )


=end pod

sub cairo_get_tolerance ( cairo_t $cr --> num64 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_antialias:
=begin pod
=head2 [cairo_] get_antialias

Gets the current shape antialiasing mode, as set by C<cairo_set_antialias()>.  Return value: the current shape antialiasing mode.

  method cairo_get_antialias ( --> Int )


=end pod

sub cairo_get_antialias ( cairo_t $cr --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_has_current_point:
=begin pod
=head2 [cairo_] has_current_point

Returns whether a current point is defined on the current path. See C<cairo_get_current_point()> for details on the current point.  Return value: whether a current point is defined.

  method cairo_has_current_point ( --> Int )


=end pod

sub cairo_has_current_point ( cairo_t $cr --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_current_point:
=begin pod
=head2 [cairo_] get_current_point

Gets the current point of the current path, which is conceptually the final point reached by the path so far.  The current point is returned in the user-space coordinate system. If there is no defined current point or if this context is in an error status, I<x> and I<y> will both be set to 0.0. It is possible to check this in advance with C<cairo_has_current_point()>.  Most path construction functions alter the current point. See the following for details on how they affect the current point: C<cairo_new_path()>, C<cairo_new_sub_path()>, C<cairo_append_path()>, C<cairo_close_path()>, C<cairo_move_to()>, C<cairo_line_to()>, C<cairo_curve_to()>, C<cairo_rel_move_to()>, C<cairo_rel_line_to()>, C<cairo_rel_curve_to()>, C<cairo_arc()>, C<cairo_arc_negative()>, C<cairo_rectangle()>, C<cairo_text_path()>, C<cairo_glyph_path()>, C<cairo_stroke_to_path()>.  Some functions use and alter the current point but do not otherwise change current path: C<cairo_show_text()>.  Some functions unset the current path and as a result, current point: C<cairo_fill()>, C<cairo_stroke()>.

  method cairo_get_current_point ( Num $x_ret, Num $y_ret )

=item $x_ret; a cairo context
=item $y_ret; return value for X coordinate of the current point

=end pod

sub cairo_get_current_point ( cairo_t $cr, num64 $x_ret, num64 $y_ret )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_fill_rule:
=begin pod
=head2 [cairo_] get_fill_rule

Gets the current fill rule, as set by C<cairo_set_fill_rule()>.  Return value: the current fill rule.

  method cairo_get_fill_rule ( --> Int )


=end pod

sub cairo_get_fill_rule ( cairo_t $cr --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_line_width:
=begin pod
=head2 [cairo_] get_line_width

This function returns the current line width value exactly as set by C<cairo_set_line_width()>. Note that the value is unchanged even if the CTM has changed between the calls to C<cairo_set_line_width()> and C<cairo_get_line_width()>.  Return value: the current line width.

  method cairo_get_line_width ( --> Num )


=end pod

sub cairo_get_line_width ( cairo_t $cr --> num64 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_line_cap:
=begin pod
=head2 [cairo_] get_line_cap

Gets the current line cap style, as set by C<cairo_set_line_cap()>.  Return value: the current line cap style.

  method cairo_get_line_cap ( --> Int )


=end pod

sub cairo_get_line_cap ( cairo_t $cr --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_line_join:
=begin pod
=head2 [cairo_] get_line_join

Gets the current line join style, as set by C<cairo_set_line_join()>.  Return value: the current line join style.

  method cairo_get_line_join ( --> Int )


=end pod

sub cairo_get_line_join ( cairo_t $cr --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_miter_limit:
=begin pod
=head2 [cairo_] get_miter_limit

Gets the current miter limit, as set by C<cairo_set_miter_limit()>.  Return value: the current miter limit.

  method cairo_get_miter_limit ( --> Num )


=end pod

sub cairo_get_miter_limit ( cairo_t $cr --> num64 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_matrix:
=begin pod
=head2 [cairo_] get_matrix

Stores the current transformation matrix (CTM) into I<matrix>.

  method cairo_get_matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a cairo context

=end pod

sub cairo_get_matrix ( cairo_t $cr, cairo_matrix_t $matrix )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_target:
=begin pod
=head2 [cairo_] get_target

Gets the target surface for the cairo context as passed to C<cairo_create()>.  This function will always return a valid pointer, but the result can be a "nil" surface if this context is already in an error state, (ie. C<cairo_status()> <literal>!=</literal> C<CAIRO_STATUS_SUCCESS>). A nil surface is indicated by C<cairo_surface_status()> <literal>!=</literal> C<CAIRO_STATUS_SUCCESS>.  Return value: the target surface. This object is owned by cairo. To keep a reference to it, you must call C<cairo_surface_reference()>.

  method cairo_get_target ( --> cairo_surface_t )


=end pod

sub cairo_get_target ( cairo_t $cr --> cairo_surface_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_get_group_target:
=begin pod
=head2 [cairo_] get_group_target

Gets the current destination surface for the context. This is either the original target surface as passed to C<cairo_create()> or the target surface for the current group as started by the most recent call to C<cairo_push_group()> or C<cairo_push_group_with_content()>.  This function will always return a valid pointer, but the result can be a "nil" surface if this context is already in an error state, (ie. C<cairo_status()> <literal>!=</literal> C<CAIRO_STATUS_SUCCESS>). A nil surface is indicated by C<cairo_surface_status()> <literal>!=</literal> C<CAIRO_STATUS_SUCCESS>.  Return value: the target surface. This object is owned by cairo. To keep a reference to it, you must call C<cairo_surface_reference()>.

  method cairo_get_group_target ( --> cairo_surface_t )


=end pod

sub cairo_get_group_target ( cairo_t $cr --> cairo_surface_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_copy_path:
=begin pod
=head2 [cairo_] copy_path

Creates a copy of the current path and returns it to the user as a B<cairo_path_t>. See B<cairo_path_data_t> for hints on how to iterate over the returned data structure.

This function will always return a valid pointer, but the result will have no data (C<.data ~~ undefined> and C<.num_data ~~ 0>), if either of the following conditions hold:

=item If there is insufficient memory to copy the path. In this case C<.status()> will be set to C<CAIRO_STATUS_NO_MEMORY>.

=item If the context is already in an error state. In this case C<.status> will contain the same status that would be returned by C<cairo_status().

The caller owns the returned object and should call C<()> when finished with it.

  method cairo_copy_path ( --> cairo_path_t )


=end pod

sub cairo_copy_path ( cairo_t $cr --> cairo_path_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_copy_path_flat:
=begin pod
=head2 [cairo_] copy_path_flat

Gets a flattened copy of the current path and returns it to the user as a B<cairo_path_t>. See B<cairo_path_data_t> for hints on how to iterate over the returned data structure.  This function is like C<cairo_copy_path()> except that any curves in the path will be approximated with piecewise-linear approximations, (accurate to within the current tolerance value). That is, the result is guaranteed to not have any elements of type C<CAIRO_PATH_CURVE_TO> which will instead be replaced by a series of C<CAIRO_PATH_LINE_TO> elements.  This function will always return a valid pointer, but the result will have no data (<literal>data==C<Any></literal> and <literal>num_data==0</literal>), if either of the following conditions hold:  <orderedlist> <listitem>If there is insufficient memory to copy the path. In this case <literal>path->status</literal> will be set to C<CAIRO_STATUS_NO_MEMORY>.</listitem> <listitem>If this context is already in an error state. In this case <literal>path->status</literal> will contain the same status that would be returned by C<cairo_status()>.</listitem> </orderedlist>  Return value: the copy of the current path. The caller owns the returned object and should call C<cairo_path_destroy()> when finished with it.

  method cairo_copy_path_flat ( --> cairo_path_t )


=end pod

sub cairo_copy_path_flat ( cairo_t $cr --> cairo_path_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_append_path:
=begin pod
=head2 [cairo_] append_path

Append the I<path> onto the current path. The I<path> may be either the return value from one of C<cairo_copy_path()> or C<cairo_copy_path_flat()> or it may be constructed manually.  See B<cairo_path_t> for details on how the path data structure should be initialized, and note that <literal>path->status</literal> must be initialized to C<CAIRO_STATUS_SUCCESS>.

  method cairo_append_path ( cairo_path_t $path )

=item cairo_path_t $path; a cairo context

=end pod

sub cairo_append_path ( cairo_t $cr, cairo_path_t $path )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:cairo_status:
=begin pod
=head2 cairo_status

Checks whether an error has previously occurred for this context.  Returns: the current status of this context, see B<cairo_status_t>

  method cairo_status ( --> Int )


=end pod

sub cairo_status ( cairo_t $cr --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:cairo_status_to_string:
=begin pod
=head2 [[cairo_] status_] to_string

Provides a human-readable description of a cairo_status_t.

  method cairo_status_to_string ( cairo_status_t $status--> Str )

=end pod

sub cairo_status_to_string ( int32 $status --> Str )
  is native(&cairo-lib)
  { * }
