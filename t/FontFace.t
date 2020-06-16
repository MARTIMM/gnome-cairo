use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Cairo::FontFace;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo::FontFace $ff;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $ff .= new;
  isa-ok $ff, Gnome::Cairo::FontFace, '.new()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}
}}

#-------------------------------------------------------------------------------
done-testing;
