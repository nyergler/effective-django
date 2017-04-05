=========================
Creating a Django Project
=========================

We'll start exploring Django by looking at how to create a new project and the way a project is laid out. Along the way we'll review (or learn) the basics of Python package management.

Setting Up Your Environment
===========================

It's important when starting a new project to create a space for it that won't be influenced by anything else you're working on. I often have multiple projects underway that may be using different versions of the same dependencies, which would be incredibly confusing if they weren't isolated from one another.

Python uses "virtual environments" (sometimes referred to as ``virtualenvs`` or ``venvs``) to keep things isolated.

.. note::

  We use Python 3.

.. code-block:: console

   $ mkdir addresses
   $ python3 -m venv addresses
   $ cd addresses
   $ source ./bin/activate
   (addresses) $

The final command (``source ./bin/activate``) activates the newly created virtual environment, as indicated by the changed prompt.

.. note::

  Windows users...

Installing Requirements
-----------------------

Most languages provide some mechanism for specifying a set of dependencies and the versions you depend on. There are a few ways to do this with Python. For most of our examples we'll be using *pip_*. Pip manages installation of Python packages, and can read *requirements files*. `Requirements files`_ specify a list of dependencies, one per line, along with an optional version specification.

To begin, create a ``requirements.txt`` file in the ``addresses`` directory with a single line in it.

.. code-block:: python

   Django ~= 1.11.0

This single requirement specifies that we depend on Django, specifically any version _like_ `1.11.0`. In other words, we'll get bug fix releases (i.e., 1.11.1, 1.11.2, etc), but not new, potentially incompatible versions (i.e., 1.12.0). Specifying the version is critical: without the version it's impossible to know that what we developed with and tested with is actually what we're running with.

Once we have the requirements file, we can use pip_ to install the dependencies we specified.

.. code-block:: console

   (addresses)$ pip install -U -r requirements.txt
   Collecting Django~=1.11.0 (from -r requirements.txt (line 1))
     Downloading Django-1.11-py2.py3-none-any.whl (6.8MB)
       100% |████████████████████████████████| 6.8MB 250kB/s
   Installing collected packages: Django
   Successfully installed Django-1.11

.. note::

  If pip complains that it expects a version specifier, you probably need to upgrade pip.

Pip will read each line of your requirements file, fetch the dependency, and then fetch any additionally required dependencies. Because we're working in our virtual environment, we don't need to worry about conflicts.

.. _pip: http://www.pip-installer.org/
.. _`requirements files`: https://pip.pypa.io/en/stable/reference/pip_install/#requirements-file-format

Beginning a Django Project
==========================

When a building is under construction, scaffolding is often used to
support the structure before it's complete. The scaffolding can be
temporary, or it can serve as part of the foundation for the
building, but regardless it provides some support when you're just
starting out.

Django, like many frameworks, provides scaffolding for your
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
assembles one or more **applications** together.

Creating the Project
--------------------

Django installs a ``django-admin.py`` script for handling scaffolding
tasks. We'll use ``startproject`` to create the project files. We
specify the project name and the directory to start in; we're already
in our isolated environment so we can just say ``.``

.. code-block:: console

  (addresses)$ django-admin.py startproject addressbook .

Running ``startproject`` creates some new files in our project directory.

* ``manage.py`` is a pointer back to ``django-admin.py`` with an
  environment variable set, pointing to your project as the one to
  read settings from and operate on when needed.
* ``addressbook/settings.py`` is where you'll configure your project. It has a
  few sensible defaults, but no database chosen when you start.
* ``addressbook/urls.py`` contains the URL to view mappings: we'll talk more about
  that shortly.
* ``addressbook/wsgi.py`` is a WSGI_ wrapper for your application. This is used
  by Django's development servers, and possibly other containers
  like mod_wsgi, uwsgi, etc. in production.

.. _WSGI: https://en.wikipedia.org/wiki/Web_Server_Gateway_Interface

At this point Django has created the scaffolding necessary to run the web server (albeit one that doesn't really do anything yet).

.. code-block:: console

  (addresses)$ python3 manage.py runserver
  Django version 1.11, using settings 'addressbook.settings'
  Starting development server at http://127.0.0.1:8000/
  Quit the server with CONTROL-C.

You can follow that link and see Django's "It worked!" page.

Creating the "App"
------------------

There's one more piece of scaffolding we need to create, and that's our "app". This is where the majority of our work will occur. On many projects you'll wind up with more than one "app", either of your own creation or that you pull in from a third party source. You use the project -- specifically settings.py and urls.py -- to stich everything together.

We'll use the manage.py wrapper to create our app, which we'll name ``contacts``.

.. code-block:: console

  (addresses)$ python3 ./manage.py startapp contacts

.. sidebar:: Project & App Organization

   In versions of Django prior to 1.4, apps were created as sub-directories of the project. You could move them around so long as you made sure your ``PYTHONPATH`` was set correctly, but the default made the two seem tightly coupled. By placing them as peers, it's a little more obvious that apps are potentitally reusable; we'll dive into that later.

Our project's management script (``manage.py``) will create a new directory, ``contacts``, with three nearly empty files:

* ``models.py`` will contain the database models for your app
* ``views.py`` will contain the views which respond to HTTP requests
* ``tests.py`` will contain the unit and integration tests you
   write

Review
======

TK
