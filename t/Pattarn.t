use v6;
use lib '../gnome-native/lib';
use NativeCall;
use Test;

use Gnome::Cairo::Pattern;
#use Gnome::Gtk3::Enums;

use Gnome::N::X;
Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
subtest 'Pattern ISA test', {
  my Gnome::Cairo::Pattern $c .= new;
  isa-ok $c, Gnome::Cairo::Pattern, '.new';
}

#-------------------------------------------------------------------------------
done-testing;
