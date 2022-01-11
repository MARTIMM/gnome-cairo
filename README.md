![gtk logo][logo]

# Cairo - Binding of Cairo to the Gnome modules

![T][travis-svg] ![A][appveyor-svg] ![L][license-svg]

[travis-svg]: https://travis-ci.org/MARTIMM/gnome-cairo.svg?branch=master
[travis-run]: https://travis-ci.org/MARTIMM/gnome-cairo

[appveyor-svg]: https://ci.appveyor.com/api/projects/status/github/MARTIMM/gnome-cairo?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true
[appveyor-run]: https://ci.appveyor.com/project/MARTIMM/gnome-cairo/branch/master

[license-svg]: http://martimm.github.io/label/License-label.svg
[licence-lnk]: http://www.perlfoundation.org/artistic_license_2_0

# Description

Cairo is a 2D graphics library with support for multiple output devices. Currently supported output targets include the X Window System (via both Xlib and XCB), Quartz, Win32, image buffers, PostScript, PDF, and SVG file output. Experimental backends include OpenGL, BeOS, OS/2, and DirectFB.

This package can be used on its own but it is meant to be used by the other Gnome packages to draw in widgets. However, if you want to use it standalone to make drawings saved in a file on disk, I would advice you to use the **Cairo** package of Timo.

# Documentation
* [ 🔗 Website](https://martimm.github.io/gnome-gtk3/content-docs/reference-cairo.html)
* [ 🔗 Travis-ci run on master branch][travis-run]
* [ 🔗 Appveyor run on master branch][appveyor-run]
* [ 🔗 License document][licence-lnk]
* [ 🔗 Release notes][changes]
* [ 🔗 Issues](https://github.com/MARTIMM/gnome-gtk3/issues)

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
