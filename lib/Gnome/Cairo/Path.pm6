#TL:1:Gnome::Cairo::Path:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Path

=end pod

#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::TopLevelClassSupport;

use Gnome::Cairo::Enums;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo::Path:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
our class cairo_path_data_header_t is repr('CStruct') {
  has uint32 $.type;
  has int32 $.length;
}

our class cairo_path_data_point_t is repr('CStruct') {
  has num64 $.x is rw;
  has num64 $.y is rw;
}

our class cairo_path_data_t is repr('CUnion') is export {
  HAS cairo_path_data_header_t $.header;
  HAS cairo_path_data_point_t $.point;

  method data-type { PathDataTypes( self.header.type ) }
  method length    { self.header.length                }
  method x is rw   { self.point.x                      }
  method y is rw   { self.point.y                      }
}

class cairo_path_t is repr('CStruct') is export {
  has uint32 $.status;   # cairo_path_data_type_t
  has Pointer[cairo_path_data_t] $.data;
  has int32 $.num_data;
}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 new()

Create a new Cairo::Path object.

  multi method new ( )

=end pod

#TM:1:new():
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Path' #`{{ or %options<> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists or %options<widget>:exists { }
    elsif %options<build-id>:exists { }

#`{{
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
      else {
#        $no = _gtk_drawing_area_new;
      }

      self.set-native-object($no);
    }
}}

    # only after creating the native-object, the gtype is known
#    self.set-class-info('GtkDrawingArea');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_path_$native-sub"); };
# check for gtk_, gdk_, g_, pango_, cairo_ !!!
#  try { $s = &::("gtk_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_path_' /;

#  self.set-class-name-of-sub('GtkDrawingArea');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_path_destroy ( cairo_path_t )
  is native(&cairo-lib)
  {*}

#  method destroy {
#    path_destroy(self);
#  }
