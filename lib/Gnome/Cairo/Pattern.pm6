#TL:1:Gnome::Cairo::Pattern:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Pattern

=end pod

#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
#use Gnome::N::N-GObject;
use Gnome::N::TopLevelClassSupport;

use Gnome::Cairo::Matrix;

unit class Gnome::Cairo::Pattern:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#TT:0::
=begin pod
=end pod

class cairo_pattern_t
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
#TM:0::
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Cairo' #`{{ or %options<GtkDrawingArea> }} {

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
#      else {
#        $no = _gtk_drawing_area_new;
#      }

#      self.set-native-object($no);
    }
}}

#    # only after creating the native-object, the gtype is known
#    self.set-class-info('Cairo');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_pattern_$native-sub"); };
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_pattern_' /;

#  self.set-class-name-of-sub('Cairo');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_pattern_destroy ( )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_pattern_get_extend ( )
  returns int32
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_pattern_set_extend ( uint32 $extend )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_pattern_set_matrix ( cairo_matrix_t $matrix )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_pattern_get_matrix ( cairo_matrix_t $matrix )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_pattern_add_color_stop_rgb (
  num64 $offset, num64 $r, num64 $g, num64 $b
  --> int32
) is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_pattern_add_color_stop_rgba (
  num64 $offset, num64 $r, num64 $g, num64 $b, num64 $a
  --> int32
) is native(&cairo-lib)
  {*}
