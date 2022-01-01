#TL:4:Gnome::Cairo::Pattern:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Pattern

Sources for drawing

=comment ![](images/X.png)

=head1 Description

 B<cairo_pattern_t> is the paint with which cairo draws. The primary use of patterns is as the source for all cairo drawing operations, although they can also be used as masks, that is, as the brush too.

 A cairo pattern is created by using one of the many constructors in the form of C<new(:rgb())> for example.


=head2 See Also

B<cairo_t>, B<cairo_surface_t>


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo::Pattern;
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
unit class Gnome::Cairo::Pattern:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 new ( :rgb( red, green, blue) )

Creates a new B<cairo_pattern_t> corresponding to an opaque color. The color components are floating point numbers in the range 0 to 1. If the values passed in are outside that range, they will be clamped. Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.

The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it. This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error. To inspect the status of a pattern use C<cairo_pattern_status()>.

A translucent colored pattern is created when also an alpha value is defined.

  multi method new ( :rgb( Num() $red, Num() $green, Num() $blue) )

=item $red; red color from 0 to 1
=item $green; green color from 0 to 1
=item $blue; blue color from 0 to 1

=head3 new ( )

Creates a new B<cairo_pattern_t> as if :rgb( 1, 1, 1) is used. This is a white colored pattern.

  multi method new ( )

=head3 new ( :rgba( red, green, blue, alpha) )

Creates a new B<cairo_pattern_t> corresponding to a color with added transparency.

The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it. This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error. To inspect the status of a pattern use C<cairo_pattern_status()>.

  multi method new (
    :rgba( Num() $red, Num() $green, Num() $blue, Num() $alpha)
  )

=item $red; red color from 0 to 1
=item $green; green color from 0 to 1
=item $blue; blue color from 0 to 1
=item $alpha; transparency from 0 to 1 (opaque)

=head3 new ( :surface )

Create a new B<cairo_pattern_t> for the given surface. The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it. This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error. To inspect the status of a pattern use C<cairo_pattern_status()>.

  multi method new ( cairo_surface_t :$surface! )


=head3 new ( :linear( x0, y0, x1, y1) )

Create a new linear gradient B<cairo_pattern_t> along the line defined by (x0, y0) and (x1, y1).  Before using the gradient pattern, a number of color stops should be defined using C<cairo_pattern_add_color_stop_rgb()> or C<cairo_pattern_add_color_stop_rgba()>.  Note: The coordinates here are in pattern space. For a new pattern, pattern space is identical to user space, but the relationship between the spaces can be changed with C<cairo_pattern_set_matrix()>.

The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error.  To inspect the status of a pattern use C<cairo_pattern_status()>.

  method new ( :linear( Num() $x0, Num() $y0, Num() $x1, Num() $y1) )

=item $x0; x coordinate of the start point
=item $y0; y coordinate of the start point
=item $x1; x coordinate of the end point
=item $y1; y coordinate of the end point


=head3 new ( :radial( cx0, cy0, radius0, cx1, cy1, radius1) )

Creates a new radial gradient B<cairo_pattern_t> between the two circles defined by (cx0, cy0, radius0) and (cx1, cy1, radius1).  Before using the gradient pattern, a number of color stops should be defined using C<cairo_pattern_add_color_stop_rgb()> or C<cairo_pattern_add_color_stop_rgba()>.  Note: The coordinates here are in pattern space. For a new pattern, pattern space is identical to user space, but the relationship between the spaces can be changed with C<cairo_pattern_set_matrix()>.

The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it. To inspect the status of a pattern use C<cairo_pattern_status()>.

  method new (
    :radial(
      Num() $cx0, Num() $cy0, Num() $radius0,
      Num() $cx1, Num() $cy1, Num() $radius1
    )
  )

=item $cx0; x coordinate for the center of the start circle
=item $cy0; y coordinate for the center of the start circle
=item $radius0; radius of the start circle
=item $cx1; x coordinate for the center of the end circle
=item $cy1; y coordinate for the center of the end circle
=item $radius1; radius of the end circle


=head3 new( :mesh )

Create a new mesh pattern.

Mesh patterns are tensor-product patch meshes (type 7 shadings in PDF). Mesh patterns may also be used to create other types of shadings that are special cases of tensor-product patch meshes such as Coons patch meshes (type 6 shading in PDF) and Gouraud-shaded triangle meshes (type 4 and 5 shadings in PDF).

Mesh patterns consist of one or more tensor-product patches, which should be defined before using the mesh pattern. Using a mesh pattern with a partially defined patch as source or mask will put the context in an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

A tensor-product patch is defined by 4 Bézier curves (side 0, 1, 2, 3) and by 4 additional control points (P0, P1, P2, P3) that provide further control over the patch and complete the definition of the tensor-product patch. The corner C0 is the first point of the patch.

Degenerate sides are permitted so straight lines may be used. A zero length line on one side may be used to create 3 sided patches.

        C1     Side 1      C2
          +---------------+
          |               |
          |  P1       P2  |
          |               |
  Side 0  |               | Side 2
          |               |
          |               |
          |  P0       P3  |
          |               |
          +---------------+
        C0     Side 3      C3

Each patch is constructed by first calling C<cairo_mesh_pattern_begin_patch()>, then C<mesh-pattern-move-to()> to specify the first point in the patch (C0). Then the sides are specified with calls to C<mesh-pattern-curve-to()> and C<mesh-pattern-line-to()>.

The four additional control points (P0, P1, P2, P3) in a patch can be specified with C<mesh-pattern-set-control_point()>.  At each corner of the patch (C0, C1, C2, C3) a color may be specified with C<mesh-pattern-set-corner-color-rgb()> or C<mesh-pattern-set-corner-color-rgba()>. Any corner whose color is not explicitly specified defaults to transparent black.  A Coons patch is a special case of the tensor-product patch where the control points are implicitly defined by the sides of the patch. The default value for any control point not specified is the implicit value for a Coons patch, i.e. if no control points are specified the patch is a Coons patch.  A triangle is a special case of the tensor-product patch where the control points are implicitly defined by the sides of the patch, all the sides are lines and one of them has length 0, i.e. if the patch is specified using just 3 lines, it is a triangle. If the corners connected by the 0-length side have the same color, the patch is a Gouraud-shaded triangle.  Patches may be oriented differently to the above diagram. For example the first point could be at the top left. The diagram only shows the relationship between the sides, corners and control points. Regardless of where the first point is located, when specifying colors, corner 0 will always be the first point, corner 1 the point between side 0 and side 1 etc.

Calling C<mesh-pattern-end-patch()> completes the current patch. If less than 4 sides have been defined, the first missing side is defined as a line from the current point to the first point of the patch (C0) and the other sides are degenerate lines from C0 to C0. The corners between the added sides will all be coincident with C0 of the patch and their color will be set to be the same as the color of C0.

Additional patches may be added with additional calls to C<mesh-pattern-begin-patch()>/C<mesh-pattern-end-patch()>.

  my Gnome::Cairo $pattern .= new(:mesh);

  # Add a Coons patch
  $pattern.mesh-pattern-begin-patch( $pattern);
  $pattern.mesh-pattern-move-to( 0, 0);
  $pattern.mesh-pattern-curve-to( 30, -30,  60,  30, 100, 0);
  $pattern.mesh-pattern-curve-to( 60,  30, 130,  60, 100, 100);
  $pattern.mesh-pattern-curve-to( 60,  70,  30, 130,   0, 100);
  $pattern.mesh-pattern-curve-to( 30,  70, -30,  30,   0, 0);
  $pattern.mesh-pattern-set-corner-color-rgb( $pattern, 0, 1, 0, 0);
  $pattern.mesh-pattern-set-corner-color-rgb( 1, 0, 1, 0);
  $pattern.mesh-pattern-set-corner-color-rgb( 2, 0, 0, 1);
  $pattern.mesh-pattern-set-corner-color-rgb( 3, 1, 1, 0);
  $pattern.mesh-pattern-end-patch;

  # Add a Gouraud-shaded triangle
  $pattern.mesh-pattern-begin-patch;
  $pattern.mesh-pattern-move-to( 100, 100);
  $pattern.mesh-pattern-line-to( 130, 130);
  $pattern.mesh-pattern-line-to( 130,  70);
  $pattern.mesh-pattern-set-corner-color-rgb( 0, 1, 0, 0);
  $pattern.mesh-pattern-set-corner-color-rgb( 1, 0, 1, 0);
  $pattern.mesh-pattern-set-corner-color-rgb( 2, 0, 0, 1);
  $pattern.mesh-pattern-end-patch;

When two patches overlap, the last one that has been added is drawn over the first one.

When a patch folds over itself, points are sorted depending on their parameter coordinates inside the patch. The v coordinate ranges from 0 to 1 when moving from side 3 to side 1; the u coordinate ranges from 0 to 1 when going from side 0 to side 2. Points with higher v coordinate hide points with lower v coordinate. When two points have the same v coordinate, the one with higher u coordinate is above. This means that points nearer to side 1 are above points nearer to side 3; when this is not sufficient to decide which point is above (for example when both points belong to side 1 or side 3) points nearer to side 2 are above points nearer to side 0.  For a complete definition of tensor-product patches, see the PDF specification (ISO32000), which describes the parametrization in detail.

Note: The coordinates are always in pattern space. For a new pattern, pattern space is identical to user space, but the relationship between the spaces can be changed with C<pattern-set-matrix()>.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory. The caller owns the returned object and should call C<pattern-destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error. To inspect the status of a pattern use C<pattern-status()>.

  multi method new ( :mesh! )


=end pod

