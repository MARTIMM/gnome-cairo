use v6;
use NativeCall;

use Gnome::Cairo::Types;

#`{{
class cairo_path_data_point_t is repr('CStruct') is export {
  has num64 $.x;
  has num64 $.y;
}
}}

my cairo_path_data_point_t $d1 .= new( :x(1e0), :y(2e0));
my cairo_path_data_point_t $d2 = $d1;

note "d2: ", $d2.perl;
