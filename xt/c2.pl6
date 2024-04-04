use v6;
#use lib '../gnome-native/lib';

use Gnome::Cairo::ImageSurface:api<1>;
use Gnome::Cairo;
use Gnome::Cairo::Pattern:api<1>;
use Gnome::Cairo::Path:api<1>;
use Gnome::Cairo::Enums:api<1>;
use Gnome::Cairo::Types:api<1>;

use Gnome::N::X:api<1>;
#Gnome::N::debug(:on);

# badly formatted Python example
# https://cairo.cairographics.narkive.com/5kDQTMXr/render-text-along-path

class PathHandling {
  has Gnome::Cairo $!context;
  has Str $!path-function;
  has Bool $!first = True;
  has Int $!width;
  has Int $!height;
  has Num $!text-width;
#  has Num $!text-height;
  has cairo_text_extents_t $!text-extents;

  submethod BUILD (
    Gnome::Cairo :$!context, Str :$!path-function,
    Int :$!width, Int :$!height,
    #cairo_text_extents_t :$text-extents
     :$text-extents
  ) {
    # the curl method needs the text width. height isn't used
    if $text-extents.defined {
      $!text-width = $text-extents.width;
#      $!text-height = $text-extents.height;
    }
  }

  method mt ( cairo_path_data_point_t $p1 ) {
#  method mt (  $p1 ) {
#    note "  move to Px: ", $p1.x, ', ', $p1.y;

    if $!first {
      $!context.new-path;
      $!first = False;
    }

    $!context.move-to( |self."$!path-function"( $p1.x, $p1.y));
  }

  method lt ( cairo_path_data_point_t $p1 ) {
#  method lt (  $p1 ) {
#    note "  line to Px: ", $p1.x, ', ', $p1.y;
    $!context.line-to( |self."$!path-function"( $p1.x, $p1.y));
  }

  method ct (
    cairo_path_data_point_t $p1, cairo_path_data_point_t $p2,
    cairo_path_data_point_t $p3
  ) {
#  method ct (     $p1,  $p2,     $p3  ) {
#    note "  curve to Px: ", $p1.x, ', ', $p1.y, ', ', $p2.x, ', ',
#      $p2.y, ', ', $p3.x, ', ', $p3.y;
    $!context.curve-to(
      |self."$!path-function"( $p1.x, $p1.y),
      |self."$!path-function"( $p2.x, $p2.y),
      |self."$!path-function"( $p3.x, $p3.y)
    );
  }

  method cp ( ) {
#    note "  close path, no points";
    $!context.close-path;
  }

  method spiral ( $x, $y --> List ) {
    my $theta = $x / $!width * π * 2 - π * 3/4;
    my $radius = $y + 200 - $x/7;
    my $xnew = $radius * cos($theta);
    my $ynew = $radius * sin(-$theta);

    ( $xnew + $!width/2, $ynew + $!height/2)
  }

  method curl ( $x, $y --> List ) {
    my $xn = $x - $!text-width/2;
    #my $yn = y - $!text-width/2;
    my $xnew = $xn;
    my $ynew = $y + $xn ** 3 / (($!text-width/2)**3) * 70;

    ( $xnew + $!width/2, $ynew + $!height * 2/5)
  }
}


my Int ( $width, $height) = ( 512, 512 );

sub warpPath (
  Gnome::Cairo $context, Str $path-function,
  #cairo_text_extents_t :$text-extents
   :$text-extents
) {

  my Gnome::Cairo::Path $path .= new(:native-object($context.copy-path));
  $path.walk-path(
    PathHandling.new(
      :$context, :$path-function, :$width, :$height, :$text-extents
    ), 'mt', 'lt', 'ct', 'cp'
  );
}


my Gnome::Cairo::ImageSurface $image-surface .= new(
  :format(CAIRO_FORMAT_ARGB32), :$width, :$height
);
my Gnome::Cairo $cairo-context .= new(:surface($image-surface));
my Gnome::Cairo::Pattern $solid-pattern .= new(
  :native-object($cairo-context.get-source)
);

# background
my Gnome::Cairo::Pattern $pat .= new(:linear( 0, 0, 0, $height));
$pat.add-color-stop-rgba( 1, 0, 0, 0, 1);
$pat.add-color-stop-rgba(0, 1, 1, 1, 1);

$cairo-context.rectangle( 0, 0, $width, $height);
$cairo-context.set-source($pat);
$cairo-context.fill;

# foreground
#Gnome::N::debug(:on);
$cairo-context.set-source($solid-pattern);
$cairo-context.set-source-rgb( 1, 1, 1);

$cairo-context.select-font-face(
  "Sans", CAIRO_FONT_SLANT_ITALIC, CAIRO_FONT_WEIGHT_BOLD
);
$cairo-context.set-font-size(80);

# spiral text
$cairo-context.new-path;
$cairo-context.move-to( 0, 0);
$cairo-context.text-path('Raku Cairo Library');
warpPath( $cairo-context, 'spiral');
$cairo-context.fill;

# curly text
$cairo-context.new-path;
$cairo-context.move-to( 0, 0);
$cairo-context.set-source-rgb( 0.3, 0.3, 0.3);
my Str $text = "I am curly";
$cairo-context.text-path($text);
warpPath(
  $cairo-context, 'curl', :text-extents($cairo-context.text-extents($text))
);
$cairo-context.fill;

$image-surface.write-to-png("xt/data/c2.png");   # save as png

$cairo-context.clear-object;
$image-surface.clear-object;
