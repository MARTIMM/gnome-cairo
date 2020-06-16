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

use Gnome::Cairo::N-Types;
use Gnome::Cairo::Enums;

#-------------------------------------------------------------------------------
unit class Gnome::Cairo::Path:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 new()

Create a new Path object.

  multi method new ( )

=begin comment
Create a Path object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

Create a Path object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )
=end comment

=end pod

#TM:0:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::Path' #`{{ or %options<CairoPath> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

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
  }
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method _fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::("cairo_path_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

  $s = callsame unless ?$s;

  $s;
}


#-------------------------------------------------------------------------------
#TM:0:cairo_path_destroy:
=begin pod
=head2 cairo_path_destroy

Paths are the most basic drawing tools and are primarily used to implicitly generate simple masks. cairo_path_destroy: C<cairo_copy_path_flat()>.  Immediately releases all memory associated with I<path>. After a call to C<cairo_path_destroy()> the I<path> pointer is no longer valid and should not be used further.  Note: C<cairo_path_destroy()> should only be called with a pointer to a B<cairo_path_t> returned by a cairo function. Any path that is created manually (ie. outside of cairo) should be destroyed manually as well.

  method cairo_path_destroy ( --> void )


=end pod

sub cairo_path_destroy ( cairo_path_t $path --> void )
  is native(&cairo-lib)
  { * }
