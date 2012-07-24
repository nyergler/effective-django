==================
First things First
==================

Your Application Environment
============================

Starting a Project
------------------

Starting a project is easy::

$ python django-admin.py startproject

What comes next? Or right before?


Deployment From Day 1
---------------------

* Pretend you need to deploy from Day 1
* And assume that you want that automated

Dependency Management
---------------------

* Choose a tool to track dependencies, use it in development

  * pip w/requirements.txt
  * virtualenv
  * buildout

* Identify specific versions of dependencies (by number or SHA)

Your Environment
----------------

* If you're on your own, just use a virtualenv
* If you're working with an ops person/team, consider Vagrant from the
  start
* Even if you don't use Puppet to configure the dev VM, at least
  you're running code on another "machine".


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

  $ python django-admin.py startproject contactmgr

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

...and the "App"
----------------

::

  $ python ./contactmgr/manage.py startapp contacts

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

URL Routing
===========

URLconfs
--------

* Django **URLconfs** define how to map requests to Python code
* **URLconfs** are Python modules
* In that module there are a few important names:

  * ``urlpatterns``
  * ``handler403``
  * ``handler404``
  * ``handler500``

* As your project grows, the URL conf can begin to import lots and
  lots of things.
* If one of those imports fails, your project will stop working in a
  slightly mysterious manner.

Defining URLs
-------------

``contactmgr/urls.py``::

  from django.conf.urls import patterns, url, include

  urlpatterns = patterns('',
      url(r'^index/$', 'contacts.views.index'),
  )

.. notslides::

   * Use of the ``url()`` function is not strictly required, but I
     like it: when you start adding more information to the URL
     pattern, it lets you use named parameters, making everything more
     clear.
   * The first parameter is a regular expression. Note the trailing
     ``$``; why might that be important?
   * The second parameter is the view callable. It can either be the
     actual callable (imported manually), or a string describing
     it. If it's a string, Django will try to import the module (up to
     the final dot, ``contacts.views`` in this case), and then call
     the final part (``index`` in this case).

.. Capturing Information
.. ---------------------

.. XXX

Naming URLs
-----------

``contactmgr/urls.py``::

  from django.conf.urls import patterns, url, include

  urlpatterns = patterns('',
      url(r'^index/$', 'contacts.views.index'
          name='index'),
  )

::

  from django.core.urlresolvers import reverse

  reverse('index')

.. notslides::

   * Giving a URL pattern a name allows you to do a reverse lookup
   * Useful when linking from one View to another, or redirecting
   * Allows you to manage your URL structure solely in the URL Conf


Views
=====

Overview
--------

* Views take an HTTP Request and return a Response

  .. blockdiag::

     blockdiag {
        // Set labels to nodes.
        A [label = "User"];
        C [label = "View"];

        A -> C [label = "Request"];
        C -> A [label = "Response"];
     }

* The can also take parameters: from the URL, or from the Request

A Simple View
-------------

``contacts/views.py``

.. testcode::

   from django.http import HttpResponse

   def index(request):
       """Contacts Index View."""

       return HttpResponse("Hello, world")

.. Templates
.. =========

.. Where to put them
.. -----------------

.. Writing a Simple Template
.. -------------------------

.. Alternative Template Engines
.. ----------------------------


Next
====

:doc:`testing`
