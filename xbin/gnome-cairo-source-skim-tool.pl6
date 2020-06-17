#!/usr/bin/env raku

use v6;

#-------------------------------------------------------------------------------
my Str $library = '';

my Str $include-filename;
my Str $lib-class-name;

my Str $base-sub-name;
my Str $raku-lib-name;
my Str $raku-class-name;
my Str $no-type-name;
#my Str $raku-parentlib-name;
#my Str $raku-parentclass-name;

my Str $output-file;

my Str ( $section-doc, $short-description, $see-also);

my Str $root-dir = '/home/marcel/Languages/Raku/Projects/gnome-cairo';
my @cairodirlist = "$root-dir/xbin/cairo-list.txt".IO.slurp.lines;
$root-dir = '/home/marcel/Languages/Raku/Projects/gnome-gtk3';
my @enum-list = "$root-dir/Design-docs/skim-tool-enum-list".IO.slurp.lines;

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $base-name, Bool :$main = False,
  Bool :$sub = False, Bool :$types = False, Bool :$test = False
) {

  my Bool $do-all = !( [or] $main, $sub, $types, $test );

#  load-dir-lists();

  my Bool $file-found;
  my Str ( $include-content, $source-content);
  $base-sub-name = $base-name;
  ( $file-found, $include-filename, $lib-class-name, $raku-class-name,
    $raku-lib-name, $include-content, $source-content, $no-type-name
  ) = setup-names($base-name);

  if $file-found {
    # test for dir 'xt'
    mkdir( 'xt', 0o766) unless 'xt'.IO.e;
    mkdir( 'xt/NewModules', 0o766) unless 'xt/NewModules'.IO.e;

#    ( $raku-parentclass-name, $raku-parentlib-name) =
#       parent-class($include-content);

    ( $section-doc, $short-description, $see-also) =
      get-section($source-content);

    substitute-in-template( $do-all, $main, $types, $include-content);

    get-subroutines( $include-content, $source-content) if $do-all or $sub;
#    get-signals($source-content) if $do-all or $sig;
#    get-properties($source-content) if $do-all or $prop;

    if $test or $do-all {
      # create var name named after classname. E.g. TextBuffer -> $tb.
      my Str $m = '$' ~
        (?$raku-class-name ?? $raku-class-name !! $raku-lib-name).comb(
          /<[A..Z]>/
        ).join.lc;

      my Str $class;
      if ?$raku-class-name {
        $class = [~] 'Gnome::', $raku-lib-name, '::', $raku-class-name;
      }
      else {
        $class = [~] 'Gnome::', $raku-lib-name;
      }

      my Str $test-content = Q:q:s:b:to/EOTEST/;
        use v6;
        use NativeCall;
        use Test;

        use $class;

        #use Gnome::N::X;
        #Gnome::N::debug(:on);

        #-------------------------------------------------------------------------------
        my $class $m;
        #-------------------------------------------------------------------------------
        subtest 'ISA test', {
          $m .= new;
          isa-ok $m, $class, '.new()';
        }

        #`{{
        #-------------------------------------------------------------------------------
        subtest 'Manipulations', {
        }
        }}

        #-------------------------------------------------------------------------------
        done-testing;

        EOTEST

      if ?$raku-class-name {
        "xt/NewModules/$raku-class-name.t".IO.spurt($test-content);
      }
      else {
        "xt/NewModules/$raku-lib-name.t".IO.spurt($test-content);
      }
    }
  }

  else {
    note "Include file '$include-filename' is not found";
  }
}

#-------------------------------------------------------------------------------
sub get-subroutines( Str:D $include-content, Str:D $source-content ) {

  my Str $sub-doc = '';
  my Array $items-src-doc = [];
#  my Bool $variable-args-list;

  # get all subroutines starting with '/** ... **/ sub declaration'. body is
  # skipped. sometimes there is a declaration of structures using { }. because
  # body is skipped, ignore the curly brackets too.
  $source-content ~~ m:g/
    $<comment-doc> = ('/**' .*? '**/')
    $<declaration> = ( <-[({]>+ '(' <-[)]>+ ')' )
  /;
  my List $results = $/[*];

  # process subroutines
  for @$results -> $r {
#    $variable-args-list = False;
#note "\n $r";

    my Str $comment-doc = ~$r<comment-doc>;
    my Str $declaration = ~$r<declaration>;

    # defines are also caught when () are used but defs are not subs -> skip
    next if $declaration ~~ m/ '#define' /;

    # sometime there is extra doc for the routine which must be removed
    # this ends up in the declaration
    $declaration ~~ s/ '/*' .*? '*/' //;

#next unless $declaration ~~ m:s/ const gchar \* /;
    # skip constants and subs with variable argument lists
#    next if $declaration ~~ m/ 'G_GNUC_CONST' /;
#    $variable-args-list = True if $declaration ~~ m/ 'G_GNUC_NULL_TERMINATED' /;

    # remove some macros
#    $declaration ~~ s/ \s* 'G_GNUC_WARN_UNUSED_RESULT' \s* //;

    # remove prefix and tidy up a bit
#    $declaration ~~ s/^ ['GDK_PIXBUF' || 'GDK' || 'GTK' || 'GLIB' || 'PANGO']
#                        '_AVAILABLE_IN_' .*?  \n
#                    //;
#    $declaration ~~ s:g/ \s* \n \s* / /;
#    $declaration ~~ s:g/ \s+ / /;
#    $declaration ~~ s/\s* 'G_GNUC_PURE' \s*//;
#note "\n0 >> $comment-doc";
#note "\n1 >> $declaration";
    next if $declaration ~~ m/ static /;

    my Str ( $return-type, $raku-return-type) = ( '', '');
    my Bool $type-is-class;

    # convert and remove return type from declaration
    ( $declaration, $return-type, $raku-return-type, $type-is-class) =
      get-type($declaration);

    # get the subroutine name and remove from declaration
    $declaration ~~ m/ $<sub-name> = [ <alnum>+ ] \s* /;
    my Str $sub-name = ~$<sub-name>;

    # assume that sub names starting with '_' are private
    next if $sub-name ~~ m/ ^ '_' /;
    note "get sub $sub-name";
    $declaration ~~ s/ $sub-name \s* //;

    # remove any brackets, and other stuff left before arguments are processed
    $declaration ~~ s:g/ <[();]> //;

    # get subroutine documentation from c source
#    ( $sub-doc, $items-src-doc) = get-sub-doc( $sub-name, $source-content);
    ( $sub-doc, $items-src-doc) = get-sub-doc($comment-doc);

#note "Pod items: $items-src-doc.elems()\n  ", $items-src-doc.join("\n  ");

    my Str $args-declaration = $declaration;
    my Str ( $pod-args, $args, $pod-doc-items) = ( '', '', '');
    my Bool $first-arg = True;

    # process arguments
    for $args-declaration.split(/ \s* ',' \s* /) -> $raw-arg {
      my Str ( $arg, $arg-type, $raku-arg-type);
      ( $arg, $arg-type, $raku-arg-type, $type-is-class) =
        get-type($raw-arg);

      if ?$arg {
        my Str $pod-doc-item-doc = $items-src-doc.shift if $items-src-doc.elems;
#note "pod info: $raku-arg-type, $arg, $pod-doc-item-doc";

        # skip first argument when type is also the class name
        if $first-arg and $type-is-class {
        }

        # skip also when variable is $any set to default Any type
        elsif $arg eq 'any = Any' {
        }

        else {
          # make arguments pod doc
          $pod-args ~= ',' if ?$pod-args;
          $pod-args ~= " $raku-arg-type \$$arg";
          $pod-doc-items ~= "=item $raku-arg-type \$$arg; {$pod-doc-item-doc//''}\n";
        }

        # add argument to list for sub declaration
        $args ~= ', ' if ?$args;
        $args ~= "$arg-type \$$arg";
      }

      $first-arg = False;
    }

#    note "2 >> $sub-name";
#    note "3 >> $args";
#    note "4 >> $return-type";

    $sub-doc = cleanup-source-doc($sub-doc);

    my Str $pod-doc-return = '';
    my Str $pod-returns = '';
    my Str $returns = '';
    if ?$return-type {
      $pod-returns = " --> $raku-return-type";
      $returns = "--> $return-type";
    }

    my Str $start-comment = ''; # $variable-args-list ?? '#`{{' ~ "\n" !! '';
    my Str $end-comment = ''; # $variable-args-list ?? "\n" ~ '}}' !! '';

    my $pod-sub-name = pod-sub-name($sub-name);
    my Str $sub = Q:qq:to/EOSUB/;

      $start-comment#-------------------------------------------------------------------------------
      #TM:0:$sub-name:
      =begin pod
      =head2 $pod-sub-name

      $sub-doc

        method $sub-name ($pod-args$pod-returns )

      $pod-doc-items$pod-doc-return
      =end pod

      sub $sub-name ( $args $returns )
        is native($library)
        \{ * \}$end-comment
      EOSUB


#    note $sub;

    $output-file.IO.spurt( $sub, :append);
  }
}

#`{{
#-------------------------------------------------------------------------------
sub parent-class ( Str:D $include-content --> List ) {

  $include-content ~~ m/
    ^^ \s*
    $<lib-parent> = [<alnum>+]
    \s+ 'parent_class'
  /;

  my Str $raku-lib-parentclass = ~($<lib-parent> // '');
  my Str $raku-parentlib-name = '';
  given $raku-lib-parentclass {
    when /^ Gtk / {
      $raku-parentlib-name = 'Gtk3';
    }

    when /^ Gdk / {
      $raku-parentlib-name = 'Gdk3';
    }
  }

  $raku-lib-parentclass ~~ s:g/ ['Gtk' || 'Gdk'|| 'Class'] //;

  ( $raku-lib-parentclass, $raku-parentlib-name);
}
}}

