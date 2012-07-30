==============
 URLs & Views
==============

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
