![gtk logo][logo]

# Gnome Gio -

[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Description

From the Gnome documentation;

GIO is striving to provide a modern, easy-to-use VFS API that sits at the right level in the library stack, as well as other generally useful APIs for desktop applications (such as networking and D-Bus support). The goal is to overcome the shortcomings of GnomeVFS and provide an API that is so good that developers prefer it over raw POSIX calls. Among other things that means using GObject. It also means not cloning the POSIX API, but providing higher-level, document-centric interfaces.

That being said, the Raku implementation is not implementing all of it, only those parts interesting to the other packages like application, resource and settings handling or DBus I/O.


# Documentation
## Release notes
* [Release notes][changes]

# Installation
Do not install this package on its own. Instead install `Gnome::Gtk3`.

`zef install Gnome::Gtk3`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**

# Issues

There are always some problems! If you find one please help by filing an issue at [my Gnome::Gtk3 github project][issues].

# Attribution
* The inventors of Raku (formerly called Perl6) of course and the writers of the documentation which help me out every time again and again.
* The builders of the GTK+ library and the documentation.
* Other helpful modules for their insight and use.

[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/perl6-gnome-gobject/blob/master/CHANGES.md
[logo]: https://martimm.github.io/perl6-gnome-gtk3/content-docs/images/gtk-perl6.png
[issues]: https://github.com/MARTIMM/perl6-gnome-gtk3/issues