#-------------------------------------------------------------------------------
# Get the type from the start of the declaration and remove it from that
# declaration. The type is cleaned up by removing 'const', 'void' and pointer(*)
sub get-type( Str:D $declaration is copy --> List ) {

  $declaration ~~ s/ inline || cairo_public //;

  # process types from arg lists, inconsequent use of gchar/char
  $declaration ~~ m/ \s*
    $<type> = [ ^^
#        void \s* '*' \s* ||
#        const \s* char \s* '*'* \s* ||
#        char \s* '*'* \s* ||
        const \s* <alnum>+ \s* '*'* \s* ||
        unsigned \s+ [ int || long || char ] \s* '*'* ||
        <alnum>+ \s* '*'* \s* ||
        <alnum>+ \s*
    ]
  /;
#note "type found: $declaration ---> ", $/.Str;


  #[ [const]? \s* <alnum>+ \s* \*? ]*

  # get type of subroutine and remove from declaration
  my Str $type = ~($<type> // '');
  $declaration ~~ s/ $type //;

  # drop the const if any and rename the void pointer
  $type ~~ s:g/ const //;
  $type ~~ s:g/ void \s* '*' \s* /OpaquePointer /;

  # convert a pointer char type
  $type ~~ s/ [unsigned]? \s+ char \s* '*' /Str/ if $type ~~ m/ char \s* '*' /;

  # if there is still another pointer, make a CArray
#  $type = "CArray[$type]" if $type ~~ m/ '*' /;
#  $type ~~ s:g/ '*' //;
#  $type ~~ s:g/ \s+ //;

#`{{
  if $declaration ~~ m/ ^ '...' / {
    $type = 'Any';
    $declaration = 'any = Any';
  }
}}

#note "\nType: $type";
  # cleanup
#  $type ~~ s:g/ '*' //;
  $type ~~ s/ \s+ / /;
  $type ~~ s/ \s+ $//;
  $type ~~ s/^ \s+ //;
  $type ~~ s/^ \s* $//;
#note "Cleaned type: $type";

  # check type for its class name
  my Bool $type-is-class = $type eq $no-type-name;

  $type = 'int32' if $type ~~ m/ cairo_bool_t /;
  $type = 'num32' if $type ~~ m/ real /;
  $type = 'num64' if $type ~~ m/ double /;

  if $type ~~ any(@enum-list) {
    $type = 'int32';
  }

#`{{
  # convert to native perl types
#note "Type: $type";
  $type = 'N-GError' if $type ~~ m/GError/;
  $type = 'N-GList' if $type ~~ m/GList/;
  $type = 'N-GSList' if $type ~~ m/GSList/;
  $type = 'N-PangoItem' if $type ~~ m/PangoItem/;
  $type = 'N-Variant' if $type ~~ m/Variant/;
  $type = 'N-VariantBuilder' if $type ~~ m/VariantBuilder/;
  $type = 'N-VariantType' if $type ~~ m/VariantType/;
  $type = 'N-VariantIter' if $type ~~ m/VariantIter/;
  $type = 'N-GtkTreeIter' if $type ~~ m/GtkTreeIter/;
  $type = 'N-GtkTreePath' if $type ~~ m/GtkTreePath/;

#  $type = 'int32' if $type ~~ m/GType/;
  $type = 'uint64' if $type ~~ m/GType/;

  $type = 'int32' if $type ~~ m/GQuark/;
#  $type = 'N-GObject' if is-n-gobject($type);

  # copy to Raku type for independent convertions
  my Str $raku-type = $type;

  # convert to native perl types
  #$type ~~ s/ g?char \s+ '*' /str/;

  # process all types from GtkEnum and some
  # use bin/gather-enums.pl6 to create a list in
  # doc/Design-docs/scim-tool-enum-list.txt
  if $type ~~ any(@enum-list) {
    $type = 'int32';
  }

  $type ~~ s:s/ gboolean || gint || gint32 /int32/;
  $type ~~ s:s/ g?char || gint8 /int8/;
  $type ~~ s:s/ gshort || gint16 /int16/;
  $type ~~ s:s/ glong || gint64 /int64/;

  $type ~~ s:s/ guint || guint32 /uint32/;
  $type ~~ s:s/ guchar || guint8 /byte/;
  $type ~~ s:s/ gushort || guint16 /uint16/;
  $type ~~ s:s/ gulong || guint64 /uint64/;

  $type ~~ s:s/ gssize || goffset /int64/;
  $type ~~ s:s/ gsize /uint64/;
  $type ~~ s:s/ gfloat /num32/;
  $type ~~ s:s/ gdouble /num64/;

  $type ~~ s:s/ int /int32/;
  $type ~~ s:s/ gpointer /Pointer/;

}}

  # convert to perl types
  my Str $raku-type = $type;
  $raku-type = 'UInt' if $raku-type ~~ m:s/ unsigned [int || long ]/;
  $raku-type = 'Int' if $raku-type ~~ m:s/ int32 || int64 || int /;
  $raku-type = 'Num' if $raku-type ~~ m:s/ num32 || num64 /;

#  $type = 'CArray[int8]' if $type ~~ m/ [unsigned]? \s+ char \s* '*' \s* /;
  $type = 'CArray[int32]' if $type ~~ m/ [unsigned]? \s+ int \s* '*' \s* /;
  $type = 'CArray[int64]' if $type ~~ m/ [unsigned]? \s+ long \s* '*' \s* /;
  $type = 'int8' if $type ~~ m:s/ [unsigned]? char /;
  $type = 'int32' if $type ~~ m:s/ [unsigned]? int /;
  $type = 'int64' if $type ~~ m:s/ [unsigned]? long /;
#  $type = 'int32' if $type ~~ m:s/ int /;
#  $type = 'int64' if $type ~~ m:s/ long /;

#`{{
  #$raku-type ~~ s/ 'gchar' \s+ '*' /Str/;
  #$raku-type ~~ s/ str /Str/;

  $raku-type ~~ s:s/ guint || guint32 || guchar || guint8 ||
                   gushort || guint16 || gulong || guint64 ||
                   gsize || uint32 || uint64 || uint
                 /UInt/;

  $raku-type ~~ s:s/ gboolean || gint || gint32 ||
                   gchar || gint8 || gshort || gint16 ||
                   glong || gint64 ||
                   gssize || goffset || int32 || int64 || int
                 /Int/;

#  $raku-type ~~ s:s/ int /Int/;
#  $raku-type ~~ s:s/ uint /UInt/;
  $raku-type ~~ s:s/ gpointer /Pointer/;

  $raku-type ~~ s:s/ gfloat || gdouble /Num/;

}}

$declaration ~~ s/ \s+ / /;
$declaration ~~ s/ \s+ $//;
$declaration ~~ s/^ \s+ //;
$declaration ~~ s/^ \s* $//;

#note "Result type: $declaration, $type, raku type: $raku-type, is class = $type-is-class";

  ( $declaration, $type, $raku-type, $type-is-class)
}

