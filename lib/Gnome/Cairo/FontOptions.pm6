#TL:0:Gnome::Cairo::FontOptions:

use v6;
#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::Cairo::FontOptions

How a font should be rendered

=comment ![](images/X.png)

=head1 Description

 The font options specify how fonts should be rendered.  Most of the  time the font options implied by a surface are just right and do not  need any changes, but for pixel-based targets tweaking font options  may result in superior output on a particular display.


=head2 See Also

B<cairo_scaled_font_t>

=head1 Synopsis
=head2 Declaration

  unit class Gnome::Cairo::FontOptions;
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
unit class Gnome::Cairo::FontOptions:auth<github:MARTIMM>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

=head3 new()

Create a new FontOptions object.

  multi method new ( )

=begin comment
Create a FontOptions object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

Create a FontOptions object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

  multi method new ( Str :$build-id! )
=end comment

=end pod

#TM:0:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::FontOptions' #`{{ or %options<CairoFontOptions> }} {

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
        $no = cairo_font_options_new();
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
  try { $s = &::("cairo_font_options_$native-sub"); };
  try { $s = &::("cairo_$native-sub"); } unless ?$s;
  try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

  $s = callsame unless ?$s;

  $s;
}

#-------------------------------------------------------------------------------
method native-object-ref ( $no ) {
#  _cairo_reference($no)
  $no
}

#-------------------------------------------------------------------------------
method native-object-unref ( $no ) {
  _cairo_destroy($no);
}

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_create:
=begin pod
=head2 cairo_font_options_create

Allocates a new font options object with all options initialized to default values.  Return value: a newly allocated B<cairo_font_options_t>. Free with C<cairo_font_options_destroy()>. This function always returns a valid pointer; if memory cannot be allocated, then a special error object is returned where all operations on the object do nothing. You can check for this with C<cairo_font_options_status()>.

  method cairo_font_options_create ( --> cairo_font_options_t )

=end pod

