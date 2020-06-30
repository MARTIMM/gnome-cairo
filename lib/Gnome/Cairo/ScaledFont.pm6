#TL:0:Gnome::Cairo::ScaledFont:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::ScaledFont

Font face at particular size and options

=comment ![](images/X.png)

=head1 Description

 B<cairo_scaled_font_t> represents a realization of a font face at a particular size and transformation and a certain set of font options.


=head2 See Also

B<cairo_font_face_t>, B<cairo_matrix_t>, B<cairo_font_options_t>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo::ScaledFont;
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
unit class Gnome::Cairo::ScaledFont:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 new()

Create a new ScaledFont object.

  multi method new ( )

=begin comment
Create a ScaledFont object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

Create a ScaledFont object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )
=end comment

=end pod

#TM:0:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::ScaledFont' #`{{ or %options<CairoScaledFont> }} {

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
        $no = cairo_scaled_font_new();
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
  try { $s = &::("cairo_scaled_font_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

  $s = callsame unless ?$s;

  $s;
}


#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_get_type:
=begin pod
=head2 [cairo_scaled_font_] get_type

This function returns the type of the backend used to create a scaled font. See B<cairo_font_type_t> for available types. However, this function never returns C<CAIRO_FONT_TYPE_TOY>.  Return value: The type of I<scaled_font>.

  method cairo_scaled_font_get_type ( --> Int )


=end pod

sub cairo_scaled_font_get_type ( cairo_scaled_font_t $scaled_font --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_status:
=begin pod
=head2 cairo_scaled_font_status

Checks whether an error has previously occurred for this scaled_font.  Return value: C<CAIRO_STATUS_SUCCESS> or another error such as C<CAIRO_STATUS_NO_MEMORY>.

  method cairo_scaled_font_status ( --> Int )


=end pod

sub cairo_scaled_font_status ( cairo_scaled_font_t $scaled_font --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_create:
=begin pod
=head2 cairo_scaled_font_create

Creates a B<cairo_scaled_font_t> object from a font face and matrices that describe the size of the font and the environment in which it will be used.  Return value: a newly created B<cairo_scaled_font_t>. Destroy with C<cairo_scaled_font_destroy()>

  method cairo_scaled_font_create ( cairo_font_face_t $font_face, cairo_matrix_t $font_matrix, cairo_matrix_t $ctm, cairo_font_options_t $options --> cairo_scaled_font_t )

=item cairo_font_face_t $font_face;  cairo_scaled_font_create:
=item cairo_matrix_t $font_matrix; a B<cairo_font_face_t>
=item cairo_matrix_t $ctm; font space to user space transformation matrix for the font. In the simplest case of a N point font, this matrix is just a scale by N, but it can also be used to shear the font or stretch it unequally along the two axes. See C<cairo_set_font_matrix()>.
=item cairo_font_options_t $options; user to device transformation matrix with which the font will be used.

=end pod

sub cairo_scaled_font_create ( cairo_font_face_t $font_face, cairo_matrix_t $font_matrix, cairo_matrix_t $ctm, cairo_font_options_t $options --> cairo_scaled_font_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_reference:
=begin pod
=head2 cairo_scaled_font_reference

Increases the reference count on I<scaled_font> by one. This prevents I<scaled_font> from being destroyed until a matching call to C<cairo_scaled_font_destroy()> is made.  Use C<cairo_scaled_font_get_reference_count()> to get the number of references to a B<cairo_scaled_font_t>.  Returns: the referenced B<cairo_scaled_font_t>

  method cairo_scaled_font_reference ( --> cairo_scaled_font_t )


=end pod

sub cairo_scaled_font_reference ( cairo_scaled_font_t $scaled_font --> cairo_scaled_font_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_destroy:
=begin pod
=head2 cairo_scaled_font_destroy

Decreases the reference count on I<font> by one. If the result is zero, then I<font> and all associated resources are freed. See C<cairo_scaled_font_reference()>.

  method cairo_scaled_font_destroy ( --> void )


=end pod

sub cairo_scaled_font_destroy ( cairo_scaled_font_t $scaled_font --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_get_reference_count:
=begin pod
=head2 [cairo_scaled_font_] get_reference_count

Returns the current reference count of I<scaled_font>.  Return value: the current reference count of I<scaled_font>.  If the object is a nil object, 0 will be returned.

  method cairo_scaled_font_get_reference_count ( --> UInt )


=end pod

sub cairo_scaled_font_get_reference_count ( cairo_scaled_font_t $scaled_font --> int32 )
  is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_get_user_data:
=begin pod
=head2 [cairo_scaled_font_] get_user_data

Return user data previously attached to I<scaled_font> using the specified key.  If no user data has been attached with the given key this function returns C<Any>.  Return value: the user data previously attached or C<Any>.

  method cairo_scaled_font_get_user_data ( cairo_user_data_key_t $key --> OpaquePointer )

=item cairo_user_data_key_t $key; a B<cairo_scaled_font_t>

=end pod

sub cairo_scaled_font_get_user_data ( cairo_scaled_font_t $scaled_font, cairo_user_data_key_t $key --> OpaquePointer )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_set_user_data:
=begin pod
=head2 [cairo_scaled_font_] set_user_data

Attach user data to I<scaled_font>.  To remove user data from a surface, call this function with the key that was used to set it and C<Any> for I<data>.  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY> if a slot could not be allocated for the user data.

  method cairo_scaled_font_set_user_data ( cairo_user_data_key_t $key, OpaquePointer $user_data, cairo_destroy_func_t $destroy --> Int )

=item cairo_user_data_key_t $key; a B<cairo_scaled_font_t>
=item OpaquePointer $user_data; the address of a B<cairo_user_data_key_t> to attach the user data to
=item cairo_destroy_func_t $destroy; the user data to attach to the B<cairo_scaled_font_t>

=end pod

sub cairo_scaled_font_set_user_data ( cairo_scaled_font_t $scaled_font, cairo_user_data_key_t $key, OpaquePointer $user_data, cairo_destroy_func_t $destroy --> int32 )
  is native(&cairo-lib)
  { * }
}}


#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_extents:
=begin pod
=head2 cairo_scaled_font_extents

Gets the metrics for a B<cairo_scaled_font_t>.

  method cairo_scaled_font_extents ( cairo_font_extents_t $extents --> void )

=item cairo_font_extents_t $extents; a B<cairo_scaled_font_t>

=end pod

sub cairo_scaled_font_extents ( cairo_scaled_font_t $scaled_font, cairo_font_extents_t $extents --> void )
  is native(&cairo-lib)
  { * }


#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_text_extents:
=begin pod
=head2 [cairo_scaled_font_] text_extents

Gets the extents for a string of text. The extents describe a user-space rectangle that encloses the "inked" portion of the text drawn at the origin (0,0) (as it would be drawn by C<cairo_show_text()> if the cairo graphics state were set to the same font_face, font_matrix, ctm, and font_options as I<scaled_font>).  Additionally, the x_advance and y_advance values indicate the amount by which the current point would be advanced by C<cairo_show_text()>.  Note that whitespace characters do not directly contribute to the size of the rectangle (extents.width and extents.height). They do contribute indirectly by changing the position of non-whitespace characters. In particular, trailing whitespace characters are likely to not affect the size of the rectangle, though they will affect the x_advance and y_advance values.

  method cairo_scaled_font_text_extents ( Str $utf8, cairo_text_extents_t $extents --> void )

=item Str $utf8; a B<cairo_scaled_font_t>
=item cairo_text_extents_t $extents; a NUL-terminated string of text, encoded in UTF-8

=end pod

sub cairo_scaled_font_text_extents ( cairo_scaled_font_t $scaled_font, Str $utf8, cairo_text_extents_t $extents --> void )
  is native(&cairo-lib)
  { * }


#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_glyph_extents:
=begin pod
=head2 [cairo_scaled_font_] glyph_extents

Gets the extents for an array of glyphs. The extents describe a user-space rectangle that encloses the "inked" portion of the glyphs, (as they would be drawn by C<cairo_show_glyphs()> if the cairo graphics state were set to the same font_face, font_matrix, ctm, and font_options as I<scaled_font>).  Additionally, the x_advance and y_advance values indicate the amount by which the current point would be advanced by C<cairo_show_glyphs()>.  Note that whitespace glyphs do not contribute to the size of the rectangle (extents.width and extents.height).

  method cairo_scaled_font_glyph_extents ( cairo_glyph_t $glyphs, Int $num_glyphs, cairo_text_extents_t $extents --> void )

=item cairo_glyph_t $glyphs; a B<cairo_scaled_font_t>
=item Int $num_glyphs; an array of glyph IDs with X and Y offsets.
=item cairo_text_extents_t $extents; the number of glyphs in the I<glyphs> array

=end pod

sub cairo_scaled_font_glyph_extents ( cairo_scaled_font_t $scaled_font, cairo_glyph_t $glyphs, int32 $num_glyphs, cairo_text_extents_t $extents --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_get_font_face:
=begin pod
=head2 [cairo_scaled_font_] get_font_face

Gets the font face that this scaled font uses.  This might be the font face passed to C<cairo_scaled_font_create()>, but this does not hold true for all possible cases.  Return value: The B<cairo_font_face_t> with which I<scaled_font> was created.  This object is owned by cairo. To keep a reference to it, you must call C<cairo_scaled_font_reference()>.

  method cairo_scaled_font_get_font_face ( --> cairo_font_face_t )


=end pod

sub cairo_scaled_font_get_font_face ( cairo_scaled_font_t $scaled_font --> cairo_font_face_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_get_font_matrix:
=begin pod
=head2 [cairo_scaled_font_] get_font_matrix

Stores the font matrix with which I<scaled_font> was created into I<matrix>.

  method cairo_scaled_font_get_font_matrix ( cairo_matrix_t $font_matrix --> void )

=item cairo_matrix_t $font_matrix; a B<cairo_scaled_font_t>

=end pod

sub cairo_scaled_font_get_font_matrix ( cairo_scaled_font_t $scaled_font, cairo_matrix_t $font_matrix --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_get_ctm:
=begin pod
=head2 [cairo_scaled_font_] get_ctm

Stores the CTM with which I<scaled_font> was created into I<ctm>. Note that the translation offsets (x0, y0) of the CTM are ignored by C<cairo_scaled_font_create()>.  So, the matrix this function returns always has 0,0 as x0,y0.

  method cairo_scaled_font_get_ctm ( cairo_matrix_t $ctm --> void )

=item cairo_matrix_t $ctm; a B<cairo_scaled_font_t>

=end pod

sub cairo_scaled_font_get_ctm ( cairo_scaled_font_t $scaled_font, cairo_matrix_t $ctm --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_get_scale_matrix:
=begin pod
=head2 [cairo_scaled_font_] get_scale_matrix

Stores the scale matrix of I<scaled_font> into I<matrix>. The scale matrix is product of the font matrix and the ctm associated with the scaled font, and hence is the matrix mapping from font space to device space.

  method cairo_scaled_font_get_scale_matrix ( cairo_matrix_t $scale_matrix --> void )

=item cairo_matrix_t $scale_matrix; a B<cairo_scaled_font_t>

=end pod

sub cairo_scaled_font_get_scale_matrix ( cairo_scaled_font_t $scaled_font, cairo_matrix_t $scale_matrix --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_scaled_font_get_font_options:
=begin pod
=head2 [cairo_scaled_font_] get_font_options

Stores the font options with which I<scaled_font> was created into I<options>.

  method cairo_scaled_font_get_font_options ( cairo_font_options_t $options --> void )

=item cairo_font_options_t $options; a B<cairo_scaled_font_t>

=end pod

sub cairo_scaled_font_get_font_options ( cairo_scaled_font_t $scaled_font, cairo_font_options_t $options --> void )
  is native(&cairo-lib)
  { * }
