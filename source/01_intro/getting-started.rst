.. tut::
   :path: /projects/addressbook

=========================
Creating a Django Project
=========================

Setting Up Your Environment
===========================

.. checkpoint:: environment

Create a Clean Workspace
------------------------

.. tut:exec::
   :path: /projects

   $ mkdir tutorial
   $ virtualenv ./tutorial/
   $ source ./tutorial/bin/activate

Installing Requirements
-----------------------

Most languages provide some mechanism for specifying a set of dependencies and the versions you depend on. There are a few ways to do this with Python. For most of our examples we'll be using *pip_*. Pip manages installation of Python packages, and can read *requirements files*. `Requirements files`_ specify a list of dependencies, one per line, along with an optional version specification.

To begin, create a ``requirements.txt`` file in the ``tutorial`` directory with a single line in it.

.. tut:content:: requirements.txt
   :path: /projects/tutorial

   Django~=1.10.0

This single requirement specifies that we depend on Django, specifically any version _like_ `1.10.0`. In other words, we'll get bug fix releases (i.e., 1.10.1), but not new versions (i.e., 1.11.0). Specifying the version is critical: without the version it's impossible to know that what we developed with and tested with is actually what we're running with.

Once we have the requirements file, we can use pip_ to install the dependencies we specified.

.. tut:exec::
   :path: /projects/tutorial

   $ ./bin/pip install -U -r requirements.txt

.. _pip: http://www.pip-installer.org/

Beginning a Django Project
==========================

When a building is under construction, scaffolding is often used to
support the structure before it's complete. The scaffolding can be
temporary, or it can serve as part of the foundation for the
building, but regardless it provides some support when you're just
starting out.

Django, like many web frameworks, provides scaffolding for your
development efforts. It does this by making decisions and providing
a starting point for your code that lets you focus on the problem
you're trying to solve, and not how to parse an HTTP request.
Django provides HTTP, as well as file system scaffolding.

The HTTP scaffolding handles things like parsing an HTTP request
into a Python object and providing tools to easily create a
response. The file system scaffolding is a little different: it's a
set of conventions for organizing your code. These conventions make
it easier to add engineers to a project, since they
(hypothetically) have some idea how the code is organized. In
Django parlance, a **project** is the final product, and it
assembles one or more **applications** together. Django 1.4 made a
change to the way the `projects and applications are laid out on
disk`_, which makes it easier to decouple and reuse applications
between projects.

.. _`projects and applications are laid out on disk`: https://docs.djangoproject.com/en/1.5/releases/1.4/#updated-default-project-layout-and-manage-py

Creating the Project
--------------------

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

* Beginning in Django 1.4, *apps* are placed alongside *project*
  packages. This is a great improvement when it comes to
  deployment.
* ``models.py`` will contain the Django ORM models for your app.
* ``views.py`` will contain the View code
* ``tests.py`` will contain the unit and integration tests you
   write.

Review
======

* Specify explicit versions for your dependencies
* Django organizes code into "Projects" and "Applications"
