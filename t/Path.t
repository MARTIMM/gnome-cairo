use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Cairo::Path;
#use Gnome::Gtk3::Enums;

use Gnome::N::X;
Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
subtest 'Path ISA test', {
  my Gnome::Cairo::Path $c .= new;
  isa-ok $c, Gnome::Cairo::Path, '.new';
}

#-------------------------------------------------------------------------------
done-testing;
