#TL:0:Gnome::Cairo::ImageSurface:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::ImageSurface

Rendering to memory buffers

=comment ![](images/X.png)

=head1 Description

 Image surfaces provide the ability to render to memory buffers either allocated by cairo or by the calling code.  The supported image formats are those defined in B<cairo_format_t>.


=head2 See Also

B<cairo_surface_t>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo::ImageSurface;
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
unit class Gnome::Cairo::ImageSurface:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;
#-------------------------------------------------------------------------------
=begin pod
=end pod
#TT:0:cairo_image_surface_t
class cairo_image_surface_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 new()

Creates an image surface of the specified format and dimensions. Initially the surface contents are set to 0. (Specifically, within each pixel, each color or alpha channel belonging to format will be 0. The contents of bits within a pixel, but not belonging to the given format are undefined).  Return value: a pointer to the newly created surface. The caller owns the surface and should call C<cairo_surface_destroy()> when done with it.  This function always returns a valid pointer, but it will return a pointer to a "nil" surface if an error such as out of memory occurs. You can use C<cairo_surface_status()> to check for this.

  multi method new ( cairo_format_t :$format, Int :$width, Int :$height )

=begin comment
Create a ImageSurface object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

Create a ImageSurface object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )
=end comment

=end pod

#TM:0:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::ImageSurface' #`{{ or %options<CairoImageSurface> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    else {
      my $no;
      if %options<format>:exists and
         %options<width>:exists and
         %options<height>:exists {

        $no = _cairo_image_surface_create(
          %options<format>, %options<width>, %options<height>
        );
      }

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

#      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
#      }}

      #`{{ when there are defaults use this instead
      # create default object
      else {
        $no = cairo_image_surface_new();
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
  try { $s = &::("cairo_image_surface_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

  $s = callsame unless ?$s;

  $s;
}


#-------------------------------------------------------------------------------
#TM:0:_cairo_image_surface_create:
#`{{
=begin pod
=head2 cairo_image_surface_create

Creates an image surface of the specified format and dimensions. Initially the surface contents are set to 0. (Specifically, within each pixel, each color or alpha channel belonging to format will be 0. The contents of bits within a pixel, but not belonging to the given format are undefined).  Return value: a pointer to the newly created surface. The caller owns the surface and should call C<cairo_surface_destroy()> when done with it.  This function always returns a valid pointer, but it will return a pointer to a "nil" surface if an error such as out of memory occurs. You can use C<cairo_surface_status()> to check for this.

  method cairo_image_surface_create ( cairo_format_t $format, Int $width, Int $height --> CArray[cairo_surface_t] )

=item Int $format; :
=item Int $width; format of pixels in the surface to create
=item Int $height; width of the surface, in pixels

=end pod
}}

sub _cairo_image_surface_create ( int32 $format, int32 $width, int32 $height --> cairo_surface_t )
  is native(&cairo-lib)
  is symbol('cairo_image_surface_create')
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_format_stride_for_width:
=begin pod
=head2 cairo_format_stride_for_width

This function provides a stride value that will respect all alignment requirements of the accelerated image-rendering code within cairo. Typical usage will be of the form:

 int stride; unsigned char *data; cairo_surface_t *surface;  stride = cairo_format_stride_for_width (format, width); data = malloc (stride * height); surface = cairo_image_surface_create_for_data (data, format, width, height, stride);

   Return value: the appropriate stride to use given the desired format and width, or -1 if either the format is invalid or the width too large.

  method cairo_format_stride_for_width ( Int $format, Int $width --> Int )

=item Int $format;  cairo_format_stride_for_width:
=item Int $width; A B<cairo_format_t> value

=end pod

