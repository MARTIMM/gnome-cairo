## Release notes
* 2024-04-04 0.3.0
  * Add `:api<1>` to all class names. Use statements loading the gnome libs have also the api<1> added. Api 1 is also added the 'META6.json' as well as to the dependencies of other gnome modules.

* 2023-01-01 0.2.8
  * Add deprecation messages of old code in **Gnome::Cairo::FontFace**,  **Gnome::Cairo::FontOptions**, **Gnome::Cairo::ImageSurface**, **Gnome::Cairo::Matrix**.

* 2022-10-13 0.2.7
  * File extensions renamed

* 2022-01- 0.2.6
  * Bugfixes in **Gnome::Cairo**.

* 2022-01- 0.2.5
  * Reviewed doc of **Gnome::Cairo::Surface**, **Gnome::Cairo::FontFace**, **Gnome::Cairo::Matrix** and **Gnome::Cairo::FontOptions** and added some tests.

* 2021-12-16 0.2.4
  * Change generator to not insert commands for glib type system. Modules are changed. Also type casting is not used in **Gnome::Cairo::**\*.
  * Modified api and doc of **Gnome::Cairo** along the lines of the tutorial.
  * Rewrite pod doc of **Gnome::Pattern**.

<!--
  * **Gnome::Cairo::Path** is deprecated because the structure `cairo_path_t` is enough to work with. Furthermore there are no specific native functions to manipulate paths. These are all done in **Gnome::Cairo::Cairo**.
-->

* 2021-12-16 0.2.3
  * Rewrite pod doc of **Gnome::Cairo**, **Gnome::Cairo::Surface**, **Gnome::Cairo::ImageSurface** and **Gnome::Cairo::Enums**. Most of the enums come from the Cairo module.
  * I've seen that the documentation is quite buggy. Need to work on this…

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
