#TL:0:Gnome::Cairo::Surface:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Surface

Base class for surfaces

=comment ![](images/X.png)

=head1 Description

 B<cairo_surface_t> is the abstract type representing all different drawing targets that cairo can render to.  The actual drawings are performed using a cairo I<context>.
 A cairo surface is created by using I<backend>-specific constructors, typically of the form C<cairo_B<backend>_surface_create( )>.
 Most surface types allow accessing the surface without using Cairo functions. If you do this, keep in mind that it is mandatory that you call C<cairo_surface_flush()> before reading from or writing to the surface and that you must use C<cairo_surface_mark_dirty()> after modifying it. <example> <title>Directly modifying an image surface</title>

 void modify_image_surface (cairo_surface_t *surface) {   unsigned char *data;   int width, height, stride;
   // flush to ensure all writing to the image was done   cairo_surface_flush (surface);
   // modify the image   data = cairo_image_surface_get_data (surface);   width = cairo_image_surface_get_width (surface);   height = cairo_image_surface_get_height (surface);   stride = cairo_image_surface_get_stride (surface);   modify_image_data (data, width, height, stride);
   // mark the image dirty so Cairo clears its caches.   cairo_surface_mark_dirty (surface); }

 </example> Note that for other surface types it might be necessary to acquire the surface's device first. See C<cairo_device_acquire()> for a discussion of devices.


=head2 See Also

B<cairo_t>, B<cairo_pattern_t>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo::Surface;
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
unit class Gnome::Cairo::Surface:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 new()

Create a new Surface object.

  multi method new ( )

=end pod

#TM:0:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Surface' #`{{ or %options<CairoSurface> }} {

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
        $no = cairo_surface_new();
      }
      }}

      self.set-native-object($no);
    }

    # only after creating the native-object
    self.set-class-info('CairoSurface');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_surface_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

  self.set-class-name-of-sub('CairoSurface');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
method native-object-ref ( $no ) {
  _cairo_surface_reference($no)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $no ) {
  _cairo_surface_destroy($no);
}

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_get_type:
=begin pod
=head2 [cairo_surface_] get_type

This function returns the type of the backend used to create a surface. See B<cairo_surface_type_t> for available types.  Return value: The type of I<surface>.

  method cairo_surface_get_type ( --> cairo_surface_type_t )


=end pod

