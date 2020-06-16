use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Cairo::FontOptions;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo::FontOptions $fo;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $fo .= new;
  isa-ok $fo, Gnome::Cairo::FontOptions, '.new()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
