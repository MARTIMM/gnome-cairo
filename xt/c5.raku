#!/usr/bin/env raku

use v6;
#use lib '../gnome-native/lib';
#use lib '../gnome-gtk3/lib';
#use lib '../gnome-gdk3/lib';

use Gnome::Cairo::ImageSurface;
use Gnome::Cairo;
use Gnome::Cairo::Pattern;
use Gnome::Cairo::Enums;
use Gnome::Cairo::Types;
use Gnome::Cairo::Surface;

use Gnome::Glib::Error;

use Gnome::Gdk3::Events;
use Gnome::Gdk3::Window;
use Gnome::Gdk3::Pixbuf;

use Gnome::Gtk3::Main;
#use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Window;
use Gnome::Gtk3::Button;
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

    note "X valid: ", $!surface.is-valid;
    note "X surface state: ", cairo_status_t($!surface.status);
    note "X surface type: ", cairo_surface_type_t($!surface.get-type);
    note "X surface content: ", cairo_content_t($!surface.get-content);
    note "X surface device: ", $!surface.get-device;

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
    given Gnome::Cairo.new(:$!surface) {
      .set-source-rgb( 1, 1, 1);
      .paint;

      .select-font-face(
        "Z003", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD
      );

      my Int $font-size = 80;
      .set-source-rgb( 0.4, 0.0, 0.0);
      .set-font-size($font-size);

      my Str $zetcode = 'ZetCode';
      #my $te = .text-extents($zetcode);
      my cairo_text_extents_t $te .= new(
        :native-object(.text-extents($zetcode))
      );
      .move-to( $!width / 2 - $te.width / 2, $!height / 2);
      .show-text($zetcode);

      given my Gnome::Cairo::Pattern $pattern .= new(
        :linear( 0, 15, 0, $font-size * 0.8)
      ) {
        .set_extend(CAIRO_EXTEND_REPEAT);
        .add-color-stop-rgb( 0.0, 1, 0.6, 0);
        .add-color-stop-rgb( 0.5, 1, 1, 0);
      }

      .move-to( $!width / 2 - $te.width / 2 + 3, $!height / 2 + 3);
      .text-path($zetcode);
      .set-source($pattern);
      .fill;

      .clear-object;
    }

    1;
  }

  #-----------------------------------------------------------------------------
  # Called by the draw signal after chaging or uncovering the window.
  method redraw ( cairo_t $n-cx, --> Int ) {

    # we have received a cairo context in which our surface must be set.
    given Gnome::Cairo.new(:native-object($n-cx)) {
      .set-source-surface( $!surface, 0, 0);

      # just repaint the whole scenery
      .paint;
      .clear-object;
    }

    1
  }

  #-----------------------------------------------------------------------------
  method exit ( Gnome::Gtk3::Main :$main ) {
    $main.gtk-main-quit;
  }
}


#-------------------------------------------------------------------------------
class Y {
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

#    $!surface.set-device-scale( 0.7, 0.7);

    note "Y valid: ", $!surface.is-valid;
    note "Y surface state: ", cairo_status_t($!surface.status);
    note "Y surface type: ", cairo_surface_type_t($!surface.get-type);
    note "Y surface content: ", cairo_content_t($!surface.get-content);
    note "Y surface device: ", $!surface.get-device;

    $!initialized = True;
  }

  #-----------------------------------------------------------------------------
  # Called by the draw signal after changing or uncovering the window.
  method redraw ( cairo_t $n-cx, :$widget-to-draw --> Int ) {

    self.init;

    # we have received a cairo context in which our surface must be set.
    given my Gnome::Cairo $cairo-context .= new(:native-object($n-cx)) {
      .set-source-surface( $!surface, 0, 0);

      # first transfor user space
      .scale( 0.7, 0.7);
      .rotate(0.6);

      # then do the drawing and paint
      $widget-to-draw.draw($cairo-context);
      .paint;
      .clear-object;
    }

    1
  }

  #-----------------------------------------------------------------------------
  # Called by the button click event.
  method save-picture ( ) {

    self!save-to-png;
    self!save-to-jpeg;
  }

  #-----------------------------------------------------------------------------
  method !save-to-png ( ) {

    my Gnome::Cairo::ImageSurface $image-surface .= new(
      :format(CAIRO_FORMAT_ARGB32), :width($!width), :height($!height)
    );

    my Gnome::Cairo $cairo-context .= new(:surface($image-surface));
    $!drawing-area.draw($cairo-context);
    $image-surface.write_to_png("xt/data/c5.png");

    $cairo-context.clear-object;
    $image-surface.clear-object;
  }

  #-----------------------------------------------------------------------------
  method !save-to-jpeg ( ) {

    my Gnome::Cairo::ImageSurface $image-surface .= new(
      :format(CAIRO_FORMAT_ARGB32), :width($!width), :height($!height)
    );

    my Gnome::Cairo $cairo-context .= new(:surface($image-surface));
    $!drawing-area.draw($cairo-context);

    my Gnome::Gdk3::Pixbuf $pb .= new(
      :surface($image-surface), :clipto( 0, 0, $!width, $!height)
    );

    my Gnome::Glib::Error $e = $pb.savev(
      'xt/data/c5.jpg', 'jpeg', ["quality",], ["100",]
    );

    note $e.is-valid;
  }
}


#-------------------------------------------------------------------------------

my Gnome::Gtk3::Main $m .= new;

given Gnome::Gtk3::Window.new {
  .set-title('My Drawing In My Window');
  .set-position(GTK_WIN_POS_MOUSE);
  .set-size-request( 600, 300);

  my Gnome::Gtk3::Frame $f .= new(:label('My Drawing'));
  .gtk-container-add($f);

  my Gnome::Gtk3::Grid $g .= new;
  $f.gtk-container-add($g);


  my Gnome::Gtk3::DrawingArea $da1 .= new;
  my X $x .= new(:drawing-area($da1));
  #$da.set-size-request( 300, 100);
  $da1.set-hexpand(True);
  $da1.set-vexpand(True);

  $g.grid-attach( $da1, 0, 0, 1, 1);

  .register-signal( $x, 'exit', 'destroy', :main($m));

  $da1.register-signal( $x, 'make-drawing', 'realize');
  $da1.register-signal( $x, 'modify-drawing', 'configure-event');
  $da1.register-signal( $x, 'redraw', 'draw');

  my Gnome::Gtk3::DrawingArea $da2 .= new;
  my Y $y .= new(:drawing-area($da2));
  $g.grid-attach( $da2, 1, 0, 1, 2);
  #$da2.set-size-request( 300, 100);
  $da2.set-hexpand(True);
  $da2.set-vexpand(True);

  my Gnome::Gtk3::Button $b .= new(:label<Save>);
  $g.grid-attach( $b, 0, 1, 1, 1);
  $b.register-signal( $y, 'save-picture', 'clicked');
  $da2.register-signal( $y, 'redraw', 'draw', :widget-to-draw($f));

  .show-all;
}

$m.gtk-main;
