#TL:1:Gnome::Cairo::Matrix:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Matrix

=end pod

#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
#use Gnome::N::N-GObject;
use Gnome::N::TopLevelClassSupport;

#use Gnome::Cairo::Enums;

unit class Gnome::Cairo::Matrix:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#TT:0::
=begin pod
=end pod

our class cairo_matrix_t is repr('CStruct') is export {
  has num64 $.xx;
  has num64 $.yx;
  has num64 $.xy;
  has num64 $.yy;
  has num64 $.x0;
  has num64 $.y0;
}

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
  try { $s = &::("cairo_matrix_$native-sub"); };
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_matrix_' /;

#  self.set-class-name-of-sub('Cairo');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub init (
  cairo_matrix_t $matrix,
  num64 $xx, num64 $yx, num64 $xy, num64 $yy, num64 $x0, num64 $y0
)
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_matrix_scale ( cairo_matrix_t $matrix, num64 $sx, num64 $sy )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_matrix_translate ( cairo_matrix_t $matrix, num64 $tx, num64 $ty )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_matrix_rotate ( cairo_matrix_t $matrix, cairo_matrix_t $b )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_matrix_invert ( cairo_matrix_t $matrix )
  is native(&cairo-lib)
  {*}

#-------------------------------------------------------------------------------
#TM:0::
=begin pod
=end pod

sub cairo_matrix_multiply (
  cairo_matrix_t $matrix, cairo_matrix_t $a, cairo_matrix_t $b
) is native(&cairo-lib)
  {*}
