#TL:1:Gnome::Cairo::Matrix:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Matrix

Generic matrix operations

=comment ![](images/X.png)

=head1 Description


B<Gnome::Cairo::Matrix> is used throughout cairo to convert between different coordinate spaces.

The native type C<cairo_matrix_t>, defined in B<Gnome::Cairo::Types> has the following members;
=item Num $.xx; xx component of the affine transformation
=item Num $.yx; yx component of the affine transformation
=item Num $.xy; xy component of the affine transformation
=item Num $.yy; yy component of the affine transformation
=item Num $.x0; X translation component of the affine transformation
=item Num $.y0; Y translation component of the affine transformation



A B<Gnome::Cairo::Matrix> holds an affine transformation, such as a scale, rotation, shear, or a combination of these. The transformation of a point C<( $x, $y)> is given by:

  $x-new = $xx * $x + $xy * $y + $x0;
  $y-new = $yx * $x + $yy * $y + $y0;

The current transformation matrix of a cairo context, defines the transformation from user-space coordinates to device-space coordinates. See C<cairo-get-matrix()> and C<cairo-set-matrix()>.


=head2 See Also

B<Gnome::Cairo>


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo::Matrix;
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
unit class Gnome::Cairo::Matrix:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 default, no options

Create a new Matrix object. All values are set to 0e0.

  multi method new ( )


=head3 :init

Sets I<matrix> to be the affine transformation given by I<$xx>, I<$yx>, I<$xy>, I<$yy>, I<$x0>, I<$y0>.

  multi method new (
    :init( Num() $xx, Num() $yx,
           Num() $xy, Num() $yy,
           Num() $x0, Num() $y0
         )!
  )

=item $xx; xx component of the affine transformation
=item $yx; yx component of the affine transformation
=item $xy; xy component of the affine transformation
=item $yy; yy component of the affine transformation
=item $x0; X translation component of the affine transformation
=item $y0; Y translation component of the affine transformation


=head3 :init-identity

Modifies I<matrix> to be an identity transformation.

  multi method new ( :init-identity! )


=head3 :init-rotate

Initialized I<matrix> to a transformation that rotates by I<radians>.

  multi method new ( :init-rotate($radians)! )

=item $radians; angle of rotation, in radians.


=head3 :init-scale

Initializes I<matrix> to a transformation that scales by I<sx> and I<sy> in the X and Y dimensions, respectively.

  multi method new ( :init-scale( Num() $sx, Num() $sy)! )

=item $sx; scale factor in the X direction
=item $sy; scale factor in the Y direction


=head3 :init-translate

Initializes I<matrix> to a transformation that translates by I<tx> and I<ty> in the X and Y dimensions, respectively.

  multi method new ( :init-translate( Num() $tx, Num() $ty )! )

=item $tx; amount to translate in the X direction
=item $ty; amount to translate in the Y direction


=head3 :$native-object

Create a Matrix object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( cairo_matrix_t :$native-object! )

=end pod

