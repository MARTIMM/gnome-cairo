use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Cairo::Surface;
#use Gnome::Gtk3::Enums;

use Gnome::N::X;
Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
subtest 'Surface ISA test', {
  my Gnome::Cairo::Surface $c .= new;
  isa-ok $c, Gnome::Cairo::Surface, '.new';
}

#-------------------------------------------------------------------------------
done-testing;
