#TL:1:Gnome::Cairo::Surface:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Surface

Base class for surfaces

=comment ![](images/X.png)

=head1 Description

B<cairo_surface_t> is the abstract type representing all different drawing targets that cairo can render to.  The actual drawings are performed using a cairo I<context>.

=comment A cairo surface is created by using I<backend>-specific constructors, typically of the form C<cairo_B<backend>_surface_create( )>.

Most surface types allow accessing the surface without using Cairo functions. If you do this, keep in mind that it is mandatory that you call C<flush()> before reading from or writing to the surface and that you must use C<mark-dirty()> after modifying it.


=begin comment
=head2 Example

An example to modify an image surface directly

  sub modify-image-surface ( Gnome::Cairo::Surface $surface ) {
    my Str $data;
    my Int ( $width, $height, $stride);

    # Flush to ensure all writing to the image was done
    $surface.flush;

    # Modify the image
    with $surface {
      $data = .get_data;
      $width = .get_width;
      $height = .get_height;
      $stride = .get_stride;
    }
    modify-image-data( $data, $width, $height, $stride);

    # mark the image dirty so Cairo clears its caches.
    $surface.mark-dirty;
  }


=comment Note that for other surface types it might be necessary to acquire the surface's device first. See C<cairo-device-acquire()> for a discussion of devices.
=end comment

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
use Gnome::N::GlibToRakuTypes;

use Gnome::Cairo::Types;
use Gnome::Cairo::Enums;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo::Surface:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :similar

Create a new surface that is as compatible as possible with an existing surface. For example the new surface will have the same device scale, fallback resolution and font options as I<other>. Generally, the new surface will also use the same backend as I<other>, unless that is not possible for some reason. The type of the returned surface may be examined with C<get-type()>.

Initially the surface contents are all 0 (transparent if contents have transparency, black otherwise.)  Use C<create-similar-image()> if you need an image surface which can be painted quickly to the target surface.  Return value: a pointer to the newly allocated surface. The caller owns the surface and should call C<clear-object()> when done with it.
=comment This function always returns a valid pointer, but it will return a pointer to a "nil" surface if I<other> is already in an error state or any other error occurs.

  multi method new (
    cairo_surface_t :$similar!,
    cairo_content_t :$content = CAIRO_CONTENT_COLOR,
    Int :$width = 32, Int :$height = 32
  )

=item $similar; the surface where the new surface is created from
=item $content; used to describe the content of a surface
=item $width; width of the image
=item $height; height of the image


=head3 :image

Create a new image surface that is as compatible as possible for uploading to and the use in conjunction with an existing surface. However, this surface can still be used like any normal image surface. Unlike C<new(:$similar)> the new image surface won't inherit the device scale from the C<$image> surface.

Initially the surface contents are all 0 (transparent if contents have transparency, black otherwise.)  Use C<new(:similar)> if you don't need an image surface.
=comment Return value: a pointer to the newly allocated image surface. The caller owns the surface and should call C<clear-object()> when done with it.  This function always returns a valid pointer, but it will return a pointer to a "nil" surface if I<other> is already in an error state or any other error occurs.

  multi method new (
    cairo_surface_t :image!, cairo_format_t :$format = CAIRO_FORMAT_RGB24,
    Int :$width = 32, Int :$height = 32
  )

=item $image; the surface where the new surface is created from
=item $format; used to identify the memory format of image
=item $width; width of the image
=item $height; height of the image


=head3 :target

Create a new surface that is a rectangle within the target surface. All operations drawn to this surface are then clipped and translated onto the target surface. Nothing drawn via this sub-surface outside of its bounds is drawn onto the target surface, making this a useful method for passing constrained child surfaces to library routines that draw directly onto the parent surface, i.e. with no further backend allocations, double buffering or copies.

The semantics of subsurfaces have not been finalized yet unless the rectangle is in full device units, is contained within the extents of the target surface, and the target or subsurface's device transforms are not changed.

  multi method new (
    cairo_surface_t :$target,
    Num() :$x = 0e0, Num() :$y = 0e0,
    Num() :$width = 128e0, Num() :$height = 128e0
    --> cairo_surface_t
  }

=item $target; the surface where the new surface is created from
=item $x, $y, $width and $height describe the rectangle from which a part of the image is copied.


=head3 :map, :rectangle

Creates an image surface that is the most efficient mechanism for modifying the backing store of the target surface. The region retrieved may be limited to the I<extents> or C<Any> for the whole surface.

