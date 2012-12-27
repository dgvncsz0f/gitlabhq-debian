===============
 gitlab-debian
===============

Provides a debian binary package for gitlab & gitolite.

Once you build this package, there is no need for `*-dev` packages. In
other words, the package will compile nothing in production. I
consider this a big win over the official installing script.

This package is pretty much self-contained. Disregarding the database
dependency, it only required `ruby1.9.1`.

The postinst script is able to configure everything, using debconf. So
it should be a fairly straightforward process.

Available packages
==================

* gitlabhq (v4.0)

* gitlabhq-gitolite (v3.2)

* gitlabhq-nginx (TODO)

* gitlabhq-apache2 (TODO)

Configuration Files
===================

Use dpkg:
::

  $ dpkg-reconfigure gitlabhq

This will effectively change the following files:

* /var/www/gitlabhq/config/gitlab.yml

* /var/www/gitlabhq/config/database.yml

* /var/lib/gitlabhq/.gitconfig

You may also do this without an interactive interface:
::

  # retrieve all config options
  $ debconf-get-selections | grep gitlabhq >gitlabhq.config

  # edit as much as you like
  $ emacs gitlabhq.config

  # apply changes
  $ debconf-set-selections -c gitlabhq.config && \
      debconf-set-selections gitlabhq.config

N.B.: Only use this command to seed debconf values for packages that
      will be or are installed [man debconf-set-selections].

If you do this prior installing the package the config files will
configures properly. If you do this a later time, make sure to invoke
`dpkg-reconfigure -u gitlabhq` to apply changes.

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

  $ dpkg-buildpackage # -uc -us

You now should have all packages built.
