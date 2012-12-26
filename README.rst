===============
 gitlab-debian
===============

Provides a debian binary package for gitlab & gitolite.

Once you build this package, there is no need for *-dev packages. In
other words, the package will compile nothing in production.

The package is self-contained. It will only depends on database
libraries and ruby1.9.1!

Available packages
==================

* gitlabhq-4.0

* gitlabhq-gitolite-3.2

Building
========

1. Clone the repo:
::

  $ git clone git://github.com/dgvncsz0f/gitlabhq-debian.git
  $ cd gitlabhq-debian

2. Update the submodules:
::

  $ git submodule init
  $ git submodule update

3. Build the package:
::

  $ dpkg-buildpackage -us -uc

That is it!
