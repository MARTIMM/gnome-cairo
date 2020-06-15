use v6;

#-------------------------------------------------------------------------------
=begin pod
=end pod
#TT:0:cairo_t
class cairo_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=end pod
#TT:0:cairo_surface_t
class cairo_surface_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
=begin pod
=end pod
#TT:0:cairo_pattern_t
class cairo_pattern_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
# below defs are from https://www.cairographics.org/manual/cairo-Types.html
=begin pod

C<cairo_user_data_key_t> is used for attaching user data to cairo data structures. The actual contents of the struct is never used, and there is no need to initialize the object; only the unique address of a C<cairo_data_key_t> object is used. Typically, you would just use the address of a static cairo_data_key_t object.

=item int unused; not used, ignore.

=end pod

#TT:0:cairo_user_data_key_t
class cairo_user_data_key_t is repr('CStruct') {
  has int $.unused;
}

#-------------------------------------------------------------------------------
=begin pod

A data structure for holding a rectangle with integer coordinates.

=item int x; X coordinate of the left side of the rectangle
=item int y; Y coordinate of the the top side of the rectangle
=item int width; width of the rectangle
=item int height; height of the rectangle

=end pod

#TT:0:cairo_rectangle_int_t
class cairo_rectangle_int_t is repr('CStruct') {
  has int $.x;
  has int $.y;
  has int $.width;
  has int $.height;
}






=finish
#-------------------------------------------------------------------------------
=begin pod
=end pod

#TT:0:
class  is repr('CStruct') {
  has  $.;
  has  $.;
}