sub cairo_font_options_create (  --> cairo_font_options_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_copy:
=begin pod
=head2 cairo_font_options_copy

Allocates a new font options object copying the option values from I<original>.  Return value: a newly allocated B<cairo_font_options_t>. Free with C<cairo_font_options_destroy()>. This function always returns a valid pointer; if memory cannot be allocated, then a special error object is returned where all operations on the object do nothing. You can check for this with C<cairo_font_options_status()>.

  method cairo_font_options_copy ( --> cairo_font_options_t )

=end pod

sub cairo_font_options_copy ( cairo_font_options_t $original --> cairo_font_options_t )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_destroy:
=begin pod
=head2 cairo_font_options_destroy

Destroys a B<cairo_font_options_t> object created with C<cairo_font_options_create()> or C<cairo_font_options_copy()>.

  method cairo_font_options_destroy ( --> void )


=end pod

sub cairo_font_options_destroy ( cairo_font_options_t $options --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_status:
=begin pod
=head2 cairo_font_options_status

Checks whether an error has previously occurred for this font options object  Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO_MEMORY>

  method cairo_font_options_status ( --> Int )


=end pod

sub cairo_font_options_status ( cairo_font_options_t $options --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_merge:
=begin pod
=head2 cairo_font_options_merge

Merges non-default options from I<other> into I<options>, replacing existing values. This operation can be thought of as somewhat similar to compositing I<other> onto I<options> with the operation of C<CAIRO_OPERATOR_OVER>.

  method cairo_font_options_merge ( cairo_font_options_t $other --> void )

=item cairo_font_options_t $other; a B<cairo_font_options_t>

=end pod

sub cairo_font_options_merge ( cairo_font_options_t $options, cairo_font_options_t $other --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_equal:
=begin pod
=head2 cairo_font_options_equal

Compares two font options objects for equality.  Return value: C<1> if all fields of the two font options objects match. Note that this function will return C<0> if either object is in error.

  method cairo_font_options_equal ( cairo_font_options_t $other --> Int )

=item cairo_font_options_t $other; a B<cairo_font_options_t>

=end pod

sub cairo_font_options_equal ( cairo_font_options_t $options, cairo_font_options_t $other --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_hash:
=begin pod
=head2 cairo_font_options_hash

Compute a hash for the font options object; this value will be useful when storing an object containing a B<cairo_font_options_t> in a hash table.  Return value: the hash value for the font options object. The return value can be cast to a 32-bit type if a 32-bit hash value is needed.

  method cairo_font_options_hash ( --> UInt )


=end pod

sub cairo_font_options_hash ( cairo_font_options_t $options --> int64 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_set_antialias:
=begin pod
=head2 [cairo_font_options_] set_antialias

Sets the antialiasing mode for the font options object. This specifies the type of antialiasing to do when rendering text.

  method cairo_font_options_set_antialias ( Int $antialias --> void )

=item Int $antialias; a B<cairo_font_options_t>

=end pod

sub cairo_font_options_set_antialias ( cairo_font_options_t $options, int32 $antialias --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_get_antialias:
=begin pod
=head2 [cairo_font_options_] get_antialias

Gets the antialiasing mode for the font options object.  Return value: the antialiasing mode

  method cairo_font_options_get_antialias ( --> Int )


=end pod

sub cairo_font_options_get_antialias ( cairo_font_options_t $options --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_set_subpixel_order:
=begin pod
=head2 [cairo_font_options_] set_subpixel_order

Sets the subpixel order for the font options object. The subpixel order specifies the order of color elements within each pixel on the display device when rendering with an antialiasing mode of C<CAIRO_ANTIALIAS_SUBPIXEL>. See the documentation for B<cairo_subpixel_order_t> for full details.

  method cairo_font_options_set_subpixel_order ( Int $subpixel_order --> void )

=item Int $subpixel_order; a B<cairo_font_options_t>

=end pod

sub cairo_font_options_set_subpixel_order ( cairo_font_options_t $options, int32 $subpixel_order --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_get_subpixel_order:
=begin pod
=head2 [cairo_font_options_] get_subpixel_order

Gets the subpixel order for the font options object. See the documentation for B<cairo_subpixel_order_t> for full details.  Return value: the subpixel order for the font options object

  method cairo_font_options_get_subpixel_order ( --> Int )


=end pod

sub cairo_font_options_get_subpixel_order ( cairo_font_options_t $options --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_set_hint_style:
=begin pod
=head2 [cairo_font_options_] set_hint_style

Sets the hint style for font outlines for the font options object. This controls whether to fit font outlines to the pixel grid, and if so, whether to optimize for fidelity or contrast. See the documentation for B<cairo_hint_style_t> for full details.

  method cairo_font_options_set_hint_style ( Int $hint_style --> void )

=item Int $hint_style; a B<cairo_font_options_t>

=end pod

sub cairo_font_options_set_hint_style ( cairo_font_options_t $options, int32 $hint_style --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_get_hint_style:
=begin pod
=head2 [cairo_font_options_] get_hint_style

Gets the hint style for font outlines for the font options object. See the documentation for B<cairo_hint_style_t> for full details.  Return value: the hint style for the font options object

  method cairo_font_options_get_hint_style ( --> Int )


=end pod

sub cairo_font_options_get_hint_style ( cairo_font_options_t $options --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_set_hint_metrics:
=begin pod
=head2 [cairo_font_options_] set_hint_metrics

Sets the metrics hinting mode for the font options object. This controls whether metrics are quantized to integer values in device units. See the documentation for B<cairo_hint_metrics_t> for full details.

  method cairo_font_options_set_hint_metrics ( Int $hint_metrics --> void )

=item Int $hint_metrics; a B<cairo_font_options_t>

=end pod

sub cairo_font_options_set_hint_metrics ( cairo_font_options_t $options, int32 $hint_metrics --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_get_hint_metrics:
=begin pod
=head2 [cairo_font_options_] get_hint_metrics

Gets the metrics hinting mode for the font options object. See the documentation for B<cairo_hint_metrics_t> for full details.  Return value: the metrics hinting mode for the font options object

  method cairo_font_options_get_hint_metrics ( --> Int )


=end pod

sub cairo_font_options_get_hint_metrics ( cairo_font_options_t $options --> int32 )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_set_variations:
=begin pod
=head2 [cairo_font_options_] set_variations

Sets the OpenType font variations for the font options object. Font variations are specified as a string with a format that is similar to the CSS font-variation-settings. The string contains a comma-separated list of axis assignments, which each assignment consists of a 4-character axis name and a value, separated by whitespace and optional equals sign.  Examples:  wght=200,wdth=140.5  wght 200 , wdth 140.5

  method cairo_font_options_set_variations ( Str $variations --> void )

=item Str $variations; a B<cairo_font_options_t>

=end pod

sub cairo_font_options_set_variations ( cairo_font_options_t $options, Str $variations --> void )
  is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_get_variations:
=begin pod
=head2 [cairo_font_options_] get_variations

Gets the OpenType font variations for the font options object. See C<cairo_font_options_set_variations()> for details about the string format.  Return value: the font variations for the font options object. The returned string belongs to the I<options> and must not be modified. It is valid until either the font options object is destroyed or the font variations in this object is modified with C<cairo_font_options_set_variations()>.

  method cairo_font_options_get_variations ( --> Str )


=end pod

sub cairo_font_options_get_variations ( cairo_font_options_t $options --> Str )
  is native(&cairo-lib)
  { * }