Note, the use of the original surface as a target or source whilst it is mapped is undefined. The result of mapping the surface multiple times is also undefined. Calling C<clear-object()> on the resulting image surface results in undefined behavior. Furthermore, changing the device transform of the image surface or of I<surface> before the image surface is unmapped results in undefined behavior.

The caller must use C<unmap-image()> to destroy this image surface. This function always creates a valid native object, but this class will become invalid if I<$map> is already in an error state or any other error occurs. If the returned pointer does not have an error status, it is guaranteed to be an image surface whose format is not C<CAIRO_FORMAT_INVALID>.

  multi method new (
    cairo_surface_t :$map, cairo_rectangle_int_t :$rectangle
  )

=item $map; the surface where the new surface is created from
=item $rectangle; an existing surface used to extract the image


=head3 :native-object

Create a B<Gnome::Cairo::Surface> object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

#TM:1:new(:similar):
#TM:1:new(:image):
#TM:1:new(:target):
#TM:1:new(:map,:rectangle):
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
      if ? %options<similar> {
        $no = %options<similar>;
        $no .= _get-native-object-no-reffing unless $no ~~ cairo_surface_t;
        $no = _cairo_surface_create_similar(
          $no, %options<content> // CAIRO_CONTENT_COLOR,
          %options<width> // 32, %options<height> // 32
        );
      }

      elsif ? %options<image> {
        $no = %options<image>;
        $no .= _get-native-object-no-reffing unless $no ~~ cairo_surface_t;
        $no = _cairo_surface_create_similar_image(
          $no, %options<format> // CAIRO_FORMAT_RGB24,
          %options<width> // 32, %options<height> // 32
        );
      }

      elsif ? %options<target> {
        $no = %options<target>;
        $no .= _get-native-object-no-reffing unless $no ~~ cairo_surface_t;
        $no = _cairo_surface_create_for_rectangle(
          $no, (%options<x> // 0).Num, (%options<y> // 0).Num,
          (%options<width> // 128).Num, (%options<height> // 128).Num
        );
      }

      elsif ? %options<map> and %options<rectangle>:exists {
        $no = %options<map>;
        $no .= _get-native-object-no-reffing unless $no ~~ cairo_surface_t;
        $no = _cairo_surface_map_to_image( $no, %options<rectangle>);
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

      ##`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      #}}

      #`{{ when there are defaults use this instead
      # create default object
      else {
        $no = _cairo_surface_new();
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the native-object
#    self._set-class-info('Surface');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_surface_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

#  self._set-class-name-of-sub('Surface');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
method native-object-ref ( $no ) {
  _cairo_surface_reference($no)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $no ) {
  _cairo_surface_destroy($no) if _cairo_surface_get_reference_count($no) > 0;
#  _cairo_surface_finish($no) if _cairo_surface_get_reference_count($no) > 0;
}

#-------------------------------------------------------------------------------
#TM:0:copy-page:
=begin pod
=head2 copy-page

Emits the current page for backends that support multiple pages, but doesn't clear it, so that the contents of the current page will be retained for the next page. Use C<show-page()> if you want to get an empty page after the emission. There is a convenience function for this that takes a B<cairo_t>, namely C<copy-page()>.

  method copy-page ( )

=end pod

method copy-page ( ) {
  cairo_surface_copy_page(self._get-native-object-no-reffing)
}

sub cairo_surface_copy_page (
  cairo_surface_t $surface
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_surface_create_for_rectangle:
sub _cairo_surface_create_for_rectangle (
  cairo_surface_t $target,
  gdouble $x, gdouble $y, gdouble $width, gdouble $height
  --> cairo_surface_t
) is native(&cairo-lib)
  is symbol('cairo_surface_create_for_rectangle')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_surface_create_similar:
#`{{
=begin pod
=head2 create-similar

Create a new surface that is as compatible as possible with an existing surface. For example the new surface will have the same device scale, fallback resolution and font options as I<other>. Generally, the new surface will also use the same backend as I<other>, unless that is not possible for some reason. The type of the returned surface may be examined with C<get-type()>.  Initially the surface contents are all 0 (transparent if contents have transparency, black otherwise.)  Use C<create-similar-image()> if you need an image surface which can be painted quickly to the target surface.  Return value: a pointer to the newly allocated surface. The caller owns the surface and should call C<clear-object()> when done with it.  This function always returns a valid pointer, but it will return a pointer to a "nil" surface if I<other> is already in an error state or any other error occurs.

  method create-similar ( Int $content, Int $width, Int $height --> cairo_surface_t )

=item Int $content; an existing surface used to select the backend of the new surface
=item Int $width; the content for the new surface
=item Int $height; width of the new surface, (in device-space units)
=end pod

method create-similar ( Int $content, Int $width, Int $height --> cairo_surface_t ) {

  cairo_surface_create_similar(
    self._get-native-object-no-reffing, $content, $width, $height
  )
}
}}

sub _cairo_surface_create_similar (
  cairo_surface_t $other, gint32 $content, int32 $width, int32 $height
  --> cairo_surface_t
) is native(&cairo-lib)
  is symbol('cairo_surface_create_similar')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_surface_create_similar_image:
#`{{
=begin pod
=head2 create-similar-image

Create a new image surface that is as compatible as possible for uploading to and the use in conjunction with an existing surface. However, this surface can still be used like any normal image surface. Unlike C<create-similar()> the new image surface won't inherit the device scale from I<other>.  Initially the surface contents are all 0 (transparent if contents have transparency, black otherwise.)  Use C<create-similar()> if you don't need an image surface.  Return value: a pointer to the newly allocated image surface. The caller owns the surface and should call C<clear-object()> when done with it.  This function always returns a valid pointer, but it will return a pointer to a "nil" surface if I<other> is already in an error state or any other error occurs.

  method create-similar-image ( Int $format, Int $width, Int $height --> cairo_surface_t )

=item Int $format; an existing surface used to select the preference of the new surface
=item Int $width; the format for the new surface
=item Int $height; width of the new surface, (in pixels)
=end pod

method create-similar-image ( Int $format, Int $width, Int $height --> cairo_surface_t ) {

  cairo_surface_create_similar_image(
    self._get-native-object-no-reffing, $format, $width, $height
  )
}
}}

sub _cairo_surface_create_similar_image (
  cairo_surface_t $other, gint32 $format, int32 $width, int32 $height --> cairo_surface_t
) is native(&cairo-lib)
  is symbol('cairo_surface_create_similar_image')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_surface_destroy:
#`{{
=begin pod
=head2 destroy

Decreases the reference count on I<surface> by one. If the result is zero, then I<surface> and all associated resources are freed.  See C<reference()>.

  method destroy ( )

=end pod

method destroy ( ) {

  cairo_surface_destroy(
    self._get-native-object-no-reffing,
  )
}
}}

