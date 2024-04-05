![gtk logo][logo]

# Cairo - Binding of Cairo to the Gnome modules

![L][license-svg]

[license-svg]: http://martimm.github.io/label/License-label.svg
[licence-lnk]: http://www.perlfoundation.org/artistic_license_2_0

# Description

Cairo is a 2D graphics library with support for multiple output devices. Currently supported output targets include the X Window System (via both Xlib and XCB), Quartz, Win32, image buffers, PostScript, PDF, and SVG file output. Experimental backends include OpenGL, BeOS, OS/2, and DirectFB.

This package can be used on its own but it is meant to be used by the other Gnome packages to draw in widgets. However, if you want to use it standalone to make drawings saved in a file on disk, I would advice you to use the **Cairo** package of Timo.

Note that all modules are now in `:api<1>`. This is done to prevent clashes with future distributions having the same class names only differing in this api string. So, add this string to your import statements and dependency modules of these classes in META6.json. Furthermore add this api string also when installing with zef.

I found out while developing the api<2> version, that it is possible to use the Cairo version of Timo. An example of this will be given later. So in some time, this package **Gnome::Cairo** will be deprecated.

# Documentation
<!--
* [ 🔗 Website](https://martimm.github.io/gnome-gtk3/content-docs/reference-cairo.html)
-->
* [ 🔗 License document][licence-lnk]
* [ 🔗 Release notes][changes]
* [ 🔗 Issues](https://github.com/MARTIMM/gnome-gtk3/issues)

# Installation
As mentioned above, this package can be used on its own. But better install **Gnome::Gtk3:api<1>** instead.

`zef install 'Gnome::Cairo:api<1>'`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**

# Issues

There are always some problems! If you find one please help by filing an issue at [my Gnome::Gtk3 github project][issues].

# Attribution
* The developers of Raku of course and the writers of the documentation which help me out every time again and again.
* The builders of the GTK+ library and the documentation.
* The builders of the Cairo library and the documentation.
* Other helpful modules for their insight and use.

[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/perl6-gnome-gobject/blob/master/CHANGES.md
[logo]: https://martimm.github.io/perl6-gnome-gtk3/content-docs/images/gtk-perl6.png
[issues]: https://github.com/MARTIMM/perl6-gnome-gtk3/issues