#-------------------------------------------------------------------------------
sub setup-names ( Str:D $base-sub-name --> List ) {
  my Str $include-file = $base-sub-name;
  $include-file ~~ s:g/ '_' /-/;

  my @parts = $base-sub-name.split(/<[_-]>/);
  my Str $lib-class = @parts>>.tc.join;

  my Str $raku-class = @parts[1..*-1]>>.tc.join;

note "Files etc.: $base-sub-name, $include-file, $lib-class, $raku-class";

  my $source-root = '/home/marcel/Software/Packages/Sources/Gnome';

  my Str ( $include-content, $source-content) = ( '', '');
  my Bool $file-found = False;
  my $path = "$source-root/cairo-1.16.0/src";

#note "Include $path/$include-file.h";
  if "$path/$include-file.h".IO.r {
    $file-found = True;
    if $include-file eq 'gdk-pixbuf' and "$path/{$include-file}-core.h".IO.r {
      $include-content = "$path/{$include-file}-core.h".IO.slurp;
    }
    else {
      $include-content = "$path/$include-file.h".IO.slurp;
    }

    $source-content = "$path/$include-file.c".IO.slurp
      if "$path/$include-file.c".IO.r;

#note "Sources: ", ?$include-content, ', ', ?$source-content;
  }

  elsif "$path/$include-file.c".IO.r {
    $file-found = True;
    $include-content = "$path/{$include-file}.c".IO.slurp;
    $source-content := $include-content;
  }

  if $file-found {
    given $path {
#`{{
      when / 'gtk+-' <-[/]>+ '/gtk' / {
        $library = '&gtk-lib';
        $raku-lib-name = 'Gtk3';
      }

      when / 'gdk-pixbuf' / {
        $library = '&gdk-pixbuf-lib';
        $raku-lib-name = 'Gdk3';
      }

      when / 'gtk+-' <-[/]>+ '/gdk' / {
        $library = "&gdk-lib";
        $raku-lib-name = 'Gdk3';
      }

      when / 'glib-' <-[/]>+ '/glib' / {
        $library = "&glib-lib";
        $raku-lib-name = 'Glib';
      }

      when / 'glib-' <-[/]>+ '/gio' / {
        $library = "&gio-lib";
        $raku-lib-name = 'Gio';
      }

      when / 'glib-' <-[/]>+ '/gobject' / {
        $library = "&gobject-lib";
        $raku-lib-name = 'GObject';
      }

      when / 'pango-' <-[/]>+ '/pango' / {
        $library = "&pango-lib";
        $raku-lib-name = 'Pango';
      }
}}
      when / 'cairo-' <-[/]>+ '/src' / {
        $library = "&cairo-lib";
        $raku-lib-name = 'Cairo';
      }

#        when $gio-path {
#          $library = "&glib-lib";
#          $raku-lib-name = 'Glib';
#        }
    }
  }

note "Library: $library, $lib-class, $raku-lib-name";

  my Str $no-type-name = $base-sub-name ~ '_t';

  ( $file-found, $include-file, $lib-class, $raku-class, $raku-lib-name,
    $include-content, $source-content, $no-type-name
  )
}

#-------------------------------------------------------------------------------
sub pod-sub-name ( Str:D $sub-name --> Str ) {

  my Str $pod-sub-name = $sub-name;

  # sometimes the sub name does not start with the base name
  if $sub-name ~~ m/ ^ $base-sub-name / {
    my Str $s = $sub-name;
    $s ~~ s/^ $base-sub-name '_' //;
    if $s ~~ m/ '_' / {
      $pod-sub-name = [~] '[', $base-sub-name, '_] ', $s;
    }
  }

  $pod-sub-name
}

#`{{
#-------------------------------------------------------------------------------
sub is-n-gobject ( Str:D $type-name is copy --> Bool ) {
  my Bool $is-n-gobject = False;

  $type-name .= lc;
#note "TN: $type-name";

  given $type-name {
    when /^ 'gtk' / {
      $is-n-gobject = $type-name ~~ any(|@gtkdirlist);
    }

    when /^ 'gdk' / {
      $is-n-gobject = $type-name ~~ any(|@gdkdirlist);
    }

    when /^ 'g' / {

      $is-n-gobject = $type-name ~~ any(|@glibdirlist);
      $is-n-gobject = $type-name ~~ any(|@gobjectdirlist) unless $is-n-gobject;
#      $is-n-gobject = $type-name ~~ any(|@giodirlist) unless $is-n-gobject;
#      $is-n-gobject = $type-name ~~ any(|@cairodirlist) unless $is-n-gobject;
    }

    when /^ 'pango' / {
      state @modified-pangodirlist = map(
        { .subst( / '-' /, ''); }, @pangodirlist
      );

      $is-n-gobject = $type-name ~~ any(|@modified-pangodirlist);
    }
  }

  $is-n-gobject
}
}}

#`{{
#-------------------------------------------------------------------------------
sub load-dir-lists ( ) {

  my Str $root-dir = '/home/marcel/Languages/Raku/Projects/gnome-gtk3';
#  @gtkdirlist = "$root-dir/Design-docs/gtk3-list.txt".IO.slurp.lines;
#  @gdkdirlist = "$root-dir/Design-docs/gdk3-list.txt".IO.slurp.lines;
#  @gdkpixbufdirlist = "$root-dir/Design-docs/gdk3-pixbuf-list.txt".IO.slurp.lines;
#  @gobjectdirlist = "$root-dir/Design-docs/gobject-list.txt".IO.slurp.lines;
#  @glibdirlist = "$root-dir/Design-docs/glib-list.txt".IO.slurp.lines;
#  @giodirlist = "$root-dir/Design-docs/gio-list.txt".IO.slurp.lines;

#  @pangodirlist = "$root-dir/Design-docs/pango-list.txt".IO.slurp.lines;
  @cairodirlist = "$root-dir/Design-docs/cairo-list.txt".IO.slurp.lines;

  @enum-list = "$root-dir/Design-docs/skim-tool-enum-list".IO.slurp.lines;
}
}}

#-------------------------------------------------------------------------------
sub substitute-in-template (
  Bool $do-all, Bool $main, Bool $types, Str $include-content
) {

  my Str $template-text = Q:q:to/EOTEMPLATE/;
    #TL:0:Gnome::LIBRARYMODULE:

    use v6;
    #-------------------------------------------------------------------------------
    =begin pod

    =head1 Gnome::LIBRARYMODULE

    MODULE-SHORTDESCRIPTION

    =comment ![](images/X.png)

    =head1 Description

    MODULE-DESCRIPTION

    MODULE-SEEALSO

    =head1 Synopsis
    =head2 Declaration

      unit class Gnome::LIBRARYMODULE;
      also is Gnome::N::TopLevelClassSupport;

    =comment head2 Example

    =end pod
    #-------------------------------------------------------------------------------
    use NativeCall;

    use Gnome::N::X;
    use Gnome::N::NativeLib;
    use Gnome::N::TopLevelClassSupport;

    use Gnome::Cairo::N-Types;
    use Gnome::Cairo::Enums;

    #-------------------------------------------------------------------------------
    unit class Gnome::LIBRARYMODULE:auth<github:MARTIMM>;
    also is Gnome::N::TopLevelClassSupport;
    EOTEMPLATE

  # All cairo modules are quite flat. Inheritng only from TopLevelClassSupport
  my Str ( $t1, $t2) = ( '', '');
#  if $raku-parentlib-name and $raku-parentclass-name {
#    $t1 = 'use Gnome::N::TopLevelClassSupport;';
#    $t2 = 'also is Gnome::N::TopLevelClassSupport;';
#  }

#  $template-text ~~ s:g/ 'MODULENAME' /$raku-class-name/;
  if ?$raku-class-name {
    $template-text ~~
      s:g/ 'LIBRARYMODULE' /{$raku-lib-name}::{$raku-class-name}/;
  }
  else {
    $template-text ~~
      s:g/ 'LIBRARYMODULE' /$raku-lib-name/;
  }

#  $template-text ~~ s:g/ 'USE-LIBRARY-PARENT' /$t1/;
#  $template-text ~~ s:g/ 'ALSO-IS-LIBRARY-PARENT' /$t2/;

  $template-text ~~ s:g/ 'MODULE-SHORTDESCRIPTION' /$short-description/;
  $template-text ~~ s:g/ 'MODULE-DESCRIPTION' /$section-doc/;
  $template-text ~~ s:g/ 'MODULE-SEEALSO' /$see-also/;
  $template-text ~~ s:g/ 'LIBCLASSNAME' /$lib-class-name/;

  if ?$raku-class-name {
    $output-file = "xt/NewModules/$raku-class-name.pm6";
  }
  else {
    $output-file = "xt/NewModules/$raku-lib-name.pm6";
  }

  $output-file.IO.spurt($template-text);

  get-vartypes($include-content) if $do-all or $types;

  if $do-all or $main {
    $template-text = Q:q:to/EOTEMPLATE/;
      #-------------------------------------------------------------------------------
      =begin pod
      =end pod
      #TT:0:NO-TYPE-NAME
      class NO-TYPE-NAME
        is repr('CPointer')
        is export
        { }

      #-------------------------------------------------------------------------------
      =begin pod
      =head1 Methods
      =head2 new

      =head3 new()

      Create a new RAKU-CLASS-NAME object.

        multi method new ( )

      =begin comment
      Create a RAKU-CLASS-NAME object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

        multi method new ( N-GObject :$native-object! )

      Create a RAKU-CLASS-NAME object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

        multi method new ( Str :$build-id! )
      =end comment

      =end pod

      #TM:0:new():
      #TM:4:new(:native-object):Gnome::N::TopLevelClassSupport
      submethod BUILD ( *%options ) {

        # prevent creating wrong native-objects
        if self.^name eq 'Gnome::LIBRARYMODULE' #`{{ or %options<LIBCLASSNAME> }} {

          # check if native object is set by a parent class
          if self.is-valid { }

          # process all options

          # check if common options are handled by some parent
          elsif %options<native-object>:exists { }

          else {
            my $no;
            # if ? %options<> {
            #   $no = %options<>;
            #   $no .= get-native-object-no-reffing
            #     if $no.^can('get-native-object-no-reffing');
            #   $no = ...($no);
            # }

            #`{{ use this when the module is not made inheritable
            # check if there are unknown options
            elsif %options.elems {
              die X::Gnome.new(
                :message(
                  'Unsupported, undefined, incomplete or wrongly typed options for ' ~
                  self.^name ~ ': ' ~ %options.keys.join(', ')
                )
              );
            }
            }}

            #`{{ when there are no defaults use this
            # check if there are any options
            elsif %options.elems == 0 {
              die X::Gnome.new(:message('No options specified ' ~ self.^name));
            }
            }}

            #`{{ when there are defaults use this instead
            # create default object
            else {
              $no = BASE-SUBNAME_new();
            }
            }}

            self.set-native-object($no);
          }
        }
      }

      #-------------------------------------------------------------------------------
      # no pod. user does not have to know about it.
      method _fallback ( $native-sub is copy --> Callable ) {

        my Callable $s;
        try { $s = &::("BASE-SUBNAME_$native-sub"); };
        try { $s = &::("cairo_$native-sub"); } unless ?$s;
        try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

        $s = callsame unless ?$s;

        $s;
      }

      EOTEMPLATE

    $template-text ~~ s:g/ 'NO-TYPE-NAME' /$no-type-name/;
    $template-text ~~ s:g/ 'RAKU-CLASS-NAME' /$raku-class-name/;
    $template-text ~~ s:g/ 'LIBRARYMODULE' /{$raku-lib-name}::{$raku-class-name}/;
    $template-text ~~ s:g/ 'BASE-SUBNAME' /$base-sub-name/;
    $template-text ~~ s:g/ 'LIBCLASSNAME' /$lib-class-name/;
    $output-file.IO.spurt( $template-text, :append);
  }
}

