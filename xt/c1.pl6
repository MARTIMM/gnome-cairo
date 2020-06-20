use v6;
#use lib '../gnome-native/lib';

use Gnome::Cairo;
#use Gnome::Cairo::Pattern;
use Gnome::Cairo::ImageSurface;
use Gnome::Cairo::Enums;
use Gnome::Cairo::N-Types;

#use Gnome::N::X;
#Gnome::N::debug(:on);

my Gnome::Cairo::ImageSurface $png .= new(
  :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128)
);
my Gnome::Cairo $p .= new(:surface($png));

given $p {
  .set-source-rgb( 0, 0.7, 0.9);    # set color blue-ish
  .rectangle( 10, 10, '50', 50);    # set rectangle
  .fill_preserve;                   # and fill with set color

  .set-source-rgb( 0, 0, 0.9);      # set color blue
  .stroke;                          # draw as a border

  .set-source-rgb( 1/3, 1/3, 1/3);  # gray color
  .rectangle( 20, 20, '101', 101);  # set larger rectangle
  .set-line-width(4);
  .set-line-cap(CAIRO_LINE_CAP_ROUND);  # no effect?
  .stroke;                          # draw as a border

  .set-source-rgb( 0, 0, 0);        # black color
  .select-font-face(
    'fantasy', CAIRO_FONT_SLANT_ITALIC, CAIRO_FONT_WEIGHT_BOLD
  );                                # set font
  .set-font-size(1.2);              # font size
  my Str $text = 'abc';
  my cairo_text_extents_t $te = .cairo_text_extents($text);
  .move-t( 0.5 - $te.width / 2 - $te.x_bearing,
           0.5 - $te.height / 2 - $te.y_bearing
  );

  .show-text($text);
}

$png.surface_write_to_png("xt/c1.png");
$p.clear-object;
