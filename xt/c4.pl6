#!/usr/bin/env raku

use v6;
#use lib '../gnome-native/lib';
use lib '../gnome-gdk3/lib';

use Gnome::Cairo;
use Gnome::Cairo::Pattern;
use Gnome::Cairo::ImageSurface;
use Gnome::Cairo::Enums;
use Gnome::Cairo::Types;
use Gnome::Cairo::Surface;

#use Gnome::N::N-GObject;
use Gnome::Gdk3::Events;
use Gnome::Gdk3::Window;

use Gnome::Gtk3::Main;
#use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Window;
#use Gnome::Gtk3::Image;
use Gnome::Gtk3::DrawingArea;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
# see also http://zetcode.com/gfx/cairo/cairotext/
# and https://developer.gnome.org/gtk3/stable/ch01s05.html

#-------------------------------------------------------------------------------
class X {
  has Gnome::Gtk3::DrawingArea $!drawing-area;
  has Gnome::Cairo::Surface $!surface;
  has Int $!width;
  has Int $!height;
  has Bool $!initialized;

  #-----------------------------------------------------------------------------
  # Store the drawing area. Used to get the surface later.
  submethod BUILD ( Gnome::Gtk3::DrawingArea:D :$!drawing-area ) { }

  #-----------------------------------------------------------------------------
  # When the garbage collector arrives here, cleanup the surface.
  submethod DESTROY ( ) {
    $!surface.clear-object if $!initialized;
  }

  #-----------------------------------------------------------------------------
  method init ( ) {
    # cleanup first when initialized
    $!surface.clear-object if $!initialized;

    $!width = $!drawing-area.get-allocated-width;
    $!height = $!drawing-area.get-allocated-height;
    note "width & height: $!width x $!height";

    # we need a GdkWindow to get a cairo surface to draw on
    my Gnome::Gdk3::Window $window .= new(:native-object(
      $!drawing-area.get-window)
    );

    # this is the surface to splash our paint on
    $!surface .= new(
      :native-object(
        $window.create-similar-surface(
          CAIRO_CONTENT_COLOR_ALPHA, $!width, $!height
        )
      )
    );

    note "valid: ", $!surface.is-valid;
    note "surface state: ", cairo_status_t($!surface.status);
    note "surface type: ", cairo_surface_type_t($!surface.get-type);
    note "surface content: ", cairo_content_t($!surface.get-content);
    note "surface device: ", $!surface.get-device;

    $!initialized = True;
  }

  #-----------------------------------------------------------------------------
  # Called by the configure-event event when window is changed or uncovered.
  method modify-drawing ( GdkEventConfigure $event --> Int ) {

    # change surface
    self.init;

    # redraw
    self.make-drawing;
  }

  #-----------------------------------------------------------------------------
  # First called by the realize event. Later it is called by modify-drawing().
  method make-drawing ( --> Int ) {

    # init if not done yet
    self.init unless $!initialized;

    # the context is created from the current surface. nothing is yet visible
    given my Gnome::Cairo $cairo-context .= new(:$!surface) {
      .set-source-rgb( 1, 1, 1);
      .paint;

      .select-font-face(
        "Z003", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD
      );

      my Int $font-size = 80;
      .set-source-rgb( 0.4, 0.0, 0.0);
      .set-font-size($font-size);

      my Str $zetcode = 'ZetCode';
      #my $te = $cairo-context.text-extents($zetcode);
      my cairo_text_extents_t $te = .text-extents($zetcode);
      .move-to(
        $!width / 2 - $te.width / 2,
        $!height / 2 #+ $te.height / 2
      );
      .show-text($zetcode);

      given my Gnome::Cairo::Pattern $pattern .= new(
        :linear( 0, 15, 0, $font-size * 0.8)
      ) {
        .set_extend(CAIRO_EXTEND_REPEAT);
        .add-color-stop-rgb( 0.0, 1, 0.6, 0);
        .add-color-stop-rgb( 0.5, 1, 1, 0);
      }

      .move-to(
        $!width / 2 - $te.width / 2 + 3,
        $!height / 2 + 3 # + $te.height / 2
      );
      .text-path($zetcode);
      .set-source($pattern);
      .fill;

      .clear-object;
    }

    1;
  }

  #-----------------------------------------------------------------------------
  # Called by the draw signal after changing the window.
  method redraw ( cairo_t $n-cx, --> Int ) {

    # we have received a cairo context in which our surface must be set.
    given my Gnome::Cairo $cairo-context .= new(:native-object($n-cx)) {
      .set-source-surface( $!surface, 0, 0);

      # just repaint the whole scenery
      .paint;
    }

    1
  }

  #-----------------------------------------------------------------------------
  method exit ( Gnome::Gtk3::Main :$main ) {
    $main.gtk-main-quit;
  }
}

#-------------------------------------------------------------------------------
my Gnome::Gtk3::Main $m .= new;

given my Gnome::Gtk3::Window $top-window .= new {
  .set-title('My Drawing In My Window');
  .set-position(GTK_WIN_POS_MOUSE);
  .set-size-request( 300, 200);

  my Gnome::Gtk3::Frame $f .= new(:label('My Drawing'));
  .gtk-container-add($f);

  my Gnome::Gtk3::DrawingArea $da .= new;
  my X $x .= new(:drawing-area($da));
  $f.gtk-container-add($da);

  .register-signal( $x, 'exit', 'destroy', :main($m));
  $da.register-signal( $x, 'make-drawing', 'realize');
  $da.register-signal( $x, 'modify-drawing', 'configure-event');
  $da.register-signal( $x, 'redraw', 'draw');
  .show-all;
}

$m.gtk-main;
