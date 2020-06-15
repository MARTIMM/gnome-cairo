#TL:0:Gnome::Cairo::Surface:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Surface

Base class for surfaces

=comment ![](images/X.png)

=head1 Description

 B<cairo_surface_t> is the abstract type representing all different drawing targets that cairo can render to. The actual drawings are performed using a cairo I<context>. A cairo surface is created by using I<backend>-specific constructors, typically of the form C<cairo_B<backend>_surface_create( )>. Most surface types allow accessing the surface without using Cairo functions. If you do this, keep in mind that it is mandatory that you call C<cairo_surface_flush()> before reading from or writing to the surface and that you must use C<cairo_surface_mark_dirty()> after modifying it. <example> <title>Directly modifying an image surface</title> <programlisting> void modify_image_surface (cairo_surface_t *surface) { unsigned char *data; int width, height, stride; // flush to ensure all writing to the image was done cairo_surface_flush (surface); // modify the image data = cairo_image_surface_get_data (surface); width = cairo_image_surface_get_width (surface); height = cairo_image_surface_get_height (surface); stride = cairo_image_surface_get_stride (surface); modify_image_data (data, width, height, stride); // mark the image dirty so Cairo clears its caches. cairo_surface_mark_dirty (surface); } </programlisting> </example> Note that for other surface types it might be necessary to acquire the surface's device first. See C<cairo_device_acquire()> for a discussion of devices. 

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
