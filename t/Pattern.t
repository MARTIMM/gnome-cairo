use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Cairo::Pattern;
use Gnome::Cairo::ImageSurface;
use Gnome::Cairo::N-Types;
use Gnome::Cairo::Enums;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo::Pattern $p;
my Gnome::Cairo::ImageSurface $is;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $p .= new( :red(1), :green(0.5), :blue(0.5e0));
  isa-ok $p, Gnome::Cairo::Pattern, '.new( :red, :green, :blue)';

  $p .= new( :red(1), :green(0.5), :blue(0.5e0), :alpha('0.8'));
  isa-ok $p, Gnome::Cairo::Pattern, '.new( :red, :green, :blue, :alpha)';

  $is .= new( :format(CAIRO_FORMAT_ARGB32), :width(128), :height(128));
  $p .= new( :surface($is));
  isa-ok $p, Gnome::Cairo::Pattern, '.new( :surface)';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
