#TL:0:Gnome::Cairo::Matrix:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Matrix

Generic matrix operations

=comment ![](images/X.png)

=head1 Description

 B<cairo_matrix_t> is used throughout cairo to convert between different coordinate spaces. A B<cairo_matrix_t> holds an affine transformation, such as a scale, rotation, shear, or a combination of these. The transformation of a point (<literal>x</literal>,<literal>y</literal>) is given by: <programlisting> x_new = xx * x + xy * y + x0; y_new = yx * x + yy * y + y0; </programlisting> The current transformation matrix of a B<cairo_t>, represented as a B<cairo_matrix_t>, defines the transformation from user-space coordinates to device-space coordinates. See C<cairo_get_matrix()> and C<cairo_set_matrix()>.

=head2 See Also

B<cairo_t>

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

use Gnome::Cairo::Types;
use Gnome::Cairo::Enums;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo::Matrix:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 new()

Create a new Matrix object.

  multi method new ( )

=begin comment
Create a Matrix object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

Create a Matrix object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )
=end comment

=end pod

#TM:0:new():
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
      my $no;
      # if ? %options<> {
      #   $no = %options<>;
      #   $no .= get-native-object-no-reffing
      #     if $no.^can('get-native-object-no-reffing');
      #   $no = ...($no);
      # }

      #`{{ use this when the module is not made inheritable
      # check if there are unknown options
      elsif %options.elems {
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

      #`{{ when there are defaults use this instead
      # create default object
      else {
        $no = cairo_matrix_new();
      }
      }}

      self.set-native-object($no);
    }
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_matrix_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

  $s = callsame unless ?$s;

  $s;
}


#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_init_identity:
=begin pod
=head2 [cairo_matrix_] init_identity

Modifies I<matrix> to be an identity transformation.

  method cairo_matrix_init_identity ( )


=end pod

