===============
 gitlab-debian
===============

:todo: Database setup:
       https://github.com/gitlabhq/gitlabhq/blob/stable/doc/install/databases.md;
:todo: App initialization: rake gitlab:app:setup RAILS_ENV=production;
:todo: logrotate.d config files

Provides a debian binary package for gitlab & gitolite.

Once you build this package, there is no need for `*-dev` packages. In
other words, the package will compile nothing in production. I
consider this a big win over the official installing script.

This package is pretty much self-contained. Disregarding the database
dependency, it only requires `ruby1.9.1`.

The postinst script is able to configure everything, using debconf. So
it should be a fairly straightforward process.

After installing and configuring the package, provided you got
dependencies right [namely the database and redis], you can use
gitlabhq itself to validate the deployment:
::

  $ cd /var/www/gitlabhq
  $ su gitlab -c "/usr/libexec/gitlabhq/env rake gitlab:check"

Installing
==========
::

  # todo: need to provide a source repo for this to work
  $ apt-get install gitlabhq-gitolite gitolite
  $ dpkg-reconfigure gitlabhq

  $ cd /var/www/gitlabhq

  # initialize the application
  $ su gitlab -c "/usr/libexec/gitlabhq/env rake gitlab:app:setup"

  # verify everything is Ok
  $ su gitlab -c "/usr/libexec/gitlabhq/env rake gitlab:check"

  # yay!
  $ /etc/init.d/gitlabhq start

Layout
======

Users
-----

:gitlab: gitlab
:gitolite: git

Home Directories
----------------

:gitlab: /var/lib/gitlabhq
:gitolite: /var/lib/gitlabhq-gitolite

Applications
------------

:rails: /var/www/gitlabhq
:logs: /var/log/gitlabhq, /var/log/gitlabhq-gitolite
:gitolite repos: /var/lib/gitlabhq-gitolite/repositories

Binaries
--------

:gems: /var/www/gitlabhq/vendor/bin
:scripts: /usr/libexec/gitlabhq, /usr/libexec/gitlabhq-gitolite

Configuring
===========

The package makes heavy use of `debconf` in order to make it easier to
install. Based on the answers you provide, the configuration scripts
will be changed. Notice you are still allowed to edit files manually,
just keep in mind that it may overwrite things you have done.

The following files are automatically managed:

* /var/www/gitlabhq/config/gitlab.yml

* /var/www/gitlabhq/config/database.yml

* /var/lib/gitlabhq/.gitconfig

The changes you make using `dpkg-reconfigure` are applied
automatically.

You may also do this without the interactive interface:
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

Gotchas
=======

The package bundles everything, including bundler. For this reason,
you have to change some environment variables, most notably
`GEM_HOME`. There is a script that does just this, and you are
advisable to use it to invoke any command that depend on bundler or
the gems managed by it:

* /usr/libexec/gitlabhq/env

To use it, simply prefix the command you want with that script, as
follows:
::

  # the following are all the same
  $ /usr/libexec/gitlabhq/env rake gitlab:env:info
  $ /usr/libexec/gitlabhq/env bundle exec rake gitlab:env:info
  $ /usr/libexec/gitlabhq/env bundle exec rake gitlab:env:info RAILS_ENV=production

  # to access rails console
  $ /usr/libexec/gitlabhq/env rails console

  # notably, mind these:
  $ /usr/libexec/gitlabhq/env python2
  $ /usr/libexec/gitlabhq/env ruby
  $ /usr/libexec/gitlabhq/env gem

  # To use something other than production
  $ env RAILS_ENV=custom /usr/libexec/gitlabhq/env ...

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

Now you should have available the following packages:

* gitlab

* gitlabh-gitolite