sub _cairo_surface_destroy (
  cairo_surface_t $surface
) is native(&cairo-lib)
  is symbol('cairo_surface_destroy')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_surface_finish:
#`{{
=begin pod
=head2 finish

This function finishes the surface and drops all references to external resources.

For example, for the Xlib backend it means that cairo will no longer access the drawable, which can be freed. After calling C<finish()> the only valid operations on a surface are getting and setting user, referencing and destroying, and flushing and finishing it. Further drawing to the surface will not affect the surface but will instead trigger a C<CAIRO_STATUS_SURFACE_FINISHED> error.

When the last call to C<clear-object()> decreases the reference count to zero, cairo will call C<finish()> if it hasn't been called already, before freeing the resources associated with the surface.

  method finish ( )

=end pod

method finish ( ) {
  cairo_surface_finish(self._get-native-object-no-reffing)
}
}}

sub _cairo_surface_finish (
  cairo_surface_t $surface
) is native(&cairo-lib)
  is symbol('cairo_surface_finish')
  { * }

#-------------------------------------------------------------------------------
#TM:0:flush:
=begin pod
=head2 flush

Do any pending drawing for the surface and also restore any temporary modifications cairo has made to the surface's state.

=comment This function must be called before switching from drawing on the surface with cairo to drawing on it directly with native APIs, or accessing its memory outside of Cairo.

If the surface doesn't support direct access, then this function does nothing.

  method flush ( )

=end pod

method flush ( ) {
  cairo_surface_flush(self._get-native-object-no-reffing)
}

