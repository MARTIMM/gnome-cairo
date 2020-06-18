use v6;
use lib '../gnome-native/lib';

use Gnome::Cairo;

use Gnome::Cairo::Pattern;
use Gnome::Cairo::ImageSurface;
use Gnome::Cairo::N-Types;
use Gnome::Cairo::Enums;
use Gnome::Cairo::Png;

my Gnome::Cairo::Pattern $p;
my Gnome::Cairo::ImageSurface $is;

$is .= new( :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128));
$p .= new(:surface($is));

given $p {
  .rgb(0, 0.7, 0.9);
  .rectangle(10, 10, 50, 50);
  .fill :preserve; .rgb(1, 1, 1);
  .stroke;
}

$is.write_png("xt/c1.png");





$p.clear-object;