sub cairo_format_stride_for_width ( int32 $format, int32 $width --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_image_surface_create_for_data:
=begin pod
=head2 [cairo_image_surface_] create_for_data

Creates an image surface for the provided pixel data. The output buffer must be kept around until the B<cairo_surface_t> is destroyed or C<cairo_surface_finish()> is called on the surface.  The initial contents of I<data> will be used as the initial image contents; you must explicitly clear the buffer, using, for example, C<cairo_rectangle()> and C<cairo_fill()> if you want it cleared.  Note that the stride may be larger than width*bytes_per_pixel to provide proper alignment for each pixel and row. This alignment is required to allow high-performance rendering within cairo. The correct way to obtain a legal stride value is to call C<cairo_format_stride_for_width()> with the desired format and maximum image width value, and then use the resulting stride value to allocate the data and to create the image surface. See C<cairo_format_stride_for_width()> for example code.  Return value: a pointer to the newly created surface. The caller owns the surface and should call C<cairo_surface_destroy()> when done with it.  This function always returns a valid pointer, but it will return a pointer to a "nil" surface in the case of an error such as out of memory or an invalid stride value. In case of invalid stride value the error status of the returned surface will be C<CAIRO_STATUS_INVALID_STRIDE>.  You can use C<cairo_surface_status()> to check for this.  See C<cairo_surface_set_user_data()> for a means of attaching a destroy-notification fallback to the surface if necessary.

  method cairo_image_surface_create_for_data ( Str $data, Int $format, Int $width, Int $height, Int $stride --> CArray[cairo_surface_t] )

=item Str $data;  cairo_image_surface_create_for_data:
=item Int $format; a pointer to a buffer supplied by the application in which to write contents. This pointer must be suitably aligned for any kind of variable, (for example, a pointer returned by malloc).
=item Int $width; the format of pixels in the buffer
=item Int $height; the width of the image to be stored in the buffer
=item Int $stride; the height of the image to be stored in the buffer

=end pod

sub cairo_image_surface_create_for_data ( Str $data, int32 $format, int32 $width, int32 $height, int32 $stride --> cairo_surface_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_image_surface_get_data:
=begin pod
=head2 [cairo_image_surface_] get_data

Get a pointer to the data of the image surface, for direct inspection or modification.  A call to C<cairo_surface_flush()> is required before accessing the pixel data to ensure that all pending drawing operations are finished. A call to C<cairo_surface_mark_dirty()> is required after the data is modified.  Return value: a pointer to the image data of this surface or C<Any> if I<surface> is not an image surface, or if C<cairo_surface_finish()> has been called.

  method cairo_image_surface_get_data ( CArray[cairo_surface_t] $surface --> Str )

=item CArray[cairo_surface_t] $surface;  cairo_image_surface_get_data:

=end pod

sub cairo_image_surface_get_data ( CArray[cairo_surface_t] $surface --> Str )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_image_surface_get_format:
=begin pod
=head2 [cairo_image_surface_] get_format

Get the format of the surface.  Return value: the format of the surface

  method cairo_image_surface_get_format ( CArray[cairo_surface_t] $surface --> Int )

=item CArray[cairo_surface_t] $surface;  cairo_image_surface_get_format:

=end pod

sub cairo_image_surface_get_format ( CArray[cairo_surface_t] $surface --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_image_surface_get_width:
=begin pod
=head2 [cairo_image_surface_] get_width

Get the width of the image surface in pixels.  Return value: the width of the surface in pixels.

  method cairo_image_surface_get_width ( CArray[cairo_surface_t] $surface --> Int )

=item CArray[cairo_surface_t] $surface;  cairo_image_surface_get_width:

=end pod

sub cairo_image_surface_get_width ( CArray[cairo_surface_t] $surface --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_image_surface_get_height:
=begin pod
=head2 [cairo_image_surface_] get_height

Get the height of the image surface in pixels.  Return value: the height of the surface in pixels.

  method cairo_image_surface_get_height ( CArray[cairo_surface_t] $surface --> Int )

=item CArray[cairo_surface_t] $surface;  cairo_image_surface_get_height:

=end pod

sub cairo_image_surface_get_height ( CArray[cairo_surface_t] $surface --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_image_surface_get_stride:
=begin pod
=head2 [cairo_image_surface_] get_stride

Get the stride of the image surface in bytes  Return value: the stride of the image surface in bytes (or 0 if I<surface> is not an image surface). The stride is the distance in bytes from the beginning of one row of the image data to the beginning of the next row.

  method cairo_image_surface_get_stride ( CArray[cairo_surface_t] $surface --> Int )

=item CArray[cairo_surface_t] $surface;  cairo_image_surface_get_stride:

=end pod

sub cairo_image_surface_get_stride ( CArray[cairo_surface_t] $surface --> int32 )
  is native(&cairo-lib)
  { * }
