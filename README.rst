===============
 gitlab-debian
===============

Provides a debian binary package for gitlab & gitolite.

Once you build this package, there is no need for `*-dev` packages. In
other words, the package will compile nothing in production.

The package is self-contained: only `ruby1.9.1` is required.

Available packages
==================

* gitlabhq (v4.0)

* gitlabhq-gitolite (v3.2)

Building
========

It takes only three steps:

1. Clone:
::

  $ git clone git://github.com/dgvncsz0f/gitlabhq-debian.git
  $ cd gitlabhq-debian

2. Source:
::

  $ git submodule init
  $ git submodule update

3. Build:
::

  $ dpkg-buildpackage -us -uc
