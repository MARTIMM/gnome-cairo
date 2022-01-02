#TL:1:Gnome::Cairo::Path:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::Path

Creating paths and manipulating path data

=comment ![](images/X.png)

=head1 Description

Paths are the most basic drawing tools and are primarily used to implicitly generate simple masks.


=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo::Path;
  also is Gnome::N::TopLevelClassSupport;


=head2 Example

  my Gnome::Cairo $context;
  my Gnome::Cairo::ImageSurface $surface;
  my Gnome::Cairo::Path $path;

  $surface .= new(
    :format(CAIRO_FORMAT_RGB24), :width(128), :height(128)
  );
  $context .= new(:$surface);

  $path .= new(:native-object($context.copy-path));


=end pod
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::TopLevelClassSupport;

use Gnome::Cairo::Types;
use Gnome::Cairo::Enums;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo::Path:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 :native-object

There is only one way to create a Path object and that is by importing a native object.

  multi method new ( N-GObject :$native-object! )

=end pod

#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

#print "\n", '-' x 80, "\nThis class is deprecated. All path operations can be done with Gnome::Cairo::Cairo\n", '-' x 80, "\n";

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Path' #`{{ or %options<CairoPath> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    else {
      my $no;
      if ? %options<_x_> {
        #$no = %options<_x_>;
        #$no .= _get-native-object-no-reffing
        #   if $no.^can('_get-native-object-no-reffing');
        #$no = ...($no);
      }

      ##`{{ use this when the module is not made inheritable
      # check if there are unknown options
      elsif %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }
      #}}

      ##`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      #}}

      #`{{ when there are defaults use this instead
      # create default object
      else {
        $no = cairo_path_new();
      }
      }}

      self._set-native-object($no);
    }

    # only after creating the native-object
#    self._set-class-info('Path');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_path_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

#  self._set-class-name-of-sub('Path');
  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
method native-object-ref ( $no ) {
  $no
}

#-------------------------------------------------------------------------------
method native-object-unref ( $no ) {
  _cairo_path_destroy($no);
}

#-------------------------------------------------------------------------------
#TM:1:length:
=begin pod
=head2 length

Return the length of the data array in the C<cairo_path_t> structure.

  method length ( --> UInt )

=end pod

method length ( --> UInt ) {
  self._get-native-object-no-reffing.num_data
}

#-----------------------------------------------------------------------------
# Convenience method to walk over the set of parts in a path.
=begin pod
=head2 walk-path

A convenience method to walk over the set of parts in a path. The method will go through the elements of he path and calls user methods in an object given by the user to let the user process specific parts in the path.

  method walk-path (
    Any:D $user-object, Str:D $move-to, Str:D $line-to,
    Str:D $curve-to, Str:D $close-path
  }

C<$move-to>, C<$line-to>, C<$curve-to> and C<$close-path> are the names of the methods defined in C<$user-object>.

=end pod

#TM:1:walk-path:
method walk-path (
  Any:D $user-object, Str:D $move-to, Str:D $line-to,
  Str:D $curve-to, Str:D $close-path
) {

  my cairo_path_t $path = self._get-native-object;
  if $path.status !~~ CAIRO_STATUS_SUCCESS {
    self.clear-object;
    X::Gnome.new(:message('Path is not valid'));
  }

  my $length = $path.num_data;
  my $i = 0;
  loop {

    my cairo_path_data_header_t $dh = $path.data[$i].header;

    with $dh.type {
      when CAIRO_PATH_MOVE_TO {
        my cairo_path_data_point_t $dp = $path.data[$i+1].point;
        $user-object."$move-to"($dp);
      }

      when CAIRO_PATH_LINE_TO {
        my cairo_path_data_point_t $dp = $path.data[$i+1].point;
        $user-object."$line-to"($dp);
      }

      when CAIRO_PATH_CURVE_TO {
        $user-object."$curve-to"(
          $path.data[$i + 1].point, $path.data[$i + 2].point,
          $path.data[$i + 3].point
        );
      }

      when CAIRO_PATH_CLOSE_PATH {
        $user-object."$close-path"();
      }
    }

    $i += $dh.length;

    last if $i >= $length;
  }
}

#-------------------------------------------------------------------------------
#TM:1:status:
=begin pod
=head2 status

Return status from the path structure C<cairo_path_t>.

  method status ( --> cairo_status_t )

=end pod

method status ( --> cairo_status_t ) {
  cairo_status_t(self._get-native-object-no-reffing.status)
}

#-------------------------------------------------------------------------------
#TM:0:_cairo_path_destroy:
#`{{
=begin pod
=head2 cairo_path_destroy

Immediately releases all memory associated with path. After a call to cairo_path_destroy() the path pointer is no longer valid and should not be used further.

Note: cairo_path_destroy() should only be called with a pointer to a cairo_path_t returned by a cairo function. Any path that is created manually (ie. outside of cairo) should be destroyed manually as well.

  method cairo_path_destroy ( )


=end pod
}}

sub _cairo_path_destroy ( cairo_path_t $path )
  is native(&cairo-lib)
  is symbol('cairo_path_destroy')
  { * }
