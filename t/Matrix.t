use v6;
use NativeCall;
use Test;

use Gnome::Cairo::Matrix;

use Gnome::Cairo::Types;
use Gnome::Cairo::Enums;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Cairo::Matrix $m;
#-------------------------------------------------------------------------------
subtest 'ISA test', {
  $m .= new;
  with $m._get-native-object {
#note $m._get-native-object.gist;
#  isa-ok $m, Gnome::Cairo::Matrix, '.new()';
    is-deeply ( .xx, .yx, .xy, .yy, .x0, .y0),
              ( 0e0, 0e0, 0e0, 0e0, 0e0, 0e0), '.new()';
  }

  my List $nums = ( 10e0, 10e0, 11e0, 11e0, 0e0, 0e0);
  my Num() ( $xx, $xy, $yx, $yy, $x0, $y0) = $nums;

  $m .= new(:init-identity);
  with $m._get-native-object {
    is-deeply ( .xx, .yx, .xy, .yy, .x0, .y0),
    ( 1e0, 0e0, 0e0, 1e0, 0e0, 0e0), '.new(:init-identity)';
  }

  $m .= new(:init(|$nums));
  with $m._get-native-object {
    is-deeply ( .xx, .yx, .xy, .yy, .x0, .y0), $nums, '.new(:init)';
  }

  $m .= new(:init-rotate(½ * π));
  with $m._get-native-object {
    is-deeply ( .yx, .xy, .x0, .y0), ( 1e0, -1e0, 0e0, 0e0),
      '.new(:init-rotate)';
    is-approx .xx, 0e0, '.new(:init-rotate) .xx';
    is-approx .yy, 0e0, '.new(:init-rotate) .yy';
  }

  $m .= new(:init-scale( 2, 3));
  with $m._get-native-object {
    is-deeply ( .xx, .yx, .xy, .yy, .x0, .y0),
              ( 2e0, 0e0, 0e0, 3e0, 0e0, 0e0), '.new(:init-scale)';
  }

  $m .= new(:init-translate( 2, 3));
  with $m._get-native-object {
    is-deeply ( .xx, .yx, .xy, .yy, .x0, .y0),
              ( 1e0, 0e0, 0e0, 1e0, 2e0, 3e0), '.new(:init-translate)';
  }
}


#-------------------------------------------------------------------------------
# set environment variable 'raku-test-all' if rest must be tested too.
unless %*ENV<raku_test_all>:exists {
  done-testing;
  exit;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
#  my cairo_matrix_t $no;
  $m .= new(:init-identity);

  is $m.invert, CAIRO_STATUS_SUCCESS, '.invert()';
#  diag $m._get-native-object.gist;
#  with $m._get-native-object {
#    is-deeply ( .xx, .yx, .xy, .yy, .x0, .y0),
#              ( 1e0, 0e0, 0e0, 1e0, 0e0, 0e0), '.invert()';
#  }

  my Gnome::Cairo::Matrix $a .= new(:init(1,1,1,1,2,2));
  my Gnome::Cairo::Matrix $b .= new(:init(1,1,2,2,2,2));
  $m.multiply( $a, $b);
#  diag $m._get-native-object.gist;
  with $m._get-native-object {
    is-deeply ( .xx, .yx, .xy, .yy, .x0, .y0),
              ( 3e0, 3e0, 3e0, 3e0, 8e0, 8e0), '.multiply()';
  }

  $m .= new(:init-identity);
  $m.rotate(½ * π);
  with $m._get-native-object {
    is-deeply ( .yx, .xy, .x0, .y0), ( 1e0, -1e0, 0e0, 0e0),
      '.rotate()';
    is-approx .xx, 0e0, '.rotate() .xx';
    is-approx .yy, 0e0, '.rotate() .yy';
  }

  $m .= new(:init-identity);
  $m.scale( 2, 3);
  with $m._get-native-object {
    is-deeply ( .xx, .yx, .xy, .yy, .x0, .y0),
              ( 2e0, 0e0, 0e0, 3e0, 0e0, 0e0), '.scale()';
  }

  $m .= new(:init-scale( 2, 3));
  my Num() ( $dx, $dy) = ( 2, 3);
  $m.transform-distance( $dx, $dy);
#  diag $m._get-native-object.gist;
  is-deeply ( $dx, $dy), ( 4e0, 9e0), '.transform-distance()';

  ( $dx, $dy) = ( 2, 3);
  $m.transform-point( $dx, $dy);
  is-deeply ( $dx, $dy), ( 4e0, 9e0), '.transform-point()';

  $m .= new(:init-identity);
  $m.translate( 2, 3);
  with $m._get-native-object {
    is-deeply ( .xx, .yx, .xy, .yy, .x0, .y0),
              ( 1e0, 0e0, 0e0, 1e0, 2e0, 3e0), '.translate()';
  }
}

#-------------------------------------------------------------------------------
done-testing;

=finish
