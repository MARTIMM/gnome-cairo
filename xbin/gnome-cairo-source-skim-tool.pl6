#!/usr/bin/env raku

use v6;

#-------------------------------------------------------------------------------
my Str $library = '';
my Str $include-filename;
my Str ( $section-doc, $short-description, $see-also);

my Str $root-dir = '/home/marcel/Languages/Raku/Projects/gnome-cairo';
my @cairodirlist = "$root-dir/xbin/cairo-list.txt".IO.slurp.lines;

$root-dir = '/home/marcel/Languages/Raku/Projects/gnome-gtk3';
my @enum-list = "$root-dir/Design-docs/skim-tool-enum-list".IO.slurp.lines;

my Bool $class-is-leaf;
my Bool $class-is-role; # is leaf implicitly
my Bool $class-is-top;
#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $base-name, Bool :$main = False,
  Bool :$sub = False, Bool :$types = False, Bool :$test = False,

# force true because cairo doesn't do casting...
  Bool :$leaf = True
) {

  my Str $*base-sub-name;
  my Str $*library = '';
  my Str $*raku-lib-name;
  my Str $*lib-class-name;
  my Str $*raku-class-name;
  my Str $*no-type-name;
  my Str $*output-file;

  my Bool $do-all = !( [or] $main, $sub, $types, $test );
  $class-is-leaf = $leaf;

  $*base-sub-name = $*base-sub-name // $base-name;

  my Bool $file-found;
  my Str ( $include-content, $source-content);
  $*base-sub-name = $*base-sub-name // $base-name;

  ( $include-content, $source-content) = setup-names($base-name);

  mkdir( 'xt', 0o766) unless 'xt'.IO.e;
  mkdir( 'xt/NewModules', 0o766) unless 'xt/NewModules'.IO.e;

  ( $section-doc, $short-description, $see-also) = get-section($source-content);

  substitute-in-template( $do-all, $main, $types, $include-content);
  get-subroutines( $include-content, $source-content) if $do-all or $sub;
  generate-test if $test or $do-all;
}

#-------------------------------------------------------------------------------
sub get-subroutines( Str:D $include-content, Str:D $source-content ) {

  my Str $sub-doc = '';
  my Array $items-src-doc = [];

  # get all subroutines starting with '/** ... **/ sub declaration'. body is
  # skipped. sometimes there is a declaration of structures using { }. because
  # body is skipped, ignore the curly brackets too.
  $source-content ~~ m:g/
    $<comment-doc> = ('/**' .*? '**/')
    [ ['/*' .*? '*/'] || ['/**' .*? '**/'] ]*
    $<declaration> = ( <-[({]>+ '(' <-[)]>+ ')' )
  /;
  my List $results = $/[*];

  # process subroutines
  print "Find subroutines ";
  my Hash $sub-documents = %();
  for @$results -> $r {

    my Str $comment-doc = ~$r<comment-doc>;
    my Str $declaration = ~$r<declaration>;

    # defines are also caught when () are used but defs are not subs -> skip
    next if $declaration ~~ m/ '#define' /;

    # sometime there is extra doc for the routine which must be removed
    # this ends up in the declaration
    $declaration ~~ s:g/ '/*' .*? '*/' //;

    next if $declaration ~~ m/^ \s* '/**' /;
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
    ( $sub-doc, $items-src-doc) = get-sub-doc($comment-doc);

#note "Pod items: $items-src-doc.elems()\n  ", $items-src-doc.join("\n  ");

    my Str $args-declaration = $declaration;
    my Str ( $pod-args, $call-args, $args, $pod-doc-items) = ( '', '', '', '');
    my Bool $first-arg = True;
    my Str $convert-lines = "";
    my Str $method-args = '';

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
          if $raku-arg-type ~~ any(
            < N-GObject N-GSList N-GList N-GOptionContext N-GOptionGroup
              N-GOptionEntry N-GError
            >
          ) {

            $convert-lines ~= "  \$$arg .= _get-native-object-no-reffing unless \$$arg ~~ $raku-arg-type;\n";

            $method-args ~= ',' if ?$method-args;
            $method-args ~= " \$$arg is copy";
            $call-args ~= ',' if ?$call-args;
            $call-args ~= " \$$arg";
            $pod-args ~= ',' if ?$pod-args;
            $pod-args ~= " $raku-arg-type \$$arg";
          }

          elsif $raku-arg-type eq 'Int-ptr' {
            # don't define method args should insert '--> List' at the end
            # also no pod args and also add '--> List' at the end, but how
            # and not always if it only one
            $raku-arg-type = 'Int';
            $call-args ~= ',' if ?$call-args;
            $call-args ~= " my gint \$$arg";
          }

          else {
            $method-args ~= ',' if ?$method-args;
            $method-args ~= " $raku-arg-type \$$arg";
            $call-args ~= ',' if ?$call-args;
            $call-args ~= " \$$arg";
            $pod-args ~= ',' if ?$pod-args;
            $pod-args ~= " $raku-arg-type \$$arg";
          }



          # remove some c-oriented remarks
          if ?$pod-doc-item-doc {
            $pod-doc-item-doc ~~ s:g/'(' [
                    nullable | 'transfer none' | 'transfer full' |
                    'allow-none' | 'not nullable' | 'array zero-terminated=1' |
                    optional | inout | out | in
                  ] ')' //;
            $pod-doc-item-doc ~~ s/^ \s* <[:;]> \s+ //;
            $pod-doc-item-doc ~~ s/ 'C<Any>-terminated' //;
            $pod-doc-items ~=
              "=item $raku-arg-type \$$arg; $pod-doc-item-doc\n";
          }

          else {
            $pod-doc-items ~= "=item $raku-arg-type \$$arg; \n";
          }

          $pod-doc-items ~~ s/^ \s+ $//;

        }

        # add argument to list for sub declaration
        $args ~= ', ' if ?$args;
        $args ~= "$arg-type \$$arg";
      }

      $first-arg = False;
    }

