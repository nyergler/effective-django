.. tut::
   :path: /src

.. slideconf::
   :autoslides: True
   :theme: slides

=================
 Getting Started
=================

Your Development Environment
============================

.. slide:: The Environment
   :level: 2

   Three important factors for your environment:

     * Isolation
     * Determinism
     * Similarity

.. ifnotslides::

   When thinking about your development environment, there are three
   important things to keep in mind: isolation, determinism, and
   similarity. They're each important, and they work in concert with one
   another.

   **Isolation** means that you're not inadvertently leveraging tools
   or packages installed outside the environment. This is particularly
   important when it comes to something like Python packages with C
   extensions: if you're using something installed at the system level
   and don't know it, you can find that when you go to deploy or share
   your code that it doesn't operate the way you expect. A tool like
   virtualenv_ can help create that sort of environment.

   Your environment is **deterministic** if you're confident about
   what versions of your dependencies you're relying on, and can
   reproduce that environment reliably.

   Finally, **similarity** to your production or deployment
   environment means you're running on the same OS, preferably the
   same release, and that you're using the same tools to configure
   your development environment that you use to configure your
   deployment environment. This is by no means a requirement, but as
   you build bigger, more complex software, it becomes advantageous to
   remove another variable from thing.

.. _virtualenv: http://www.virtualenv.org/

Isolation
---------

* We want to avoid using unknown dependencies, or unknown versions
* virtualenv_ provides an easy way to work on a project without your
  system's ``site-packages``

Determinism
-----------

* Determinism is all about dependency management
* Choose a tool, use it in development and production

  * pip, specifically a `requirements files`_
  * buildout_
  * install_requires_ in setup.py

* Identify specific versions of dependencies

.. ifnotslides::

   You can specify versions either by the version for a package on
   PyPI, or a specific revision (SHA in git, revision number in
   Subversion, etc). This ensures that you're getting the exact
   version you're testing with.

.. _`requirements files`: http://www.pip-installer.org/en/latest/requirements.html
.. _buildout: http://www.buildout.org/
.. _install_requires: http://pythonhosted.org/distribute/setuptools.html#declaring-dependencies

Similarity
----------

* Working in an environment similar to where you deploy eliminates
  variables when trying to diagnose an issue
* If you're building something that requires additional services, this
  becomes even more important.
* Vagrant_ is a tool for managing virtual machines, let's you easily
  create an environment separate from your day to day work.

.. _Vagrant: http://vagrantup.com/


Setting Up Your Environment
===========================

.. checkpoint:: environment

Create a Clean Workspace
------------------------

::

  $ mkdir tutorial
  $ virtualenv ./tutorial/
  New python executable in ./tutorial/bin/python
  Installing setuptools............done.
  Installing pip...............done.
  $ source ./tutorial/bin/activate
  (tutorial)$

.. Alternately, start by cloning the `example repository`_::

..   $ git clone git://github.com/nyergler/effective-django-tutorial.git
..   $ cd effective-django-tutorial
..   $ git checkout environment
..   $ virtualenv .
..   New python executable in ./bin/python
..   Installing setuptools............done.
..   Installing pip...............done.
..   $ source ./bin/activate
..   (effective-django-tutorial) $

.. _`example repository`: https://github.com/nyergler/effective-django-tutorial

Start a Requirements File
-------------------------

Create a ``requirements.txt`` in the ``tutorial`` directory with a
single requirement in it.

.. literalinclude:: /src/requirements.txt

Installing Requirements
-----------------------

And then we can use pip_ to install the dependencies.

::

  (tutorial)$ pip install -U -r requirements.txt


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

.. _pip: http://www.pip-installer.org/

Beginning a Django Project
==========================

Scaffolding
-----------

* Django provides file system scaffolding just like HTTP scaffolding
* Helps engineers understand where to find things when they go looking
* Django 1.4 made a change that decouples apps from projects
* In Django parlance, your **project** is a collections of **applications**.

Creating the Project
--------------------

.. ifnotslides::

   Django installs a ``django-admin.py`` script for handling scaffolding
   tasks. We'll use ``startproject`` to create the project files. We
   specify the project name and the directory to start in; we're already
   in our isolated environment so we can just say ``.``

::

  (tutorial)$ django-admin.py startproject addressbook .

::

  manage.py
  ./addressbook
      __init__.py
      settings.py
      urls.py
      wsgi.py

Project Scaffolding
-------------------

.. ifnotslides::

   * ``manage.py`` is a pointer back to ``django-admin.py`` with an
     environment variable set, pointing to your project as the one to
     read settings from and operate on when needed.
   * ``settings.py`` is where you'll configure your project. It has a
     few sensible defaults, but no database chosen when you start.
   * ``urls.py`` contains the URL to view mappings: we'll talk more about
     that shortly.
   * ``wsgi.py`` is a WSGI_ wrapper for your application. This is used
     by Django's development servers, and possibly other containers
     like mod_wsgi, uwsgi, etc. in production.

.. ifslides::

   manage.py
   ~~~~~~~~~

   Wrapper around ``django-admin.py`` that operates on your project. You
   can run the tests or the development server using this.

   settings.py
   ~~~~~~~~~~~

   Your project configuration.

   urls.py
   ~~~~~~~

   URL definitions for your project

   wsgi.py
   ~~~~~~~

   A wrapper for running your project in a WSGI_ server.

.. _WSGI: https://en.wikipedia.org/wiki/Web_Server_Gateway_Interface

Creating the "App"
------------------

::

  (tutorial)$ python ./manage.py startapp contacts

::

  ./addressbook
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

Review
======

* Make sure your development environment is deterministic and as
  similar to where you'll deploy as possible
* Specify explicit versions for your dependencies
* Django organizes code into "Projects" and "Applications"
* Applications are [potentially] reusable

.. ifslides::

   * Next: :doc:`models`
