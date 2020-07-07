![gtk logo][logo]

# Gnome Gio -

[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Description

Cairo is a 2D graphics library with support for multiple output devices. Currently supported output targets include the X Window System (via both Xlib and XCB), Quartz, Win32, image buffers, PostScript, PDF, and SVG file output. Experimental backends include OpenGL, BeOS, OS/2, and DirectFB.

This package can be used on its own but it is meant to be used by the other Gnome package to draw in widgets. However, if you want to use it standalone to make drawings saved in a file on disk, I would advice you to use the **Cairo** package of Timo.

# Documentation
## Release notes
* [Release notes][changes]

# Installation
As mentioned above, this package can be used on its own. But better install **Gnome::Gtk3** instead.

`zef install Gnome::Cairo`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**

# Issues

There are always some problems! If you find one please help by filing an issue at [my Gnome::Gtk3 github project][issues].

# Attribution
* The inventors of Raku (formerly called Perl6) of course and the writers of the documentation which help me out every time again and again.
* The builders of the GTK+ library and the documentation.
* The builders of the Cairo library and the documentation.
* Other helpful modules for their insight and use.

[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/perl6-gnome-gobject/blob/master/CHANGES.md
[logo]: https://martimm.github.io/perl6-gnome-gtk3/content-docs/images/gtk-perl6.png
[issues]: https://github.com/MARTIMM/perl6-gnome-gtk3/issues