sub cairo_matrix_init_identity ( cairo_matrix_t $matrix  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_init:
=begin pod
=head2 cairo_matrix_init

Sets I<matrix> to be the affine transformation given by I<xx>, I<yx>, I<xy>, I<yy>, I<x0>, I<y0>. The transformation is given by: <programlisting> x_new = xx * x + xy * y + x0; y_new = yx * x + yy * y + y0; </programlisting>

  method cairo_matrix_init ( Num $xx, Num $yx, Num $xy, Num $yy, Num $x0, Num $y0 )

=item Num $xx; a B<cairo_matrix_t>
=item Num $yx; xx component of the affine transformation
=item Num $xy; yx component of the affine transformation
=item Num $yy; xy component of the affine transformation
=item Num $x0; yy component of the affine transformation
=item Num $y0; X translation component of the affine transformation

=end pod

sub cairo_matrix_init ( cairo_matrix_t $matrix, num64 $xx, num64 $yx, num64 $xy, num64 $yy, num64 $x0, num64 $y0  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_init_translate:
=begin pod
=head2 [cairo_matrix_] init_translate

Initializes I<matrix> to a transformation that translates by I<tx> and I<ty> in the X and Y dimensions, respectively.

  method cairo_matrix_init_translate ( Num $tx, Num $ty )

=item Num $tx; a B<cairo_matrix_t>
=item Num $ty; amount to translate in the X direction

=end pod

sub cairo_matrix_init_translate ( cairo_matrix_t $matrix, num64 $tx, num64 $ty  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_translate:
=begin pod
=head2 cairo_matrix_translate

Applies a translation by I<tx>, I<ty> to the transformation in I<matrix>. The effect of the new transformation is to first translate the coordinates by I<tx> and I<ty>, then apply the original transformation to the coordinates.

  method cairo_matrix_translate ( Num $tx, Num $ty )

=item Num $tx; a B<cairo_matrix_t>
=item Num $ty; amount to translate in the X direction

=end pod

sub cairo_matrix_translate ( cairo_matrix_t $matrix, num64 $tx, num64 $ty  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_init_scale:
=begin pod
=head2 [cairo_matrix_] init_scale

Initializes I<matrix> to a transformation that scales by I<sx> and I<sy> in the X and Y dimensions, respectively.

  method cairo_matrix_init_scale ( Num $sx, Num $sy )

=item Num $sx; a B<cairo_matrix_t>
=item Num $sy; scale factor in the X direction

=end pod

sub cairo_matrix_init_scale ( cairo_matrix_t $matrix, num64 $sx, num64 $sy  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_scale:
=begin pod
=head2 cairo_matrix_scale

Applies scaling by I<sx>, I<sy> to the transformation in I<matrix>. The effect of the new transformation is to first scale the coordinates by I<sx> and I<sy>, then apply the original transformation to the coordinates.

  method cairo_matrix_scale ( Num $sx, Num $sy )

=item Num $sx; a B<cairo_matrix_t>
=item Num $sy; scale factor in the X direction

=end pod

sub cairo_matrix_scale ( cairo_matrix_t $matrix, num64 $sx, num64 $sy  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_init_rotate:
=begin pod
=head2 [cairo_matrix_] init_rotate

Initialized I<matrix> to a transformation that rotates by I<radians>.

  method cairo_matrix_init_rotate ( Num $radians )

=item Num $radians; a B<cairo_matrix_t>

=end pod

sub cairo_matrix_init_rotate ( cairo_matrix_t $matrix, num64 $radians  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_rotate:
=begin pod
=head2 cairo_matrix_rotate

Applies rotation by I<radians> to the transformation in I<matrix>. The effect of the new transformation is to first rotate the coordinates by I<radians>, then apply the original transformation to the coordinates.

  method cairo_matrix_rotate ( Num $radians )

=item Num $radians; a B<cairo_matrix_t>

=end pod

sub cairo_matrix_rotate ( cairo_matrix_t $matrix, num64 $radians  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_multiply:
=begin pod
=head2 cairo_matrix_multiply

Multiplies the affine transformations in I<a> and I<b> together and stores the result in I<result>. The effect of the resulting transformation is to first apply the transformation in I<a> to the coordinates and then apply the transformation in I<b> to the coordinates. It is allowable for I<result> to be identical to either I<a> or I<b>.

  method cairo_matrix_multiply ( cairo_matrix_t $a, cairo_matrix_t $b )

=item cairo_matrix_t $a; a B<cairo_matrix_t> in which to store the result
=item cairo_matrix_t $b; a B<cairo_matrix_t>

=end pod

sub cairo_matrix_multiply ( cairo_matrix_t $result, cairo_matrix_t $a, cairo_matrix_t $b  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_transform_distance:
=begin pod
=head2 [cairo_matrix_] transform_distance

Transforms the distance vector (I<dx>,I<dy>) by I<matrix>. This is similar to C<cairo_matrix_transform_point()> except that the translation components of the transformation are ignored. The calculation of the returned vector is as follows: <programlisting> dx2 = dx1 * a + dy1 * c; dy2 = dx1 * b + dy1 * d; </programlisting> Affine transformations are position invariant, so the same vector always transforms to the same vector. If (I<x1>,I<y1>) transforms to (I<x2>,I<y2>) then (I<x1>+I<dx1>,I<y1>+I<dy1>) will transform to (I<x1>+I<dx2>,I<y1>+I<dy2>) for all values of I<x1> and I<x2>.

  method cairo_matrix_transform_distance ( Num $dx, Num $dy )

=item Num $dx; a B<cairo_matrix_t>
=item Num $dy; X component of a distance vector. An in/out parameter

=end pod

sub cairo_matrix_transform_distance ( cairo_matrix_t $matrix, num64 $dx, num64 $dy  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_transform_point:
=begin pod
=head2 [cairo_matrix_] transform_point

Transforms the point (I<x>, I<y>) by I<matrix>.

  method cairo_matrix_transform_point ( Num $x, Num $y )

=item Num $x; a B<cairo_matrix_t>
=item Num $y; X position. An in/out parameter

=end pod

sub cairo_matrix_transform_point ( cairo_matrix_t $matrix, num64 $x, num64 $y  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_matrix_invert:
=begin pod
=head2 cairo_matrix_invert

Changes I<matrix> to be the inverse of its original value. Not all transformation matrices have inverses; if the matrix collapses points together (it is I<degenerate>), then it has no inverse and this function will fail. Returns: If I<matrix> has an inverse, modifies I<matrix> to be the inverse matrix and returns C<CAIRO_STATUS_SUCCESS>. Otherwise, returns C<CAIRO_STATUS_INVALID_MATRIX>.

  method cairo_matrix_invert ( --> Int )


=end pod

sub cairo_matrix_invert ( cairo_matrix_t $matrix --> int32 )
  is native(&cairo-lib)
  { * }
