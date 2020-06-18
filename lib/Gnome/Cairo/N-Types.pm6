use v6;
use NativeCall;

use Gnome::Cairo::Enums;

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_t
=end pod

#TT:0:cairo_t
class cairo_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_surface_t
=end pod

#TT:0:cairo_surface_t
class cairo_surface_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_pattern_t
=end pod

#TT:0:cairo_pattern_t
class cairo_pattern_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_matrix_t
=end pod

#TT:0:cairo_matrix_t
class cairo_matrix_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_path_t
=end pod

#TT:0:cairo_path_t
class cairo_path_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_font_face_t
=end pod

#TT:0:cairo_font_face_t
class cairo_font_face_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_font_options_t
=end pod

#TT:0:cairo_font_options_t
class cairo_font_options_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2
=end pod

#TT:0:cairo_scaled_font_t
class cairo_scaled_font_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_font_extents_t
=end pod

#TT:0:cairo_font_extents_t
class cairo_font_extents_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_text_extents_t
=end pod

#TT:0:cairo_text_extents_t
class cairo_text_extents_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_device_t
=end pod

#TT:0:cairo_device_t
class cairo_device_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
# below defs are from https://www.cairographics.org/manual/cairo-Types.html
=begin pod
=head2 cairo_user_data_key_t

C<cairo_user_data_key_t> is used for attaching user data to cairo data structures. The actual contents of the struct is never used, and there is no need to initialize the object; only the unique address of a C<cairo_data_key_t> object is used. Typically, you would just use the address of a static cairo_data_key_t object.

=item Int $.unused; not used, ignore.

=end pod

#TT:0:cairo_user_data_key_t
class cairo_user_data_key_t is repr('CStruct') {
  has int32 $.unused;
}

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_rectangle_int_t

A data structure for holding a rectangle with integer coordinates.

=item Int $.x; X coordinate of the left side of the rectangle
=item Int $.y; Y coordinate of the the top side of the rectangle
=item Int $.width; width of the rectangle
=item Int $.height; height of the rectangle

=end pod

#TT:0:cairo_rectangle_int_t
class cairo_rectangle_int_t is repr('CStruct') {
  has int32 $.x;
  has int32 $.y;
  has int32 $.width;
  has int32 $.height;
}

#-------------------------------------------------------------------------------
# other cairo types
# https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-rectangle-list-t
=begin pod
=head2 cairo_rectangle_t

A data structure for holding a rectangle using doubles this time.

=item Num $.x; X coordinate of the left side of the rectangle
=item Num $.y; Y coordinate of the the top side of the rectangle
=item Num $.width; width of the rectangle
=item Num $.height; height of the rectangle
=end pod

#TT:0:cairo_rectangle_t
class cairo_rectangle_t is repr('CStruct') {
  has num64 $.x;
  has num64 $.y;
  has num64 $.width;
  has num64 $.height;
}

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_rectangle_list_t

A data structure for holding a dynamically allocated array of rectangles.

=item cairo_status_t $.status; Error status of the rectangle list
=item CArray cairo_rectangle_t $.rectangles; Array containing cairo_rectangle_t rectangles
=item int $.num_rectangles; Number of rectangles in this list
=end pod

#TT:0:cairo_rectangle_list_t
class cairo_rectangle_list_t is repr('CStruct') {
  has int32 $.status;          # cairo_status_t
  has CArray $.rectangles;     # array of cairo_rectangle_t
  has int32 $.num_rectangles;
}

#-------------------------------------------------------------------------------
# https://www.cairographics.org/manual/cairo-text.html
=begin pod
=head2 cairo_glyph_t

The cairo_glyph_t structure holds information about a single glyph when drawing or measuring text. A font is (in simple terms) a collection of shapes used to draw text. A glyph is one of these shapes. There can be multiple glyphs for a single character (alternates to be used in different contexts, for example), or a glyph can be a ligature of multiple characters. Cairo doesn't expose any way of converting input text into glyphs, so in order to use the Cairo interfaces that take arrays of glyphs, you must directly access the appropriate underlying font system.

Note that the offsets given by x and y are not cumulative. When drawing or measuring text, each glyph is individually positioned with respect to the overall origin

=item int64 $.index; glyph index in the font. The exact interpretation of the glyph index depends on the font technology being used.

=item num64 $.x; the offset in the X direction between the origin used for drawing or measuring the string and the origin of this glyph.

=item num64 $.y; the offset in the Y direction between the origin used for drawing or measuring the string and the origin of this glyph.

=end pod

#TT:0:cairo_glyph_t
class cairo_glyph_t is repr('CStruct') {
  has int64 $.index;
  has num64 $.x;
  has num64 $.y;
}

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_text_cluster_t

The cairo_text_cluster_t structure holds information about a single text cluster. A text cluster is a minimal mapping of some glyphs corresponding to some UTF-8 text.

For a cluster to be valid, both num_bytes and num_glyphs should be non-negative, and at least one should be non-zero. Note that clusters with zero glyphs are not as well supported as normal clusters. For example, PDF rendering applications typically ignore those clusters when PDF text is being selected.

See C<cairo_show_text_glyphs()> for how clusters are used in advanced text operations.

=item int32 $.num_bytes; the number of bytes of UTF-8 text covered by cluster
=item int32 $.num_glyphs; the number of glyphs covered by cluster

=end pod

#TT:0:cairo_text_cluster_t
class cairo_text_cluster_t is repr('CStruct') {
  has int32 $.num_bytes;
  has int32 $.num_glyphs;
}


=finish
#-------------------------------------------------------------------------------
=begin pod
=head2
=end pod

#TT:0:
class  is repr('CStruct') {
  has  $.;
  has  $.;
}
