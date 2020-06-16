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
=end pod
#TT:0:cairo_font_face_t
class cairo_font_face_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=end pod
#TT:0:cairo_font_options_t
class cairo_font_options_t
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