#note "2 >> $sub-name";
#note "3 >> $args";
#note "4 >> $return-type";

    $sub-doc = cleanup-source-doc($sub-doc);

    my Str $return-dot-comma = '';
#    my Str $pod-doc-return = '';
    my Str $pod-returns = '';
    my Str $returns = '';
    if ?$return-type and $return-type !~~ m/ void / {
      $pod-returns = " --> $raku-return-type";
      $returns = "--> $return-type";
    }

    my Str $start-comment = ''; # $variable-args-list ?? '#`{{' ~ "\n" !! '';
    my Str $end-comment = ''; # $variable-args-list ?? "\n" ~ '}}' !! '';

    my $pod-sub-name = pod-sub-name($sub-name);
    my Str $sub = '';
    my Str $pod-doc-key;
    my Str $return-conversion = '';
    given $raku-return-type {
      when 'Bool' { $return-conversion = '.Bool'; }
    }

    # process new subroutines. they will be sorted to the end and do not get a
    # method because they are accessed from BUILD. Also doc is commented out.
    if $class-is-leaf {
      $pod-doc-key = $pod-sub-name;

      $sub = Q:qq:to/EOSUB/;

        $start-comment#-------------------------------------------------------------------------------
        #TM:0:$pod-sub-name:
        =begin pod
        =head2 $pod-sub-name

        $sub-doc

          method $pod-sub-name ($pod-args$pod-returns )

        $pod-doc-items=end pod

        method $pod-sub-name ($method-args$pod-returns ) \{
        $convert-lines
          $sub-name\(
            self\._get-native-object-no-reffing,$call-args
          )$return-conversion$return-dot-comma
        \}

        sub $sub-name (
          $args $returns
        ) is native($*library)
          \{ * \}$end-comment
        EOSUB
    }

    # process methods in other classes. they do need casting
    else {
      $pod-doc-key = $pod-sub-name;
#note "get sub as $pod-sub-name";

      $sub = Q:qq:to/EOSUB/;

        $start-comment#-------------------------------------------------------------------------------
        #TM:0:$pod-sub-name:
        =begin pod
        =head2 $pod-sub-name

        $sub-doc

          method $pod-sub-name ($pod-args$pod-returns )

        $pod-doc-items=end pod

        method $pod-sub-name ($method-args$pod-returns ) \{
        $convert-lines
          $sub-name\(
            self\._f\('$*lib-class-name'),$call-args
          )$return-conversion$return-dot-comma
        \}

        sub $sub-name (
          $args $returns
        ) is native($*library)
          \{ * \}$end-comment
        EOSUB
    }

