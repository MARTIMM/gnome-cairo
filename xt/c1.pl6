use v6;
#use lib '../gnome-native/lib';
#use NativeCall;

use Gnome::Cairo::ImageSurface;
use Gnome::Cairo;
use Gnome::Cairo::Pattern;
use Gnome::Cairo::Enums;
use Gnome::Cairo::Types;

#use Gnome::N::X;
#Gnome::N::debug(:on);

# See also https://www.cairographics.org/tutorial/

# create an image surface
my Gnome::Cairo::ImageSurface $image-surface .= new(
  :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128)
);

# tie a cairo context to the image surface
my Gnome::Cairo $cairo-context .= new(:surface($image-surface));

given $cairo-context {
  .set-source-rgb( 0, 0.7, 0.9);          # set color blue-ish
  .rectangle( 10, 10, '50', 50);          # set rectangle
  .fill_preserve;                         # and fill with set color

  .set-source-rgb( 0, 0, 0.9);            # set color blue
  .stroke;                                # draw as a border


  .set-source-rgba( 1/4, 1/4, 1/4, 0.5);  # gray color
  .rectangle( 20, 20, '101', 101);        # set larger rectangle
  .set-dash( [ 5, 5, 10, 15], 1, 0);
#  note "dash status: ", cairo_status_t(.status);
  .set-line-width(4);
  .set-line-cap(CAIRO_LINE_CAP_ROUND);    # end of a line set round
  .set-line-join(CAIRO_LINE_JOIN_ROUND);  # corners are round
  .stroke;                                # draw as a border


  .set-source-rgb( 0, 0, 0);              # black color
  .select-font-face(
    'helvetica', CAIRO_FONT_SLANT_ITALIC, CAIRO_FONT_WEIGHT_BOLD
  );                                      # set font
  .set-font-size(30);                     # font size
  my Str $text = 'abc';                   # move to coords
#  my cairo_text_extents_t $te = .cairo_text_extents($text);
  my  $te = .cairo_text_extents($text);
  .move-to( 58 - $te.width / 2 - $te.x_bearing,
           100 - $te.height / 2 - $te.y_bearing
  );
  .show-text($text);                      # and show text


  .set-source-rgba( 1, .5, 0, 0.8);       # orange color. start at end of text
  .curve-to( 120, 120, 120, 20, 60, 10);  # bezier curve
  .set-line-width(1);                     # change width
  .set-dash( [ ], 0, 0);                  # turn of dashing
  .stroke;


  # try to understand some patterns and mask
  my Gnome::Cairo::Pattern $linpat .= new(:linear( 128, 0, 0, 128));
  $linpat.add-color-stop-rgb( 0, 0, 0.3, 0.8);
  $linpat.add-color-stop-rgb( 1, 0, 0.8, 0.3);
  my Gnome::Cairo::Pattern $radpat .= new(:radial( 85, 65, 10, 75, 55, 30));
  $radpat.add-color-stop-rgba( 0, 0, 0, 0, 1);
  $radpat.add-color-stop-rgba( 0.5, 0, 0, 0, 0);
  .set-source($linpat);
  .cairo-mask($radpat);
}

$image-surface.write_to_png("xt/data/c1.png");   # save as png

$cairo-context.clear-object;
$image-surface.clear-object;