sub cairo_surface_get_type ( cairo_surface_t $surface --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_get_content:
=begin pod
=head2 [cairo_surface_] get_content

This function returns the content type of I<surface> which indicates whether the surface contains color and/or alpha information. See B<cairo_content_t>.  Return value: The content type of this I<surface>.

  method cairo_surface_get_content ( --> Int )


=end pod

sub cairo_surface_get_content ( cairo_surface_t $surface --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_status:
=begin pod
=head2 cairo_surface_status

Checks whether an error has previously occurred for this surface.  Return value: C<CAIRO_STATUS_SUCCESS>, C<CAIRO_STATUS_NULL_POINTER>, C<CAIRO_STATUS_NO_MEMORY>, C<CAIRO_STATUS_READ_ERROR>, C<CAIRO_STATUS_INVALID_CONTENT>, C<CAIRO_STATUS_INVALID_FORMAT>, or C<CAIRO_STATUS_INVALID_VISUAL>.

  method cairo_surface_status ( --> cairo_status_t )


=end pod

sub cairo_surface_status ( cairo_surface_t $surface --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_get_device:
=begin pod
=head2 [cairo_surface_] get_device

This function returns the device for a I<surface>. See B<cairo_device_t>.  Return value: The device for I<surface> or C<Any> if the surface does not have an associated device.

  method cairo_surface_get_device ( --> cairo_device_t )


=end pod

sub cairo_surface_get_device ( cairo_surface_t $surface --> cairo_device_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_create_similar:
=begin pod
=head2 [cairo_surface_] create_similar

Create a new surface that is as compatible as possible with an existing surface. For example the new surface will have the same device scale, fallback resolution and font options as this surface. Generally, the new surface will also use the same backend as this surface, unless that is not possible for some reason. The type of the returned surface may be examined with C<cairo_surface_get_type()>.

Initially the surface contents are all 0 (transparent if contents have transparency, black otherwise.)  Use C<cairo_surface_create_similar_image()> if you need an image surface which can be painted quickly to the target surface.

Return value: a pointer to the newly allocated surface. The caller owns the surface and should call C<cairo_surface_destroy()> when done with it.

This function always returns a valid pointer, but it will return a pointer to a "nil" surface if I<other> is already in an error state or any other error occurs.

  method cairo_surface_create_similar ( Int $content, Int $width, Int $height --> cairo_surface_t )

=item Int $content; an existing surface used to select the backend of the new surface
=item Int $width; the content for the new surface
=item Int $height; width of the new surface, (in device-space units)

=end pod

sub cairo_surface_create_similar ( cairo_surface_t $other, int32 $content, int32 $width, int32 $height --> cairo_surface_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_create_similar_image:
=begin pod
=head2 [cairo_surface_] create_similar_image

Create a new image surface that is as compatible as possible for uploading to and the use in conjunction with an existing surface. However, this surface can still be used like any normal image surface. Unlike C<cairo_surface_create_similar()> the new image surface won't inherit the device scale from I<other>.  Initially the surface contents are all 0 (transparent if contents have transparency, black otherwise.)  Use C<cairo_surface_create_similar()> if you don't need an image surface.  Return value: a pointer to the newly allocated image surface. The caller owns the surface and should call C<cairo_surface_destroy()> when done with it.  This function always returns a valid pointer, but it will return a pointer to a "nil" surface if I<other> is already in an error state or any other error occurs.

  method cairo_surface_create_similar_image ( Int $format, Int $width, Int $height --> cairo_surface_t )

=item Int $format; an existing surface used to select the preference of the new surface
=item Int $width; the format for the new surface
=item Int $height; width of the new surface, (in pixels)

=end pod

sub cairo_surface_create_similar_image ( cairo_surface_t $other, int32 $format, int32 $width, int32 $height --> cairo_surface_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_map_to_image:
=begin pod
=head2 [cairo_surface_] map_to_image

Returns an image surface that is the most efficient mechanism for modifying the backing store of the target surface. The region retrieved may be limited to the I<extents> or C<Any> for the whole surface  Note, the use of the original surface as a target or source whilst it is mapped is undefined. The result of mapping the surface multiple times is undefined. Calling C<cairo_surface_destroy()> or C<cairo_surface_finish()> on the resulting image surface results in undefined behavior. Changing the device transform of the image surface or of I<surface> before the image surface is unmapped results in undefined behavior.  Return value: a pointer to the newly allocated image surface. The caller must use C<cairo_surface_unmap_image()> to destroy this image surface.  This function always returns a valid pointer, but it will return a pointer to a "nil" surface if I<other> is already in an error state or any other error occurs. If the returned pointer does not have an error status, it is guaranteed to be an image surface whose format is not C<CAIRO_FORMAT_INVALID>.

  method cairo_surface_map_to_image ( cairo_rectangle_int_t $extents --> cairo_surface_t )

=item cairo_rectangle_int_t $extents; an existing surface used to extract the image from

=end pod

sub cairo_surface_map_to_image ( cairo_surface_t $surface, cairo_rectangle_int_t $extents --> cairo_surface_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_unmap_image:
=begin pod
=head2 [cairo_surface_] unmap_image

Unmaps the image surface as returned from B<cairo_surface_map_to_image>().  The content of the image will be uploaded to the target surface. Afterwards, the image is destroyed.  Using an image surface which wasn't returned by C<cairo_surface_map_to_image()> results in undefined behavior.

  method cairo_surface_unmap_image ( cairo_surface_t $image )

=item cairo_surface_t $image; the surface passed to C<cairo_surface_map_to_image()>.

=end pod

sub cairo_surface_unmap_image ( cairo_surface_t $surface, cairo_surface_t $image  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:_cairo_surface_reference:
#`{{
=begin pod
=head2 cairo_surface_reference

Increases the reference count on I<surface> by one. This prevents I<surface> from being destroyed until a matching call to C<cairo_surface_destroy()> is made.  Use C<cairo_surface_get_reference_count()> to get the number of references to a B<cairo_surface_t>.  Return value: the referenced B<cairo_surface_t>.

  method cairo_surface_reference ( --> cairo_surface_t )


=end pod
}}

sub _cairo_surface_reference ( cairo_surface_t $surface --> cairo_surface_t )
  is native(&cairo-lib)
  is symbol('cairo_surface_reference')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_surface_destroy:
#`{{
=begin pod
=head2 cairo_surface_destroy

Decreases the reference count on I<surface> by one. If the result is zero, then I<surface> and all associated resources are freed.  See C<cairo_surface_reference()>.

  method cairo_surface_destroy ( )

=end pod
}}

sub _cairo_surface_destroy ( cairo_surface_t $surface  )
  is native(&cairo-lib)
  is symbol('cairo_surface_destroy')
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_get_reference_count:
=begin pod
=head2 [cairo_surface_] get_reference_count

Returns the current reference count of I<surface>.  Return value: the current reference count of I<surface>.  If the object is a nil object, 0 will be returned.

  method cairo_surface_get_reference_count ( --> UInt )


=end pod

sub cairo_surface_get_reference_count ( cairo_surface_t $surface --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_finish:
=begin pod
=head2 cairo_surface_finish

This function finishes the surface and drops all references to external resources.  For example, for the Xlib backend it means that cairo will no longer access the drawable, which can be freed. After calling C<cairo_surface_finish()> the only valid operations on a surface are getting and setting user, referencing and destroying, and flushing and finishing it. Further drawing to the surface will not affect the surface but will instead trigger a C<CAIRO_STATUS_SURFACE_FINISHED> error.  When the last call to C<cairo_surface_destroy()> decreases the reference count to zero, cairo will call C<cairo_surface_finish()> if it hasn't been called already, before freeing the resources associated with the surface.

  method cairo_surface_finish ( )


=end pod

sub cairo_surface_finish ( cairo_surface_t $surface  )
  is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:cairo_surface_get_user_data:
=begin pod
=head2 [cairo_surface_] get_user_data

Return user data previously attached to I<surface> using the specified key.  If no user data has been attached with the given key this function returns C<Any>.  Return value: the user data previously attached or C<Any>.

  method cairo_surface_get_user_data ( cairo_user_data_key_t $key --> OpaquePointer )

=item cairo_user_data_key_t $key; a B<cairo_surface_t>

=end pod

sub cairo_surface_get_user_data ( cairo_surface_t $surface, cairo_user_data_key_t $key --> OpaquePointer )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_set_user_data:
=begin pod
=head2 [cairo_surface_] set_user_data

Attach user data to I<surface>.  To remove user data from a surface, call this function with the key that was used to set it and C<Any> for I<data>.  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY> if a slot could not be allocated for the user data.

  method cairo_surface_set_user_data ( cairo_user_data_key_t $key, OpaquePointer $user_data, cairo_destroy_func_t $destroy --> Int )

=item cairo_user_data_key_t $key; a B<cairo_surface_t>
=item OpaquePointer $user_data; the address of a B<cairo_user_data_key_t> to attach the user data to
=item cairo_destroy_func_t $destroy; the user data to attach to the surface

=end pod

sub cairo_surface_set_user_data ( cairo_surface_t $surface, cairo_user_data_key_t $key, OpaquePointer $user_data, cairo_destroy_func_t $destroy --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_get_mime_data:
=begin pod
=head2 [cairo_surface_] get_mime_data

Return mime data previously attached to I<surface> using the specified mime type.  If no data has been attached with the given mime type, I<data> is set C<Any>.

  method cairo_surface_get_mime_data ( Str $mime_type, Str $data, UInt $length )

=item Str $mime_type; a B<cairo_surface_t>
=item Str $data; the mime type of the image data
=item UInt $length; the image data to attached to the surface

=end pod

sub cairo_surface_get_mime_data ( cairo_surface_t $surface, Str $mime_type, Str $data, int64 $length  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_set_mime_data:
=begin pod
=head2 [cairo_surface_] set_mime_data

Attach an image in the format I<mime_type> to I<surface>. To remove the data from a surface, call this function with same mime type and C<Any> for I<data>.  The attached image (or filename) data can later be used by backends which support it (currently: PDF, PS, SVG and Win32 Printing surfaces) to emit this data instead of making a snapshot of the I<surface>.  This approach tends to be faster and requires less memory and disk space.  The recognized MIME types are the following: C<CAIRO_MIME_TYPE_JPEG>, C<CAIRO_MIME_TYPE_PNG>, C<CAIRO_MIME_TYPE_JP2>, C<CAIRO_MIME_TYPE_URI>, C<CAIRO_MIME_TYPE_UNIQUE_ID>, C<CAIRO_MIME_TYPE_JBIG2>, C<CAIRO_MIME_TYPE_JBIG2_GLOBAL>, C<CAIRO_MIME_TYPE_JBIG2_GLOBAL_ID>, C<CAIRO_MIME_TYPE_CCITT_FAX>, C<CAIRO_MIME_TYPE_CCITT_FAX_PARAMS>.  See corresponding backend surface docs for details about which MIME types it can handle. Caution: the associated MIME data will be discarded if you draw on the surface afterwards. Use this function with care.  Even if a backend supports a MIME type, that does not mean cairo will always be able to use the attached MIME data. For example, if the backend does not natively support the compositing operation used to apply the MIME data to the backend. In that case, the MIME data will be ignored. Therefore, to apply an image in all cases, it is best to create an image surface which contains the decoded image data and then attach the MIME data to that. This ensures the image will always be used while still allowing the MIME data to be used whenever possible.  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY> if a slot could not be allocated for the user data.

  method cairo_surface_set_mime_data ( Str $mime_type, Str $data, UInt $length, cairo_destroy_func_t $destroy, OpaquePointer $closure --> Int )

=item Str $mime_type; a B<cairo_surface_t>
=item Str $data; the MIME type of the image data
=item UInt $length; the image data to attach to the surface
=item cairo_destroy_func_t $destroy; the length of the image data
=item OpaquePointer $closure; a B<cairo_destroy_func_t> which will be called when the surface is destroyed or when new image data is attached using the same mime type.

=end pod

sub cairo_surface_set_mime_data ( cairo_surface_t $surface, Str $mime_type, Str $data, int64 $length, cairo_destroy_func_t $destroy, OpaquePointer $closure --> int32 )
  is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_supports_mime_type:
=begin pod
=head2 [cairo_surface_] supports_mime_type

Return whether I<surface> supports I<mime_type>.  Return value: C<1> if I<surface> supports I<mime_type>, C<0> otherwise

  method cairo_surface_supports_mime_type ( Str $mime_type --> Int )

=item Str $mime_type; a B<cairo_surface_t>

=end pod

sub cairo_surface_supports_mime_type ( cairo_surface_t $surface, Str $mime_type --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_get_font_options:
=begin pod
=head2 [cairo_surface_] get_font_options

Retrieves the default font rendering options for the surface. This allows display surfaces to report the correct subpixel order for rendering on them, print surfaces to disable hinting of metrics and so forth. The result can then be used with C<cairo_scaled_font_create()>.

  method cairo_surface_get_font_options ( cairo_font_options_t $options )

=item cairo_font_options_t $options; a B<cairo_surface_t>

=end pod

sub cairo_surface_get_font_options ( cairo_surface_t $surface, cairo_font_options_t $options  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_flush:
=begin pod
=head2 cairo_surface_flush

Do any pending drawing for the surface and also restore any temporary modifications cairo has made to the surface's state. This function must be called before switching from drawing on the surface with cairo to drawing on it directly with native APIs, or accessing its memory outside of Cairo. If the surface doesn't support direct access, then this function does nothing.

  method cairo_surface_flush ( )


=end pod

sub cairo_surface_flush ( cairo_surface_t $surface  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_mark_dirty:
=begin pod
=head2 [cairo_surface_] mark_dirty

Tells cairo that drawing has been done to surface using means other than cairo, and that cairo should reread any cached areas. Note that you must call C<cairo_surface_flush()> before doing such drawing.

  method cairo_surface_mark_dirty ( )


=end pod

sub cairo_surface_mark_dirty ( cairo_surface_t $surface  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_mark_dirty_rectangle:
=begin pod
=head2 [cairo_surface_] mark_dirty_rectangle

Like C<cairo_surface_mark_dirty()>, but drawing has been done only to the specified rectangle, so that cairo can retain cached contents for other parts of the surface.  Any cached clip set on the surface will be reset by this function, to make sure that future cairo calls have the clip set that they expect.

  method cairo_surface_mark_dirty_rectangle ( Int $x, Int $y, Int $width, Int $height )

=item Int $x; a B<cairo_surface_t>
=item Int $y; X coordinate of dirty rectangle
=item Int $width; Y coordinate of dirty rectangle
=item Int $height; width of dirty rectangle

=end pod

sub cairo_surface_mark_dirty_rectangle ( cairo_surface_t $surface, int32 $x, int32 $y, int32 $width, int32 $height  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_set_device_scale:
=begin pod
=head2 [cairo_surface_] set_device_scale

Sets a scale that is multiplied to the device coordinates determined by the CTM when drawing to I<surface>. One common use for this is to render to very high resolution display devices at a scale factor, so that code that assumes 1 pixel will be a certain size will still work. Setting a transformation via C<cairo_translate()> isn't sufficient to do this, since functions like C<cairo_device_to_user()> will expose the hidden scale.  Note that the scale affects drawing to the surface as well as using the surface in a source pattern.

  method cairo_surface_set_device_scale ( Num $x_scale, Num $y_scale )

=item Num $x_scale; a B<cairo_surface_t>
=item Num $y_scale; a scale factor in the X direction

=end pod

sub cairo_surface_set_device_scale ( cairo_surface_t $surface, num64 $x_scale, num64 $y_scale  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_get_device_scale:
=begin pod
=head2 [cairo_surface_] get_device_scale

This function returns the previous device offset set by C<cairo_surface_set_device_scale()>.

  method cairo_surface_get_device_scale ( Num $x_scale, Num $y_scale )

=item Num $x_scale; a B<cairo_surface_t>
=item Num $y_scale; the scale in the X direction, in device units

=end pod

sub cairo_surface_get_device_scale ( cairo_surface_t $surface, num64 $x_scale, num64 $y_scale  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_set_device_offset:
=begin pod
=head2 [cairo_surface_] set_device_offset

Sets an offset that is added to the device coordinates determined by the CTM when drawing to I<surface>. One use case for this function is when we want to create a B<cairo_surface_t> that redirects drawing for a portion of an onscreen surface to an offscreen surface in a way that is completely invisible to the user of the cairo API. Setting a transformation via C<cairo_translate()> isn't sufficient to do this, since functions like C<cairo_device_to_user()> will expose the hidden offset.  Note that the offset affects drawing to the surface as well as using the surface in a source pattern.

  method cairo_surface_set_device_offset ( Num $x_offset, Num $y_offset )

=item Num $x_offset; a B<cairo_surface_t>
=item Num $y_offset; the offset in the X direction, in device units

=end pod

sub cairo_surface_set_device_offset ( cairo_surface_t $surface, num64 $x_offset, num64 $y_offset  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_get_device_offset:
=begin pod
=head2 [cairo_surface_] get_device_offset

This function returns the previous device offset set by C<cairo_surface_set_device_offset()>.

  method cairo_surface_get_device_offset ( Num $x_offset, Num $y_offset )

=item Num $x_offset; a B<cairo_surface_t>
=item Num $y_offset; the offset in the X direction, in device units

=end pod

sub cairo_surface_get_device_offset ( cairo_surface_t $surface, num64 $x_offset, num64 $y_offset  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_set_fallback_resolution:
=begin pod
=head2 [cairo_surface_] set_fallback_resolution

Set the horizontal and vertical resolution for image fallbacks.  When certain operations aren't supported natively by a backend, cairo will fallback by rendering operations to an image and then overlaying that image onto the output. For backends that are natively vector-oriented, this function can be used to set the resolution used for these image fallbacks, (larger values will result in more detailed images, but also larger file sizes).  Some examples of natively vector-oriented backends are the ps, pdf, and svg backends.  For backends that are natively raster-oriented, image fallbacks are still possible, but they are always performed at the native device resolution. So this function has no effect on those backends.  Note: The fallback resolution only takes effect at the time of completing a page (with C<cairo_show_page()> or C<cairo_copy_page()>) so there is currently no way to have more than one fallback resolution in effect on a single page.  The default fallback resoultion is 300 pixels per inch in both dimensions.

  method cairo_surface_set_fallback_resolution ( Num $x_pixels_per_inch, Num $y_pixels_per_inch )

=item Num $x_pixels_per_inch; a B<cairo_surface_t>
=item Num $y_pixels_per_inch; horizontal setting for pixels per inch

=end pod

sub cairo_surface_set_fallback_resolution ( cairo_surface_t $surface, num64 $x_pixels_per_inch, num64 $y_pixels_per_inch  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_get_fallback_resolution:
=begin pod
=head2 [cairo_surface_] get_fallback_resolution

This function returns the previous fallback resolution set by C<cairo_surface_set_fallback_resolution()>, or default fallback resolution if never set.

  method cairo_surface_get_fallback_resolution ( Num $x_pixels_per_inch, Num $y_pixels_per_inch )

=item Num $x_pixels_per_inch; a B<cairo_surface_t>
=item Num $y_pixels_per_inch; horizontal pixels per inch

=end pod

sub cairo_surface_get_fallback_resolution ( cairo_surface_t $surface, num64 $x_pixels_per_inch, num64 $y_pixels_per_inch  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_copy_page:
=begin pod
=head2 [cairo_surface_] copy_page

Emits the current page for backends that support multiple pages, but doesn't clear it, so that the contents of the current page will be retained for the next page.  Use C<cairo_surface_show_page()> if you want to get an empty page after the emission.  There is a convenience function for this that takes a B<cairo_t>, namely C<cairo_copy_page()>.

  method cairo_surface_copy_page ( )


=end pod

sub cairo_surface_copy_page ( cairo_surface_t $surface  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_show_page:
=begin pod
=head2 [cairo_surface_] show_page

Emits and clears the current page for backends that support multiple pages.  Use C<cairo_surface_copy_page()> if you don't want to clear the page.  There is a convenience function for this that takes a B<cairo_t>, namely C<cairo_show_page()>.

  method cairo_surface_show_page ( )


=end pod

sub cairo_surface_show_page ( cairo_surface_t $surface  )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_surface_has_show_text_glyphs:
=begin pod
=head2 [cairo_surface_] has_show_text_glyphs

Returns whether the surface supports sophisticated C<cairo_show_text_glyphs()> operations.  That is, whether it actually uses the provided text and cluster data to a C<cairo_show_text_glyphs()> call.  Note: Even if this function returns C<0>, a C<cairo_show_text_glyphs()> operation targeted at I<surface> will still succeed.  It just will act like a C<cairo_show_glyphs()> operation.  Users can use this function to avoid computing UTF-8 text and cluster mapping if the target surface does not use it.  Return value: C<1> if I<surface> supports C<cairo_show_text_glyphs()>, C<0> otherwise

  method cairo_surface_has_show_text_glyphs ( --> Int )


=end pod

sub cairo_surface_has_show_text_glyphs ( cairo_surface_t $surface --> int32 )
  is native(&cairo-lib)
  { * }


#--[ png support ]--------------------------------------------------------------
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