#    note $sub;

    $sub-documents{$pod-doc-key} = $sub;
  }
  print "\n";

  # place all non-new modules at the end
  for $sub-documents.keys.sort -> $key {
    note "save doc for sub $key";
    $*output-file.IO.spurt( $sub-documents{$key}, :append);
  }
}

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
        const \s+ unsigned \s+ [ int || long || char ] \s* '*'* ||
        unsigned \s+ [ int || long || char ] \s* '*'* ||
        const \s* <alnum>+ \s* '*'* \s* ||
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
#  $type ~~ s:g/ void \s* '*' \s* /OpaquePointer /;

  # convert a pointer char type
#  $type ~~ s/ [unsigned]? \s+ char \s* '*'*/Str/;
  $type ~~ s/ g?char \s* '*' \s* '*' \s* '*' /gchar-ppptr/;
  $type ~~ s/ g?char \s* '*' \s* '*' /gchar-pptr/;
  $type ~~ s/ g?char \s* '*' /gchar-ptr/;

  # convert other pointer types
  $type ~~ s/ void \s* '*' /void-ptr/;
  $type ~~ s/ g?int \s* '*' /gint-ptr/;

  # convert unsigned types
  $type ~~ s:s/ unsigned char /guint8/;
  $type ~~ s:s/ unsigned int32 /guint32/;
  $type ~~ s:s/ unsigned int64 /guint64/;
  $type ~~ s:s/ unsigned int /guint/;

#`{{
  # if there is still another pointer, make a CArray
#  $type = "CArray[$type]" if $type ~~ m/ '*' /;
  $type ~~ s:g/ '*' //;
#  $type ~~ s:g/ \s+ //;

#`{{
  if $declaration ~~ m/ ^ '...' / {
    $type = 'Any';
    $declaration = 'any = Any';
  }
}}
}}

#note "\nType: $type";
  # cleanup
  $type ~~ s:g/ '*' //;
  $type ~~ s/ \s+ / /;
  $type ~~ s/ \s+ $//;
  $type ~~ s/^ \s+ //;
  $type ~~ s/^ \s* $//;
#note "Cleaned type: $type";

  # check type for its class name
  my Bool $type-is-class = $type eq $*no-type-name;

  $type = 'gint32' if $type ~~ m/ cairo_bool_t /;
  $type = 'gfloat' if $type ~~ m/ real /;
  $type = 'gdouble' if $type ~~ m/ double /;

  if $type ~~ any(@enum-list) {
    $type = 'gint32';
  }

  # convert to Raku types
  my Str $raku-type = $type;
##`{{
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
#}}

##`{{
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

#}}

$declaration ~~ s/ \s+ / /;
$declaration ~~ s/ \s+ $//;
$declaration ~~ s/^ \s+ //;
$declaration ~~ s/^ \s* $//;

#note "Result type: $declaration, $type, raku type: $raku-type, is class = $type-is-class";

  ( $declaration, $type, $raku-type, $type-is-class)
}

