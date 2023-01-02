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
use Gnome::N::GlibToRakuTypes;

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
      #   $no .= _get-native-object-no-reffing
      #     if $no.^can('_get-native-object-no-reffing');
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

      self._set-native-object($no);
    }
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Str $new-patt = $native-sub.subst( '_', '-', :g);

  my Callable $s;
  try { $s = &::("cairo_scaled_font_$native-sub"); };
  if ?$s {
    Gnome::N::deprecate(
      "cairo_scaled_font_$native-sub", $new-patt, '0.2.8', '0.3.0'
    );
  }

  else {
    try { $s = &::("cairo_$native-sub"); } unless ?$s;
    if ?$s {
      Gnome::N::deprecate(
        "cairo_$native-sub", $new-patt.subst('scaled-font-'),
        '0.2.8', '0.3.0'
      );
    }

    else {
      try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;
      if ?$s {
        Gnome::N::deprecate(
          "$native-sub", $new-patt.subst('cairo-scaled-font-'),
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
#  _cairo_reference($no);
  $no
}

#-------------------------------------------------------------------------------
method native-object-unref ( $no ) {
#  _cairo_destroy($no) if _cairo_get_reference_count($no) > 0;
  $no
}

#-------------------------------------------------------------------------------
#TM:0:create:
=begin pod
=head2 create

Creates a B<t> object from a font face and matrices that describe the size of the font and the environment in which it will be used. Return value: a newly created B<t>. Destroy with C<destroy()>

  method create ( cairo_font_face_t $font_face, cairo_matrix_t $font_matrix, cairo_matrix_t $ctm, cairo_font_options_t $options --> cairo_scaled_font_t )

=item $font_face; a B<cairo-font-face-t>
=item $font_matrix; font space to user space transformation matrix for the font. In the simplest case of a N point font, this matrix is just a scale by N, but it can also be used to shear the font or stretch it unequally along the two axes. See C<cairo-set-font-matrix()>.
=item $ctm; user to device transformation matrix with which the font will be used.
=item $options; options to use when getting metrics for the font and rendering with it.
=end pod

method create ( $font_face is copy, $font_matrix is copy, $ctm is copy, $options is copy --> cairo_scaled_font_t ) {
  $font_face .= _get-native-object-no-reffing unless $font_face ~~ cairo_font_face_t;
  $font_matrix .= _get-native-object-no-reffing unless $font_matrix ~~ cairo_matrix_t;
  $ctm .= _get-native-object-no-reffing unless $ctm ~~ cairo_matrix_t;
  $options .= _get-native-object-no-reffing unless $options ~~ cairo_font_options_t;

  cairo_scaled_font_create(
    self._get-native-object-no-reffing, $font_face, $font_matrix, $ctm, $options
  )
}

sub cairo_scaled_font_create (
  cairo_font_face_t $font_face, cairo_matrix_t $font_matrix, cairo_matrix_t $ctm, cairo_font_options_t $options --> cairo_scaled_font_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:destroy:
=begin pod
=head2 destroy

Decreases the reference count on I<font> by one. If the result is zero, then I<font> and all associated resources are freed. See C<reference()>.

  method destroy ( )

=end pod

method destroy ( ) {

  cairo_scaled_font_destroy(
    self._get-native-object-no-reffing,
  )
}

sub cairo_scaled_font_destroy (
  cairo_scaled_font_t $scaled_font 
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:extents:
=begin pod
=head2 extents

Gets the metrics for a B<t>.

  method extents ( cairo_font_extents_t $extents )

=item $extents; a B<cairo-font-extents-t> which to store the retrieved extents.
=end pod

method extents ( $extents is copy ) {
  $extents .= _get-native-object-no-reffing unless $extents ~~ cairo_font_extents_t;

  cairo_scaled_font_extents(
    self._get-native-object-no-reffing, $extents
  )
}

sub cairo_scaled_font_extents (
  cairo_scaled_font_t $scaled_font, cairo_font_extents_t $extents 
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-ctm:
=begin pod
=head2 get-ctm

Stores the CTM with which I<scaled-font> was created into I<ctm>. Note that the translation offsets (x0, y0) of the CTM are ignored by C<create()>. So, the matrix this function returns always has 0,0 as x0,y0.

  method get-ctm ( cairo_matrix_t $ctm )

=item $ctm; return value for the CTM
=end pod

method get-ctm ( $ctm is copy ) {
  $ctm .= _get-native-object-no-reffing unless $ctm ~~ cairo_matrix_t;

  cairo_scaled_font_get_ctm(
    self._get-native-object-no-reffing, $ctm
  )
}

sub cairo_scaled_font_get_ctm (
  cairo_scaled_font_t $scaled_font, cairo_matrix_t $ctm 
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-font-face:
=begin pod
=head2 get-font-face

Gets the font face that this scaled font uses. This might be the font face passed to C<create()>, but this does not hold true for all possible cases. Return value: The B<cairo-font-face-t> with which I<scaled-font> was created. This object is owned by cairo. To keep a reference to it, you must call C<reference()>.

  method get-font-face ( --> cairo_font_face_t )

=end pod

method get-font-face ( --> cairo_font_face_t ) {

  cairo_scaled_font_get_font_face(
    self._get-native-object-no-reffing,
  )
}

sub cairo_scaled_font_get_font_face (
  cairo_scaled_font_t $scaled_font --> cairo_font_face_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-font-matrix:
=begin pod
=head2 get-font-matrix

Stores the font matrix with which I<scaled-font> was created into I<matrix>.

  method get-font-matrix ( cairo_matrix_t $font_matrix )

=item $font_matrix; return value for the matrix
=end pod

method get-font-matrix ( $font_matrix is copy ) {
  $font_matrix .= _get-native-object-no-reffing unless $font_matrix ~~ cairo_matrix_t;

  cairo_scaled_font_get_font_matrix(
    self._get-native-object-no-reffing, $font_matrix
  )
}

sub cairo_scaled_font_get_font_matrix (
  cairo_scaled_font_t $scaled_font, cairo_matrix_t $font_matrix 
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-font-options:
=begin pod
=head2 get-font-options

Stores the font options with which I<scaled-font> was created into I<options>.

  method get-font-options ( cairo_font_options_t $options )

=item $options; return value for the font options
=end pod

method get-font-options ( $options is copy ) {
  $options .= _get-native-object-no-reffing unless $options ~~ cairo_font_options_t;

  cairo_scaled_font_get_font_options(
    self._get-native-object-no-reffing, $options
  )
}

sub cairo_scaled_font_get_font_options (
  cairo_scaled_font_t $scaled_font, cairo_font_options_t $options 
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-reference-count:
=begin pod
=head2 get-reference-count

Returns the current reference count of I<scaled-font>. Return value: the current reference count of I<scaled-font>. If the object is a nil object, 0 will be returned.

  method get-reference-count ( --> Int )

=end pod

method get-reference-count ( --> Int ) {

  cairo_scaled_font_get_reference_count(
    self._get-native-object-no-reffing,
  )
}

sub cairo_scaled_font_get_reference_count (
  cairo_scaled_font_t $scaled_font --> guint
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-scale-matrix:
=begin pod
=head2 get-scale-matrix

Stores the scale matrix of I<scaled-font> into I<matrix>. The scale matrix is product of the font matrix and the ctm associated with the scaled font, and hence is the matrix mapping from font space to device space.

  method get-scale-matrix ( cairo_matrix_t $scale_matrix )

=item $scale_matrix; return value for the matrix
=end pod

method get-scale-matrix ( $scale_matrix is copy ) {
  $scale_matrix .= _get-native-object-no-reffing unless $scale_matrix ~~ cairo_matrix_t;

  cairo_scaled_font_get_scale_matrix(
    self._get-native-object-no-reffing, $scale_matrix
  )
}

sub cairo_scaled_font_get_scale_matrix (
  cairo_scaled_font_t $scaled_font, cairo_matrix_t $scale_matrix 
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-type:
=begin pod
=head2 get-type

This function returns the type of the backend used to create a scaled font. See B<cairo-font-type-t> for available types. However, this function never returns C<CAIRO-FONT-TYPE-TOY>. Return value: The type of I<scaled-font>.

  method get-type ( --> cairo_font_type_t )

=end pod

method get-type ( --> cairo_font_type_t ) {

  cairo_scaled_font_get_type(
    self._get-native-object-no-reffing,
  )
}

sub cairo_scaled_font_get_type (
  cairo_scaled_font_t $scaled_font --> GEnum
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:get-user-data:
=begin pod
=head2 get-user-data

Return user data previously attached to I<scaled-font> using the specified key. If no user data has been attached with the given key this function returns C<Any>. Return value: the user data previously attached or C<Any>.

  method get-user-data ( cairo_user_data_key_t $key )

=item $key; the address of the B<cairo-user-data-key-t> the user data was attached to
=end pod

method get-user-data ( $key is copy ) {
  $key .= _get-native-object-no-reffing unless $key ~~ cairo_user_data_key_t;

  cairo_scaled_font_get_user_data(
    self._get-native-object-no-reffing, $key
  )
}

sub cairo_scaled_font_get_user_data (
  cairo_scaled_font_t $scaled_font, cairo_user_data_key_t $key 
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:glyph-extents:
=begin pod
=head2 glyph-extents

Gets the extents for an array of glyphs. The extents describe a user-space rectangle that encloses the "inked" portion of the glyphs, (as they would be drawn by C<cairo-show-glyphs()> if the cairo graphics state were set to the same font-face, font-matrix, ctm, and font-options as I<scaled-font>). Additionally, the x-advance and y-advance values indicate the amount by which the current point would be advanced by C<cairo-show-glyphs()>. Note that whitespace glyphs do not contribute to the size of the rectangle (extents.width and extents.height).

  method glyph-extents ( cairo_glyph_t $glyphs, Int $num_glyphs, cairo_text_extents_t $extents )

=item $glyphs; an array of glyph IDs with X and Y offsets.
=item $num_glyphs; the number of glyphs in the I<glyphs> array
=item $extents; a B<cairo-text-extents-t> which to store the retrieved extents.
=end pod

method glyph-extents ( $glyphs is copy, Int $num_glyphs, $extents is copy ) {
  $glyphs .= _get-native-object-no-reffing unless $glyphs ~~ cairo_glyph_t;
  $extents .= _get-native-object-no-reffing unless $extents ~~ cairo_text_extents_t;

  cairo_scaled_font_glyph_extents(
    self._get-native-object-no-reffing, $glyphs, $num_glyphs, $extents
  )
}

sub cairo_scaled_font_glyph_extents (
  cairo_scaled_font_t $scaled_font, cairo_glyph_t $glyphs, int32 $num_glyphs, cairo_text_extents_t $extents 
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:reference:
=begin pod
=head2 reference

Increases the reference count on I<scaled-font> by one. This prevents I<scaled-font> from being destroyed until a matching call to C<destroy()> is made. Use C<get-reference-count()> to get the number of references to a B<t>.
 Returns: the referenced B<t>

  method reference ( --> cairo_scaled_font_t )

=end pod

method reference ( --> cairo_scaled_font_t ) {

  cairo_scaled_font_reference(
    self._get-native-object-no-reffing,
  )
}

sub cairo_scaled_font_reference (
  cairo_scaled_font_t $scaled_font --> cairo_scaled_font_t
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:set-user-data:
=begin pod
=head2 set-user-data

Attach user data to I<scaled-font>. To remove user data from a surface, call this function with the key that was used to set it and C<Any> for I<data>. Return value: C<CAIRO-STATUS-SUCCESS> or C<CAIRO-STATUS-NO-MEMORY> if a slot could not be allocated for the user data.

  method set-user-data ( cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> cairo_status_t )

=item $key; the address of a B<cairo-user-data-key-t> to attach the user data to
=item $user_data; the user data to attach to the B<t>
=item $destroy; a B<cairo-destroy-func-t> which will be called when the B<cairo-t> is destroyed or when new user data is attached using the same key.
=end pod

method set-user-data ( $key is copy, void-ptr $user_data, $destroy is copy --> cairo_status_t ) {
  $key .= _get-native-object-no-reffing unless $key ~~ cairo_user_data_key_t;
  $destroy .= _get-native-object-no-reffing unless $destroy ~~ cairo_destroy_func_t;

  cairo_scaled_font_set_user_data(
    self._get-native-object-no-reffing, $key, $user_data, $destroy
  )
}

sub cairo_scaled_font_set_user_data (
  cairo_scaled_font_t $scaled_font, cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> GEnum
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:status:
=begin pod
=head2 status

Checks whether an error has previously occurred for this scaled-font. Return value: C<CAIRO-STATUS-SUCCESS> or another error such as C<CAIRO-STATUS-NO-MEMORY>.

  method status ( --> cairo_status_t )

=end pod

method status ( --> cairo_status_t ) {

  cairo_scaled_font_status(
    self._get-native-object-no-reffing,
  )
}

sub cairo_scaled_font_status (
  cairo_scaled_font_t $scaled_font --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:text-extents:
=begin pod
=head2 text-extents

Gets the extents for a string of text. The extents describe a user-space rectangle that encloses the "inked" portion of the text drawn at the origin (0,0) (as it would be drawn by C<cairo-show-text()> if the cairo graphics state were set to the same font-face, font-matrix, ctm, and font-options as I<scaled-font>). Additionally, the x-advance and y-advance values indicate the amount by which the current point would be advanced by C<cairo-show-text()>. Note that whitespace characters do not directly contribute to the size of the rectangle (extents.width and extents.height). They do contribute indirectly by changing the position of non-whitespace characters. In particular, trailing whitespace characters are likely to not affect the size of the rectangle, though they will affect the x-advance and y-advance values.

  method text-extents ( cairo_text_extents_t $extents )

=item $utf8; a NUL-terminated string of text, encoded in UTF-8
=item $extents; a B<cairo-text-extents-t> which to store the retrieved extents.
=end pod

method text-extents ( $extents is copy ) {
  $extents .= _get-native-object-no-reffing unless $extents ~~ cairo_text_extents_t;

  cairo_scaled_font_text_extents(
    self._get-native-object-no-reffing, my gint $utf8, $extents
  )
}

sub cairo_scaled_font_text_extents (
  cairo_scaled_font_t $scaled_font, gchar-ptr $utf8, cairo_text_extents_t $extents 
) is native(&cairo-lib)
  { * }













=finish
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
