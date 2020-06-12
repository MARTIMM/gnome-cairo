use v6;
use lib '../gnome-native/lib';
#use NativeCall;
use Test;

use Gnome::Cairo;
#use Gnome::Gtk3::Enums;

use Gnome::N::X;
Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
subtest 'Cairo ISA test', {
  my Gnome::Cairo::Cairo $c .= new;
  isa-ok $c, Gnome::Cairo::Cairo, '.new';
}

#-------------------------------------------------------------------------------
done-testing;
