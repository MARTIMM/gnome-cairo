#TL:1:Gnome::Cairo::FontOptions:

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
use Gnome::N::GlibToRakuTypes;

use Gnome::Cairo::Types;
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


=head3 :native-object

Create a FontOptions object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

  multi method new ( N-GObject :$native-object! )

=end pod

#TM:1:new():
#TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
submethod BUILD ( *%options ) {

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Cairo::FontOptions' #`{{ or %options<FontOptions> }} {

    # check if native object is set by a parent class
    if self.is-valid { }

    # process all options

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    else {
      my $no;
      if ? %options<> {
#        $no = %options<>;
#        $no .= _get-native-object-no-reffing unless $no ~~ cairo_font_options_t;
#        $no = _.cairo_font_options_new_..($no);
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

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X::Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      ##`{{ when there are defaults use this instead
      # create default object
      else {
        $no = _cairo_font_options_create();
      }
      #}}

      self.set-native-object($no);
    }

    # only after creating the native-object
#    self._set-class-info('FontOptions');
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
  _cairo_font_options_destroy($no);
}

#-------------------------------------------------------------------------------
#TM:1:_cairo_font_options_create:
#`{{
=begin pod
=head2 cairo_font_options_create

Allocates a new font options object with all options initialized to default values.

Return value: a newly allocated B<cairo_font_options_t>. Free with C<cairo_font_options_destroy()>. This function always returns a valid pointer; if memory cannot be allocated, then a special error object is returned where all operations on the object do nothing. You can check for this with C<cairo_font_options_status()>.

  method cairo_font_options_create ( --> cairo_font_options_t )

=end pod
}}
sub _cairo_font_options_create ( --> cairo_font_options_t )
  is native(&cairo-lib)
  is symbol('cairo_font_options_create')
  { * }

#`{{
#-------------------------------------------------------------------------------
#TM:0:cairo_font_options_copy:
=begin pod
=head2 cairo_font_options_copy

Allocates a new font options object copying the option values from I<original>.

Return value: a newly allocated B<cairo_font_options_t>. Free with C<cairo_font_options_destroy()>. This function always returns a valid pointer; if memory cannot be allocated, then a special error object is returned where all operations on the object do nothing. You can check for this with C<cairo_font_options_status()>.

  method cairo_font_options_copy ( --> cairo_font_options_t )

=end pod

sub cairo_font_options_copy ( cairo_font_options_t $original --> cairo_font_options_t )
  is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:_cairo_font_options_destroy:
#`{{
=begin pod
=head2 cairo_font_options_destroy

Destroys a B<cairo_font_options_t> object created with C<cairo_font_options_create()> or C<cairo_font_options_copy()>.

  method cairo_font_options_destroy ( )

=end pod
}}

sub _cairo_font_options_destroy ( cairo_font_options_t $options )
  is native(&cairo-lib)
  is symbol('cairo_font_options_destroy')
  { * }

#-------------------------------------------------------------------------------
#TM:1:equal:
=begin pod
=head2 equal

Compares two font options objects for equality.

Return value: C<True> if all fields of the two font options objects match. Note that this function will return C<False> if either object is in error.

  method equal ( cairo_font_options_t $other --> Bool )

=item $other; another B<Gnome::Cairo::FontOptions>
=end pod

method equal ( $other is copy --> Bool ) {
  $other .= _get-native-object-no-reffing unless $other ~~ cairo_font_options_t;
  cairo_font_options_equal( self._get-native-object-no-reffing, $other).Bool
}