#-------------------------------------------------------------------------------
#sub get-sub-doc ( Str:D $sub-name, Str:D $source-content --> List ) {
sub get-sub-doc ( Str:D $doc --> List ) {

#  return ( '', '') unless $source-content;

#  $source-content ~~ m/ '/**' .*? $sub-name ':' $<sub-doc> = [ .*? '*/' ] /;
#  my Str $doc = ~($<sub-doc> // '');

  my Array $items-src-doc = [];
  my Bool $gather-items-doc = True;
  my Str ( $item, $sub-doc) = ( '', '');
  for $doc.lines -> $line {

    if $line ~~ m/ ^ \s+ '* @' <alnum>+ ':' $<item-doc> = [ .* ] / {
      # check if there was some item. if so save before set to new item
      # @ can be in documentation too!
      if $gather-items-doc {
        $items-src-doc.push(primary-doc-changes($item)) if ?$item;
      }

      # new item. remove first space char
      $item = ~($<item-doc> // '');
      $item ~~ s/ ^ \s+ //;
    }

    elsif $line ~~ m/ ^ \s+ '*' \s+ $<doc> = [ .+ ] / {
      # additional doc for items. separate with a space.
      if $gather-items-doc {
        $item ~= " " ~ ~($<doc> // '');
      }

      else {
        $sub-doc ~= " " ~ ~($<doc> // '');
      }
    }


    # an empty line is end of items doc and starts/continues sub doc
    elsif $line ~~ m/ ^ \s+ '*' \s* $ / {
      if $gather-items-doc {
        # save previous item
        $items-src-doc.push(primary-doc-changes($item));

        $gather-items-doc = False;
        $sub-doc ~= " ";
      }

      else {
        $sub-doc ~= " ";
      }
    }
  }

  # in case there is no doc, we need to save the last item still
  $items-src-doc.push(primary-doc-changes($item)) if $gather-items-doc;

  $sub-doc ~~ s/ ^ \s+ //;
  $sub-doc ~~ s/ \n\s*Since:\s+\d+\.\d+\s*\n //;

  ( primary-doc-changes($sub-doc), $items-src-doc )
}

#-------------------------------------------------------------------------------
# get the class title and class info from the source file
sub get-section ( Str:D $source-content --> List ) {

  return ( '', '', '') unless $source-content;

  $source-content ~~ m/ '/**' .*? SECTION ':' .*? '*/' /;
  return ( '', '', '') unless ?$/;

  my Str $section-doc = ~$/;

  $section-doc ~~ m:i/
      ^^ \s+ '*' \s+ '@Short_description:' \s* $<text> = [.*?] $$
  /;
  my Str $short-description = ~($<text>//'');
  $section-doc ~~ s:i/ ^^ \s+ '*' \s+ '@Short_description:' [.*?] \n //;

  $section-doc ~~ m:i/ ^^ \s+ '*' \s+ '@See_also:' \s* $<text> = [.*?] $$ /;
  my Str $see-also = ~($<text>//'');
  $section-doc ~~ s:i/ ^^ \s+ '*' \s+ '@See_also:' [.*?] \n //;

  # cleanup rest
  $section-doc ~~ s:i/ ^^ \s+ '*' \s+ 'SECTION:' [.*?] \n //;
  $section-doc ~~ s:i/ ^^ \s+ '*' \s+ '@Title:' [.*?] \n //;
  $section-doc = cleanup-source-doc($section-doc);
#  $section-doc ~~ s:i/ ^^ '#' \s+ 'CSS' \s+ 'nodes'/\n=head2 Css Nodes\n/;
#  $section-doc ~~ s:g:i/ ^^ '#' \s+ /\n=head2 /;
#note "doc 2: ", $section-doc;


  ( primary-doc-changes($section-doc),
    primary-doc-changes($short-description),
    (?$see-also ?? "=head2 See Also\n\n" ~ primary-doc-changes($see-also) !! '')
  )
}

#`{{
#-------------------------------------------------------------------------------
sub get-signals ( Str:D $source-content is copy ) {

  return unless $source-content;

  my Array $items-src-doc;
  my Str $signal-name;
  my Str $signal-doc = '';
  my Hash $signal-classes = %();

  loop {
    $items-src-doc = [];
    $signal-name = '';

    $source-content ~~ m/
      $<signal-doc> = [ '/**' \s+ '*' \s+ $lib-class-name '::'  .*? '*/' ]
    /;

    # save doc and remove from source but stop if none left
    my Str $sdoc = ~($<signal-doc> // '');
#note "SDoc 0 $lib-class-name: ", ?$sdoc;
    my Bool $has-doc = ($sdoc ~~ m/ '/**' / ?? True !! False);

    # possibly no documentation
    if $has-doc {
      $source-content ~~ s/$sdoc//;

      # get lib class name and remove line from source
      $sdoc ~~ m/
        ^^ \s+ '*' \s+ $lib-class-name '::' $<signal-name> = [ [<alnum> || '-']+ ]
      /;
      $signal-name = ~($<signal-name> // '');
      $sdoc ~~ s/ ^^ \s+ '*' \s+ $lib-class-name '::' $signal-name ':'? //;
#note "SDoc 1 ", $sdoc;
    }

    # get some more info from the function call
    $source-content ~~ m/
      'g_signal_new' '_class_handler'? \s* '('
      $<signal-args> = [
        [ <[A..Z]> '_('                     || # gtk sources
          'g_intern_static_string' \s* '('     # gdk sources
        ]
        '"' <-[\"]>+ '"' .*?
      ] ');'
    /;
#note "SDoc 2 ",  ~($<signal-args>//'-');

    # save and remove from source but stop if there isn't any left
    my Str $sig-args = ~($<signal-args>//'');
    if !$sig-args {
      $sdoc = '';
      last;
    }
    $source-content ~~
       s/ 'g_signal_new' '_class_handler'? \s* '(' $sig-args ');' //;

#note "sig args: ", $sig-args;
    # when there's no doc, signal name must be retrieved from function argument
    unless $signal-name {
      $sig-args ~~ m/ '"' $<signal-name> = [ <-[\"]>+ ] '"' /;
      $signal-name = ($<signal-name>//'').Str;
    }

#note "SA $signal-name: ", $sig-args;

    # start pod doc
    $signal-doc ~= "\n=comment #TS:0:$signal-name:\n=head3 $signal-name\n";
    note "get signal $signal-name";

    # process g_signal_new arguments, remove commas from specific macro
    # by removing the complete argument list. it's not needed.
    $sig-args ~~ s/ 'G_STRUCT_OFFSET' \s* \( <-[\)]>+ \) /G_STRUCT_OFFSET/;
    my @args = ();
    for $sig-args.split(/ \s* ',' \s* /) -> $arg is copy {
#note "arg: '$arg'";
      @args.push($arg);
    }

#note "Args: ", @args[7..*-1];
    # get a return type
    my Str $return-type = '';
    given @args[7] {
      # most of the time it is a boolean ( == c int32)
      when 'G_TYPE_BOOLEAN' { $return-type = 'Int'; }
      when 'G_TYPE_INT' { $return-type = 'Int'; }
      when 'G_TYPE_UINT' { $return-type = 'Int'; }
      when 'G_TYPE_STRING' { $return-type = 'Str'; }
      when 'G_TYPE_NONE' { $return-type = ''; }
      when 'GTK_TYPE_TREE_ITER' { $return-type = 'N-GtkTreeIter'; }
      # show that there is something
      default { $return-type = "Unknown type @args[7]"; }
    }

    my Int $item-count = 0;

    # create proper variable name when not available from the doc
    my Str $iname = $lib-class-name;
    $iname ~~ s:i/^ [ gtk || gdk || g ] //;
    $iname .= lc;
    $items-src-doc.push: %(
      :item-type<Gnome::GObject::Object>, :item-name($iname),
      :item-doc('')
    );

    my Array $signal-args = ['Gnome::GObject::Object'];
    my Int $arg-count = @args[8].Int;
    loop ( my $i = 0; $i < $arg-count; $i++ ) {

      my Str $arg-type = '';
      given @args[9 + $i] {
        when 'G_TYPE_BOOLEAN' { $arg-type = 'Int'; }
        when 'G_TYPE_INT' { $arg-type = 'Int'; }
        when 'G_TYPE_UINT' { $return-type = 'Int'; }
        when 'G_TYPE_LONG' { $arg-type = 'int64 #`{ use NativeCall }'; }
        when 'G_TYPE_FLOAT' { $arg-type = 'Num'; }
        when 'G_TYPE_DOUBLE' { $arg-type = 'num64 #`{ use NativeCall }'; }
        when 'G_TYPE_STRING' { $arg-type = 'Str'; }
        when 'G_TYPE_ERROR' { $arg-type = 'N-GError'; }

        when 'GTK_TYPE_OBJECT' { $arg-type = 'N-GObject #`{ is object }'; }
        when 'GTK_TYPE_WIDGET' { $arg-type = 'N-GObject #`{ is widget }'; }
        when 'GTK_TYPE_TEXT_ITER' {
          $arg-type = 'N-GObject #`{ native Gnome::Gtk3::TextIter }';
        }
        when 'GTK_TYPE_TREE_ITER' {
          $arg-type = 'N-GtkTreeIter #`{ native Gnome::Gtk3::TreeIter }';
        }

        when 'GDK_TYPE_DISPLAY' {
          $arg-type = 'N-GObject #`{ native Gnome::Gdk3::Display }';
        }
        when 'GDK_TYPE_DEVICE' {
          $arg-type = 'N-GObject #`{ native Gnome::Gdk3::Device }';
        }
        when 'GDK_TYPE_DEVICE_TOOL' {
          $arg-type = 'N-GObject #`{ native Gnome::Gdk3::DeviceTool }';
        }
        when 'GDK_TYPE_MONITOR' {
          $arg-type = 'N-GObject #`{ native Gnome::Gdk3::Monitor }';
        }
        when 'GDK_TYPE_SCREEN' {
          $arg-type = 'N-GObject #`{ native Gnome::Gdk3::Screen }';
        }
        when 'GDK_TYPE_SEAT' {
          $arg-type = 'N-GObject #`{ native Gnome::Gdk3::Seat }';
        }
        when 'GDK_TYPE_MODIFIER_TYPE' {
          $arg-type = 'GdkModifierType #`{ from Gnome::Gdk3::Window }';
        }
        default { $arg-type = "Unknown type @args[{9 + $i}]"; }
      }

      my Str $item-name = $arg-type.lc;
      $item-name ~~ s/ 'gnome::gtk3::' //;
      $items-src-doc.push: %(
        :item-type($arg-type), :$item-name,
        :item-doc('')
      );

#note "AT: $i, $arg-type";
      $signal-args.push: $arg-type;
    }

    # we know the number of extra arguments and signal name
    my Str $sig-class = "w$arg-count";
    $signal-classes{$sig-class} = [] unless $signal-classes{$sig-class}:exists;
    $signal-classes{$sig-class}.push: $signal-name;

    # get arguments for this signal handler
    my Str ( $item-doc, $item-name, $spart-doc) = ( '', '', '');
    my Bool $item-scan = True;
    #my Bool $first-arg = True;

    $item-count = 0;
    if $has-doc {
      $items-src-doc = [];
      for $sdoc.lines -> $line {
#note "L: $line";

        # argument doc start
        if $item-scan and $line ~~ m/^ \s* '*' \s+ '@' / {

          # push when 2nd arg is found
#note "ISD 0: $item-count, $item-name, $signal-args[$item-count]" if ?$item-name;
          $items-src-doc.push: %(
            :item-type($signal-args[$item-count++]), :$item-name, :$item-doc
          ) if ?$item-name;

          # get the info from the current line
          $line ~~ m/ '*' \s+ '@' $<item-name> = [<alnum>+] ':'
                      \s* $<item-doc> = [ .* ]
                    /;

          $item-name = ~($<item-name> // '');
          $item-doc = primary-doc-changes(~($<item-doc> // '')) ~ "\n";
#note "n, d: $item-name, $item-doc";
        }

        # continue previous argument doc
        elsif $item-scan and
              $line ~~ m/^ \s* '*' \s ** 2..* $<item-doc> = [ .* ] / {
          my Str $s = ~($<item-doc> // '');
          $item-doc ~= primary-doc-changes($s);
#note "d: $item-doc";
        }

        # on empty line after '*' start sub doc
        elsif $line ~~ m/^ \s* '*' \s* $/ {
          # push last arg
#note "ISD 1: $item-count, $item-name, $signal-args[$item-count]"
#if $item-scan and ?$item-name;
          $items-src-doc.push: %(
            :item-type($signal-args[$item-count]), :$item-name, :$item-doc
          ) if $item-scan and ?$item-name;

          $spart-doc ~= "\n";
          $item-scan = False;
        }

        # rest is sub doc
        elsif !$item-scan {
          # skip end of document
          next if $line ~~ m/ '*/' /;

          my Str $l = $line;
          $l ~~ s/^ \s* '*' \s* //;
          $spart-doc ~= $l ~ "\n";
        }
      }

      # when there is no sub doc, it might end a bit abdrupt
      #note "ISD 2: $item-count, $item-name, $signal-args[$item-count]"
      #if $item-scan and ?$item-name;

      $items-src-doc.push: %(
      :item-type($signal-args[$item-count]), :$item-name, :$item-doc
      ) if $item-scan and ?$item-name;

      $signal-doc ~= primary-doc-changes($spart-doc);
    }


    $signal-doc ~= "\n  method handler (\n";
    $item-count = 0;
    my Str $first-arg = '';
    for @$items-src-doc -> $idoc {
#note "IDoc: $item-count, ", $idoc;
      if $item-count == 0 {
        $first-arg =
          "$idoc<item-type> \:widget\(\$$idoc<item-name>\)";
      }

      else {
        $signal-doc ~= "    {$idoc<item-type>//'-'} \$$idoc<item-name>,\n";
      }

      $item-count++;
    }

    $signal-doc ~= "    $first-arg,\n    \*\%user-options\n";
    $signal-doc ~= "    --> $return-type\n" if ?$return-type;
    $signal-doc ~= "  );\n\n";

    for @$items-src-doc -> $idoc {
      $signal-doc ~= "=item \$$idoc<item-name>; $idoc<item-doc>\n";
    }
#note "next signal";
  }
#note "last signal";

  my Str $bool-signals-added = '';
  my Str $build-add-signals = '';
  if ?$signal-doc {

    $signal-doc = Q:q:to/EOSIGDOC/ ~ $signal-doc ~ "\n=end pod\n\n";

      #-------------------------------------------------------------------------------
      =begin pod
      =head1 Signals

      There are two ways to connect to a signal. The first option you have is to use C<register-signal()> from B<Gnome::GObject::Object>. The second option is to use C<g_signal_connect_object()> directly from B<Gnome::GObject::Signal>.

      =head2 First method

      The positional arguments of the signal handler are all obligatory as well as their types. The named attributes C<:$widget> and user data are optional.

        # handler method
        method mouse-event ( GdkEvent $event, :$widget ) { ... }

        # connect a signal on window object
        my Gnome::Gtk3::Window $w .= new( ... );
        $w.register-signal( self, 'mouse-event', 'button-press-event');

      =head2 Second method

        my Gnome::Gtk3::Window $w .= new( ... );
        my Callable $handler = sub (
          N-GObject $native, GdkEvent $event, OpaquePointer $data
        ) {
          ...
        }

        $w.connect-object( 'button-press-event', $handler);

      Also here, the types of positional arguments in the signal handler are important. This is because both methods C<register-signal()> and C<g_signal_connect_object()> are using the signatures of the handler routines to setup the native call interface.

      =head2 Supported signals

      EOSIGDOC

    # create the class string to substitute in the source
    my Str $sig-class-str = '';
    for $signal-classes.kv -> $class, $signals {
      $sig-class-str ~= "\:$class\<";
      $sig-class-str ~= $signals.join(' ');
      $sig-class-str ~= '>, ';
    }

    $bool-signals-added = Q:q:to/EOBOOL/;
      my Bool $signals-added = False;
      #-------------------------------------------------------------------------------
      EOBOOL

    $build-add-signals = Q:q:to/EOBUILD/;
        # add signal info in the form of w*<signal-name>.
        unless $signals-added {
          $signals-added = self.add-signal-types( $?CLASS.^name,
            SIG_CLASS_STR
          );

          # signals from interfaces
          #_add_..._signal_types($?CLASS.^name);
        }
      EOBUILD
      $build-add-signals ~~ s/SIG_CLASS_STR/$sig-class-str/;

    # and append signal data to result module
    $output-file.IO.spurt( $signal-doc, :append);
  }

  # load the module for substitutions
  my Str $module = $output-file.IO.slurp;

  # substitute
  $module ~~ s/ 'BOOL-SIGNALS-ADDED' /$bool-signals-added/;
  $module ~~ s/ 'BUILD-ADD-SIGNALS' /$build-add-signals/;

  # rewrite
  $output-file.IO.spurt($module);
}
}}
#`{{
#-------------------------------------------------------------------------------
sub get-properties ( Str:D $source-content is copy ) {

  return unless $source-content;

  my Str $property-name;
  my Str $property-doc = '';

  loop {
    $property-name = '';

#`{{
    $source-content ~~ m/
      $<property-doc> = [
          [ '/**'                           # start c-comment block
            \s+ '*' \s+ [<alnum>||'-']+     # first line has Gtk class name
           ':' [<alnum>||'-']+ ':'          # and a :property name:
            [^^ \s+ '*' <!before '/'> .*? $$ ]*    # anything else but '*/'
            \s* '*/'                        # till the end of c-comment
          ]?                                # sometimes there's no comment block
          \s+ [ 'g_object_interface_install_property' .*? ||
                                            # sometimes a call for interfaces
            'props[' <-[\]]>+ ']' \s* '=' \s*
                                            # sometimes there's an array def
          ]                             # anything else
        'g_param_spec_'                     # till prop spec starts
        .*? ');'                            # till the spec ends
      ]
    /;
}}
    $source-content ~~ m/
      $<property-doc> = [
        [ '/**'                           # start c-comment block
          \s+ '*' \s+ [<alnum>||'-']+     # first line has Gtk class name
         ':' [<alnum>||'-']+ ':'          # and a :property name:
          .*? '*/'                        # till the end of c-comment
        ]?                                # sometimes there's no comment block
                                          # optional comment block
        \s+ [ 'g_object_interface_install_property' .*? ||
                                          # sometimes a call for interfaces
         'g_object_class_install_property' .*? ||
                                          # sometimes a call for classes
          <alnum>*? 'props[' <-[\]]>+ ']' \s* '=' \s*
                                          # sometimes there's an array def
        ]                                 # anything else
        'g_param_spec_'                   # till prop spec starts
        .*? ');'                          # till the spec ends
      ]
    /;

    my Str $sdoc = ~($<property-doc> // '');
#note "sdoc: ", ?$sdoc;
    last unless ?$sdoc;

    # remove from source
    $source-content ~~ s/$sdoc//;

    # skip deprecated properties
    next if $sdoc ~~ m/ '*' \s+ 'Deprecated:' /;

    my Bool $has-doc = ($sdoc ~~ m/ '/**' / ?? True !! False);
#note "\nHD: $has-doc: ", $sdoc;

    unless ?$property-doc {
      $property-doc ~= Q:to/EODOC/;

        #-------------------------------------------------------------------------------
        =begin pod
        =head1 Properties

        An example of using a string type property of a B<Gnome::Gtk3::Label> object. This is just showing how to set/read a property, not that it is the best way to do it. This is because a) The class initialization often provides some options to set some of the properties and b) the classes provide many methods to modify just those properties. In the case below one can use B<new(:label('my text label'))> or B<gtk_label_set_text('my text label')>.

          my Gnome::Gtk3::Label $label .= new;
          my Gnome::GObject::Value $gv .= new(:init(G_TYPE_STRING));
          $label.g-object-get-property( 'label', $gv);
          $gv.g-value-set-string('my text label');

        =head2 Supported properties
        EODOC

    }
#note "Property sdoc 1:\n", $sdoc;

    if $has-doc {
      $sdoc ~~ m/
        ^^ \s+ '*' \s+ $lib-class-name ':'
        $<prop-name> = [ <-[:]> [<alnum> || '-']+ ]
      /;
      $property-name = ~($<prop-name> // '');
    }
# $property-name must come from call to param_spec

# note "sdoc 2: $sdoc";

    # modify and cleanup
    $sdoc ~~ s/ ^^ \s+ '*' \s+ <alnum>+ ':' [ <alnum> || '-' ]+ ':' \n //
      if $has-doc;

    $sdoc ~~ m/ ^^ \s+ 'g_param_spec_' $<prop-type> = [ <alnum>+ ] \s* '(' /;
    my Str $spec-type = ~($<prop-type> // '' );
    my Str $prop-type = 'G_TYPE_' ~ $spec-type.uc;

    my Str $prop-args = $sdoc;
    my Str ( $prop-name, $prop-nick, $prop-blurp);

    if $has-doc {
#      $prop-name = $property-name;
      $sdoc = primary-doc-changes($sdoc);
      $sdoc = cleanup-source-doc($sdoc);
    }

    else {
      $sdoc = '';
    }


    $prop-args ~~ s/ .*? 'g_param_spec_' $spec-type \s* '(' //;
    $prop-args ~~ s/ '));' //;

    # process arguments. first rename commas in string into _COMMA_
    my Bool $in-string = False;
    my Str $temp-prop-args = $prop-args;
    $prop-args = '';
    for $temp-prop-args.split('')[1..*-2] -> $c {
#note "C: '$c'";
      if $c eq '"' {
        $in-string = !$in-string;
        $prop-args ~= '"';
        next;
      }

      if $in-string and $c eq ',' {
        $prop-args ~= '_COMMA_';
      }

      else {
        $prop-args ~= $c;
      }
    }
#note $prop-args;

    my @args = ();
    for $prop-args.split(/ \s* ',' \s* /) -> $arg is copy {
      $arg ~~ s/ '_COMMA_' /,/;
      $arg ~~ s/ 'P_(' //;
      $arg ~~ s/ ')' //;
      $arg ~~ s:g/ \" \s+ \" //;
      $arg ~~ s:g/ \" //;
      @args.push($arg);
    }
#note "args: ", @args.join(', ');

    $prop-name = @args[0];
    $prop-nick = @args[1];
    $prop-blurp = $has-doc ?? $sdoc !! @args[2];

    my Str $flags;
    my Str $gtype-string;
    my $prop-default;
    my Str $prop-doc = '';
    given $spec-type {

      when 'boolean' {
        $prop-default = @args[3] ~~ 'TRUE' ?? True !! False;
        $flags = @args[4];

        $prop-doc = Q:qq:to/EOP/;
          $prop-blurp

          Default value: $prop-default
          EOP
      }

      when 'string' {
        $prop-default = @args[3] ~~ 'NULL' ?? 'Any' !! @args[3];
        $flags = @args[4];

        $prop-doc = Q:qq:to/EOP/;
          $prop-blurp

          Default value: $prop-default
          EOP
      }

      when 'enum' {
        $gtype-string = @args[3];
        $prop-default = @args[4] ~~ 'TRUE' ?? True !! False;
        $flags = @args[5];

        $prop-doc = Q:qq:to/EOP/;
          $prop-blurp

          Default value: $prop-default
          EOP
      }

      when 'object' {
        $gtype-string = @args[3];
        $flags = @args[4];

        $prop-doc = Q:qq:to/EOP/;
          $prop-blurp

          Widget type: $gtype-string
          EOP
      }

      when '' {
      }

    }

    if $has-doc {
      $sdoc ~= "Widget type: $gtype-string\n" if ?$gtype-string;
#      $sdoc ~= "Flags: $flags\n" if ?$flags;
    }

    else {
      $sdoc = $prop-doc;
      $sdoc = primary-doc-changes($sdoc);
      $sdoc = cleanup-source-doc($sdoc);
    }

    $sdoc ~~ s:g/\n\n/\n/;;


#note "sdoc 3: ", $sdoc if $has-doc;

    note "get property $prop-name";
    $property-doc ~= Q:qq:to/EOHEADER/;

      =comment #TP:0:$prop-name:
      =head3 $prop-nick

      $sdoc
      The B<Gnome::GObject::Value> type of property I<$prop-name> is C<$prop-type>.
      EOHEADER
#note "end prop";
  }
#note "end of all props";

  $property-doc ~= "=end pod\n" if ?$property-doc;

  $output-file.IO.spurt( $property-doc, :append);
}
}}

#-------------------------------------------------------------------------------
sub get-vartypes ( Str:D $include-content ) {

#  my Str $enums-doc = get-enumerations($include-content);
#  my Str $structs-doc = get-structures($include-content);

  get-enumerations($include-content);
#  get-structures($include-content);
}

#-------------------------------------------------------------------------------
sub get-enumerations ( Str:D $include-content is copy ) {

  my Str $enums-doc = Q:qq:to/EODOC/;

    #-------------------------------------------------------------------------------
    =begin pod
    =head1 Types
    =end pod
    EODOC


  my Bool $found-doc = False;

  loop {
    my Str $enum-name = '';
    my Str $items-doc = '';
    my Str $enum-doc = '';
    my Str $enum-spec = '';

    $include-content ~~ m:s/
      $<enum-type-section> = [
         '/**' .*? '*/' 'typedef' 'enum' \w* '{' .*? '}' <-[;]>+ ';'
      ]
    /;
    my Str $enum-type-section = ~($<enum-type-section> // '');
#note $enum-type-section;

    # if no enums are found, clear the string
    if !?$enum-type-section {
      $enums-doc = '' unless $found-doc;
      last;
    }

    # this match "m:g/'/**' .*? '*/' ...etc... /" can fail. It can gather
    # too many comment blocks to stop at a final enum. So try to find the
    # last doc section.
    my Int $start-doc = 1;  # There is a '/**' string at 0!
    my Int $x;
    while ?($x = $enum-type-section.index( '/**', $start-doc)) {
      $start-doc = $x + 1;
    }

    $start-doc -= 1;
    $enum-type-section = $enum-type-section.substr(
      $start-doc, $enum-type-section.chars - $start-doc
    );

    # remove type info for next search
    $include-content ~~ s/ $enum-type-section //;

    # enums found
    $found-doc = True;

    my Bool ( $get-item-doc, $get-enum-doc, $process-enum) =
            ( False, False, False);

    for $enum-type-section.lines -> $line {
#note "Line: $line";

      next if $line ~~ m/ '/**' /;

      if $line ~~ m/ ^ \s+ '*' \s+ $<enum-name> = [<alnum>+] ':' \s* $ / {
        $enum-name = ~($<enum-name>//'');
        note "get enumeration $enum-name";
        $get-item-doc = True;
      }

      elsif $line ~~ m/ ^ \s+ '* @' $<item> = [ <alnum>+ ':' .* ] $ / {
        $items-doc ~= "\n=item " ~ ~($<item>//'');
#note "Item: $items-doc";
      }

      # on empty line swith from item to enum doc
      elsif $line ~~ m/ ^ \s+ '*' \s* $ / {
        $get-item-doc = False;
        $get-enum-doc = True;

        $enum-doc ~= "\n";
      }

      # end of type documentation
      elsif $line ~~ m/ ^ \s+ '*'*? '*/' \s* $ / {
        $get-item-doc = False;
        $get-enum-doc = False;
        $process-enum = True;

        $enum-spec = "\n=end pod\n\n#TE:0:$enum-name:\nenum $enum-name is export (\n";
      }

      elsif $line ~~ m/ ^ \s+ '*' \s* 'Since:' .* $ / {
        # ignore
      }

      elsif $line ~~ m/ ^ \s+ '*' \s+ $<doc> = [ \S .* ] $ / {
        if $get-item-doc {
          $items-doc ~= " " ~ ~($<doc>//'');
        }

        elsif $get-enum-doc {
          $enum-doc ~= "\n" ~ ~($<doc>//'');
        }
      }

      elsif $line ~~ m/ ^ \s+ $<item-name> = [<alnum>+ <-[,]>* ','? ] \s* $ / {
        my Str $s = ~($<item-name> // '');
        $s ~~ s/ '=' /=>/;
        $s ~~ s/ '<<' /+</;
        $s ~~ s/ ( <alnum>+ ) /'$/[0]'/;
        $enum-spec ~= "  $s\n";
      }

      elsif $line ~~ m:s/ '}' $enum-name ';' / {
        $enum-spec ~= ");\n";
      }
    }

    # remove first space
    $enum-doc ~~ s/ ^ \s+ //;

    $enum-doc = primary-doc-changes($enum-doc);
    $enum-doc = cleanup-source-doc($enum-doc);
    $items-doc = primary-doc-changes($items-doc);

    $enums-doc ~= Q:qq:to/EODOC/;
      #-------------------------------------------------------------------------------
      =begin pod
      =head2 enum $enum-name

      $enum-doc

      $items-doc

      $enum-spec
      EODOC
  }

  $output-file.IO.spurt( $enums-doc, :append);
}

#-------------------------------------------------------------------------------
sub get-structures ( Str:D $include-content is copy ) {

  my Str $structs-doc = '';
  my Bool $found-doc = False;

  # now we try again to get structs
  loop {
    my Str $struct-name = '';
    my Str $items-doc = '';
    my Str $struct-doc = '';
    my Str $struct-spec = '';
    my Str ( $entry-type, $raku-entry-type);
    my Bool $type-is-class;

    $include-content ~~ m:s/
      $<struct-type-section> = [
          '/**' .*? '*/' struct <-[{]>+ '{' <-[}]>+ '};'
      ]
    /;

    my Str $struct-type-section = ~($<struct-type-section> // '');
#note $struct-type-section;

    # if no structs are found, clear the string
    if !?$struct-type-section {
      $structs-doc = '' unless $found-doc;
      last;
    }

    # this match "m:g/'/**' .*? '*/' ...etc... /" can fail. It can gather
    # too many comment blocks to stop at a final struct. So try to find the
    # last doc section.
    my Int $start-doc = 1;  # There is a '/**' string at 0!
    my Int $x;
    while ?($x = $struct-type-section.index( '/**', $start-doc)) {
      $start-doc = $x + 1;
    }

    $start-doc -= 1;
    $struct-type-section = $struct-type-section.substr(
      $start-doc, $struct-type-section.chars - $start-doc
    );
#note $struct-type-section;


    # remove struct info for next search
    $include-content ~~ s/$struct-type-section//;

    # structs found
    $found-doc = True;
    my Bool $struct-skip = False;

    my Bool ( $get-item-doc, $get-struct-doc, $process-struct) =
            ( False, False, False);

    for $struct-type-section.lines -> $line {
      next if $line ~~ m/ '/**' /;

      if $line ~~ m/^ \s+ '*' \s+ $<struct-name> = [<alnum>+] ':' \s* $/ {
        $struct-name = 'N-' ~ ~($<struct-name> // '');

        # skip this structure if it is about this classes structure
        if $struct-name ~~ m/ \w+ Class $/ {
          $struct-skip = True;
          last;
        }
        note "get structure $struct-name";
        $get-item-doc = True;
      }

      elsif $line ~~ m/^ \s+ '*' \s+ '@' $<item> = [ <alnum>+ ':' .* ] $ / {
        # Add extra characters to insert type information later on
        $items-doc ~= "\n=item ___" ~ ~($<item>//'');
#note "Item: $items-doc";
      }

      # on empty line swith from item to enum doc
      elsif $line ~~ m/ ^ \s+ '*' \s* $ / {
        $get-item-doc = False;
        $get-struct-doc = True;

        $struct-doc ~= "\n";
      }

      # end of type documentation
      elsif $line ~~ m/ ^ \s+ '*'*? '*/' \s* $ / {
        $get-item-doc = False;
        $get-struct-doc = False;
        $process-struct = True;

        $struct-spec = "\n=end pod\n\n#TT:0:$struct-name:\n" ~
          "class $struct-name is export is repr\('CStruct') \{\n";
      }

      elsif $line ~~ m/ ^ \s+ '*' \s* 'Since:' .* $ / {
        # ignore
      }

      elsif $line ~~ m/ ^ \s+ '*' \s+ $<doc> = [ \S .* ] $ / {
        if $get-item-doc {
          $items-doc ~= " " ~ ~($<doc>//'');
        }

        elsif $get-struct-doc {
          $struct-doc ~= "\n" ~ ~($<doc>//'');
        }
      }

      elsif $line ~~ m:s/ '};' / {
        $struct-spec ~= "}\n";
      }

      elsif $line ~~ m/^ \s+ $<struct-entry> = [ .*? ] ';' $/ {
        my Str $s = ~($<struct-entry> // '');
        ( $s, $entry-type, $raku-entry-type, $type-is-class) =
          get-type($s);

        # entry type Str must be converted to str
        $entry-type ~~ s/Str/str/;

        # if there is a comma separated list then split vars up
        if $s ~~ m/ ',' / {
          my @varlist = $s.split( / \s* ',' \s* /);
          for @varlist -> $var {
            $struct-spec ~= "  has $entry-type \$.$var;\n";
            $items-doc ~~ s/ 'item ___' $var /item $raku-entry-type \$.$var/;
          }
        }

        # $s is holding a single var
        else {
          $struct-spec ~= "  has $entry-type \$.$s;\n";
  #note "check for 'item ___$s'";
          $items-doc ~~ s/ 'item ___' $s /item $raku-entry-type \$.$s/;
        }
      }
    }

    # remove first space
    $struct-doc ~~ s/ ^ \s+ //;

    $struct-doc = primary-doc-changes($struct-doc);
    $items-doc = primary-doc-changes($items-doc);

    unless $struct-skip {
      $structs-doc ~= Q:qq:to/EODOC/;
        #-------------------------------------------------------------------------------
        =begin pod
        =head2 class $struct-name

        $struct-doc

        $items-doc

        $struct-spec
        EODOC
    }
  }

  $output-file.IO.spurt( $structs-doc, :append);
}

#-------------------------------------------------------------------------------
sub cleanup-source-doc ( Str:D $text is copy --> Str ) {

  # remove property and signal line
  $text ~~ s/ ^^ \s+ '*' \s+ $lib-class-name ':'+ .*? \n //;

  $text ~~ s/ ^^ '/**' .*? \n //;                       # Doc start
  $text ~~ s/ \s* '*/' .* $ //;                         # Doc end
  $text ~~ s/ 'Since:' \s* \d+\.\d+ //;                 # Since: version
  $text ~~ s:g/ ^^ \s+ '*' ' '? (.*?) $$ /$/[0]/;       # Leading star
  $text ~~ s:g/ ^^ \s+ '*' \s* \n //;                   # Leading star on Empty line
#  $text ~~ s:g/ ^^ \s* \n //;
  $text ~~ s:g/ \n <!before <[\n]>> / /;

  $text ~~ s:g/ '<firstterm>' /I</;
  $text ~~ s:g/ '</firstterm>' />/;
  $text ~~ s:g/ '<emphasis>' /B</;
  $text ~~ s:g/ '</emphasis>' />/;
  $text ~~ s:g/ '<function>' /C</;
  $text ~~ s:g/ '</function>' />/;
  $text ~~ s:g/ '<informalexample>' / /;
  $text ~~ s:g/ '</informalexample>' / /;
  $text ~~ s:g/ '<programlisting>' /\n\n/;
  $text ~~ s:g/ '</programlisting>' /\n\n/;
  $text ~~ s:g/ '<screen>' /\n\n/;
  $text ~~ s:g/ '</screen>' /\n\n/;

  # keep a space, otherwise other subs will change it
  $text ~~ s:g/ '<!--' .*? '-->' / /;
#  $text ~~ s:g/ '/*' .*? '*/' / /;
#  $text ~~ s:g/ \s+ / /;
  $text
}

#-------------------------------------------------------------------------------
sub primary-doc-changes ( Str:D $text is copy --> Str ) {

  $text = podding-class($text);
#  $text = podding-signal($text);
#  $text = podding-property($text);
  $text = modify-at-vars($text);
  $text = modify-percent-types($text);
  $text = podding-function($text);
  $text = adjust-image-path($text);

  $text
}

#-------------------------------------------------------------------------------
# change any #GtkClass to B<Gnome::Gtk::Class> and Gdk likewise
sub podding-class ( Str:D $text is copy --> Str ) {

  loop {
    # check for property spec with classname in doc
    $text ~~ m/ '#' (<alnum>+) ':' ([<alnum> || '-']+) /;
    my Str $oct = ~($/[1] // '');
    last unless ?$oct;

    $text ~~ s/ '#' (<alnum>+) ':' [<alnum> || '-']+ / I\<$oct\>/;
  }

  loop {
    # check for signal spec with classname in doc
    $text ~~ m/ '#' (<alnum>+) '::' ([<alnum> || '-']+) /;
    my Str $oct = ~($/[1] // '');
    last unless ?$oct;

    $text ~~ s/ '#' (<alnum>+) '::' [<alnum> || '-']+ / I\<$oct\>/;
  }

  loop {
    # check for class specs
    $text ~~ m/ '#' (<alnum>+) /;
    my Str $oct = ~($/[0] // '');
    last unless ?$oct;

    $oct ~~ s/^ ('Gtk' || 'Gdk') (<alnum>+) /Gnome::$/[0]3::$/[1]/;
    $text ~~ s/ '#' (<alnum>+) /B\<$oct\>/;
  }

  # convert a few without leading octagon (#)
  $text ~~ s:g/ <!after '%' > ('Gtk' || 'Gdk') (\D <alnum>+)
              /B<Gnome::$/[0]3::$/[1]>/;

  $text
}

#`{{
#-------------------------------------------------------------------------------
# change any ::signal to I<signal>
sub podding-signal ( Str:D $text is copy --> Str ) {

  loop {
    last unless $text ~~ m/ \s '::' [<alnum> || '-']+ /;
    $text ~~ s/ \s '::' ([<alnum> || '-']+) / I<$/[0]>/;
  }

  $text
}

#-------------------------------------------------------------------------------
# change any :property to I<property>
sub podding-property ( Str:D $text is copy --> Str ) {

  loop {
    last unless $text ~~ m/ \s ':' [<alnum> || '-']+ /;
    $text ~~ s/ \s ':' ([<alnum> || '-']+) / I<$/[0]>/;
  }

  $text
}
}}

#-------------------------------------------------------------------------------
# change any function() to C<function()>
sub podding-function ( Str:D $text is copy --> Str ) {

  # change any function() to C<function()>. first change to [[function]] to
  # prevent nested substitutions.
  $text ~~ s:g/ ([<alnum> || '_']+) \s* '()' /\[\[$/[0]\]\]/;
  $text ~~ s:g/ '[[' ([<alnum> || '_']+ )']]' /C<$/[0]\()>/;

  $text
}

#-------------------------------------------------------------------------------
# change any %type to C<type>
sub modify-percent-types ( Str:D $text is copy --> Str ) {
  $text ~~ s:g/ '%TRUE' /C<1>/;
  $text ~~ s:g/ '%FALSE' /C<0>/;
  $text ~~ s:g/ '%NULL' /C<Any>/;
  $text ~~ s:g/ '%' ([<alnum> || '_' ]+) /C<$/[0]>/;

  $text
}

#-------------------------------------------------------------------------------
# change any @var to I<var>
sub modify-at-vars ( Str:D $text is copy --> Str ) {
  $text ~~ s:g/ '@' (<alnum>+) /I<$/[0]>/;

  $text
}

#-------------------------------------------------------------------------------
# change any ![alt](path) to ![alt](images/path)
sub adjust-image-path ( Str:D $text is copy --> Str ) {
  $text ~~ s:g/ '![' (<-[\]]>*) '](' (<-[\)]>+) ')'
              /\!\[$/[0]\]\(images\/$/[1]\)/;

  $text
}
