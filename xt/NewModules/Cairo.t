use v6;
use NativeCall;
use Test;

use Gnome::Cairo;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo $c;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $c .= new;
  isa-ok $c, Gnome::Cairo, '.new()';
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Manipulations', {
}
}}

#-------------------------------------------------------------------------------
done-testing;

