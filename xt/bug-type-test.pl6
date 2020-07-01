use v6;

use Gnome::Cairo::ImageSurface;
use Gnome::Cairo;
use Gnome::Cairo::Types;
use Gnome::Cairo::Enums;
use Gnome::Cairo::Path;

say ' ';

class PathHandling {
  method mt ( cairo_path_data_point_t $p ) {
    note "  move to Px: ", $p.x, ', ', $p.y;
  }

  method lt ( cairo_path_data_point_t $p ) {
    note "  line to Px: ", $p.x, ', ', $p.y;
  }

  method ct (
    cairo_path_data_point_t $p1, cairo_path_data_point_t $p2,
    cairo_path_data_point_t $p3
  ) {
    note "  curve to Px: ", $p1.x, ', ', $p1.y, ', ', $p2.x, ', ',
      $p2.y, ', ', $p3.x, ', ', $p3.y;
  }

  method cp ( ) {
    note "  close path, no points";
  }
}


# create an image surface
my Gnome::Cairo::ImageSurface $image-surface .= new(
  :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128)
);

# tie a cairo context to the image surface
my Gnome::Cairo $context .= new(:surface($image-surface));

# create some path
$context.move-to( 10, 10);
$context.line-to( 10, 20);


my Gnome::Cairo::Path $path .= new(:native-object($context.copy-path));

$path.walk-path( PathHandling.new, 'mt', 'lt', 'ct', 'cp');