#TM:1:new(:init):
#TM:1:new(:init-identity):
#TM:1:new(:init-rotate):
#TM:1:new(:init-scale):
#TM:1:new(:init-translate):
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Matrix' #`{{ or %options<CairoMatrix> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    else {
      my cairo_matrix_t $no;

      if ? %options<init> {
        my @nums = |%options<init>;
        die X::Gnome.new(
          :message(':init needs 6 values')
        ) unless @nums.elems == 6;

        $no .= new;

        cairo_matrix_init(
          $no, @nums[0].Num, @nums[1].Num, @nums[2].Num,
               @nums[3].Num, @nums[4].Num, @nums[5].Num
        );
      }

      elsif ? %options<init-identity> {
        $no .= new;
        cairo_matrix_init_identity($no);
      }

      elsif ? %options<init-rotate> {
        my @nums = |%options<init-rotate>;
        die X::Gnome.new(
          :message(':init-rotate needs 1 value')
        ) unless @nums.elems == 1;

        $no .= new;

        cairo_matrix_init_rotate( $no, @nums[0].Num);
      }

      elsif ? %options<init-scale> {
        my @nums = |%options<init-scale>;
        die X::Gnome.new(
          :message(':init-scale needs 2 values')
        ) unless @nums.elems == 2;

        $no .= new;

        cairo_matrix_init_scale( $no, @nums[0].Num, @nums[1].Num);
      }

      elsif ? %options<init-translate> {
        my @nums = |%options<init-translate>;
        die X::Gnome.new(
          :message(':init-translate needs 2 values')
        ) unless @nums.elems == 2;

        $no .= new;

        cairo_matrix_init_translate( $no, @nums[0].Num, @nums[1].Num)
      }

      ##`{{ use this when the module is not made inheritable
      # check if there are unknown options
      elsif %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }
      #}}

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      ##`{{ when there are defaults use this instead
      # create default object
      else {
        $no .= new;
      }
      #}}

      self._set-native-object($no);
    }
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Str $new-patt = $native-sub.subst( '_', '-', :g);

  my Callable $s;
  try { $s = &::("cairo_matrix_$native-sub"); };
  if ?$s {
    Gnome::N::deprecate(
      "cairo_matrix_$native-sub", $new-patt, '0.2.8', '0.3.0'
    );
  }

  else {
    try { $s = &::("cairo_$native-sub"); } unless ?$s;
    if ?$s {
      Gnome::N::deprecate(
        "cairo_$native-sub", $new-patt.subst('matrix-'),
        '0.2.8', '0.3.0'
      );
    }

    else {
      try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;
      if ?$s {
        Gnome::N::deprecate(
          "$native-sub", $new-patt.subst('cairo-matrix-'),
          '0.2.8', '0.3.0'
        );
      }
    }
  }

  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
method native-object-ref ( $no ) {
  $no
}

#-------------------------------------------------------------------------------
method native-object-unref ( $no ) {
  $no
}



#-------------------------------------------------------------------------------
#TM:1:init:
#`{{
=begin pod
=head2 init

Sets I<matrix> to be the affine transformation given by I<$xx>, I<$yx>, I<$xy>, I<$yy>, I<$x0>, I<$y0>. The transformation is given by:

=begin code
  $x-new = $xx * $x + $xy * $y + $x0;
  $y-new = $yx * $x + $yy * $y + $y0;
=end code


=begin code
  method init (
    Num() $xx, Num() $yx,
    Num() $xy, Num() $yy,
    Num() $x0, Num() $y0
  )
=end code

=item $xx; xx component of the affine transformation
=item $yx; yx component of the affine transformation
=item $xy; xy component of the affine transformation
=item $yy; yy component of the affine transformation
=item $x0; X translation component of the affine transformation
=item $y0; Y translation component of the affine transformation
=end pod

method init (
  Num() $xx, Num() $yx, Num() $xy, Num() $yy, Num() $x0, Num() $y0
) {
  cairo_matrix_init(
    self._get-native-object-no-reffing, $xx, $yx, $xy, $yy, $x0, $y0
  )
}
}}

sub _cairo_matrix_init (
  cairo_matrix_t $matrix, gdouble $xx, gdouble $yx, gdouble $xy, gdouble $yy, gdouble $x0, gdouble $y0
) is native(&cairo-lib)
  is symbol('cairo_matrix_init')
  { * }

#-------------------------------------------------------------------------------
#TM:1:init-identity:
#`{{
=begin pod
=head2 init-identity

Modifies I<matrix> to be an identity transformation.

  method init-identity ( )

=end pod

method init-identity ( ) {
  cairo_matrix_init_identity(self._get-native-object-no-reffing)
}
}}

sub _cairo_matrix_init_identity (
  cairo_matrix_t $matrix
) is native(&cairo-lib)
  is symbol('cairo_matrix_init_identity')

  { * }

