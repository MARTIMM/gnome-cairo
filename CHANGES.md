## Release notes
* 2021-12-12 0.2.2
  * Changes for renamed methods in **Gnome::N::TopLevelClassSupport**.

* 2021-04-05 0.2.1
  * renamed `xt/c5.raku` and made small modifications for changes from other modules.

* 2020-11-17 0.2.0
  * Improve **Gnome::Cairo::ImageSurface**, new option `:png` to initialize and added tests. method `.cairo_image_surface_create_from_png()` dropped in favor of the .new(:png).
  * Added `cairo_status_to_string()` to **Gnome::Cairo**.

* 2020-06-24 0.1.1
  * Several modules changed and tests added. The tests also involve use with GTK and GDK.

* 2020-06-24 0.1.0
  * Got some modules working;
    * Enums for all enumerations
    * Types for all types used in Cairo. Maybe the lot will be renamed!
    * Already useful are FontFace, ImageSurface, Path, Pattern, Surface and Cairo.

* 2020-06-10 0.0.1
  * Start Cairo project
