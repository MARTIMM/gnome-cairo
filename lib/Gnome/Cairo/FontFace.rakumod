#TL:0:Gnome::Cairo::FontFace:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::FontFace

Base class for font faces

=comment ![](images/X.png)

=head1 Description

B<Gnome::Cairo::FontFace> represents a particular font at a particular weight, slant, and other characteristic but no size, transformation, or size.

=comment Font faces are created using I<font-backend>-specific constructors, typically of the form C<cairo_B<backend>_font_face_create( )>, or implicitly using the I<toy> text API by way of C<cairo_select_font_face()>.  The resulting face can be accessed using C<cairo_get_font_face()>.

=begin comment
=head2 See Also

B<cairo_scaled_font_t>
=end comment

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo::FontFace;
  also is Gnome::N::TopLevelClassSupport;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X:api<1>;
use Gnome::N::NativeLib:api<1>;
use Gnome::N::TopLevelClassSupport:api<1>;
use Gnome::N::GlibToRakuTypes:api<1>;

use Gnome::Cairo::Types:api<1>;
use Gnome::Cairo::Enums:api<1>;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo::FontFace:auth<github:MARTIMM>:api<1>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods

=head2 new

There are no creation methods to get a new B<Gnome::Cairo::FontFace>. You can import it from elsewhere when a native object is returned or sometimes the Raku object can be produced like the C<Gnome::Cairo.get-font-face()> call;

  my Gnome::Cairo::FontFace $ff = $context.get-font-face;


=head3 :native-object

Create a FontFace object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )


=end pod

#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::FontFace' #`{{ or %options<CairoFontFace> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    #`{{
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
        $no = cairo_font_face_new();
      }
      }}

      self._set-native-object($no);
    }
    }}

    # only after creating the native-object
#    self._set-class-info('CairoFontFace');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Str $new-patt = $native-sub.subst( '_', '-', :g);

  my Callable $s;
  try { $s = &::("cairo_font_face_$native-sub"); };
  if ?$s {
    Gnome::N::deprecate(
      "cairo_font_face_$native-sub", $new-patt, '0.2.8', '0.3.0'
    );
  }

  else {
    try { $s = &::("cairo_$native-sub"); } unless ?$s;
    if ?$s {
      Gnome::N::deprecate(
        "cairo_$native-sub", $new-patt.subst('font-face-'),
        '0.2.8', '0.3.0'
      );
    }

    else {
      try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;
      if ?$s {
        Gnome::N::deprecate(
          "$native-sub", $new-patt.subst('cairo-font-face-'),
          '0.2.8', '0.3.0'
        );
      }
    }
  }

#  self._set-class-name-of-sub('CairoFontFace');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
method native-object-ref ( $no ) {
  _cairo_font_face_reference($no)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $no ) {
  _cairo_font_face_destroy($no)
    if _cairo_font_face_get_reference_count($no) > 0;
}


#-------------------------------------------------------------------------------
#TM:1:_cairo_font_face_reference:
#`{{
=begin pod
=head2 cairo_font_face_reference

B<cairo_font_face_t> represents a particular font at a particular weight, slant, and other characteristic but no size, transformation, or size.  Font faces are created using I<font-backend>-specific constructors, typically of the form C<cairo_B<backend>_font_face_create( )>, or implicitly using the I<toy> text API by way of C<cairo_select_font_face()>.  The resulting face can be accessed using C<cairo_get_font_face()>. error, which is the most significant.

  method cairo_font_face_reference ( --> cairo_font_face_t )

=end pod
}}

sub _cairo_font_face_reference ( cairo_font_face_t $font_face --> cairo_font_face_t )
  is native(&cairo-lib)
  is symbol('cairo_font_face_reference')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_font_face_destroy:
#`{{
=begin pod
=head2 cairo_font_face_destroy

Decreases the reference count on I<font_face> by one. If the result is zero, then I<font_face> and all associated resources are freed. See C<cairo_font_face_reference()>.

  method cairo_font_face_destroy ( --> void )

=end pod
}}

sub _cairo_font_face_destroy ( cairo_font_face_t $font_face )
  is native(&cairo-lib)
  is symbol('cairo_font_face_destroy')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_font_face_get_reference_count:
#`{{
=begin pod
=head2 get-reference-count

Returns the current reference count of I<font-face>. Return value: the current reference count of I<font-face>. If the object is a nil object, 0 will be returned.

  method get-reference-count ( --> Int )

=end pod

method get-reference-count ( --> Int ) {

  cairo_font_face_get_reference_count(
    self._get-native-object-no-reffing,
  )
}
}}

sub _cairo_font_face_get_reference_count (
  cairo_font_face_t $font_face --> guint
) is native(&cairo-lib)
  is symbol('cairo_font_face_get_reference_count')
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-type:
=begin pod
=head2 get-type

This function returns the type of the backend used to create a font face. See B<cairo-font-type-t> for available types. Return value: The type of I<font-face>.

  method get-type ( --> cairo_font_type_t )

=end pod

method get-type ( --> cairo_font_type_t ) {
  cairo_font_type_t(
    cairo_font_face_get_type(self._get-native-object-no-reffing)
  )
}

sub cairo_font_face_get_type (
  cairo_font_face_t $font_face --> GEnum
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:get-user-data:
=begin pod
=head2 get-user-data

Return user data previously attached to I<font-face> using the specified key. If no user data has been attached with the given key this function returns C<Any>. Return value: the user data previously attached or C<Any>.

  method get-user-data ( cairo_user_data_key_t $key )

=item $key; the address of the B<cairo-user-data-key-t> the user data was attached to
=end pod

method get-user-data ( $key is copy ) {
  $key .= _get-native-object-no-reffing unless $key ~~ cairo_user_data_key_t;

  cairo_font_face_get_user_data(
    self._get-native-object-no-reffing, $key
  )
}

sub cairo_font_face_get_user_data (
  cairo_font_face_t $font_face, cairo_user_data_key_t $key
) is native(&cairo-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:set-user-data:
=begin pod
=head2 set-user-data

Attach user data to I<font-face>. To remove user data from a font face, call this function with the key that was used to set it and C<Any> for I<data>. Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO-MEMORY> if a slot could not be allocated for the user data.

  method set-user-data ( cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> cairo_status_t )

=item $key; the address of a B<cairo-user-data-key-t> to attach the user data to
=item $user_data; the user data to attach to the font face
=item $destroy; a B<cairo-destroy-func-t> which will be called when the font face is destroyed or when new user data is attached using the same key.
=end pod

method set-user-data ( $key is copy, void-ptr $user_data, $destroy is copy --> cairo_status_t ) {
  $key .= _get-native-object-no-reffing unless $key ~~ cairo_user_data_key_t;
  $destroy .= _get-native-object-no-reffing unless $destroy ~~ cairo_destroy_func_t;

  cairo_font_face_set_user_data(
    self._get-native-object-no-reffing, $key, $user_data, $destroy
  )
}

sub cairo_font_face_set_user_data (
  cairo_font_face_t $font_face, cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> GEnum
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:status:
=begin pod
=head2 status

Checks whether an error has previously occurred for this font face Return value: C<CAIRO_STATUS_SUCCESS> or another error such as C<CAIRO_STATUS_NO-MEMORY>.

  method status ( --> cairo_status_t )

=end pod

method status ( --> cairo_status_t ) {
  cairo_status_t(
    cairo_font_face_status(self._get-native-object-no-reffing)
  )
}

sub cairo_font_face_status (
  cairo_font_face_t $font_face --> GEnum
) is native(&cairo-lib)
  { * }
