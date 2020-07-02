#TL:0:Gnome::Cairo::Path:

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

=comment head2 Example

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
=end pod

#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Path' #`{{ or %options<CairoPath> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }
#`{{
    else {
      my $no;
      # if ? %options<> {
      #   $no = %options<>;
      #   $no .= get-native-object-no-reffing
      #     if $no.^can('get-native-object-no-reffing');
      #   $no = ...($no);
      # }

      #`{{ use this when the module is not made inheritable
      # check if there are unknown options
      elsif %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }
      }}

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      #`{{ when there are defaults use this instead
      # create default object
      else {
        $no = cairo_path_new();
      }
      }}

      self.set-native-object($no);
    }
}}

    # only after creating the native-object
    self.set-class-info('CairoPath');
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_path_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

  self.set-class-name-of-sub('CairoPath');
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



#TM:0:walk-path:
method walk-path (
  Any:D $user-object, Str:D $move-to, Str:D $line-to,
  Str:D $curve-to, Str:D $close-path
) {

  my cairo_path_t $path = self.get-native-object;
  if $path.status !~~ CAIRO_STATUS_SUCCESS {
    self.clear-object;
    X::Gnome.new(:message('Path is not valid'));
  }

  my $length = $path.num_data;
  my $i = 0;
  loop {

    my cairo_path_data_header_t $dh = $path.data[$i].header;

    given $$dh.type {
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
#TM:0:_cairo_path_destroy:
#`{{
=begin pod
=head2 cairo_path_destroy

Paths are the most basic drawing tools and are primarily used to implicitly generate simple masks. cairo_path_destroy: C<cairo_copy_path_flat()>.  Immediately releases all memory associated with I<path>. After a call to C<cairo_path_destroy()> the I<path> pointer is no longer valid and should not be used further.  Note: C<cairo_path_destroy()> should only be called with a pointer to a B<cairo_path_t> returned by a cairo function. Any path that is created manually (ie. outside of cairo) should be destroyed manually as well.

  method cairo_path_destroy ( --> void )


=end pod
}}

sub _cairo_path_destroy ( cairo_path_t $path --> void )
  is native(&cairo-lib)
  is symbol('cairo_path_destroy')
  { * }
