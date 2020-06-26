use v6;
#use lib '../gnome-native/lib';
#use NativeCall;

use Gnome::Cairo;
use Gnome::Cairo::Pattern;
use Gnome::Cairo::Path;
use Gnome::Cairo::ImageSurface;
use Gnome::Cairo::Enums;
use Gnome::Cairo::Types;

use Gnome::N::X;
#Gnome::N::debug(:on);

# http://zetcode.com/gfx/cairo/cairotext

sub natasha-beddingfield( Gnome::Cairo $cx ) {

  $cx.set-source-rgb( 0.1, 0.1, 0.1);

  $cx.select-font-face(
    "Z003", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD
  );

  $cx.set-font-size(18);

  for
     20, 30, "Most relationships seem so transitory",
     20, 60, "They're all good but not the permanent one",
     20, 120, "Who doesn't long for someone to hold",
     20, 150, "Who knows how to love you without being told",
     20, 180, "Somebody tell me why I'm on my own",
     20, 210, "If there's a soulmate for everyone"
     -> $x, $y, $text {

    $cx.move-to( $x, $y);
    $cx.show-text($text);
  }
}

# create an image surface
my Gnome::Cairo::ImageSurface $image-surface .= new(
  :format(CAIRO_FORMAT_ARGB32), :width(370), :height(240)
);

my Gnome::Cairo $cairo-context .= new(:surface($image-surface));
natasha-beddingfield($cairo-context);
$image-surface.write_to_png("xt/c3.png");   # save as png

$cairo-context.clear-object;
$image-surface.clear-object;