sub cairo_font_options_equal (
  cairo_font_options_t $options, cairo_font_options_t $other --> gboolean
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-antialias:
=begin pod
=head2 get-antialias

Gets the antialiasing mode for the font options object. Return value: the antialiasing mode

  method get-antialias ( --> cairo_antialias_t )

=end pod

method get-antialias ( --> cairo_antialias_t ) {
  cairo_antialias_t(
    cairo_font_options_get_antialias(self._get-native-object-no-reffing)
  )
}

sub cairo_font_options_get_antialias (
  cairo_font_options_t $options --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-hint-metrics:
=begin pod
=head2 get-hint-metrics

Gets the metrics hinting mode for the font options object. See the documentation for B<cairo-hint-metrics-t> for full details. Return value: the metrics hinting mode for the font options object

  method get-hint-metrics ( --> cairo_hint_metrics_t )

=end pod

method get-hint-metrics ( --> cairo_hint_metrics_t ) {
  cairo_hint_metrics_t(
    cairo_font_options_get_hint_metrics(self._get-native-object-no-reffing)
  )
}

sub cairo_font_options_get_hint_metrics (
  cairo_font_options_t $options --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-hint-style:
=begin pod
=head2 get-hint-style

Gets the hint style for font outlines for the font options object. See the documentation for B<cairo-hint-style-t> for full details.

Return value: the hint style for the font options object

  method get-hint-style ( --> cairo_hint_style_t )

=end pod

method get-hint-style ( --> cairo_hint_style_t ) {
  cairo_hint_style_t(
    cairo_font_options_get_hint_style(self._get-native-object-no-reffing)
  )
}

sub cairo_font_options_get_hint_style (
  cairo_font_options_t $options --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-subpixel-order:
=begin pod
=head2 get-subpixel-order

Gets the subpixel order for the font options object. See the documentation for B<cairo-subpixel-order-t> for full details.

Return value: the subpixel order for the font options object

  method get-subpixel-order ( --> cairo_subpixel_order_t )

=end pod

method get-subpixel-order ( --> cairo_subpixel_order_t ) {
  cairo_subpixel_order_t(
    cairo_font_options_get_subpixel_order(self._get-native-object-no-reffing)
  )
}

sub cairo_font_options_get_subpixel_order (
  cairo_font_options_t $options --> GEnum
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:get-variations:
=begin pod
=head2 get-variations

Gets the OpenType font variations for the font options object. See C<set-variations()> for details about the string format.

Return value: the font variations for the font options object. The returned string belongs to the I<options> and must not be modified. It is valid until either the font options object is destroyed or the font variations in this object is modified with C<set-variations()>.

  method get-variations ( --> Str )

=end pod

method get-variations ( --> Str ) {
  cairo_font_options_get_variations(self._get-native-object-no-reffing)
}

sub cairo_font_options_get_variations (
  cairo_font_options_t $options --> gchar-ptr
) is native(&cairo-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:hash:
=begin pod
=head2 hash

Compute a hash for the font options object; this value will be useful when storing an object containing a B<t> in a hash table. Return value: the hash value for the font options object. The return value can be cast to a 32-bit type if a 32-bit hash value is needed.

  method hash ( --> UInt )

=end pod

method hash ( --> UInt ) {

  cairo_font_options_hash(
    self._get-native-object-no-reffing,
  )
}

sub cairo_font_options_hash (
  cairo_font_options_t $options --> int64
) is native(&cairo-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:1:merge:
=begin pod
=head2 merge

Merges non-default options from I<$other> into I<options>, replacing existing values. This operation can be thought of as somewhat similar to compositing I<$other> onto I<options> with the operation of C<CAIRO-OPERATOR-OVER>.

  method merge ( cairo_font_options_t $other )

=item $other; another B<Gnome::Cairo::FontOptions>
=end pod

method merge ( $other is copy ) {
  $other .= _get-native-object-no-reffing unless $other ~~ cairo_font_options_t;
  cairo_font_options_merge( self._get-native-object-no-reffing, $other)
}

sub cairo_font_options_merge (
  cairo_font_options_t $options, cairo_font_options_t $other
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-antialias:
=begin pod
=head2 set-antialias

Sets the antialiasing mode for the font options object. This specifies the type of antialiasing to do when rendering text.

  method set-antialias ( cairo_antialias_t $antialias )

=item $antialias; the new antialiasing mode
=end pod

method set-antialias ( cairo_antialias_t $antialias ) {
  cairo_font_options_set_antialias(
    self._get-native-object-no-reffing, $antialias
  )
}

sub cairo_font_options_set_antialias (
  cairo_font_options_t $options, GEnum $antialias
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-hint-metrics:
=begin pod
=head2 set-hint-metrics

Sets the metrics hinting mode for the font options object. This controls whether metrics are quantized to integer values in device units. See the documentation for B<cairo-hint-metrics-t> for full details.

  method set-hint-metrics ( cairo_hint_metrics_t $hint_metrics )

=item $hint_metrics; the new metrics hinting mode
=end pod

method set-hint-metrics ( cairo_hint_metrics_t $hint_metrics ) {
  cairo_font_options_set_hint_metrics(
    self._get-native-object-no-reffing, $hint_metrics
  )
}

sub cairo_font_options_set_hint_metrics (
  cairo_font_options_t $options, GEnum $hint_metrics
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-hint-style:
=begin pod
=head2 set-hint-style

Sets the hint style for font outlines for the font options object. This controls whether to fit font outlines to the pixel grid, and if so, whether to optimize for fidelity or contrast. See the documentation for B<cairo-hint-style-t> for full details.

  method set-hint-style ( cairo_hint_style_t $hint_style )

=item $hint_style; the new hint style
=end pod

method set-hint-style ( cairo_hint_style_t $hint_style ) {
  cairo_font_options_set_hint_style(
    self._get-native-object-no-reffing, $hint_style
  )
}

sub cairo_font_options_set_hint_style (
  cairo_font_options_t $options, GEnum $hint_style
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-subpixel-order:
=begin pod
=head2 set-subpixel-order

Sets the subpixel order for the font options object. The subpixel order specifies the order of color elements within each pixel on the display device when rendering with an antialiasing mode of C<CAIRO-ANTIALIAS-SUBPIXEL>. See the documentation for B<cairo-subpixel-order-t> for full details.

  method set-subpixel-order ( cairo_subpixel_order_t $subpixel_order )

=item $subpixel_order; the new subpixel order
=end pod

method set-subpixel-order ( cairo_subpixel_order_t $subpixel_order ) {
  cairo_font_options_set_subpixel_order(
    self._get-native-object-no-reffing, $subpixel_order
  )
}

sub cairo_font_options_set_subpixel_order (
  cairo_font_options_t $options, GEnum $subpixel_order
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:1:set-variations:
=begin pod
=head2 set-variations

Sets the OpenType font variations for the font options object. Font variations are specified as a string with a format that is similar to the CSS font-variation-settings. The string contains a comma-separated list of axis assignments, which each assignment consists of a 4-character axis name and a value, separated by whitespace and optional equals sign.

Examples: C<wght=200,wdth=140.5> or C<wght 200 , wdth 140.5> or mixed.

  method set-variations ( )

=item $variations; the new font variations, or C<Any>
=end pod

method set-variations ( Str $variations ) {
  cairo_font_options_set_variations(
    self._get-native-object-no-reffing, $variations
  )
}

sub cairo_font_options_set_variations (
  cairo_font_options_t $options, gchar-ptr $variations
) is native(&cairo-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:0:status:
=begin pod
=head2 status

Checks whether an error has previously occurred for this font options object

Return value: C<CAIRO_STATUS_SUCCESS> or C<CAIRO_STATUS_NO-MEMORY>

  method status ( --> cairo_status_t )

=end pod

method status ( --> cairo_status_t ) {
  cairo_status_t(cairo_font_options_status(self._get-native-object-no-reffing))
}

sub cairo_font_options_status (
  cairo_font_options_t $options --> GEnum
) is native(&cairo-lib)
  { * }
