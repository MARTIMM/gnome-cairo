#TL:0:Gnome::Cairo::Png:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Png

Reading and writing PNG images

=comment ![](images/X.png)

=head1 Description

 The PNG functions allow reading PNG images into image surfaces, and writing any surface to a PNG file.
 It is a toy API. It only offers very simple support for reading and writing PNG files, which is sufficient for testing and demonstration purposes. Applications which need more control over the generated PNG file should access the pixel data directly, using C<cairo_image_surface_get_data()> or a backend-specific access function, and process it with another library, e.g. gdk-pixbuf or libpng.


=head2 See Also

B<cairo_surface_t>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo::Png;
  also is Gnome::Cairo::Surface;

=comment head2 Example

=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
#use Gnome::N::TopLevelClassSupport;
use Gnome::Cairo::Surface;

use Gnome::Cairo::N-Types;
use Gnome::Cairo::Enums;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo::Png:auth<github:MARTIMM>;
#also is Gnome::N::TopLevelClassSupport;
also is Gnome::Cairo::Surface;

#`{{
#-------------------------------------------------------------------------------
=begin pod
=end pod
#TT:0:cairo_png_t
class cairo_png_t
  is repr('CPointer')
  is export
  { }
}}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 new()

Create a new Png object.

  multi method new ( )

=end pod

#TM:0:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Png' #`{{ or %options<CairoPng> }} {

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
        $no = cairo_png_new();
      }
      }}

      self.set-native-object($no);
    }

    # only after creating the native-object
    self.set-class-info('CairoPng');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_png_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

  self.set-class-name-of-sub('CairoPng');
  $s = callsame unless ?$s;

  $s;
}


#-------------------------------------------------------------------------------
#TM:0:cairo_surface_write_to_png:
=begin pod
=head2 cairo_surface_write_to_png

The PNG functions allow reading PNG images into image surfaces, and writing any surface to a PNG file.  It is a toy API. It only offers very simple support for reading and writing PNG files, which is sufficient for testing and demonstration purposes. Applications which need more control over the generated PNG file should access the pixel data directly, using C<cairo_image_surface_get_data()> or a backend-specific access function, and process it with another library, e.g. gdk-pixbuf or libpng. CAIRO_HAS_PNG_FUNCTIONS:  Defined if the PNG functions are available. This macro can be used to conditionally compile code using the cairo PNG functions.   stderr and rely on the user to check for errors via the B<cairo_status_t> return. loading the image after a warning. So we also want to return the (incorrect?) surface.  We use our own warning callback to squelch any attempts by libpng to write to stderr as we may not be in control of that output. Otherwise, we will segfault if we are writing to a stream.

  method cairo_surface_write_to_png ( cairo_surface_t $surface, Str $filename --> Int )

=item cairo_surface_t $surface;  SECTION:cairo-png
=item Str $filename; PNG Support

=end pod

sub cairo_surface_write_to_png ( cairo_surface_t $surface, Str $filename --> int32 )
  is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:cairo_surface_write_to_png_stream:
=begin pod
=head2 cairo_surface_write_to_png_stream

Writes the image surface to the write function.  Return value: C<CAIRO_STATUS_SUCCESS> if the PNG file was written successfully.  Otherwise, C<CAIRO_STATUS_NO_MEMORY> is returned if memory could not be allocated for the operation, C<CAIRO_STATUS_SURFACE_TYPE_MISMATCH> if the surface does not have pixel contents, or C<CAIRO_STATUS_PNG_ERROR> if libpng returned an error.

  method cairo_surface_write_to_png_stream ( cairo_surface_t $surface, cairo_write_func_t $write_func, OpaquePointer $closure --> Int )

=item cairo_surface_t $surface;  cairo_surface_write_to_png_stream:
=item cairo_write_func_t $write_func; a B<cairo_surface_t> with pixel contents
=item OpaquePointer $closure; a B<cairo_write_func_t>

=end pod

sub cairo_surface_write_to_png_stream ( cairo_surface_t $surface, cairo_write_func_t $write_func, OpaquePointer $closure --> int32 )
  is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:cairo_image_surface_create_from_png:
=begin pod
=head2 cairo_image_surface_create_from_png

Creates a new image surface and initializes the contents to the given PNG file.  Return value: a new B<cairo_surface_t> initialized with the contents of the PNG file, or a "nil" surface if any error occurred. A nil surface can be checked for with cairo_surface_status(surface) which may return one of the following values:  C<CAIRO_STATUS_NO_MEMORY> C<CAIRO_STATUS_FILE_NOT_FOUND> C<CAIRO_STATUS_READ_ERROR> C<CAIRO_STATUS_PNG_ERROR>  Alternatively, you can allow errors to propagate through the drawing operations and check the status on the context upon completion using C<cairo_status()>.

  method cairo_image_surface_create_from_png ( Str $filename --> cairo_surface_t )

=item Str $filename;  cairo_image_surface_create_from_png:

=end pod

sub cairo_image_surface_create_from_png ( Str $filename --> cairo_surface_t )
  is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:cairo_image_surface_create_from_png_stream:
=begin pod
=head2 cairo_image_surface_create_from_png_stream

Creates a new image surface from PNG data read incrementally via the I<read_func> function.  Return value: a new B<cairo_surface_t> initialized with the contents of the PNG file or a "nil" surface if the data read is not a valid PNG image or memory could not be allocated for the operation.  A nil surface can be checked for with cairo_surface_status(surface) which may return one of the following values:  C<CAIRO_STATUS_NO_MEMORY> C<CAIRO_STATUS_READ_ERROR> C<CAIRO_STATUS_PNG_ERROR>  Alternatively, you can allow errors to propagate through the drawing operations and check the status on the context upon completion using C<cairo_status()>.

  method cairo_image_surface_create_from_png_stream ( cairo_read_func_t $read_func, OpaquePointer $closure --> cairo_surface_t )

=item cairo_read_func_t $read_func;  cairo_image_surface_create_from_png_stream:
=item OpaquePointer $closure; function called to read the data of the file

=end pod

sub cairo_image_surface_create_from_png_stream ( cairo_read_func_t $read_func, OpaquePointer $closure --> cairo_surface_t )
  is native(&cairo-lib)
  { * }
}}
