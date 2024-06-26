use v6;
use NativeCall;

use Gnome::Cairo::Enums:api<1>;
use Gnome::N::GlibToRakuTypes:api<1>;

#unit class Gnome::Cairo::Types:auth<github:MARTIMM>:api<1>;

# TODO Must I ?? Rename all classes which are the same as N-Cairo. Using
# TopLevelClassSupport the same way as Gtk/Gdk/GObject by storing a N-GObject.
# Other classes which have content should be renamed too;
# E.g. cairo_rectangle_int_t should become N-CairoRectangleInt.
# To keep backwards compatibility a module like GlibToRakuTypes can be created
# to map the old types to its new types
#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_t
=end pod

#TT:1:cairo_t
class cairo_t is repr('CPointer') is export { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_surface_t
=end pod

#TT:1:cairo_surface_t
class cairo_surface_t is repr('CPointer') is export { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_pattern_t
=end pod

#TT:1:cairo_pattern_t
class cairo_pattern_t is repr('CPointer') is export { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_matrix_t

A cairo_matrix_t holds an affine transformation, such as a scale, rotation, shear, or a combination of those. The transformation of a point (x, y) is given by:

=item Num $.xx; xx component of the affine transformation
=item Num $.yx; yx component of the affine transformation
=item Num $.xy; xy component of the affine transformation
=item Num $.yy; yy component of the affine transformation
=item Num $.x0; X translation component of the affine transformation
=item Num $.y0; Y translation component of the affine transformation

=end pod

#TT:1:cairo_matrix_t
class cairo_matrix_t is repr('CStruct') is export {
  has gdouble $.xx;
  has gdouble $.yx;
  has gdouble $.xy;
  has gdouble $.yy;
  has gdouble $.x0;
  has gdouble $.y0;
}


#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_font_face_t
=end pod

#TT:1:cairo_font_face_t
class cairo_font_face_t is repr('CPointer') is export { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_font_options_t
=end pod

#TT:1:cairo_font_options_t
class cairo_font_options_t is repr('CPointer') is export { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_scaled_font_t
=end pod

#TT:1:cairo_scaled_font_t
class cairo_scaled_font_t is repr('CPointer') is export { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_font_extents_t
=end pod

#TT:0:cairo_font_extents_t
class cairo_font_extents_t is repr('CStruct') is export {
  has gdouble $.ascent;
  has gdouble $.descent;
  has gdouble $.height;
  has gdouble $.max_x_advance;
  has gdouble $.max_y_advance;
}

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_device_t
=end pod

#TT:0:cairo_device_t
class cairo_device_t is repr('CPointer') is export { }

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_path_data_t
=end pod

#TT:1:cairo_path_data_header_t
class cairo_path_data_header_t is repr('CStruct') is export {
  has guint32 $.type;                  # enum cairo_path_data_type_t
  has gint32 $.length;                 # nbr points following header
}

#TT:1:cairo_path_data_point_t
class cairo_path_data_point_t is repr('CStruct') is export {
  has gdouble $.x;
  has gdouble $.y;
}

#TT:1:cairo_path_data_t
class cairo_path_data_t is repr('CUnion') is export {
  HAS cairo_path_data_header_t $.header;
  HAS cairo_path_data_point_t $.point;
}

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_path_t
=end pod

#TT:1:cairo_path_t
class cairo_path_t is repr('CStruct') is export {
  has guint32 $.status;                # enum cairo_status_t
  has gpointer[cairo_path_data_t] $.data;
  has gint32 $.num_data;
}

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_text_extents_t

The cairo_text_extents_t structure stores the extents of a single glyph or a string of glyphs in user-space coordinates. Because text extents are in user-space coordinates, they are mostly, but not entirely, independent of the current transformation matrix. If you call cairo_scale(cr, 2.0, 2.0), text will be drawn twice as big, but the reported text extents will not be doubled. They will change slightly due to hinting (so you can't assume that metrics are independent of the transformation matrix), but otherwise will remain unchanged.

=item double x_bearing; the horizontal distance from the origin to the leftmost part of the glyphs as drawn. Positive if the glyphs lie entirely to the right of the origin.

=item double y_bearing; the vertical distance from the origin to the topmost part of the glyphs as drawn. Positive only if the glyphs lie completely below the origin; will usually be negative.

=item double width; width of the glyphs as drawn

=item double height; height of the glyphs as drawn

=item double x_advance; distance to advance in the X direction after drawing these glyphs

=item double y_advance; distance to advance in the Y direction after drawing these glyphs. Will typically be zero except for vertical text layout as found in East-Asian languages.
=end pod

#TT:1:cairo_text_extents_t
class cairo_text_extents_t is repr('CStruct') is export {
  has gdouble $.x_bearing;
  has gdouble $.y_bearing;
  has gdouble $.width;
  has gdouble $.height;
  has gdouble $.x_advance;
  has gdouble $.y_advance;
};

#`{{
#-------------------------------------------------------------------------------
# below defs are from https://www.cairographics.org/manual/cairo-Types.html
=begin pod
=head2 cairo_user_data_key_t

C<cairo_user_data_key_t> is used for attaching user data to cairo data structures. The actual contents of the struct is never used, and there is no need to initialize the object; only the unique address of a C<cairo_data_key_t> object is used. Typically, you would just use the address of a static cairo_data_key_t object.

=item Int $.unused; not used, ignore.

=end pod

# TT:0:cairo_user_data_key_t
class cairo_user_data_key_t is repr('CStruct') is export {
  has gint32 $.unused;
}
}}

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_rectangle_int_t

A data structure for holding a rectangle with integer coordinates.

=item Int $.x; X coordinate of the left side of the rectangle
=item Int $.y; Y coordinate of the the top side of the rectangle
=item Int $.width; width of the rectangle
=item Int $.height; height of the rectangle

=end pod

#TT:1:cairo_rectangle_int_t
class cairo_rectangle_int_t is repr('CStruct') is export {
  has gint32 $.x;
  has gint32 $.y;
  has gint32 $.width;
  has gint32 $.height;
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

#TT:1:cairo_rectangle_t
class cairo_rectangle_t is repr('CStruct') is export {
  has gdouble $.x;
  has gdouble $.y;
  has gdouble $.width;
  has gdouble $.height;
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
class cairo_rectangle_list_t is repr('CStruct') is export {
  has gint32 $.status;          # cairo_status_t
  has CArray $.rectangles;     # array of cairo_rectangle_t
  has gint32 $.num_rectangles;
}

#-------------------------------------------------------------------------------
# https://www.cairographics.org/manual/cairo-text.html
=begin pod
=head2 cairo_glyph_t

The cairo_glyph_t structure holds information about a single glyph when drawing or measuring text. A font is (in simple terms) a collection of shapes used to draw text. A glyph is one of these shapes. There can be multiple glyphs for a single character (alternates to be used in different contexts, for example), or a glyph can be a ligature of multiple characters. Cairo doesn't expose any way of converting input text into glyphs, so in order to use the Cairo interfaces that take arrays of glyphs, you must directly access the appropriate underlying font system.

Note that the offsets given by x and y are not cumulative. When drawing or measuring text, each glyph is individually positioned with respect to the overall origin

=item int64 $.index; glyph index in the font. The exact interpretation of the glyph index depends on the font technology being used.

=item gdouble $.x; the offset in the X direction between the origin used for drawing or measuring the string and the origin of this glyph.

=item gdouble $.y; the offset in the Y direction between the origin used for drawing or measuring the string and the origin of this glyph.

=end pod

#TT:0:cairo_glyph_t
class cairo_glyph_t is repr('CStruct') is export {
  has int64 $.index;
  has gdouble $.x;
  has gdouble $.y;
}

#-------------------------------------------------------------------------------
=begin pod
=head2 cairo_text_cluster_t

The cairo_text_cluster_t structure holds information about a single text cluster. A text cluster is a minimal mapping of some glyphs corresponding to some UTF-8 text.

For a cluster to be valid, both num_bytes and num_glyphs should be non-negative, and at least one should be non-zero. Note that clusters with zero glyphs are not as well supported as normal clusters. For example, PDF rendering applications typically ignore those clusters when PDF text is being selected.

See C<cairo_show_text_glyphs()> for how clusters are used in advanced text operations.

=item gint32 $.num_bytes; the number of bytes of UTF-8 text covered by cluster
=item gint32 $.num_glyphs; the number of glyphs covered by cluster

=end pod

#TT:0:cairo_text_cluster_t
class cairo_text_cluster_t is repr('CStruct') is export {
  has gint32 $.num_bytes;
  has gint32 $.num_glyphs;
}


=finish
#-------------------------------------------------------------------------------
=begin pod
=head2
=end pod

#TT:0:
class  is repr('CStruct') is export {
  has  $.;
  has  $.;
}