#-------------------------------------------------------------------------------
sub setup-names ( Str:D $*base-sub-name --> List ) {
  my Str $include-file = $*base-sub-name;
  $include-file ~~ s:g/ '_' /-/;

  my @parts = $*base-sub-name.split(/<[_-]>/);
  $*lib-class-name = @parts>>.tc.join;
  $*lib-class-name ~~ s/^ Cairo(\w) /$/[0]/;
  $*raku-class-name = @parts>>.tc.join;
  $*raku-class-name ~~ s/^ Cairo(\w) /$/[0]/;

#note "Files etc.: $include-file, $*base-sub-name, $*lib-class-name, $*raku-class-name, @parts.raku()";
#exit(0);

  my $source-root = '/home/marcel/Software/Packages/Sources/Gnome';

  my Str ( $include-content, $source-content) = ( '', '');
  my Bool $file-found = False;
  my $path = "$source-root/cairo-1.16.0/src";

#note "Include $path/$include-file.h";
  if "$path/$include-file.h".IO.r {
    $file-found = True;
#    if $include-file eq 'gdk-pixbuf' and "$path/{$include-file}-core.h".IO.r {
#      $include-content = "$path/{$include-file}-core.h".IO.slurp;
#    }
#    else {
      $include-content = "$path/$include-file.h".IO.slurp;
#    }

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
    $*library = "&cairo-lib";
    $*raku-lib-name = 'Cairo';
  }

#note "Library: $library, $lib-class, $*raku-lib-name";

  $*no-type-name = $*base-sub-name ~ '_t';

#`{{
  ( $file-found, $include-file, $lib-class, $raku-class, $*raku-lib-name,
    $include-content, $source-content, $*no-type-name
  )
}}

  ( $include-content, $source-content)
}

#-------------------------------------------------------------------------------
sub pod-sub-name ( Str:D $sub-name --> Str ) {

  my Str $pod-sub-name = $sub-name;

  # sometimes the sub name does not start with the base name
  if $sub-name ~~ m/ ^ $*base-sub-name / {
    $pod-sub-name = $sub-name;

    # remove base subname and an '_', then test if there is another '_' to
    # see if a part could be made optional by circumventing with '[' and ']'.
    $pod-sub-name ~~ s/^ $*base-sub-name '_' //;
  }

  # and replace '_' with '-'
  $pod-sub-name ~~ s:g/ '_' /-/;

#note "psn: $sub-name, $pod-sub-name, $*base-sub-name";
  $pod-sub-name
}

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
    use Gnome::N::GlibToRakuTypes;

    use Gnome::Cairo::Types;
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

#  $template-text ~~ s:g/ 'MODULENAME' /$*raku-class-name/;
  if ?$*raku-class-name {
    $template-text ~~
      s:g/ 'LIBRARYMODULE' /{$*raku-lib-name}::{$*raku-class-name}/;
  }
  else {
    $template-text ~~
      s:g/ 'LIBRARYMODULE' /$*raku-lib-name/;
  }

#  $template-text ~~ s:g/ 'USE-LIBRARY-PARENT' /$t1/;
#  $template-text ~~ s:g/ 'ALSO-IS-LIBRARY-PARENT' /$t2/;

  $template-text ~~ s:g/ 'MODULE-SHORTDESCRIPTION' /$short-description/;
  $template-text ~~ s:g/ 'MODULE-DESCRIPTION' /$section-doc/;
  $template-text ~~ s:g/ 'MODULE-SEEALSO' /$see-also/;
  $template-text ~~ s:g/ 'LIBCLASSNAME' /$*lib-class-name/;

  if ?$*raku-class-name {
    $*output-file = "xt/NewModules/$*raku-class-name.rakumod";
  }
  else {
    $*output-file = "xt/NewModules/$*raku-lib-name.rakumod";
  }

  $*output-file.IO.spurt($template-text);

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

      =head3 default, no options

      Create a new RAKU-CLASS-NAME object.

        multi method new ( )


      =head3 :native-object

      Create a RAKU-CLASS-NAME object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

        multi method new ( N-GObject :$native-object! )

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

          #`{{ if there are options
          else {
            my $no;
            if ? %options<> {
              $no = %options<>;
              $no .= _get-native-object-no-reffing unless $no ~~ BASE-SUBNAME_t;
              $no = _.BASE-SUBNAME_new_..($no);
            }

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
              $no = _BASE-SUBNAME_new();
            }
            }}

            self.set-native-object($no);
          }
          }}

          # only after creating the native-object
          self._set-class-info('LIBCLASSNAME');
        }
      }

      #-------------------------------------------------------------------------------
      # no pod. user does not have to know about it.
      method _fallback ( $native-sub is copy --> Callable ) {

        my Callable $s;
        try { $s = &::("BASE-SUBNAME_$native-sub"); };
        try { $s = &::("cairo_$native-sub"); } unless ?$s;
        try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'cairo_' /;

        self._set-class-name-of-sub('LIBCLASSNAME');
        $s = callsame unless ?$s;

        $s;
      }

      EOTEMPLATE

    $template-text ~~ s:g/ 'NO-TYPE-NAME' /$*no-type-name/;
    $template-text ~~ s:g/ 'RAKU-CLASS-NAME' /$*raku-class-name/;
    $template-text ~~ s:g/ 'LIBRARYMODULE' /{$*raku-lib-name}::{$*raku-class-name}/;
    $template-text ~~ s:g/ 'BASE-SUBNAME' /$*base-sub-name/;
    $template-text ~~ s:g/ 'LIBCLASSNAME' /$*lib-class-name/;
    $*output-file.IO.spurt( $template-text, :append);
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