#TM:1:new():
#TM:1:new(:rgb):
#TM:1:new(:rgba):
#TM:1:new(:linear):
#TM:1:new(:radial):
#TM:1:new(:surface):
#TM:1:new(:mesh):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Pattern' #`{{ or %options<CairoPattern> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    else {
      my $no;

      # set rgba
      if %options<rgb>:exists {
        my @rgb = map { ($_//0).Num }, %options<rgb>[^3];
        $no = _cairo_pattern_create_rgb(|@rgb);
      }

      # set rgb
      elsif %options<rgba>:exists {
        my @rgba = map { ($_//0).Num }, %options<rgba>[^4];
        $no = _cairo_pattern_create_rgba(|@rgba);
      }

      # linear gradient
      elsif %options<linear>:exists {
        my @linear = map { ($_//0).Num }, %options<linear>[^4];
        $no = _cairo_pattern_create_linear(|@linear);
      }

      # radial gradient
      elsif %options<radial>:exists {
        my @radial = map { ($_//0).Num }, %options<radial>[^6];
        $no = _cairo_pattern_create_radial(|@radial);
      }

      # surface
      elsif %options<surface>:exists {
        $no = %options<surface>;
        $no .= _get-native-object-no-reffing
          if $no.^can('_get-native-object-no-reffing');
        $no = _cairo_pattern_create_for_surface($no);
      }

      # mesh
      elsif %options<mesh>:exists {
        $no = _cairo_pattern_create_mesh;
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

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

#      #`{{ when there are defaults use this instead
      # create default object
      else {
        $no = _cairo_pattern_create_rgb( 1e0, 1e0, 1e0);
      }
#      }}

      self._set-native-object($no);
    }

    # only after creating the native-object
    self._set-class-info('CairoPattern');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_pattern_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

  self._set-class-name-of-sub('CairoPattern');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
method native-object-ref ( $no ) {
  _cairo_pattern_reference($no)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $no ) {
  _cairo_pattern_destroy($no)
}


#-------------------------------------------------------------------------------
#TM:0:add-color-stop-rgb:
=begin pod
=head2 add-color-stop-rgb

Adds an opaque color stop to a gradient pattern. The offset specifies the location along the gradient's control vector. For example, a linear gradient's control vector is from (x0,y0) to (x1,y1) while a radial gradient's control vector is from any point on the start circle to the corresponding point on the end circle.  The color is specified in the same way as in C<cairo_set_source_rgb()>.  If two (or more) stops are specified with identical offset values, they will be sorted according to the order in which the stops are added, (stops added earlier will compare less than stops added later). This can be useful for reliably making sharp color transitions instead of the typical blend.   Note: If the pattern is not a gradient pattern, (eg. a linear or radial pattern), then the pattern will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>.

  method add-color-stop-rgb ( Num $offset, Num $red, Num $green, Num $blue )

=item Num $offset; a B<cairo_pattern_t>
=item Num $red; an offset in the range [0.0 .. 1.0]
=item Num $green; red component of color
=item Num $blue; green component of color
=end pod

method add-color-stop-rgb ( Num $offset, Num $red, Num $green, Num $blue ) {

  cairo_pattern_add_color_stop_rgb(
    self._get-native-object-no-reffing, $offset, $red, $green, $blue
  )
}

sub cairo_pattern_add_color_stop_rgb (
  cairo_pattern_t $pattern, gdouble $offset, gdouble $red, gdouble $green, gdouble $blue
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:add-color-stop-rgba:
=begin pod
=head2 add-color-stop-rgba

Adds a translucent color stop to a gradient pattern. The offset specifies the location along the gradient's control vector. For example, a linear gradient's control vector is from (x0,y0) to (x1,y1) while a radial gradient's control vector is from any point on the start circle to the corresponding point on the end circle.  The color is specified in the same way as in C<cairo_set_source_rgba()>.  If two (or more) stops are specified with identical offset values, they will be sorted according to the order in which the stops are added, (stops added earlier will compare less than stops added later). This can be useful for reliably making sharp color transitions instead of the typical blend.  Note: If the pattern is not a gradient pattern, (eg. a linear or radial pattern), then the pattern will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>.

  method add-color-stop-rgba ( Num $offset, Num $red, Num $green, Num $blue, Num $alpha )

=item Num $offset; a B<cairo_pattern_t>
=item Num $red; an offset in the range [0.0 .. 1.0]
=item Num $green; red component of color
=item Num $blue; green component of color
=item Num $alpha; blue component of color
=end pod

method add-color-stop-rgba ( Num $offset, Num $red, Num $green, Num $blue, Num $alpha ) {

  cairo_pattern_add_color_stop_rgba(
    self._get-native-object-no-reffing, $offset, $red, $green, $blue, $alpha
  )
}

sub cairo_pattern_add_color_stop_rgba (
  cairo_pattern_t $pattern, gdouble $offset, gdouble $red, gdouble $green, gdouble $blue, gdouble $alpha
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-begin-patch:
=begin pod
=head2 mesh-pattern-begin-patch

Begin a patch in a mesh pattern.  After calling this function, the patch shape should be defined with C<cairo_mesh_pattern_move_to()>, C<cairo_mesh_pattern_line_to()> and C<cairo_mesh_pattern_curve_to()>.  After defining the patch, C<cairo_mesh_pattern_end_patch()> must be called before using I<pattern> as a source or mask.  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<pattern> already has a current patch, it will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method mesh-pattern-begin-patch ( )

=end pod

method mesh-pattern-begin-patch ( ) {

  cairo_mesh_pattern_begin_patch(
    self._get-native-object-no-reffing,
  )
}

sub cairo_mesh_pattern_begin_patch (
  cairo_pattern_t $pattern
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-curve-to:
=begin pod
=head2 mesh-pattern-curve-to

Adds a cubic Bézier spline to the current patch from the current point to position (I<x3>, I<y3>) in pattern-space coordinates, using (I<x1>, I<y1>) and (I<x2>, I<y2>) as the control points.  If the current patch has no current point before the call to C<cairo_mesh_pattern_curve_to()>, this function will behave as if preceded by a call to cairo_mesh_pattern_move_to(I<pattern>, I<x1>, I<y1>).  After this call the current point will be (I<x3>, I<y3>).  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<pattern> has no current patch or the current patch already has 4 sides, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method mesh-pattern-curve-to ( Num $x1, Num $y1, Num $x2, Num $y2, Num $x3, Num $y3 )

=item Num $x1; a B<cairo_pattern_t>
=item Num $y1; the X coordinate of the first control point
=item Num $x2; the Y coordinate of the first control point
=item Num $y2; the X coordinate of the second control point
=item Num $x3; the Y coordinate of the second control point
=item Num $y3; the X coordinate of the end of the curve
=end pod

method mesh-pattern-curve-to ( Num $x1, Num $y1, Num $x2, Num $y2, Num $x3, Num $y3 ) {

  cairo_mesh_pattern_curve_to(
    self._get-native-object-no-reffing, $x1, $y1, $x2, $y2, $x3, $y3
  )
}

sub cairo_mesh_pattern_curve_to (
  cairo_pattern_t $pattern, gdouble $x1, gdouble $y1, gdouble $x2, gdouble $y2, gdouble $x3, gdouble $y3
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-end-patch:
=begin pod
=head2 mesh-pattern-end-patch

Indicates the end of the current patch in a mesh pattern.  If the current patch has less than 4 sides, it is closed with a straight line from the current point to the first point of the patch as if C<cairo_mesh_pattern_line_to()> was used.  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<pattern> has no current patch or the current patch has no current point, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method mesh-pattern-end-patch ( )

=end pod

method mesh-pattern-end-patch ( ) {

  cairo_mesh_pattern_end_patch(
    self._get-native-object-no-reffing,
  )
}

sub cairo_mesh_pattern_end_patch (
  cairo_pattern_t $pattern
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-get-control-point:
=begin pod
=head2 mesh-pattern-get-control-point

Gets the control point I<point_num> of patch I<patch_num> for a mesh pattern.  I<patch_num> can range from 0 to n-1 where n is the number returned by C<cairo_mesh_pattern_get_patch_count()>.  Valid values for I<point_num> are from 0 to 3 and identify the control points as explained in C<cairo_pattern_create_mesh()>.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_INVALID_INDEX> if I<patch_num> or I<point_num> is not valid for I<pattern>. If I<pattern> is not a mesh pattern, C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> is returned.

  method mesh-pattern-get-control-point ( Int $patch_num, Int $point_num, Num $x, Num $y --> cairo_status_t )

=item Int $patch_num; a B<cairo_pattern_t>
=item Int $point_num; the patch number to return data for
=item Num $x; the control point number to return data for
=item Num $y; return value for the x coordinate of the control point, or C<Any>
=end pod

method mesh-pattern-get-control-point ( Int $patch_num, Int $point_num, Num $x, Num $y --> cairo_status_t ) {

  cairo_mesh_pattern_get_control_point(
    self._get-native-object-no-reffing, $patch_num, $point_num, $x, $y
  )
}

sub cairo_mesh_pattern_get_control_point (
  cairo_pattern_t $pattern, guint $patch_num, guint $point_num, gdouble $x, gdouble $y --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-get-corner-color-rgba:
=begin pod
=head2 mesh-pattern-get-corner-color-rgba

Gets the color information in corner I<corner_num> of patch I<patch_num> for a mesh pattern.  I<patch_num> can range from 0 to n-1 where n is the number returned by C<cairo_mesh_pattern_get_patch_count()>.  Valid values for I<corner_num> are from 0 to 3 and identify the corners as explained in C<cairo_pattern_create_mesh()>.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_INVALID_INDEX> if I<patch_num> or I<corner_num> is not valid for I<pattern>. If I<pattern> is not a mesh pattern, C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> is returned.

  method mesh-pattern-get-corner-color-rgba ( Int $patch_num, Int $corner_num, Num $red, Num $green, Num $blue, Num $alpha --> cairo_status_t )

=item Int $patch_num; a B<cairo_pattern_t>
=item Int $corner_num; the patch number to return data for
=item Num $red; the corner number to return data for
=item Num $green; return value for red component of color, or C<Any>
=item Num $blue; return value for green component of color, or C<Any>
=item Num $alpha; return value for blue component of color, or C<Any>
=end pod

method mesh-pattern-get-corner-color-rgba ( Int $patch_num, Int $corner_num, Num $red, Num $green, Num $blue, Num $alpha --> cairo_status_t ) {

  cairo_mesh_pattern_get_corner_color_rgba(
    self._get-native-object-no-reffing, $patch_num, $corner_num, $red, $green, $blue, $alpha
  )
}

sub cairo_mesh_pattern_get_corner_color_rgba (
  cairo_pattern_t $pattern, guint $patch_num, guint $corner_num, gdouble $red, gdouble $green, gdouble $blue, gdouble $alpha --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-get-patch-count:
=begin pod
=head2 mesh-pattern-get-patch-count

Gets the number of patches specified in the given mesh pattern. The number only includes patches which have been finished by calling C<cairo_mesh_pattern_end_patch()>. For example it will be 0 during the definition of the first patch.

  method mesh-pattern-get-patch-count ( --> List )

Returned List holds;
=item Int; The count of patches
=item cairo_status_t; The status, C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if I<pattern> is not a mesh pattern.
=end pod

method mesh-pattern-get-patch-count ( --> List ) {
  my guint $count;
  my cairo_status_t $s = cairo_status_t(
    cairo_mesh_pattern_get_patch_count(
      self._get-native-object-no-reffing, $count
    )
  );

  ( $count, $s)
}

sub cairo_mesh_pattern_get_patch_count (
  cairo_pattern_t $pattern, guint $count is rw --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-get-path:
=begin pod
=head2 mesh-pattern-get-path

Gets path defining the patch I<patch_num> for a mesh pattern.  I<patch_num> can range from 0 to n-1 where n is the number returned by C<cairo_mesh_pattern_get_patch_count()>.  Return value: the path defining the patch, or a path with status C<CAIRO_STATUS_INVALID_INDEX> if I<patch_num> or I<point_num> is not valid for I<pattern>. If I<pattern> is not a mesh pattern, a path with status C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> is returned.

  method mesh-pattern-get-path ( Int $patch_num --> cairo_path_t )

=item Int $patch_num; a B<cairo_pattern_t>
=end pod

method mesh-pattern-get-path ( Int $patch_num --> cairo_path_t ) {

  cairo_mesh_pattern_get_path(
    self._get-native-object-no-reffing, $patch_num
  )
}

sub cairo_mesh_pattern_get_path (
  cairo_pattern_t $pattern, guint $patch_num --> cairo_path_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-line-to:
=begin pod
=head2 mesh-pattern-line-to

Adds a line to the current patch from the current point to position (I<x>, I<y>) in pattern-space coordinates.  If there is no current point before the call to C<cairo_mesh_pattern_line_to()> this function will behave as cairo_mesh_pattern_move_to(I<pattern>, I<x>, I<y>).  After this call the current point will be (I<x>, I<y>).  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<pattern> has no current patch or the current patch already has 4 sides, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method mesh-pattern-line-to ( Num $x, Num $y )

=item Num $x; a B<cairo_pattern_t>
=item Num $y; the X coordinate of the end of the new line
=end pod

method mesh-pattern-line-to ( Num $x, Num $y ) {

  cairo_mesh_pattern_line_to(
    self._get-native-object-no-reffing, $x, $y
  )
}

sub cairo_mesh_pattern_line_to (
  cairo_pattern_t $pattern, gdouble $x, gdouble $y
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-move-to:
=begin pod
=head2 mesh-pattern-move-to

Define the first point of the current patch in a mesh pattern.  After this call the current point will be (I<x>, I<y>).  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<pattern> has no current patch or the current patch already has at least one side, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method mesh-pattern-move-to ( Num $x, Num $y )

=item Num $x; a B<cairo_pattern_t>
=item Num $y; the X coordinate of the new position
=end pod

method mesh-pattern-move-to ( Num $x, Num $y ) {

  cairo_mesh_pattern_move_to(
    self._get-native-object-no-reffing, $x, $y
  )
}

sub cairo_mesh_pattern_move_to (
  cairo_pattern_t $pattern, gdouble $x, gdouble $y
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-set-control-point:
=begin pod
=head2 mesh-pattern-set-control-point

Set an internal control point of the current patch.  Valid values for I<point_num> are from 0 to 3 and identify the control points as explained in C<cairo_pattern_create_mesh()>.  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<point_num> is not valid, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_INDEX>.  If I<pattern> has no current patch, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method mesh-pattern-set-control-point ( Int $point_num, Num $x, Num $y )

=item Int $point_num; a B<cairo_pattern_t>
=item Num $x; the control point to set the position for
=item Num $y; the X coordinate of the control point
=end pod

method mesh-pattern-set-control-point ( Int $point_num, Num $x, Num $y ) {

  cairo_mesh_pattern_set_control_point(
    self._get-native-object-no-reffing, $point_num, $x, $y
  )
}

sub cairo_mesh_pattern_set_control_point (
  cairo_pattern_t $pattern, guint $point_num, gdouble $x, gdouble $y
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-set-corner-color-rgb:
=begin pod
=head2 mesh-pattern-set-corner-color-rgb

Sets the color of a corner of the current patch in a mesh pattern.  The color is specified in the same way as in C<cairo_set_source_rgb()>.  Valid values for I<corner_num> are from 0 to 3 and identify the corners as explained in C<cairo_pattern_create_mesh()>.  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<corner_num> is not valid, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_INDEX>.  If I<pattern> has no current patch, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method mesh-pattern-set-corner-color-rgb ( Int $corner_num, Num $red, Num $green, Num $blue )

=item Int $corner_num; a B<cairo_pattern_t>
=item Num $red; the corner to set the color for
=item Num $green; red component of color
=item Num $blue; green component of color
=end pod

method mesh-pattern-set-corner-color-rgb ( Int $corner_num, Num $red, Num $green, Num $blue ) {

  cairo_mesh_pattern_set_corner_color_rgb(
    self._get-native-object-no-reffing, $corner_num, $red, $green, $blue
  )
}

sub cairo_mesh_pattern_set_corner_color_rgb (
  cairo_pattern_t $pattern, guint $corner_num, gdouble $red, gdouble $green, gdouble $blue
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mesh-pattern-set-corner-color-rgba:
=begin pod
=head2 mesh-pattern-set-corner-color-rgba

Sets the color of a corner of the current patch in a mesh pattern.  The color is specified in the same way as in C<cairo_set_source_rgba()>.  Valid values for I<corner_num> are from 0 to 3 and identify the corners as explained in C<cairo_pattern_create_mesh()>.  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<corner_num> is not valid, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_INDEX>.  If I<pattern> has no current patch, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method mesh-pattern-set-corner-color-rgba ( Int $corner_num, Num $red, Num $green, Num $blue, Num $alpha )

=item Int $corner_num; a B<cairo_pattern_t>
=item Num $red; the corner to set the color for
=item Num $green; red component of color
=item Num $blue; green component of color
=item Num $alpha; blue component of color
=end pod

method mesh-pattern-set-corner-color-rgba ( Int $corner_num, Num $red, Num $green, Num $blue, Num $alpha ) {

  cairo_mesh_pattern_set_corner_color_rgba(
    self._get-native-object-no-reffing, $corner_num, $red, $green, $blue, $alpha
  )
}

sub cairo_mesh_pattern_set_corner_color_rgba (
  cairo_pattern_t $pattern, guint $corner_num, gdouble $red, gdouble $green, gdouble $blue, gdouble $alpha
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_pattern_create_for_surface:
#`{{
=begin pod
=head2 create-for-surface

Create a new B<cairo_pattern_t> for the given surface.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.  The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error.  To inspect the status of a pattern use C<cairo_pattern_status()>.

  method create-for-surface ( cairo_surface_t $surface --> cairo_pattern_t )

=item cairo_surface_t $surface;  cairo_pattern_create_for_surface:
=end pod

method create-for-surface ( cairo_surface_t $surface --> cairo_pattern_t ) {

  cairo_pattern_create_for_surface(
    self._get-native-object-no-reffing, $surface
  )
}
}}

sub _cairo_pattern_create_for_surface (
  cairo_surface_t $surface --> cairo_pattern_t
) is native(&cairo-lib)
  is symbol('cairo_pattern_create_for_surface')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_pattern_create_linear:
#`{{
=begin pod
=head2 create-linear

Create a new linear gradient B<cairo_pattern_t> along the line defined by (x0, y0) and (x1, y1).  Before using the gradient pattern, a number of color stops should be defined using C<cairo_pattern_add_color_stop_rgb()> or C<cairo_pattern_add_color_stop_rgba()>.  Note: The coordinates here are in pattern space. For a new pattern, pattern space is identical to user space, but the relationship between the spaces can be changed with C<cairo_pattern_set_matrix()>.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.  The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error.  To inspect the status of a pattern use C<cairo_pattern_status()>.

  method create-linear ( Num $x0, Num $y0, Num $x1, Num $y1 --> cairo_pattern_t )

=item Num $x0;  cairo_pattern_create_linear:
=item Num $y0; x coordinate of the start point
=item Num $x1; y coordinate of the start point
=item Num $y1; x coordinate of the end point
=end pod

method create-linear ( Num $x0, Num $y0, Num $x1, Num $y1 --> cairo_pattern_t ) {

  cairo_pattern_create_linear(
    self._get-native-object-no-reffing, $x0, $y0, $x1, $y1
  )
}
}}

sub _cairo_pattern_create_linear (
  gdouble $x0, gdouble $y0, gdouble $x1, gdouble $y1 --> cairo_pattern_t
) is native(&cairo-lib)
  is symbol('cairo_pattern_create_linear')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_pattern_create_mesh:
#`{{
=begin pod
=head2 create-mesh

Create a new mesh pattern.  Mesh patterns are tensor-product patch meshes (type 7 shadings in PDF). Mesh patterns may also be used to create other types of shadings that are special cases of tensor-product patch meshes such as Coons patch meshes (type 6 shading in PDF) and Gouraud-shaded triangle meshes (type 4 and 5 shadings in PDF).  Mesh patterns consist of one or more tensor-product patches, which should be defined before using the mesh pattern. Using a mesh pattern with a partially defined patch as source or mask will put the context in an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.  A tensor-product patch is defined by 4 Bézier curves (side 0, 1, 2, 3) and by 4 additional control points (P0, P1, P2, P3) that provide further control over the patch and complete the definition of the tensor-product patch. The corner C0 is the first point of the patch.  Degenerate sides are permitted so straight lines may be used. A zero length line on one side may be used to create 3 sided patches.

 C1     Side 1       C2 +---------------+ |               | |  P1       P2  | |               | Side 0 |               | Side 2 |               | |               | |  P0       P3  | |               | +---------------+ C0     Side 3        C3

   Each patch is constructed by first calling C<cairo_mesh_pattern_begin_patch()>, then C<cairo_mesh_pattern_move_to()> to specify the first point in the patch (C0). Then the sides are specified with calls to C<cairo_mesh_pattern_curve_to()> and C<cairo_mesh_pattern_line_to()>.  The four additional control points (P0, P1, P2, P3) in a patch can be specified with C<cairo_mesh_pattern_set_control_point()>.  At each corner of the patch (C0, C1, C2, C3) a color may be specified with C<cairo_mesh_pattern_set_corner_color_rgb()> or C<cairo_mesh_pattern_set_corner_color_rgba()>. Any corner whose color is not explicitly specified defaults to transparent black.  A Coons patch is a special case of the tensor-product patch where the control points are implicitly defined by the sides of the patch. The default value for any control point not specified is the implicit value for a Coons patch, i.e. if no control points are specified the patch is a Coons patch.  A triangle is a special case of the tensor-product patch where the control points are implicitly defined by the sides of the patch, all the sides are lines and one of them has length 0, i.e. if the patch is specified using just 3 lines, it is a triangle. If the corners connected by the 0-length side have the same color, the patch is a Gouraud-shaded triangle.  Patches may be oriented differently to the above diagram. For example the first point could be at the top left. The diagram only shows the relationship between the sides, corners and control points. Regardless of where the first point is located, when specifying colors, corner 0 will always be the first point, corner 1 the point between side 0 and side 1 etc.  Calling C<cairo_mesh_pattern_end_patch()> completes the current patch. If less than 4 sides have been defined, the first missing side is defined as a line from the current point to the first point of the patch (C0) and the other sides are degenerate lines from C0 to C0. The corners between the added sides will all be coincident with C0 of the patch and their color will be set to be the same as the color of C0.  Additional patches may be added with additional calls to C<cairo_mesh_pattern_begin_patch()>/C<cairo_mesh_pattern_end_patch()>.

 cairo_pattern_t *pattern = C<cairo_pattern_create_mesh()>;  /&ast; Add a Coons patch &ast;/ cairo_mesh_pattern_begin_patch (pattern); cairo_mesh_pattern_move_to (pattern, 0, 0); cairo_mesh_pattern_curve_to (pattern, 30, -30,  60,  30, 100, 0); cairo_mesh_pattern_curve_to (pattern, 60,  30, 130,  60, 100, 100); cairo_mesh_pattern_curve_to (pattern, 60,  70,  30, 130,   0, 100); cairo_mesh_pattern_curve_to (pattern, 30,  70, -30,  30,   0, 0); cairo_mesh_pattern_set_corner_color_rgb (pattern, 0, 1, 0, 0); cairo_mesh_pattern_set_corner_color_rgb (pattern, 1, 0, 1, 0); cairo_mesh_pattern_set_corner_color_rgb (pattern, 2, 0, 0, 1); cairo_mesh_pattern_set_corner_color_rgb (pattern, 3, 1, 1, 0); cairo_mesh_pattern_end_patch (pattern);  /&ast; Add a Gouraud-shaded triangle &ast;/ cairo_mesh_pattern_begin_patch (pattern) cairo_mesh_pattern_move_to (pattern, 100, 100); cairo_mesh_pattern_line_to (pattern, 130, 130); cairo_mesh_pattern_line_to (pattern, 130,  70); cairo_mesh_pattern_set_corner_color_rgb (pattern, 0, 1, 0, 0); cairo_mesh_pattern_set_corner_color_rgb (pattern, 1, 0, 1, 0); cairo_mesh_pattern_set_corner_color_rgb (pattern, 2, 0, 0, 1); cairo_mesh_pattern_end_patch (pattern)

   When two patches overlap, the last one that has been added is drawn over the first one.  When a patch folds over itself, points are sorted depending on their parameter coordinates inside the patch. The v coordinate ranges from 0 to 1 when moving from side 3 to side 1; the u coordinate ranges from 0 to 1 when going from side 0 to side 2. Points with higher v coordinate hide points with lower v coordinate. When two points have the same v coordinate, the one with higher u coordinate is above. This means that points nearer to side 1 are above points nearer to side 3; when this is not sufficient to decide which point is above (for example when both points belong to side 1 or side 3) points nearer to side 2 are above points nearer to side 0.  For a complete definition of tensor-product patches, see the PDF specification (ISO32000), which describes the parametrization in detail.  Note: The coordinates are always in pattern space. For a new pattern, pattern space is identical to user space, but the relationship between the spaces can be changed with C<cairo_pattern_set_matrix()>.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory. The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error. To inspect the status of a pattern use C<cairo_pattern_status()>.

  method create-mesh ( --> cairo_pattern_t )

=end pod

method create-mesh ( --> cairo_pattern_t ) {

  cairo_pattern_create_mesh(
    self._get-native-object-no-reffing,
  )
}
}}

sub _cairo_pattern_create_mesh (
   --> cairo_pattern_t
) is native(&cairo-lib)
  is symbol('cairo_pattern_create_mesh')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_pattern_create_radial:
#`{{
=begin pod
=head2 create-radial

Creates a new radial gradient B<cairo_pattern_t> between the two circles defined by (cx0, cy0, radius0) and (cx1, cy1, radius1).  Before using the gradient pattern, a number of color stops should be defined using C<cairo_pattern_add_color_stop_rgb()> or C<cairo_pattern_add_color_stop_rgba()>.  Note: The coordinates here are in pattern space. For a new pattern, pattern space is identical to user space, but the relationship between the spaces can be changed with C<cairo_pattern_set_matrix()>.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.  The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error.  To inspect the status of a pattern use C<cairo_pattern_status()>.

  method create-radial ( Num $cx0, Num $cy0, Num $radius0, Num $cx1, Num $cy1, Num $radius1 --> cairo_pattern_t )

=item Num $cx0;  cairo_pattern_create_radial:
=item Num $cy0; x coordinate for the center of the start circle
=item Num $radius0; y coordinate for the center of the start circle
=item Num $cx1; radius of the start circle
=item Num $cy1; x coordinate for the center of the end circle
=item Num $radius1; y coordinate for the center of the end circle
=end pod

method create-radial ( Num $cx0, Num $cy0, Num $radius0, Num $cx1, Num $cy1, Num $radius1 --> cairo_pattern_t ) {

  cairo_pattern_create_radial(
    self._get-native-object-no-reffing, $cx0, $cy0, $radius0, $cx1, $cy1, $radius1
  )
}
}}

sub _cairo_pattern_create_radial (
  gdouble $cx0, gdouble $cy0, gdouble $radius0, gdouble $cx1, gdouble $cy1, gdouble $radius1 --> cairo_pattern_t
) is native(&cairo-lib)
  is symbol('cairo_pattern_create_radial')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_pattern_create_rgb:
#`{{
=begin pod
=head2 create-rgb

Creates a new B<cairo_pattern_t> corresponding to an opaque color.  The color components are floating point numbers in the range 0 to 1. If the values passed in are outside that range, they will be clamped.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.  The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error.  To inspect the status of a pattern use C<cairo_pattern_status()>.

  method create-rgb ( Num $red, Num $green, Num $blue --> cairo_pattern_t )

=item Num $red;  cairo_pattern_create_rgb:
=item Num $green; red component of the color
=item Num $blue; green component of the color
=end pod

method create-rgb ( Num $red, Num $green, Num $blue --> cairo_pattern_t ) {

  cairo_pattern_create_rgb(
    self._get-native-object-no-reffing, $red, $green, $blue
  )
}
}}

sub _cairo_pattern_create_rgb (
  gdouble $red, gdouble $green, gdouble $blue --> cairo_pattern_t
) is native(&cairo-lib)
  is symbol('cairo_pattern_create_rgb')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_pattern_create_rgba:
#`{{
=begin pod
=head2 create-rgba

Creates a new B<cairo_pattern_t> corresponding to a translucent color. The color components are floating point numbers in the range 0 to 1.  If the values passed in are outside that range, they will be clamped.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.  The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error.  To inspect the status of a pattern use C<cairo_pattern_status()>.

  method create-rgba ( Num $red, Num $green, Num $blue, Num $alpha --> cairo_pattern_t )

=item Num $red;  cairo_pattern_create_rgba:
=item Num $green; red component of the color
=item Num $blue; green component of the color
=item Num $alpha; blue component of the color
=end pod

method create-rgba ( Num $red, Num $green, Num $blue, Num $alpha --> cairo_pattern_t ) {

  cairo_pattern_create_rgba(
    self._get-native-object-no-reffing, $red, $green, $blue, $alpha
  )
}
}}

sub _cairo_pattern_create_rgba (
  gdouble $red, gdouble $green, gdouble $blue, gdouble $alpha --> cairo_pattern_t
) is native(&cairo-lib)
  is symbol('cairo_pattern_create_rgba')
  { * }

#-------------------------------------------------------------------------------
#TM:0:destroy:
=begin pod
=head2 destroy

Decreases the reference count on I<pattern> by one. If the result is zero, then I<pattern> and all associated resources are freed.  See C<cairo_pattern_reference()>.

  method destroy ( )

=end pod

method destroy ( ) {

  cairo_pattern_destroy(
    self._get-native-object-no-reffing,
  )
}

sub cairo_pattern_destroy (
  cairo_pattern_t $pattern
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-color-stop-count:
=begin pod
=head2 get-color-stop-count

Gets the number of color stops specified in the given gradient pattern.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if I<pattern> is not a gradient pattern.

  method get-color-stop-count ( Int $count --> cairo_status_t )

=item Int $count; a B<cairo_pattern_t>
=end pod

method get-color-stop-count ( Int $count --> cairo_status_t ) {

  cairo_pattern_get_color_stop_count(
    self._get-native-object-no-reffing, $count
  )
}

sub cairo_pattern_get_color_stop_count (
  cairo_pattern_t $pattern, gint-ptr $count --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-color-stop-rgba:
=begin pod
=head2 get-color-stop-rgba

Gets the color and offset information at the given I<index> for a gradient pattern.  Values of I<index> range from 0 to n-1 where n is the number returned by C<cairo_pattern_get_color_stop_count()>.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_INVALID_INDEX> if I<index> is not valid for the given pattern.  If the pattern is not a gradient pattern, C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> is returned.

  method get-color-stop-rgba ( Int $index, Num $offset, Num $red, Num $green, Num $blue, Num $alpha --> cairo_status_t )

=item Int $index; a B<cairo_pattern_t>
=item Num $offset; index of the stop to return data for
=item Num $red; return value for the offset of the stop, or C<Any>
=item Num $green; return value for red component of color, or C<Any>
=item Num $blue; return value for green component of color, or C<Any>
=item Num $alpha; return value for blue component of color, or C<Any>
=end pod

method get-color-stop-rgba ( Int $index, Num $offset, Num $red, Num $green, Num $blue, Num $alpha --> cairo_status_t ) {

  cairo_pattern_get_color_stop_rgba(
    self._get-native-object-no-reffing, $index, $offset, $red, $green, $blue, $alpha
  )
}

sub cairo_pattern_get_color_stop_rgba (
  cairo_pattern_t $pattern, int32 $index, gdouble $offset, gdouble $red, gdouble $green, gdouble $blue, gdouble $alpha --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-extend:
=begin pod
=head2 get-extend

Gets the current extend mode for a pattern.  See B<cairo_extend_t> for details on the semantics of each extend strategy.  Return value: the current extend strategy used for drawing the pattern.

  method get-extend ( --> cairo_extend_t )

=end pod

method get-extend ( --> cairo_extend_t ) {

  cairo_pattern_get_extend(
    self._get-native-object-no-reffing,
  )
}

sub cairo_pattern_get_extend (
  cairo_pattern_t $pattern --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-filter:
=begin pod
=head2 get-filter

Gets the current filter for a pattern.  See B<cairo_filter_t> for details on each filter.  Return value: the current filter used for resizing the pattern.

  method get-filter ( --> cairo_filter_t )

=end pod

method get-filter ( --> cairo_filter_t ) {

  cairo_pattern_get_filter(
    self._get-native-object-no-reffing,
  )
}

sub cairo_pattern_get_filter (
  cairo_pattern_t $pattern --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-linear-points:
=begin pod
=head2 get-linear-points

Gets the gradient endpoints for a linear gradient.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if I<pattern> is not a linear gradient pattern.

  method get-linear-points ( Num $x0, Num $y0, Num $x1, Num $y1 --> cairo_status_t )

=item Num $x0; a B<cairo_pattern_t>
=item Num $y0; return value for the x coordinate of the first point, or C<Any>
=item Num $x1; return value for the y coordinate of the first point, or C<Any>
=item Num $y1; return value for the x coordinate of the second point, or C<Any>
=end pod

method get-linear-points ( Num $x0, Num $y0, Num $x1, Num $y1 --> cairo_status_t ) {

  cairo_pattern_get_linear_points(
    self._get-native-object-no-reffing, $x0, $y0, $x1, $y1
  )
}

sub cairo_pattern_get_linear_points (
  cairo_pattern_t $pattern, gdouble $x0, gdouble $y0, gdouble $x1, gdouble $y1 --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-matrix:
=begin pod
=head2 get-matrix

Stores the pattern's transformation matrix into I<matrix>.

  method get-matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a B<cairo_pattern_t>
=end pod

method get-matrix ( cairo_matrix_t $matrix ) {

  cairo_pattern_get_matrix(
    self._get-native-object-no-reffing, $matrix
  )
}

sub cairo_pattern_get_matrix (
  cairo_pattern_t $pattern, cairo_matrix_t $matrix
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-radial-circles:
=begin pod
=head2 get-radial-circles

Gets the gradient endpoint circles for a radial gradient, each specified as a center coordinate and a radius.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if I<pattern> is not a radial gradient pattern.

  method get-radial-circles ( Num $x0, Num $y0, Num $r0, Num $x1, Num $y1, Num $r1 --> cairo_status_t )

=item Num $x0; a B<cairo_pattern_t>
=item Num $y0; return value for the x coordinate of the center of the first circle, or C<Any>
=item Num $r0; return value for the y coordinate of the center of the first circle, or C<Any>
=item Num $x1; return value for the radius of the first circle, or C<Any>
=item Num $y1; return value for the x coordinate of the center of the second circle, or C<Any>
=item Num $r1; return value for the y coordinate of the center of the second circle, or C<Any>
=end pod

method get-radial-circles ( Num $x0, Num $y0, Num $r0, Num $x1, Num $y1, Num $r1 --> cairo_status_t ) {

  cairo_pattern_get_radial_circles(
    self._get-native-object-no-reffing, $x0, $y0, $r0, $x1, $y1, $r1
  )
}

sub cairo_pattern_get_radial_circles (
  cairo_pattern_t $pattern, gdouble $x0, gdouble $y0, gdouble $r0, gdouble $x1, gdouble $y1, gdouble $r1 --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-reference-count:
=begin pod
=head2 get-reference-count

Returns the current reference count of I<pattern>.  Return value: the current reference count of I<pattern>.  If the object is a nil object, 0 will be returned.

  method get-reference-count ( --> Int )

=end pod

method get-reference-count ( --> Int ) {

  cairo_pattern_get_reference_count(
    self._get-native-object-no-reffing,
  )
}

sub cairo_pattern_get_reference_count (
  cairo_pattern_t $pattern --> guint
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-rgba:
=begin pod
=head2 get-rgba

Gets the solid color for a solid color pattern.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if the pattern is not a solid color pattern.

  method get-rgba ( Num $red, Num $green, Num $blue, Num $alpha --> cairo_status_t )

=item Num $red; a B<cairo_pattern_t>
=item Num $green; return value for red component of color, or C<Any>
=item Num $blue; return value for green component of color, or C<Any>
=item Num $alpha; return value for blue component of color, or C<Any>
=end pod

method get-rgba ( Num $red, Num $green, Num $blue, Num $alpha --> cairo_status_t ) {

  cairo_pattern_get_rgba(
    self._get-native-object-no-reffing, $red, $green, $blue, $alpha
  )
}

sub cairo_pattern_get_rgba (
  cairo_pattern_t $pattern, gdouble $red, gdouble $green, gdouble $blue, gdouble $alpha --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-surface:
=begin pod
=head2 get-surface

Gets the surface of a surface pattern.  The reference returned in I<surface> is owned by the pattern; the caller should call C<cairo_surface_reference()> if the surface is to be retained.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if the pattern is not a surface pattern.

  method get-surface ( cairo_surface_t $surface --> cairo_status_t )

=item cairo_surface_t $surface; a B<cairo_pattern_t>
=end pod

method get-surface ( cairo_surface_t $surface --> cairo_status_t ) {

  cairo_pattern_get_surface(
    self._get-native-object-no-reffing, $surface
  )
}

sub cairo_pattern_get_surface (
  cairo_pattern_t $pattern, cairo_surface_t $surface --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-type:
=begin pod
=head2 get-type

Get the pattern's type.  See B<cairo_pattern_type_t> for available types.  Return value: The type of I<pattern>.

  method get-type ( --> cairo_pattern_type_t )

=end pod

method get-type ( --> cairo_pattern_type_t ) {

  cairo_pattern_get_type(
    self._get-native-object-no-reffing,
  )
}

sub cairo_pattern_get_type (
  cairo_pattern_t $pattern --> GEnum
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:get-user-data:
=begin pod
=head2 get-user-data

Return user data previously attached to I<pattern> using the specified key.  If no user data has been attached with the given key this function returns C<Any>.  Return value: the user data previously attached or C<Any>.

  method get-user-data ( cairo_user_data_key_t $key )

=item cairo_user_data_key_t $key; a B<cairo_pattern_t>
=end pod

method get-user-data ( cairo_user_data_key_t $key ) {

  cairo_pattern_get_user_data(
    self._get-native-object-no-reffing, $key
  )
}

sub cairo_pattern_get_user_data (
  cairo_pattern_t $pattern, cairo_user_data_key_t $key
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:reference:
=begin pod
=head2 reference

Increases the reference count on I<pattern> by one. This prevents I<pattern> from being destroyed until a matching call to C<cairo_pattern_destroy()> is made.  Use C<cairo_pattern_get_reference_count()> to get the number of references to a B<cairo_pattern_t>.  Return value: the referenced B<cairo_pattern_t>.

  method reference ( --> cairo_pattern_t )

=end pod

method reference ( --> cairo_pattern_t ) {

  cairo_pattern_reference(
    self._get-native-object-no-reffing,
  )
}

sub cairo_pattern_reference (
  cairo_pattern_t $pattern --> cairo_pattern_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-extend:
=begin pod
=head2 set-extend

Sets the mode to be used for drawing outside the area of a pattern. See B<cairo_extend_t> for details on the semantics of each extend strategy.  The default extend mode is C<CAIRO_EXTEND_NONE> for surface patterns and C<CAIRO_EXTEND_PAD> for gradient patterns.

  method set-extend ( cairo_extend_t $extend )

=item cairo_extend_t $extend; a B<cairo_pattern_t>
=end pod

method set-extend ( cairo_extend_t $extend ) {

  cairo_pattern_set_extend(
    self._get-native-object-no-reffing, $extend
  )
}

sub cairo_pattern_set_extend (
  cairo_pattern_t $pattern, GEnum $extend
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-filter:
=begin pod
=head2 set-filter

Sets the filter to be used for resizing when using this pattern. See B<cairo_filter_t> for details on each filter.  * Note that you might want to control filtering even when you do not have an explicit B<cairo_pattern_t> object, (for example when using C<cairo_set_source_surface()>). In these cases, it is convenient to use C<cairo_get_source()> to get access to the pattern that cairo creates implicitly. For example:

 cairo_set_source_surface (cr, image, x, y); cairo_pattern_set_filter (cairo_get_source (cr), CAIRO_FILTER_NEAREST);



  method set-filter ( cairo_filter_t $filter )

=item cairo_filter_t $filter; a B<cairo_pattern_t>
=end pod

method set-filter ( cairo_filter_t $filter ) {

  cairo_pattern_set_filter(
    self._get-native-object-no-reffing, $filter
  )
}

sub cairo_pattern_set_filter (
  cairo_pattern_t $pattern, GEnum $filter
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-matrix:
=begin pod
=head2 set-matrix

Sets the pattern's transformation matrix to I<matrix>. This matrix is a transformation from user space to pattern space.  When a pattern is first created it always has the identity matrix for its transformation matrix, which means that pattern space is initially identical to user space.  Important: Please note that the direction of this transformation matrix is from user space to pattern space. This means that if you imagine the flow from a pattern to user space (and on to device space), then coordinates in that flow will be transformed by the inverse of the pattern matrix.  For example, if you want to make a pattern appear twice as large as it does by default the correct code to use is:

 cairo_matrix_init_scale (&amp;matrix, 0.5, 0.5); cairo_pattern_set_matrix (pattern, &amp;matrix);

   Meanwhile, using values of 2.0 rather than 0.5 in the code above would cause the pattern to appear at half of its default size.  Also, please note the discussion of the user-space locking semantics of C<cairo_set_source()>.

  method set-matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a B<cairo_pattern_t>
=end pod

method set-matrix ( cairo_matrix_t $matrix ) {

  cairo_pattern_set_matrix(
    self._get-native-object-no-reffing, $matrix
  )
}

sub cairo_pattern_set_matrix (
  cairo_pattern_t $pattern, cairo_matrix_t $matrix
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:set-user-data:
=begin pod
=head2 set-user-data

Attach user data to I<pattern>.  To remove user data from a surface, call this function with the key that was used to set it and C<Any> for I<data>.  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY> if a slot could not be allocated for the user data.

  method set-user-data ( cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> cairo_status_t )

=item cairo_user_data_key_t $key; a B<cairo_pattern_t>
=item void-ptr $user_data; the address of a B<cairo_user_data_key_t> to attach the user data to
=item cairo_destroy_func_t $destroy; the user data to attach to the B<cairo_pattern_t>
=end pod

method set-user-data ( cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> cairo_status_t ) {

  cairo_pattern_set_user_data(
    self._get-native-object-no-reffing, $key, $user_data, $destroy
  )
}

sub cairo_pattern_set_user_data (
  cairo_pattern_t $pattern, cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> GEnum
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:status:
=begin pod
=head2 status

Checks whether an error has previously occurred for this pattern.

  method status ( --> cairo_status_t )

=end pod

method status ( --> cairo_status_t ) {

  cairo_pattern_status(
    self._get-native-object-no-reffing,
  )
}

sub cairo_pattern_status (
  cairo_pattern_t $pattern --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:_cairo_pattern_reference:native-object-ref
#`{{
=begin pod
=head2 cairo_pattern_reference

Increases the reference count on I<pattern> by one. This prevents I<pattern> from being destroyed until a matching call to C<cairo_pattern_destroy()> is made.  Use C<cairo_pattern_get_reference_count()> to get the number of references to a B<cairo_pattern_t>.  Return value: the referenced B<cairo_pattern_t>.

  method cairo_pattern_reference ( --> cairo_pattern_t )


=end pod
}}

sub _cairo_pattern_reference ( cairo_pattern_t $pattern --> cairo_pattern_t )
  is native(&cairo-lib)
  is symbol('cairo_pattern_reference')
  { * }

#-------------------------------------------------------------------------------
#TM:2:_cairo_pattern_destroy:native-object-unref
#`{{
=begin pod
=head2 cairo_pattern_destroy

Decreases the reference count on I<pattern> by one. If the result is zero, then I<pattern> and all associated resources are freed.  See C<cairo_pattern_reference()>.

  method cairo_pattern_destroy ( )


=end pod
}}

sub _cairo_pattern_destroy ( cairo_pattern_t $pattern )
  is native(&cairo-lib)
  is symbol('cairo_pattern_destroy')
  { * }
























=finish
#-------------------------------------------------------------------------------
#TM:2:_cairo_pattern_create_rgb:new
#`{{
=begin pod
=head2 [cairo_pattern_] create_rgb

Creates a new B<cairo_pattern_t> corresponding to an opaque color.  The color components are floating point numbers in the range 0 to 1. If the values passed in are outside that range, they will be clamped.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.  The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error.  To inspect the status of a pattern use C<cairo_pattern_status()>.

  method cairo_pattern_create_rgb ( Num $red, Num $green, Num $blue --> cairo_pattern_t )

=item $red;  cairo_pattern_create_rgb:
=item $green; red component of the color
=item $blue; green component of the color

=end pod
}}
sub _cairo_pattern_create_rgb (
  num64 $red, num64 $green, num64 $blue --> cairo_pattern_t
) is native(&cairo-lib)
  is symbol('cairo_pattern_create_rgb')
  { * }

#-------------------------------------------------------------------------------
#TM:2:_cairo_pattern_create_rgba:new
#`{{
=begin pod
=head2 [cairo_pattern_] create_rgba

Creates a new B<cairo_pattern_t> corresponding to a translucent color. The color components are floating point numbers in the range 0 to 1.  If the values passed in are outside that range, they will be clamped.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.  The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error. To inspect the status of a pattern use C<cairo_pattern_status()>.

  method cairo_pattern_create_rgba ( Num $red, Num $green, Num $blue, Num $alpha --> cairo_pattern_t )

=item $red;  cairo_pattern_create_rgba:
=item $green; red component of the color
=item $blue; green component of the color
=item $alpha; blue component of the color

=end pod
}}

sub _cairo_pattern_create_rgba (
  num64 $red, num64 $green, num64 $blue, num64 $alpha --> cairo_pattern_t
) is native(&cairo-lib)
  is symbol('cairo_pattern_create_rgba')
  { * }

#-------------------------------------------------------------------------------
#TM:2:_cairo_pattern_create_for_surface:new
#`{{
=begin pod
=head2 [cairo_pattern_] create_for_surface

Create a new B<cairo_pattern_t> for the given surface.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.  The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error.  To inspect the status of a pattern use C<cairo_pattern_status()>.

  method cairo_pattern_create_for_surface ( cairo_surface_t $surface --> cairo_pattern_t )

=item cairo_surface_t $surface;  cairo_pattern_create_for_surface:

=end pod
}}

sub _cairo_pattern_create_for_surface ( cairo_surface_t $surface --> cairo_pattern_t )
  is native(&cairo-lib)
  is symbol('cairo_pattern_create_for_surface')
  { * }

#-------------------------------------------------------------------------------
#TM:2:_cairo_pattern_create_linear:new
#`{{
=begin pod
=head2 [cairo_pattern_] create_linear

Create a new linear gradient B<cairo_pattern_t> along the line defined by (x0, y0) and (x1, y1).  Before using the gradient pattern, a number of color stops should be defined using C<cairo_pattern_add_color_stop_rgb()> or C<cairo_pattern_add_color_stop_rgba()>.  Note: The coordinates here are in pattern space. For a new pattern, pattern space is identical to user space, but the relationship between the spaces can be changed with C<cairo_pattern_set_matrix()>.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.  The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error.  To inspect the status of a pattern use C<cairo_pattern_status()>.

  method cairo_pattern_create_linear ( Num $x0, Num $y0, Num $x1, Num $y1 --> cairo_pattern_t )

=item $x0; x coordinate of the start point
=item $y0; y coordinate of the start point
=item $x1; x coordinate of the end point
=item $y1; y coordinate of the end point

=end pod
}}

sub _cairo_pattern_create_linear ( num64 $x0, num64 $y0, num64 $x1, num64 $y1 --> cairo_pattern_t )
  is native(&cairo-lib)
  is symbol('cairo_pattern_create_linear')
  { * }

#-------------------------------------------------------------------------------
#TM:2:_cairo_pattern_create_radial:new
#`{{
=begin pod
=head2 [cairo_pattern_] create_radial

Creates a new radial gradient B<cairo_pattern_t> between the two circles defined by (cx0, cy0, radius0) and (cx1, cy1, radius1).  Before using the gradient pattern, a number of color stops should be defined using C<cairo_pattern_add_color_stop_rgb()> or C<cairo_pattern_add_color_stop_rgba()>.  Note: The coordinates here are in pattern space. For a new pattern, pattern space is identical to user space, but the relationship between the spaces can be changed with C<cairo_pattern_set_matrix()>.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory.  The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error.  To inspect the status of a pattern use C<cairo_pattern_status()>.

  method cairo_pattern_create_radial ( Num $cx0, Num $cy0, Num $radius0, Num $cx1, Num $cy1, Num $radius1 --> cairo_pattern_t )

=item $cx0;  cairo_pattern_create_radial:
=item $cy0; x coordinate for the center of the start circle
=item $radius0; y coordinate for the center of the start circle
=item $cx1; radius of the start circle
=item $cy1; x coordinate for the center of the end circle
=item $radius1; y coordinate for the center of the end circle

=end pod
}}

sub _cairo_pattern_create_radial (
  num64 $cx0, num64 $cy0, num64 $radius0,
  num64 $cx1, num64 $cy1, num64 $radius1
  --> cairo_pattern_t
) is native(&cairo-lib)
  is symbol('cairo_pattern_create_radial')
  { * }

#-------------------------------------------------------------------------------
#TM:2:_cairo_pattern_create_mesh:new
#`{{
=begin pod
=head2 [cairo_pattern_] create_mesh

Create a new mesh pattern.  Mesh patterns are tensor-product patch meshes (type 7 shadings in PDF). Mesh patterns may also be used to create other types of shadings that are special cases of tensor-product patch meshes such as Coons patch meshes (type 6 shading in PDF) and Gouraud-shaded triangle meshes (type 4 and 5 shadings in PDF).  Mesh patterns consist of one or more tensor-product patches, which should be defined before using the mesh pattern. Using a mesh pattern with a partially defined patch as source or mask will put the context in an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.  A tensor-product patch is defined by 4 Bézier curves (side 0, 1, 2, 3) and by 4 additional control points (P0, P1, P2, P3) that provide further control over the patch and complete the definition of the tensor-product patch. The corner C0 is the first point of the patch.  Degenerate sides are permitted so straight lines may be used. A zero length line on one side may be used to create 3 sided patches.

        C1     Side 1      C2
          +---------------+
          |               |
          |  P1       P2  |
          |               |
  Side 0  |               | Side 2
          |               |
          |               |
          |  P0       P3  |
          |               |
          +---------------+
        C0     Side 3      C3

   Each patch is constructed by first calling C<cairo_mesh_pattern_begin_patch()>, then C<cairo_mesh_pattern_move_to()> to specify the first point in the patch (C0). Then the sides are specified with calls to C<cairo_mesh_pattern_curve_to()> and C<cairo_mesh_pattern_line_to()>.  The four additional control points (P0, P1, P2, P3) in a patch can be specified with C<cairo_mesh_pattern_set_control_point()>.  At each corner of the patch (C0, C1, C2, C3) a color may be specified with C<cairo_mesh_pattern_set_corner_color_rgb()> or C<cairo_mesh_pattern_set_corner_color_rgba()>. Any corner whose color is not explicitly specified defaults to transparent black.  A Coons patch is a special case of the tensor-product patch where the control points are implicitly defined by the sides of the patch. The default value for any control point not specified is the implicit value for a Coons patch, i.e. if no control points are specified the patch is a Coons patch.  A triangle is a special case of the tensor-product patch where the control points are implicitly defined by the sides of the patch, all the sides are lines and one of them has length 0, i.e. if the patch is specified using just 3 lines, it is a triangle. If the corners connected by the 0-length side have the same color, the patch is a Gouraud-shaded triangle.  Patches may be oriented differently to the above diagram. For example the first point could be at the top left. The diagram only shows the relationship between the sides, corners and control points. Regardless of where the first point is located, when specifying colors, corner 0 will always be the first point, corner 1 the point between side 0 and side 1 etc.  Calling C<cairo_mesh_pattern_end_patch()> completes the current patch. If less than 4 sides have been defined, the first missing side is defined as a line from the current point to the first point of the patch (C0) and the other sides are degenerate lines from C0 to C0. The corners between the added sides will all be coincident with C0 of the patch and their color will be set to be the same as the color of C0.  Additional patches may be added with additional calls to C<cairo_mesh_pattern_begin_patch()>/C<cairo_mesh_pattern_end_patch()>.

 cairo_pattern_t *pattern = C<cairo_pattern_create_mesh()>;  /&ast; Add a Coons patch &ast;/ cairo_mesh_pattern_begin_patch (pattern); cairo_mesh_pattern_move_to (pattern, 0, 0); cairo_mesh_pattern_curve_to (pattern, 30, -30,  60,  30, 100, 0); cairo_mesh_pattern_curve_to (pattern, 60,  30, 130,  60, 100, 100); cairo_mesh_pattern_curve_to (pattern, 60,  70,  30, 130,   0, 100); cairo_mesh_pattern_curve_to (pattern, 30,  70, -30,  30,   0, 0); cairo_mesh_pattern_set_corner_color_rgb (pattern, 0, 1, 0, 0); cairo_mesh_pattern_set_corner_color_rgb (pattern, 1, 0, 1, 0); cairo_mesh_pattern_set_corner_color_rgb (pattern, 2, 0, 0, 1); cairo_mesh_pattern_set_corner_color_rgb (pattern, 3, 1, 1, 0); cairo_mesh_pattern_end_patch (pattern);  /&ast; Add a Gouraud-shaded triangle &ast;/ cairo_mesh_pattern_begin_patch (pattern) cairo_mesh_pattern_move_to (pattern, 100, 100); cairo_mesh_pattern_line_to (pattern, 130, 130); cairo_mesh_pattern_line_to (pattern, 130,  70); cairo_mesh_pattern_set_corner_color_rgb (pattern, 0, 1, 0, 0); cairo_mesh_pattern_set_corner_color_rgb (pattern, 1, 0, 1, 0); cairo_mesh_pattern_set_corner_color_rgb (pattern, 2, 0, 0, 1); cairo_mesh_pattern_end_patch (pattern)

   When two patches overlap, the last one that has been added is drawn over the first one.  When a patch folds over itself, points are sorted depending on their parameter coordinates inside the patch. The v coordinate ranges from 0 to 1 when moving from side 3 to side 1; the u coordinate ranges from 0 to 1 when going from side 0 to side 2. Points with higher v coordinate hide points with lower v coordinate. When two points have the same v coordinate, the one with higher u coordinate is above. This means that points nearer to side 1 are above points nearer to side 3; when this is not sufficient to decide which point is above (for example when both points belong to side 1 or side 3) points nearer to side 2 are above points nearer to side 0.  For a complete definition of tensor-product patches, see the PDF specification (ISO32000), which describes the parametrization in detail.  Note: The coordinates are always in pattern space. For a new pattern, pattern space is identical to user space, but the relationship between the spaces can be changed with C<cairo_pattern_set_matrix()>.  Return value: the newly created B<cairo_pattern_t> if successful, or an error pattern in case of no memory. The caller owns the returned object and should call C<cairo_pattern_destroy()> when finished with it.  This function will always return a valid pointer, but if an error occurred the pattern status will be set to an error. To inspect the status of a pattern use C<cairo_pattern_status()>.

  method cairo_pattern_create_mesh ( --> cairo_pattern_t )


=end pod
}}

sub _cairo_pattern_create_mesh ( --> cairo_pattern_t )
  is native(&cairo-lib)
  is symbol('cairo_pattern_create_mesh')
  { * }

#-------------------------------------------------------------------------------
#TM:2:_cairo_pattern_reference:native-object-ref
#`{{
=begin pod
=head2 cairo_pattern_reference

Increases the reference count on I<pattern> by one. This prevents I<pattern> from being destroyed until a matching call to C<cairo_pattern_destroy()> is made.  Use C<cairo_pattern_get_reference_count()> to get the number of references to a B<cairo_pattern_t>.  Return value: the referenced B<cairo_pattern_t>.

  method cairo_pattern_reference ( --> cairo_pattern_t )


=end pod
}}

sub _cairo_pattern_reference ( cairo_pattern_t $pattern --> cairo_pattern_t )
  is native(&cairo-lib)
  is symbol('cairo_pattern_reference')
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_type:
=begin pod
=head2 [cairo_pattern_] get_type

Get the pattern's type.  See B<cairo_pattern_type_t> for available types.  Return value: The type of I<pattern>.

  method cairo_pattern_get_type ( --> Int )


=end pod

sub cairo_pattern_get_type ( cairo_pattern_t $pattern --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_status:
=begin pod
=head2 cairo_pattern_status

Checks whether an error has previously occurred for this pattern.  Return value: C<CAIRO_STATUS_SUCCESS>, C<CAIRO_STATUS_NO_MEMORY>, C<CAIRO_STATUS_INVALID_MATRIX>, C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>, or C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method cairo_pattern_status ( --> Int )

=end pod

sub cairo_pattern_status ( cairo_pattern_t $pattern --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:_cairo_pattern_destroy:native-object-unref
#`{{
=begin pod
=head2 cairo_pattern_destroy

Decreases the reference count on I<pattern> by one. If the result is zero, then I<pattern> and all associated resources are freed.  See C<cairo_pattern_reference()>.

  method cairo_pattern_destroy ( )


=end pod
}}

sub _cairo_pattern_destroy ( cairo_pattern_t $pattern )
  is native(&cairo-lib)
  is symbol('cairo_pattern_destroy')
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_reference_count:
=begin pod
=head2 [cairo_pattern_] get_reference_count

Returns the current reference count of I<pattern>.  Return value: the current reference count of I<pattern>.  If the object is a nil object, 0 will be returned.

  method cairo_pattern_get_reference_count ( --> UInt )

=end pod

sub cairo_pattern_get_reference_count ( cairo_pattern_t $pattern --> int32 )
  is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_user_data:
=begin pod
=head2 [cairo_pattern_] get_user_data

Return user data previously attached to I<pattern> using the specified key.  If no user data has been attached with the given key this function returns C<Any>.  Return value: the user data previously attached or C<Any>.

  method cairo_pattern_get_user_data ( cairo_user_data_key_t $key --> OpaquePointer )

=item cairo_user_data_key_t $key; a B<cairo_pattern_t>

=end pod

sub cairo_pattern_get_user_data ( cairo_pattern_t $pattern, cairo_user_data_key_t $key --> OpaquePointer )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_set_user_data:
=begin pod
=head2 [cairo_pattern_] set_user_data

Attach user data to I<pattern>.  To remove user data from a surface, call this function with the key that was used to set it and C<Any> for I<data>.  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY> if a slot could not be allocated for the user data.

  method cairo_pattern_set_user_data ( cairo_user_data_key_t $key, OpaquePointer $user_data, cairo_destroy_func_t $destroy --> Int )

=item cairo_user_data_key_t $key; a B<cairo_pattern_t>
=item OpaquePointer $user_data; the address of a B<cairo_user_data_key_t> to attach the user data to
=item cairo_destroy_func_t $destroy; the user data to attach to the B<cairo_pattern_t>

=end pod

sub cairo_pattern_set_user_data ( cairo_pattern_t $pattern, cairo_user_data_key_t $key, OpaquePointer $user_data, cairo_destroy_func_t $destroy --> int32 )
  is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_begin_patch:
=begin pod
=head2 cairo_mesh_pattern_begin_patch

Begin a patch in a mesh pattern.  After calling this function, the patch shape should be defined with C<cairo_mesh_pattern_move_to()>, C<cairo_mesh_pattern_line_to()> and C<cairo_mesh_pattern_curve_to()>.  After defining the patch, C<cairo_mesh_pattern_end_patch()> must be called before using I<pattern> as a source or mask.  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<pattern> already has a current patch, it will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method cairo_mesh_pattern_begin_patch ( )


=end pod

sub cairo_mesh_pattern_begin_patch ( cairo_pattern_t $pattern )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_end_patch:
=begin pod
=head2 cairo_mesh_pattern_end_patch

Indicates the end of the current patch in a mesh pattern.  If the current patch has less than 4 sides, it is closed with a straight line from the current point to the first point of the patch as if C<cairo_mesh_pattern_line_to()> was used.  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<pattern> has no current patch or the current patch has no current point, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method cairo_mesh_pattern_end_patch ( )


=end pod

sub cairo_mesh_pattern_end_patch ( cairo_pattern_t $pattern )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_curve_to:
=begin pod
=head2 cairo_mesh_pattern_curve_to

Adds a cubic Bézier spline to the current patch from the current point to position (I<x3>, I<y3>) in pattern-space coordinates, using (I<x1>, I<y1>) and (I<x2>, I<y2>) as the control points.  If the current patch has no current point before the call to C<cairo_mesh_pattern_curve_to()>, this function will behave as if preceded by a call to cairo_mesh_pattern_move_to(I<pattern>, I<x1>, I<y1>).  After this call the current point will be (I<x3>, I<y3>).  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<pattern> has no current patch or the current patch already has 4 sides, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method cairo_mesh_pattern_curve_to ( Num $x1, Num $y1, Num $x2, Num $y2, Num $x3, Num $y3 )

=item $x1; a B<cairo_pattern_t>
=item $y1; the X coordinate of the first control point
=item $x2; the Y coordinate of the first control point
=item $y2; the X coordinate of the second control point
=item $x3; the Y coordinate of the second control point
=item $y3; the X coordinate of the end of the curve

=end pod

sub cairo_mesh_pattern_curve_to ( cairo_pattern_t $pattern, num64 $x1, num64 $y1, num64 $x2, num64 $y2, num64 $x3, num64 $y3 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_line_to:
=begin pod
=head2 cairo_mesh_pattern_line_to

Adds a line to the current patch from the current point to position (I<x>, I<y>) in pattern-space coordinates.  If there is no current point before the call to C<cairo_mesh_pattern_line_to()> this function will behave as cairo_mesh_pattern_move_to(I<pattern>, I<x>, I<y>).  After this call the current point will be (I<x>, I<y>).  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<pattern> has no current patch or the current patch already has 4 sides, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method cairo_mesh_pattern_line_to ( Num $x, Num $y )

=item $x; a B<cairo_pattern_t>
=item $y; the X coordinate of the end of the new line

=end pod

sub cairo_mesh_pattern_line_to ( cairo_pattern_t $pattern, num64 $x, num64 $y )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_move_to:
=begin pod
=head2 cairo_mesh_pattern_move_to

Define the first point of the current patch in a mesh pattern.  After this call the current point will be (I<x>, I<y>).  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<pattern> has no current patch or the current patch already has at least one side, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method cairo_mesh_pattern_move_to ( Num $x, Num $y )

=item $x; a B<cairo_pattern_t>
=item $y; the X coordinate of the new position

=end pod

sub cairo_mesh_pattern_move_to ( cairo_pattern_t $pattern, num64 $x, num64 $y )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_set_control_point:
=begin pod
=head2 cairo_mesh_pattern_set_control_point

Set an internal control point of the current patch.  Valid values for I<point_num> are from 0 to 3 and identify the control points as explained in C<cairo_pattern_create_mesh()>.  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<point_num> is not valid, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_INDEX>.  If I<pattern> has no current patch, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method cairo_mesh_pattern_set_control_point ( UInt $point_num, Num $x, Num $y )

=item UInt $point_num; a B<cairo_pattern_t>
=item $x; the control point to set the position for
=item $y; the X coordinate of the control point

=end pod

sub cairo_mesh_pattern_set_control_point ( cairo_pattern_t $pattern, int32 $point_num, num64 $x, num64 $y )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_set_corner_color_rgb:
=begin pod
=head2 cairo_mesh_pattern_set_corner_color_rgb

Sets the color of a corner of the current patch in a mesh pattern.  The color is specified in the same way as in C<cairo_set_source_rgb()>.  Valid values for I<corner_num> are from 0 to 3 and identify the corners as explained in C<cairo_pattern_create_mesh()>.  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<corner_num> is not valid, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_INDEX>.  If I<pattern> has no current patch, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method cairo_mesh_pattern_set_corner_color_rgb ( UInt $corner_num, Num $red, Num $green, Num $blue )

=item UInt $corner_num; a B<cairo_pattern_t>
=item $red; the corner to set the color for
=item $green; red component of color
=item $blue; green component of color

=end pod

sub cairo_mesh_pattern_set_corner_color_rgb ( cairo_pattern_t $pattern, int32 $corner_num, num64 $red, num64 $green, num64 $blue )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_set_corner_color_rgba:
=begin pod
=head2 cairo_mesh_pattern_set_corner_color_rgba

Sets the color of a corner of the current patch in a mesh pattern.  The color is specified in the same way as in C<cairo_set_source_rgba()>.  Valid values for I<corner_num> are from 0 to 3 and identify the corners as explained in C<cairo_pattern_create_mesh()>.  Note: If I<pattern> is not a mesh pattern then I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>. If I<corner_num> is not valid, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_INDEX>.  If I<pattern> has no current patch, I<pattern> will be put into an error status with a status of C<CAIRO_STATUS_INVALID_MESH_CONSTRUCTION>.

  method cairo_mesh_pattern_set_corner_color_rgba ( UInt $corner_num, Num $red, Num $green, Num $blue, Num $alpha )

=item UInt $corner_num; a B<cairo_pattern_t>
=item $red; the corner to set the color for
=item $green; red component of color
=item $blue; green component of color
=item $alpha; blue component of color

=end pod

sub cairo_mesh_pattern_set_corner_color_rgba ( cairo_pattern_t $pattern, int32 $corner_num, num64 $red, num64 $green, num64 $blue, num64 $alpha )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:4:cairo_pattern_add_color_stop_rgb:
=begin pod
=head2 [cairo_pattern_] add_color_stop_rgb

Adds an opaque color stop to a gradient pattern. The offset specifies the location along the gradient's control vector. For example, a linear gradient's control vector is from (x0,y0) to (x1,y1) while a radial gradient's control vector is from any point on the start circle to the corresponding point on the end circle.  The color is specified in the same way as in C<cairo_set_source_rgb()>.  If two (or more) stops are specified with identical offset values, they will be sorted according to the order in which the stops are added, (stops added earlier will compare less than stops added later). This can be useful for reliably making sharp color transitions instead of the typical blend.

Note: If the pattern is not a gradient pattern, (eg. a linear or radial pattern), then the pattern will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>.

  method cairo_pattern_add_color_stop_rgb (
    Num $offset, Num $red, Num $green, Num $blue
  )

=item $offset; a B<cairo_pattern_t>
=item $red; an offset in the range [0.0 .. 1.0]
=item $green; red component of color
=item $blue; green component of color

=end pod

method add-color-stop-rgb(
  Num() $offset, Num() $red, Num() $green, Num() $blue
) {
  cairo_pattern_add_color_stop_rgb(
    self._get-native-object-no-reffing, $offset, $red, $green, $blue
  )
}

sub cairo_pattern_add_color_stop_rgb ( cairo_pattern_t $pattern, num64 $offset, num64 $red, num64 $green, num64 $blue )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_add_color_stop_rgba:
=begin pod
=head2 [cairo_pattern_] add_color_stop_rgba

Adds a translucent color stop to a gradient pattern. The offset specifies the location along the gradient's control vector. For example, a linear gradient's control vector is from (x0,y0) to (x1,y1) while a radial gradient's control vector is from any point on the start circle to the corresponding point on the end circle.  The color is specified in the same way as in C<cairo_set_source_rgba()>.  If two (or more) stops are specified with identical offset values, they will be sorted according to the order in which the stops are added, (stops added earlier will compare less than stops added later). This can be useful for reliably making sharp color transitions instead of the typical blend.  Note: If the pattern is not a gradient pattern, (eg. a linear or radial pattern), then the pattern will be put into an error status with a status of C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH>.

  method cairo_pattern_add_color_stop_rgba ( Num $offset, Num $red, Num $green, Num $blue, Num $alpha )

=item $offset; a B<cairo_pattern_t>
=item $red; an offset in the range [0.0 .. 1.0]
=item $green; red component of color
=item $blue; green component of color
=item $alpha; blue component of color

=end pod

method add-color-stop-rgba(
  Num() $offset, Num() $red, Num() $green, Num() $blue, Num() $alpha
) {
  cairo_pattern_add_color_stop_rgb(
    self._get-native-object-no-reffing, $offset, $red, $green, $blue, $alpha
  )
}

sub cairo_pattern_add_color_stop_rgba ( cairo_pattern_t $pattern, num64 $offset, num64 $red, num64 $green, num64 $blue, num64 $alpha )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_set_matrix:
=begin pod
=head2 [cairo_pattern_] set_matrix

Sets the pattern's transformation matrix to I<matrix>. This matrix is a transformation from user space to pattern space.  When a pattern is first created it always has the identity matrix for its transformation matrix, which means that pattern space is initially identical to user space.  Important: Please note that the direction of this transformation matrix is from user space to pattern space. This means that if you imagine the flow from a pattern to user space (and on to device space), then coordinates in that flow will be transformed by the inverse of the pattern matrix.  For example, if you want to make a pattern appear twice as large as it does by default the correct code to use is:

 cairo_matrix_init_scale (&amp;matrix, 0.5, 0.5); cairo_pattern_set_matrix (pattern, &amp;matrix);

   Meanwhile, using values of 2.0 rather than 0.5 in the code above would cause the pattern to appear at half of its default size.  Also, please note the discussion of the user-space locking semantics of C<cairo_set_source()>.

  method cairo_pattern_set_matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a B<cairo_pattern_t>

=end pod

sub cairo_pattern_set_matrix ( cairo_pattern_t $pattern, cairo_matrix_t $matrix )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_matrix:
=begin pod
=head2 [cairo_pattern_] get_matrix

Stores the pattern's transformation matrix into I<matrix>.

  method cairo_pattern_get_matrix ( cairo_matrix_t $matrix )

=item cairo_matrix_t $matrix; a B<cairo_pattern_t>

=end pod

sub cairo_pattern_get_matrix ( cairo_pattern_t $pattern, cairo_matrix_t $matrix )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_set_filter:
=begin pod
=head2 [cairo_pattern_] set_filter

Sets the filter to be used for resizing when using this pattern. See B<cairo_filter_t> for details on each filter.  * Note that you might want to control filtering even when you do not have an explicit B<cairo_pattern_t> object, (for example when using C<cairo_set_source_surface()>). In these cases, it is convenient to use C<cairo_get_source()> to get access to the pattern that cairo creates implicitly. For example:

 cairo_set_source_surface (cr, image, x, y); cairo_pattern_set_filter (cairo_get_source (cr), CAIRO_FILTER_NEAREST);



  method cairo_pattern_set_filter ( Int $filter )

=item Int $filter; a B<cairo_pattern_t>

=end pod

sub cairo_pattern_set_filter ( cairo_pattern_t $pattern, int32 $filter )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_filter:
=begin pod
=head2 [cairo_pattern_] get_filter

Gets the current filter for a pattern.  See B<cairo_filter_t> for details on each filter.  Return value: the current filter used for resizing the pattern.

  method cairo_pattern_get_filter ( --> Int )


=end pod

sub cairo_pattern_get_filter ( cairo_pattern_t $pattern --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_set_extend:
=begin pod
=head2 [cairo_pattern_] set_extend

Sets the mode to be used for drawing outside the area of a pattern. See B<cairo_extend_t> for details on the semantics of each extend strategy.  The default extend mode is C<CAIRO_EXTEND_NONE> for surface patterns and C<CAIRO_EXTEND_PAD> for gradient patterns.

  method cairo_pattern_set_extend ( Int $extend )

=item Int $extend; a B<cairo_pattern_t>

=end pod

sub cairo_pattern_set_extend ( cairo_pattern_t $pattern, int32 $extend )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_extend:
=begin pod
=head2 [cairo_pattern_] get_extend

Gets the current extend mode for a pattern.  See B<cairo_extend_t> for details on the semantics of each extend strategy.  Return value: the current extend strategy used for drawing the pattern.

  method cairo_pattern_get_extend ( --> Int )


=end pod

sub cairo_pattern_get_extend ( cairo_pattern_t $pattern --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_rgba:
=begin pod
=head2 [cairo_pattern_] get_rgba

Gets the solid color for a solid color pattern.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if the pattern is not a solid color pattern.

  method cairo_pattern_get_rgba ( Num $red, Num $green, Num $blue, Num $alpha --> Int )

=item $red; a B<cairo_pattern_t>
=item $green; return value for red component of color, or C<Any>
=item $blue; return value for green component of color, or C<Any>
=item $alpha; return value for blue component of color, or C<Any>

=end pod

sub cairo_pattern_get_rgba ( cairo_pattern_t $pattern, num64 $red, num64 $green, num64 $blue, num64 $alpha --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_surface:
=begin pod
=head2 [cairo_pattern_] get_surface

Gets the surface of a surface pattern.  The reference returned in I<surface> is owned by the pattern; the caller should call C<cairo_surface_reference()> if the surface is to be retained.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if the pattern is not a surface pattern.

  method cairo_pattern_get_surface ( cairo_surface_t $surface --> Int )

=item cairo_surface_t $surface; a B<cairo_pattern_t>

=end pod

sub cairo_pattern_get_surface ( cairo_pattern_t $pattern, cairo_surface_t $surface --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_color_stop_rgba:
=begin pod
=head2 [cairo_pattern_] get_color_stop_rgba

Gets the color and offset information at the given I<index> for a gradient pattern.  Values of I<index> range from 0 to n-1 where n is the number returned by C<cairo_pattern_get_color_stop_count()>.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_INVALID_INDEX> if I<index> is not valid for the given pattern.  If the pattern is not a gradient pattern, C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> is returned.

  method cairo_pattern_get_color_stop_rgba ( Int $index, Num $offset, Num $red, Num $green, Num $blue, Num $alpha --> Int )

=item Int $index; a B<cairo_pattern_t>
=item $offset; index of the stop to return data for
=item $red; return value for the offset of the stop, or C<Any>
=item $green; return value for red component of color, or C<Any>
=item $blue; return value for green component of color, or C<Any>
=item $alpha; return value for blue component of color, or C<Any>

=end pod

sub cairo_pattern_get_color_stop_rgba ( cairo_pattern_t $pattern, int32 $index, num64 $offset, num64 $red, num64 $green, num64 $blue, num64 $alpha --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_color_stop_count:
=begin pod
=head2 [cairo_pattern_] get_color_stop_count

Gets the number of color stops specified in the given gradient pattern.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if I<pattern> is not a gradient pattern.

  method cairo_pattern_get_color_stop_count ( Int $count --> Int )

=item Int $count; a B<cairo_pattern_t>

=end pod

sub cairo_pattern_get_color_stop_count ( cairo_pattern_t $pattern, int32 $count --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_linear_points:
=begin pod
=head2 [cairo_pattern_] get_linear_points

Gets the gradient endpoints for a linear gradient.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if I<pattern> is not a linear gradient pattern.

  method cairo_pattern_get_linear_points ( Num $x0, Num $y0, Num $x1, Num $y1 --> Int )

=item $x0; a B<cairo_pattern_t>
=item $y0; return value for the x coordinate of the first point, or C<Any>
=item $x1; return value for the y coordinate of the first point, or C<Any>
=item $y1; return value for the x coordinate of the second point, or C<Any>

=end pod

sub cairo_pattern_get_linear_points ( cairo_pattern_t $pattern, num64 $x0, num64 $y0, num64 $x1, num64 $y1 --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_pattern_get_radial_circles:
=begin pod
=head2 [cairo_pattern_] get_radial_circles

Gets the gradient endpoint circles for a radial gradient, each specified as a center coordinate and a radius.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if I<pattern> is not a radial gradient pattern.

  method cairo_pattern_get_radial_circles ( Num $x0, Num $y0, Num $r0, Num $x1, Num $y1, Num $r1 --> Int )

=item $x0; a B<cairo_pattern_t>
=item $y0; return value for the x coordinate of the center of the first circle, or C<Any>
=item $r0; return value for the y coordinate of the center of the first circle, or C<Any>
=item $x1; return value for the radius of the first circle, or C<Any>
=item $y1; return value for the x coordinate of the center of the second circle, or C<Any>
=item $r1; return value for the y coordinate of the center of the second circle, or C<Any>

=end pod

sub cairo_pattern_get_radial_circles ( cairo_pattern_t $pattern, num64 $x0, num64 $y0, num64 $r0, num64 $x1, num64 $y1, num64 $r1 --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_get_patch_count:
=begin pod
=head2 cairo_mesh_pattern_get_patch_count

Gets the number of patches specified in the given mesh pattern.  The number only includes patches which have been finished by calling C<cairo_mesh_pattern_end_patch()>. For example it will be 0 during the definition of the first patch.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> if I<pattern> is not a mesh pattern.

  method cairo_mesh_pattern_get_patch_count ( UInt $*count --> Int )

=item UInt $*count; a B<cairo_pattern_t>

=end pod

sub cairo_mesh_pattern_get_patch_count ( cairo_pattern_t $pattern, int32 $*count --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_get_path:
=begin pod
=head2 cairo_mesh_pattern_get_path

Gets path defining the patch I<patch_num> for a mesh pattern.  I<patch_num> can range from 0 to n-1 where n is the number returned by C<cairo_mesh_pattern_get_patch_count()>.  Return value: the path defining the patch, or a path with status C<CAIRO_STATUS_INVALID_INDEX> if I<patch_num> or I<point_num> is not valid for I<pattern>. If I<pattern> is not a mesh pattern, a path with status C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> is returned.

  method cairo_mesh_pattern_get_path ( UInt $patch_num --> cairo_path_t )

=item UInt $patch_num; a B<cairo_pattern_t>

=end pod

sub cairo_mesh_pattern_get_path ( cairo_pattern_t $pattern, int32 $patch_num --> cairo_path_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_get_corner_color_rgba:
=begin pod
=head2 cairo_mesh_pattern_get_corner_color_rgba

Gets the color information in corner I<corner_num> of patch I<patch_num> for a mesh pattern.  I<patch_num> can range from 0 to n-1 where n is the number returned by C<cairo_mesh_pattern_get_patch_count()>.  Valid values for I<corner_num> are from 0 to 3 and identify the corners as explained in C<cairo_pattern_create_mesh()>.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_INVALID_INDEX> if I<patch_num> or I<corner_num> is not valid for I<pattern>. If I<pattern> is not a mesh pattern, C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> is returned.

  method cairo_mesh_pattern_get_corner_color_rgba ( UInt $patch_num, UInt $corner_num, Num $red, Num $green, Num $blue, Num $alpha --> Int )

=item UInt $patch_num; a B<cairo_pattern_t>
=item UInt $corner_num; the patch number to return data for
=item $red; the corner number to return data for
=item $green; return value for red component of color, or C<Any>
=item $blue; return value for green component of color, or C<Any>
=item $alpha; return value for blue component of color, or C<Any>

=end pod

sub cairo_mesh_pattern_get_corner_color_rgba ( cairo_pattern_t $pattern, int32 $patch_num, int32 $corner_num, num64 $red, num64 $green, num64 $blue, num64 $alpha --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_mesh_pattern_get_control_point:
=begin pod
=head2 cairo_mesh_pattern_get_control_point

Gets the control point I<point_num> of patch I<patch_num> for a mesh pattern.  I<patch_num> can range from 0 to n-1 where n is the number returned by C<cairo_mesh_pattern_get_patch_count()>.  Valid values for I<point_num> are from 0 to 3 and identify the control points as explained in C<cairo_pattern_create_mesh()>.  Return value: C<CAIRO_STATUS_SUCCESS>, or C<CAIRO_STATUS_INVALID_INDEX> if I<patch_num> or I<point_num> is not valid for I<pattern>. If I<pattern> is not a mesh pattern, C<CAIRO_STATUS_PATTERN_TYPE_MISMATCH> is returned.

  method cairo_mesh_pattern_get_control_point ( UInt $patch_num, UInt $point_num, Num $x, Num $y --> Int )

=item UInt $patch_num; a B<cairo_pattern_t>
=item UInt $point_num; the patch number to return data for
=item $x; the control point number to return data for
=item $y; return value for the x coordinate of the control point, or C<Any>

=end pod

sub cairo_mesh_pattern_get_control_point ( cairo_pattern_t $pattern, int32 $patch_num, int32 $point_num, num64 $x, num64 $y --> int32 )
  is native(&cairo-lib)
  { * }
