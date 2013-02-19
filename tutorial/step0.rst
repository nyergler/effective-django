.. slideconf::
   :autoslides: False

===============
Getting Started
===============

Your Application Environment
============================

Deployment From Day 1
---------------------

* Pretend you need to deploy from Day 1
* And assume that you want that automated
* Why?

  * Determinism
  * Repeatability
  * Scale

TK:Environment
--------------

XXX explain this section, consider merging with next two

* It's important to use a reproducible environment
* It's nice if that environment is also similar to where you'll wind
  up deploying
* The first can be achieved with a tool that isolates you from the
  system python and tracks dependencies: virtualenv + requirements,
  buildout, paver, etc.
* The second can be achieved with something like Vagrant

Dependency Management
---------------------

* Choose a tool to track dependencies, use it in development

  * pip with a requirements files
  * virtualenv
  * buildout

* Identify specific versions of dependencies (by number or SHA)

Your Environment
----------------

* If you're on your own, just use a virtualenv
* If you're working with an ops person/team, consider Vagrant_ from the
  start

  * Even if you don't use Puppet to configure the dev VM, at least
    you're running code on another "machine".

Setting Up Your Environment
===========================

Create a Clean Workspace
------------------------

::

  $ mkdir contacts
  $ virtualenv ./contacts/
  New python executable in ./contacts/bin/python
  Installing setuptools............done.
  Installing pip...............done.
  $ source ./contacts/bin/activate
  (contacts) $


Start a Requirements File
-------------------------

TK: why requirements.txt

requirements.txt

.. literalinclude:: /examples/1_scaffolding/requirements.txt

::

  $ pip install -U -r requirements.txt


::

  Downloading/unpacking Django==1.4.3 (from -r requirements.txt (line 1))
    Downloading Django-1.4.3.tar.gz (7.7Mb): 7.7Mb downloaded
    Running setup.py egg_info for package Django

  Installing collected packages: Django
    Running setup.py install for Django
      changing mode of build/scripts-2.7/django-admin.py from 664 to 775

      changing mode of /home/nathan/p/contacts/bin/django-admin.py to 775
  Successfully installed Django
  Cleaning up...


Beginning a Django Project
==========================

Scaffolding
-----------

* Django provides file system scaffolding just like HTTP scaffolding
* Helps engineers understand where to find things when they go looking
* Django 1.4 made a change that decouples apps from projects
* In Django parlance, your **project** is a collections of **applications**.

Creating the Scaffolding
------------------------

::

  $ django-admin.py startproject contactmgr

::

  ./contactmgr
      manage.py
      ./contactmgr
          __init__.py
          settings.py
          urls.py
          wsgi.py

.. notslides::

   * ``manage.py`` is a pointer back to ``django-admin.py`` with an
     environment variable set, pointing to your project as the one to
     read settings from and operate on when needed.
   * ``settings.py`` is where you'll configure your app. It has a few
     sensible defaults, but no database chosen when you start.
   * ``urls.py`` contains the URL to view mappings: we'll talk more about
     that shortly.
   * ``wsgi.py`` is WSGI_ wrapper for your application. This is used by
     Django's development servers, and possibly (hopefully) other
     containers like mod_wsgi, uwsgi, etc.

manage.py
---------

TK

settings.py
-----------

TK

urls.py
-------

TK

wsgi.py
-------

TK

...and the "App"
----------------

::

  $ cd contactmgr
  $ python ./manage.py startapp contacts

::

  ./contactmgr
  ./contacts
      __init__.py
      models.py
      tests.py
      views.py

.. notslides::

   * Beginning in Django 1.4, *apps* are placed alongside *project*
     packages. This is a great improvement when it comes to
     deployment.
   * ``models.py`` will contain the Django ORM models for your app.
   * ``views.py`` will contain the View code
   * ``tests.py`` will contain the unit and integration tests you
     write.

TK: Review
----------
