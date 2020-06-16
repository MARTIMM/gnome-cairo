#TL:0:Gnome::Cairo::FontFace:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::FontFace

Base class for font faces

=comment ![](images/X.png)

=head1 Description

 B<cairo_font_face_t> represents a particular font at a particular weight, slant, and other characteristic but no size, transformation, or size.
 Font faces are created using I<font-backend>-specific constructors, typically of the form C<cairo_B<backend>_font_face_create( )>, or implicitly using the I<toy> text API by way of C<cairo_select_font_face()>.  The resulting face can be accessed using C<cairo_get_font_face()>.


=head2 See Also

B<cairo_scaled_font_t>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo::FontFace;
  also is Gnome::N::TopLevelClassSupport;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;

use Gnome::Cairo::N-Types;
use Gnome::Cairo::Enums;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo::FontFace:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 new()

Create a new FontFace object.

  multi method new ( )

=begin comment
Create a FontFace object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

Create a FontFace object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )
=end comment

=end pod

#TM:0:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::FontFace' #`{{ or %options<CairoFontFace> }} {

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
        $no = cairo_font_face_new();
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
  try { $s = &::("cairo_font_face_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

  $s = callsame unless ?$s;

  $s;
}


#-------------------------------------------------------------------------------
#TM:0:cairo_font_face_reference:
=begin pod
=head2 cairo_font_face_reference

B<cairo_font_face_t> represents a particular font at a particular weight, slant, and other characteristic but no size, transformation, or size.  Font faces are created using I<font-backend>-specific constructors, typically of the form C<cairo_B<backend>_font_face_create( )>, or implicitly using the I<toy> text API by way of C<cairo_select_font_face()>.  The resulting face can be accessed using C<cairo_get_font_face()>. error, which is the most significant.

  method cairo_font_face_reference ( --> cairo_font_face_t )


=end pod

sub cairo_font_face_reference ( cairo_font_face_t $font_face --> cairo_font_face_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_face_destroy:
=begin pod
=head2 cairo_font_face_destroy

Decreases the reference count on I<font_face> by one. If the result is zero, then I<font_face> and all associated resources are freed. See C<cairo_font_face_reference()>.

  method cairo_font_face_destroy ( --> void )


=end pod

sub cairo_font_face_destroy ( cairo_font_face_t $font_face --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_face_get_type:
=begin pod
=head2 [cairo_font_face_] get_type

This function returns the type of the backend used to create a font face. See B<cairo_font_type_t> for available types.  Return value: The type of I<font_face>.

  method cairo_font_face_get_type ( --> Int )


=end pod

sub cairo_font_face_get_type ( cairo_font_face_t $font_face --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_face_get_reference_count:
=begin pod
=head2 [cairo_font_face_] get_reference_count

Returns the current reference count of I<font_face>.  Return value: the current reference count of I<font_face>.  If the object is a nil object, 0 will be returned.

  method cairo_font_face_get_reference_count ( --> UInt )


=end pod

sub cairo_font_face_get_reference_count ( cairo_font_face_t $font_face --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_face_status:
=begin pod
=head2 cairo_font_face_status

Checks whether an error has previously occurred for this font face  Return value: C<CAIRO_STATUS_SUCCESS> or another error such as C<CAIRO_STATUS_NO_MEMORY>.

  method cairo_font_face_status ( --> Int )


=end pod

sub cairo_font_face_status ( cairo_font_face_t $font_face --> int32 )
  is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:cairo_font_face_get_user_data:
=begin pod
=head2 [cairo_font_face_] get_user_data

Return user data previously attached to I<font_face> using the specified key.  If no user data has been attached with the given key this function returns C<Any>.  Return value: the user data previously attached or C<Any>.

  method cairo_font_face_get_user_data ( cairo_user_data_key_t $key --> OpaquePointer )

=item cairo_user_data_key_t $key; a B<cairo_font_face_t>

=end pod

sub cairo_font_face_get_user_data ( cairo_font_face_t $font_face, cairo_user_data_key_t $key --> OpaquePointer )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_face_set_user_data:
=begin pod
=head2 [cairo_font_face_] set_user_data

Attach user data to I<font_face>.  To remove user data from a font face, call this function with the key that was used to set it and C<Any> for I<data>.  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY> if a slot could not be allocated for the user data.

  method cairo_font_face_set_user_data ( cairo_user_data_key_t $key, OpaquePointer $user_data, cairo_destroy_func_t $destroy --> Int )

=item cairo_user_data_key_t $key; a B<cairo_font_face_t>
=item OpaquePointer $user_data; the address of a B<cairo_user_data_key_t> to attach the user data to
=item cairo_destroy_func_t $destroy; the user data to attach to the font face

=end pod

sub cairo_font_face_set_user_data ( cairo_font_face_t $font_face, cairo_user_data_key_t $key, OpaquePointer $user_data, cairo_destroy_func_t $destroy --> int32 )
  is native(&cairo-lib)
  { * }
}}