#-------------------------------------------------------------------------------
sub get-vartypes ( Str:D $include-content ) {

#  my Str $enums-doc = get-enumerations($include-content);
#  my Str $structs-doc = get-structures($include-content);

  get-enumerations($include-content);
#  get-structures($include-content);
}

#-------------------------------------------------------------------------------
sub get-enumerations ( Str:D $include-content is copy ) {

  my Bool $found-doc = False;
  my Hash $enum-docs = %();

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
#      $enums-doc = '' unless $found-doc;
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

#`{{
    $enums-doc ~= Q:qq:to/EODOC/;
      #-------------------------------------------------------------------------------
      =begin pod
      =head2 enum $enum-name

      $enum-doc

      $items-doc

      $enum-spec
      EODOC
}}
    $enum-docs{$enum-name} = Q:qq:to/EODOC/;
      #-------------------------------------------------------------------------------
      =begin pod
      =head2 enum $enum-name

      $enum-doc

      $items-doc

      $enum-spec
      EODOC
  }

#  $*output-file.IO.spurt( $enums-doc, :append);
   $*output-file.IO.spurt( Q:qq:to/EODOC/, :append);

    #-------------------------------------------------------------------------------
    =begin pod
    =head1 Types
    =end pod
    EODOC

  for $enum-docs.keys.sort -> $enum-name {
    $*output-file.IO.spurt( $enum-docs{$enum-name}, :append);
  }
}

#-------------------------------------------------------------------------------
sub cleanup-source-doc ( Str:D $text is copy --> Str ) {

  # remove property and signal line
  $text ~~ s/ ^^ \s+ '*' \s+ $*lib-class-name ':'+ .*? \n //;

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

#-------------------------------------------------------------------------------
sub generate-test ( ) {

  # create var name named after classname. E.g. TextBuffer -> $tb.
  my Str $m = '$' ~ $*raku-class-name.comb(/<[A..Z]>/).join.lc;
  my Str $class = [~] 'Gnome::', $*raku-lib-name, '::', $*raku-class-name;
#note "GT: $*raku-class-name, $*raku-lib-name, $m, $class";

  my Str $test-content = Q:q:s:b:to/EOTEST/;
    use v6;
    use NativeCall;
    use Test;

    use $class;

    use Gnome::Cairo::Types;
    use Gnome::Cairo::Enums;

    #use Gnome::N::X;
    #Gnome::N::debug(:on);

    #-------------------------------------------------------------------------------
    my $class $m;
    #-------------------------------------------------------------------------------
    subtest 'ISA test', {
      $m .= new;
      isa-ok $m, $class, '.new()';
    }

    #-------------------------------------------------------------------------------
    done-testing;

    =finish


    #-------------------------------------------------------------------------------
    # set environment variable 'raku-test-all' if rest must be tested too.
    unless %*ENV<raku_test_all>:exists {
      done-testing;
      exit;
    }

    #-------------------------------------------------------------------------------
    subtest 'Manipulations', {
    }

    EOTEST

  "xt/NewModules/$*raku-class-name.rakutest".IO.spurt($test-content);
  note "generate tests in xt/NewModules/$*raku-class-name.rakutest";
}