sub cairo_surface_flush (
  cairo_surface_t $surface
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-content:
=begin pod
=head2 get-content

This function returns the content type of I<surface> which indicates whether the surface contains color and/or alpha information. See B<cairo_content_t>.

Return value: The content type of I<surface>.

  method get-content ( --> cairo_content_t )

=end pod

method get-content ( --> cairo_content_t ) {
  cairo_content_t(cairo_surface_get_content(self._get-native-object-no-reffing))
}

sub cairo_surface_get_content (
  cairo_surface_t $surface --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-device:
=begin pod
=head2 get-device

This function returns the device for a I<surface>. See B<cairo_device_t>.

Return value: The device for I<surface> or C<Any> if the surface does not have an associated device.

  method get-device ( --> cairo_device_t )

=end pod

method get-device ( --> cairo_device_t ) {
  cairo_surface_get_device(self._get-native-object-no-reffing)
}

sub cairo_surface_get_device (
  cairo_surface_t $surface --> cairo_device_t
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-device-offset:
=begin pod
=head2 get-device-offset

This function returns the previous device offset set by C<set-device-offset()>.

  method get-device-offset ( --> List )

List returns
=item Num; the offset in the X direction, in device units
=item Num; the offset in the Y direction, in device units
=end pod

method get-device-offset ( --> List ) {
  my gdouble $x_offset;
  my gdouble $y_offset;
  cairo_surface_get_device_offset(
    self._get-native-object-no-reffing, $x_offset, $y_offset
  );

  ( Num($x_offset), Num($y_offset) )
}

sub cairo_surface_get_device_offset (
  cairo_surface_t $surface, gdouble $x_offset is rw, gdouble $y_offset is rw
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-device-scale:
=begin pod
=head2 get-device-scale

This function returns the previous device offset set by C<set-device-scale()>.

  method get-device-scale ( --> List )

List returns
=item Num; the scale in the X direction, in device units
=item Num; the scale in the Y direction, in device units
=end pod

method get-device-scale ( --> List ) {
  my gdouble $x_scale;
  my gdouble $y_scale;
  cairo_surface_get_device_scale(
    self._get-native-object-no-reffing, $x_scale, $y_scale
  );

  ( Num($x_scale), Num($y_scale) )
}

sub cairo_surface_get_device_scale (
  cairo_surface_t $surface, gdouble $x_scale is rw, gdouble $y_scale is rw
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-fallback-resolution:
=begin pod
=head2 get-fallback-resolution

This function returns the previous fallback resolution set by C<set-fallback-resolution()>, or default fallback resolution if never set.

  method get-fallback-resolution ( --> List )

List returns
=item Num; horizontal pixels per inch
=item Num; vertical pixels per inch
=end pod

method get-fallback-resolution ( --> List ) {
  my gdouble $x_pixels_per_inch;
  my gdouble $y_pixels_per_inch;
  cairo_surface_get_fallback_resolution(
    self._get-native-object-no-reffing, $x_pixels_per_inch, $y_pixels_per_inch
  );

  ( Num($x_pixels_per_inch), Num($y_pixels_per_inch) )
}

sub cairo_surface_get_fallback_resolution (
  cairo_surface_t $surface, gdouble $x_pixels_per_inch is rw, gdouble $y_pixels_per_inch is rw
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:get-font-options:
=begin pod
=head2 get-font-options

Retrieves the default font rendering options for the surface. This allows display surfaces to report the correct subpixel order for rendering on them, print surfaces to disable hinting of metrics and so forth. The result can then be used with C<scaled-font-create()>.

  method get-font-options ( --> Gnome::Cairo::FontOptions )

=item cairo_font_options_t $options; a B<cairo_surface_t>
=end pod

method get-font-options ( --> Any ) {
  my cairo_font_options_t $options .= new;
  self._wrap-native-type(
    'Gnome::Cairo::FontOptions',
    cairo_surface_get_font_options(
      self._get-native-object-no-reffing, $options
    )
  )
}

sub cairo_surface_get_font_options (
  cairo_surface_t $surface, cairo_font_options_t $options
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:get-mime-data:
=begin pod
=head2 get-mime-data

Return mime data previously attached to I<surface> using the specified mime type.  If no data has been attached with the given mime type, I<data> is set to C<Any>.

  method get-mime-data ( unsigned Int-pptr $data, UInt $length )

=item Int $mime_type; a B<cairo_surface_t>
=item unsigned Int-pptr $data; the mime type of the image data
=item UInt $length; the image data tattached to the surface
=end pod

method get-mime-data ( unsigned Int-pptr $data, UInt $length ) {

  cairo_surface_get_mime_data(
    self._get-native-object-no-reffing, my gint $mime_type, $data, $length
  )
}

sub cairo_surface_get_mime_data (
  cairo_surface_t $surface, gchar-ptr $mime_type, unsigned gchar-pptr $data, int64 $length
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:_cairo_surface_get_reference_count:
#`{{
=begin pod
=head2 get-reference-count

Returns the current reference count of I<surface>.  Return value: the current reference count of I<surface>.  If the object is a nil object, 0 will be returned.

  method get-reference-count ( --> Int )

=end pod

method get-reference-count ( --> Int ) {

  cairo_surface_get_reference_count(
    self._get-native-object-no-reffing,
  )
}
}}
sub _cairo_surface_get_reference_count (
  cairo_surface_t $surface --> guint
) is native(&cairo-lib)
  is symbol('cairo_surface_get_reference_count')
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-type:
=begin pod
=head2 get-type

This function returns the type of the backend used to create a surface. See B<cairo_surface_type_t> for available types.  Return value: The type of I<surface>.

  method get-type ( --> cairo_surface_type_t )

=end pod

method get-type ( --> cairo_surface_type_t ) {
  cairo_surface_type_t(
    cairo_surface_get_type(self._get-native-object-no-reffing)
  )
}

sub cairo_surface_get_type (
  cairo_surface_t $surface --> GEnum
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:get-user-data:
=begin pod
=head2 get-user-data

Return user data previously attached to I<surface> using the specified key.  If no user data has been attached with the given key this function returns C<Any>.  Return value: the user data previously attached or C<Any>.

  method get-user-data ( cairo_user_data_key_t $key )

=item cairo_user_data_key_t $key; a B<cairo_surface_t>
=end pod

method get-user-data ( cairo_user_data_key_t $key ) {

  cairo_surface_get_user_data(
    self._get-native-object-no-reffing, $key
  )
}

sub cairo_surface_get_user_data (
  cairo_surface_t $surface, cairo_user_data_key_t $key
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:has-show-text-glyphs:
=begin pod
=head2 has-show-text-glyphs

Returns whether the surface supports sophisticated C<show-text-glyphs()> operations. That is, whether it actually uses the provided text and cluster data to a C<show-text-glyphs()> call.

Note: Even if this function returns C<False>, a C<show-text-glyphs()> operation targeted at I<surface> will still succeed. It just will act like a C<show-glyphs()> operation.

Users can use this function to avoid computing UTF-8 text and cluster mapping if the target surface does not use it.

Return value: C<True> if I<surface> supports C<show-text-glyphs()>, C<False> otherwise.

  method has-show-text-glyphs ( --> Bool )

=end pod

method has-show-text-glyphs ( --> Bool ) {
  cairo_surface_has_show_text_glyphs(self._get-native-object-no-reffing).Bool
}

sub cairo_surface_has_show_text_glyphs (
  cairo_surface_t $surface --> gint32
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:map-to-image:
#`{{
=begin pod
=head2 map-to-image

Returns an image surface that is the most efficient mechanism for modifying the backing store of the target surface. The region retrieved may be limited to the I<extents> or C<Any> for the whole surface  Note, the use of the original surface as a target or source whilst it is mapped is undefined. The result of mapping the surface multiple times is undefined. Calling C<clear-object()> or C<surface-finish()> on the resulting image surface results in undefined behavior. Changing the device transform of the image surface or of I<surface> before the image surface is unmapped results in undefined behavior.  Return value: a pointer to the newly allocated image surface. The caller must use C<unmap-image()> to destroy this image surface.  This function always returns a valid pointer, but it will return a pointer to a "nil" surface if I<other> is already in an error state or any other error occurs. If the returned pointer does not have an error status, it is guaranteed to be an image surface whose format is not C<CAIRO_FORMAT_INVALID>.

  method map-to-image ( cairo_rectangle_int_t $extents --> cairo_surface_t )

=item $extents; an existing surface used to extract the image from
=end pod

method map-to-image ( cairo_rectangle_int_t $extents --> cairo_surface_t ) {
  cairo_surface_map_to_image( self._get-native-object-no-reffing, $extents)
}
}}

sub _cairo_surface_map_to_image (
  cairo_surface_t $surface, cairo_rectangle_int_t $extents --> cairo_surface_t
) is native(&cairo-lib)
  is symbol('cairo_surface_map_to_image')
  { * }

#-------------------------------------------------------------------------------
#TM:0:mark-dirty:
=begin pod
=head2 mark-dirty

Tells cairo that drawing has been done to surface using means other than cairo, and that cairo should reread any cached areas. Note that you must call C<flush()> before doing such drawing.

  method mark-dirty ( )

=end pod

method mark-dirty ( ) {
  cairo_surface_mark_dirty(self._get-native-object-no-reffing)
}

sub cairo_surface_mark_dirty (
  cairo_surface_t $surface
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:mark-dirty-rectangle:
=begin pod
=head2 mark-dirty-rectangle

Like C<mark-dirty()>, but drawing has been done only to the specified rectangle, so that cairo can retain cached contents for other parts of the surface.  Any cached clip set on the surface will be reset by this function, to make sure that future cairo calls have the clip set that they expect.

  method mark-dirty-rectangle (
    Int $x, Int $y, Int $width, Int $height
  )

=item $x; X coordinate of dirty rectangle
=item $y; Y coordinate of dirty rectangle
=item $width; width of dirty rectangle
=item $height; height of dirty rectangle
=end pod

method mark-dirty-rectangle ( Int $x, Int $y, Int $width, Int $height ) {

  cairo_surface_mark_dirty_rectangle(
    self._get-native-object-no-reffing, $x, $y, $width, $height
  )
}

sub cairo_surface_mark_dirty_rectangle (
  cairo_surface_t $surface, int32 $x, int32 $y, int32 $width, int32 $height
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:_cairo_surface_reference:
#`{{
=begin pod
=head2 reference

Increases the reference count on I<surface> by one. This prevents I<surface> from being destroyed until a matching call to C<clear-object()> is made.  Use C<get-reference-count()> to get the number of references to a B<cairo_surface_t>.  Return value: the referenced B<cairo_surface_t>.

  method reference ( --> cairo_surface_t )

=end pod

method reference ( --> cairo_surface_t ) {

  cairo_surface_reference(
    self._get-native-object-no-reffing,
  )
}
}}

sub _cairo_surface_reference (
  cairo_surface_t $surface --> cairo_surface_t
) is native(&cairo-lib)
  is symbol('cairo_surface_reference')
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-device-offset:
=begin pod
=head2 set-device-offset

Sets an offset that is added to the device coordinates determined by the CTM when drawing to I<surface>. One use case for this function is when we want to create a B<cairo_surface_t> that redirects drawing for a portion of an onscreen surface to an offscreen surface in a way that is completely invisible to the user of the cairo API. Setting a transformation via C<translate()> isn't sufficient to do this, since functions like C<device-to-user()> will expose the hidden offset.  Note that the offset affects drawing to the surface as well as using the surface in a source pattern.

  method set-device-offset ( Num() $x_offset, Num() $y_offset )

=item $x_offset; the offset in the X direction, in device units
=item $y_offset; the offset in the Y direction, in device units
=end pod

method set-device-offset ( Num() $x_offset, Num() $y_offset ) {
  cairo_surface_set_device_offset(
    self._get-native-object-no-reffing, $x_offset, $y_offset
  )
}

sub cairo_surface_set_device_offset (
  cairo_surface_t $surface, gdouble $x_offset, gdouble $y_offset
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:set-device-scale:
=begin pod
=head2 set-device-scale

Sets a scale that is multiplied to the device coordinates determined by the CTM when drawing to I<surface>. One common use for this is to render to very high resolution display devices at a scale factor, so that code that assumes 1 pixel will be a certain size will still work. Setting a transformation via C<translate()> isn't sufficient to do this, since functions like C<device-to-user()> will expose the hidden scale.  Note that the scale affects drawing to the surface as well as using the surface in a source pattern.

  method set-device-scale ( Num() $x_scale, Num() $y_scale )

=item $x_scale; a scale factor in the X direction
=item $y_scale; a scale factor in the Y direction
=end pod

method set-device-scale ( Num() $x_scale, Num() $y_scale ) {
  cairo_surface_set_device_scale(
    self._get-native-object-no-reffing, $x_scale, $y_scale
  )
}

sub cairo_surface_set_device_scale (
  cairo_surface_t $surface, gdouble $x_scale, gdouble $y_scale
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-fallback-resolution:
=begin pod
=head2 set-fallback-resolution

Set the horizontal and vertical resolution for image fallbacks.  When certain operations aren't supported natively by a backend, cairo will fallback by rendering operations to an image and then overlaying that image onto the output. For backends that are natively vector-oriented, this function can be used to set the resolution used for these image fallbacks, (larger values will result in more detailed images, but also larger file sizes).  Some examples of natively vector-oriented backends are the ps, pdf, and svg backends.  For backends that are natively raster-oriented, image fallbacks are still possible, but they are always performed at the native device resolution. So this function has no effect on those backends.  Note: The fallback resolution only takes effect at the time of completing a page (with C<show-page()> or C<copy-page()>) so there is currently no way to have more than one fallback resolution in effect on a single page.  The default fallback resoultion is 300 pixels per inch in both dimensions.

  method set-fallback-resolution (
    Num() $x_pixels_per_inch, Num() $y_pixels_per_inch
  )

=item $x_pixels_per_inch; horizontal setting for pixels per inch
=item $y_pixels_per_inch; vertical setting for pixels per inch
=end pod

method set-fallback-resolution (
  Num() $x_pixels_per_inch, Num() $y_pixels_per_inch
) {
  cairo_surface_set_fallback_resolution(
    self._get-native-object-no-reffing, $x_pixels_per_inch, $y_pixels_per_inch
  )
}

sub cairo_surface_set_fallback_resolution (
  cairo_surface_t $surface, gdouble $x_pixels_per_inch, gdouble $y_pixels_per_inch
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:set-mime-data:
=begin pod
=head2 set-mime-data

Attach an image in the format I<mime_type> to I<surface>. To remove the data from a surface, call this function with same mime type and C<Any> for I<data>.  The attached image (or filename) data can later be used by backends which support it (currently: PDF, PS, SVG and Win32 Printing surfaces) to emit this data instead of making a snapshot of the I<surface>.  This approach tends to be faster and requires less memory and disk space.  The recognized MIME types are the following: C<CAIRO_MIME_TYPE_JPEG>, C<CAIRO_MIME_TYPE_PNG>, C<CAIRO_MIME_TYPE_JP2>, C<CAIRO_MIME_TYPE_URI>, C<CAIRO_MIME_TYPE_UNIQUE_ID>, C<CAIRO_MIME_TYPE_JBIG2>, C<CAIRO_MIME_TYPE_JBIG2_GLOBAL>, C<CAIRO_MIME_TYPE_JBIG2_GLOBAL_ID>, C<CAIRO_MIME_TYPE_CCITT_FAX>, C<CAIRO_MIME_TYPE_CCITT_FAX_PARAMS>.  See corresponding backend surface docs for details about which MIME types it can handle. Caution: the associated MIME data will be discarded if you draw on the surface afterwards. Use this function with care.  Even if a backend supports a MIME type, that does not mean cairo will always be able to use the attached MIME data. For example, if the backend does not natively support the compositing operation used to apply the MIME data to the backend. In that case, the MIME data will be ignored. Therefore, to apply an image in all cases, it is best to create an image surface which contains the decoded image data and then attach the MIME data to that. This ensures the image will always be used while still allowing the MIME data to be used whenever possible.  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY> if a slot could not be allocated for the user data.

  method set-mime-data ( unsigned Int-ptr $data, UInt $length, cairo_destroy_func_t $destroy, void-ptr $closure --> Int )

=item Int $mime_type; a B<cairo_surface_t>
=item unsigned Int-ptr $data; the MIME type of the image data
=item UInt $length; the image data to attach to the surface
=item cairo_destroy_func_t $destroy; the length of the image data
=item void-ptr $closure; a B<cairo_destroy_func_t> which will be called when the surface is destroyed or when new image data is attached using the same mime type.
=end pod

method set-mime-data ( unsigned Int-ptr $data, UInt $length, cairo_destroy_func_t $destroy, void-ptr $closure --> Int ) {

  cairo_surface_set_mime_data(
    self._get-native-object-no-reffing, my gint $mime_type, $data, $length, $destroy, $closure
  )
}

sub cairo_surface_set_mime_data (
  cairo_surface_t $surface, gchar-ptr $mime_type, unsigned gchar-ptr $data, int64 $length, cairo_destroy_func_t $destroy, void-ptr $closure --> gint32
) is native(&cairo-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
#TM:0:set-user-data:
=begin pod
=head2 set-user-data

Attach user data to I<surface>.  To remove user data from a surface, call this function with the key that was used to set it and C<Any> for I<data>.  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY> if a slot could not be allocated for the user data.

  method set-user-data ( cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> Int )

=item cairo_user_data_key_t $key; a B<cairo_surface_t>
=item void-ptr $user_data; the address of a B<cairo_user_data_key_t> to attach the user data to
=item cairo_destroy_func_t $destroy; the user data to attach to the surface
=end pod

method set-user-data ( cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> Int ) {

  cairo_surface_set_user_data(
    self._get-native-object-no-reffing, $key, $user_data, $destroy
  )
}

sub cairo_surface_set_user_data (
  cairo_surface_t $surface, cairo_user_data_key_t $key, void-ptr $user_data, cairo_destroy_func_t $destroy --> gint32
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:0:show-page:
=begin pod
=head2 show-page

Emits and clears the current page for backends that support multiple pages.  Use C<copy-page()> if you don't want to clear the page. There is a convenience function for this that takes a B<cairo_t>, namely C<show-page()>.

  method show-page ( )

=end pod

method show-page ( ) {
  cairo_surface_show_page(self._get-native-object-no-reffing)
}

sub cairo_surface_show_page (
  cairo_surface_t $surface
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:status:
=begin pod
=head2 status

Checks whether an error has previously occurred for this surface.
Return value can be one of: C<CAIRO_STATUS_SUCCESS>, C<CAIRO_STATUS_NULL_POINTER>, C<CAIRO_STATUS_NO_MEMORY>, C<CAIRO_STATUS_READ_ERROR>, C<CAIRO_STATUS_INVALID_CONTENT>, C<CAIRO_STATUS_INVALID_FORMAT>, or C<CAIRO_STATUS_INVALID_VISUAL>.

  method status ( --> cairo_status_t )

=end pod

method status ( --> cairo_status_t ) {
  cairo_status_t(cairo_surface_status(self._get-native-object-no-reffing))
}

sub cairo_surface_status (
  cairo_surface_t $surface --> gint32
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:supports-mime-type:
=begin pod
=head2 supports-mime-type

Return whether I<surface> supports I<mime_type>.  Return value: C<True> if I<surface> supports I<mime_type>, C<False> otherwise

  method supports-mime-type ( --> Bool )

=item Int $mime_type; a B<cairo_surface_t>
=end pod

method supports-mime-type ( --> Int ) {
  cairo_surface_supports_mime_type(
    self._get-native-object-no-reffing, my gint $mime_type
  )
}

sub cairo_surface_supports_mime_type (
  cairo_surface_t $surface, gchar-ptr $mime_type --> gint32
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:unmap-image:
=begin pod
=head2 unmap-image

Unmaps the image surface as returned from C<map-to-image>()>. The content of the image will be uploaded to the target surface. Afterwards, the image is destroyed. Using an image surface which wasn't returned by C<map-to-image()> results in undefined behavior.

  method unmap-image ( cairo_surface_t $image )

=item $image; the currently mapped image
=end pod

method unmap-image ( $image is copy ) {
  $image .= _get-native-object-no-reffing unless $image ~~ cairo_surface_t;
  cairo_surface_unmap_image( self._get-native-object-no-reffing, $image)
}

sub cairo_surface_unmap_image (
  cairo_surface_t $surface, cairo_surface_t $image
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:write-to-png:
=begin pod
=head2 write-to-png

=comment The PNG functions allow reading PNG images into image surfaces, and writing any surface to a PNG file. It is a toy API. It only offers very simple support for reading and writing PNG files, which is sufficient for testing and demonstration purposes. Applications which need more control over the generated PNG file should access the pixel data directly, using C<image-surface-get-data()> or a backend-specific access function, and process it with another library, e.g. B<Gnome::Gdk3::Pixbuf> or libpng.

=comment CAIRO_HAS_PNG_FUNCTIONS:  Defined if the PNG functions are available. This macro can be used to conditionally compile code using the cairo PNG functions.   stderr and rely on the user to check for errors via the B<cairo_status_t> return. loading the image after a warning. So we also want to return the (incorrect?) surface.  We use our own warning callback to squelch any attempts by libpng to write to stderr as we may not be in control of that output. Otherwise, we will segfault if we are writing to a stream.

Writes the contents of surface to a new file filename as a PNG image.

  method write-to-png ( Str $filename --> cairo_status_t )

=item $filename; PNG Support

=end pod

method write-to-png ( Str $filename --> cairo_status_t ) {
  cairo_status_t(
    cairo_surface_write_to_png( self._get-native-object-no-reffing, $filename)
  )
}

sub cairo_surface_write_to_png (
  cairo_surface_t $surface, Str $filename --> int32
) is native(&cairo-lib)
  { * }