#-------------------------------------------------------------------------------
#TM:1:init-rotate:
#`{{
=begin pod
=head2 init-rotate

Initialized I<matrix> to a transformation that rotates by I<radians>.

The direction of rotation is defined such that positive angles rotate in the direction from the positive X axis toward the positive Y axis. With the default axis orientation of cairo, positive angles rotate in a clockwise direction.

  method init-rotate ( Num() $radians )

=item $radians; angle of rotation, in radians.

=end pod

method init-rotate ( Num() $radians ) {
  cairo_matrix_init_rotate( self._get-native-object-no-reffing, $radians)
}
}}

sub _cairo_matrix_init_rotate (
  cairo_matrix_t $matrix, gdouble $radians
) is native(&cairo-lib)
  is symbol('cairo_matrix_init_rotate')
  { * }

#-------------------------------------------------------------------------------
#TM:1:init-scale:
#`{{
=begin pod
=head2 init-scale

Initializes I<matrix> to a transformation that scales by I<sx> and I<sy> in the X and Y dimensions, respectively.

  method init-scale ( Num() $sx, Num() $sy )

=item $sx; scale factor in the X direction
=item $sy; scale factor in the Y direction
=end pod

method init-scale ( Num() $sx, Num() $sy ) {
  cairo_matrix_init_scale( self._get-native-object-no-reffing, $sx, $sy)
}
}}

sub cairo_matrix_init_scale (
  cairo_matrix_t $matrix, gdouble $sx, gdouble $sy
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:init-translate:
#`{{
=begin pod
=head2 init-translate

Initializes I<matrix> to a transformation that translates by I<tx> and I<ty> in the X and Y dimensions, respectively.

  method init-translate ( Num() $tx, Num() $ty )

=item $tx; amount to translate in the X direction
=item $ty; amount to translate in the Y direction
=end pod

method init-translate ( Num() $tx, Num() $ty ) {
  cairo_matrix_init_translate( self._get-native-object-no-reffing, $tx, $ty)
}
}}

