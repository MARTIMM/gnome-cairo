#TL:1:Gnome::Cairo::Surface:
use v6;
use NativeCall;

# Hijacked project Cairo of Timo

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo::Surface:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
class cairo_surface_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Cairo' #`{{ or %options<GtkDrawingArea> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists or %options<widget>:exists { }
    elsif %options<build-id>:exists { }

    else {
      my $no;
      # if ? %options<> {
      #   $no = %options<>;
      #   $no .= get-native-object-no-reffing
      #     if $no.^can('get-native-object-no-reffing');
      #   $no = ...($no);
      # }

      # use this when the module is not made inheritable
      # check if there are unknown options
      if %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      # create default object
#      else {
#        $no = _gtk_drawing_area_new;
#      }

      self.set-native-object($no);
    }

#    # only after creating the native-object, the gtype is known
#    self.set-class-info('Cairo');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_surface_$native-sub"); };
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_surface' /;

#  self.set-class-name-of-sub('Cairo');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_status ( --> uint32 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_write_to_png ( Str $filename --> int32 )
  is native(&cairo-lib)
  {*}

#`{{
#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_write_to_png_stream(
  &write-func (StreamClosure, Pointer[uint8], uint32 --> int32),
  StreamClosure
  --> int32
) is native(&cairo-lib)
  {*}
}}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_reference ( --> cairo_surface_t )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_show_page
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_flush
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_finish
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_destroy
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_get_image_data ( --> OpaquePointer )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_get_image_stride ( --> int32 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_get_image_width ( --> int32 )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_surface_get_image_height ( --> int32 )
  is native(&cairo-lib)
  {*}