sub cairo_matrix_init_translate (
  cairo_matrix_t $matrix, gdouble $tx, gdouble $ty
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:invert:
=begin pod
=head2 invert

Changes I<matrix> to be the inverse of its original value. Not all transformation matrices have inverses; if the matrix collapses points together (it is I<degenerate>), then it has no inverse and this function will fail.

 Returns: If I<matrix> has an inverse, modifies I<matrix> to be the inverse matrix and returns C<CAIRO_STATUS_SUCCESS>. Otherwise, returns C<CAIRO_STATUS_INVALID-MATRIX>.

  method invert ( --> cairo_status_t )

=end pod

method invert ( --> cairo_status_t ) {
  cairo_status_t(cairo_matrix_invert(self._get-native-object-no-reffing))
}

sub cairo_matrix_invert (
  cairo_matrix_t $matrix --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:multiply:
=begin pod
=head2 multiply

Multiplies the affine transformations in I<$a> and I<$b> together and stores the result in the current matrix. The effect of the resulting transformation is to first apply the transformation in I<$a> to the coordinates and then apply the transformation in I<$b> to the coordinates. It is allowable for the current matrix to be identical to either I<$a> or I<$b>.

  method multiply ( cairo_matrix_t $a, cairo_matrix_t $b )

=item $a; a matrix
=item $b; a matrix
=end pod

method multiply ( $a is copy, $b is copy ) {
  $a .= _get-native-object-no-reffing unless $a ~~ cairo_matrix_t;
  $b .= _get-native-object-no-reffing unless $b ~~ cairo_matrix_t;

  cairo_matrix_multiply( self._get-native-object-no-reffing, $a, $b);
}

sub cairo_matrix_multiply (
  cairo_matrix_t $result, cairo_matrix_t $a, cairo_matrix_t $b
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:rotate:
=begin pod
=head2 rotate

Applies rotation by I<$radians> to the transformation in I<matrix>. The effect of the new transformation is to first rotate the coordinates by I<$radians>, then apply the original transformation to the coordinates.

The direction of rotation is defined such that positive angles rotate in the direction from the positive X axis toward the positive Y axis. With the default axis orientation of cairo, positive angles rotate in a clockwise direction.

  method rotate ( Num() $radians )

=item $radians; angle of rotation, in radians.
=end pod

method rotate ( Num() $radians ) {
  cairo_matrix_rotate( self._get-native-object-no-reffing, $radians)
}

sub cairo_matrix_rotate (
  cairo_matrix_t $matrix, gdouble $radians
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:scale:
=begin pod
=head2 scale

Applies scaling by I<$sx>, I<$sy> to the transformation in I<matrix>. The effect of the new transformation is to first scale the coordinates by I<$sx> and I<$sy>, then apply the original transformation to the coordinates.

  method scale ( Num() $sx, Num() $sy )

=item $sx; scale factor in the X direction
=item $sy; scale factor in the Y direction
=end pod

method scale ( Num() $sx, Num() $sy ) {
  cairo_matrix_scale( self._get-native-object-no-reffing, $sx, $sy)
}

sub cairo_matrix_scale (
  cairo_matrix_t $matrix, gdouble $sx, gdouble $sy
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:transform-distance:
=begin pod
=head2 transform-distance

Transforms the distance vector (I<$dx>, I<$dy>) by I<matrix>. This is similar to C<transform-point()> except that the translation components of the transformation are ignored. The calculation of the returned vector is as follows:

  dx2 = dx1 * a + dy1 * c;
  dy2 = dx1 * b + dy1 * d;

 Affine transformations are position invariant, so the same vector always transforms to the same vector. If C<( x1, y1)> transforms to C<( x2, y2)> then C<( x1 + dx1, y1 + dy1)> will transform to C<( x1 + dx2, y1 + dy2)> for all values of C<x1> and C<x2>.

  method transform-distance ( Num() $dx is rw, Num() $dy is rw )

=item $dx; X component of a distance vector. An in/out parameter
=item $dy; Y component of a distance vector. An in/out parameter
=end pod

method transform-distance ( Num() $dx is rw, Num() $dy is rw ) {
  my gdouble $gdx = $dx;
  my gdouble $gdy = $dy;
  cairo_matrix_transform_distance(
    self._get-native-object-no-reffing, $gdx, $gdy
  );
  $dx = $gdx;
  $dy = $gdy;
}

sub cairo_matrix_transform_distance (
  cairo_matrix_t $matrix, gdouble $dx is rw, gdouble $dy is rw
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:transform-point:
=begin pod
=head2 transform-point

Transforms the point (I<x>, I<y>) by I<matrix>.

  method transform-point ( Num() $x is rw, Num() $y is rw )

=item $x; X position. An in/out parameter
=item $y; Y position. An in/out parameter
=end pod

method transform-point ( Num() $x is rw, Num() $y is rw ) {
  my gdouble $gx = $x;
  my gdouble $gy = $y;
  cairo_matrix_transform_point( self._get-native-object-no-reffing, $gx, $gy);
  $x = $gx;
  $y = $gy;
}

sub cairo_matrix_transform_point (
  cairo_matrix_t $matrix, gdouble $x is rw, gdouble $y is rw
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:translate:
=begin pod
=head2 translate

Applies a translation by I<tx>, I<ty> to the transformation in I<matrix>. The effect of the new transformation is to first translate the coordinates by I<tx> and I<ty>, then apply the original transformation to the coordinates.

  method translate ( Num() $tx, Num() $ty )

=item $tx; amount to translate in the X direction
=item $ty; amount to translate in the Y direction
=end pod

method translate ( Num() $tx, Num() $ty ) {

  cairo_matrix_translate(
    self._get-native-object-no-reffing, $tx, $ty
  )
}

sub cairo_matrix_translate (
  cairo_matrix_t $matrix, gdouble $tx, gdouble $ty
) is native(&cairo-lib)
  { * }
