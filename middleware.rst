.. slideconf::
   :theme: single-level

==========================
 Understanding Middleware
==========================


Overview of Middleware
======================

* Lightweight "plug-ins" for Django
* Allows modifying the Request or Response, or mutating the View
  parameters
* Defined as a sequence (tuple) of classes in ``settings``

.. testcode::

  MIDDLEWARE_CLASSES = (
      'django.middleware.common.CommonMiddleware',
      'django.contrib.sessions.middleware.SessionMiddleware',
      'django.middleware.csrf.CsrfViewMiddleware',
      'django.contrib.auth.middleware.AuthenticationMiddleware',
      'django.contrib.messages.middleware.MessageMiddleware',
  )

Middleware Hooks
================

* Middleware classes have a few hooks:

  - ``request``
  - ``response``
  - ``view``
  - ``template_response``
  - ``exception``

* Individual middleware may implement some or all

Typical Uses
============

* Sessions
* Authentication
* CSRF Protection
* GZipping Content

Middleware Example
==================

.. testcode::

   class LocaleMiddleware(object):

       def process_request(self, request):

           if 'locale' in request.cookies:
               request.locale = request.cookies.locale
           else:
               request.locale = None

       def process_response(self, request, response):

           if getattr(request, 'locale', False):
               response.cookies['locale'] = request.locale


Request Middleware
==================

* On ingress, middleware is executed in order
* Request middleware returns ``None`` to continue processing
* Returning an ``HttpResponse`` short circuits additional middleware

Response Middleware
===================

* On egress, middleware is executed in reverse order
* Response middleware is executed *even if corresponding request
  middleware not executed*

Writing Your Own
================

* Simple Python Classes
* Can implement all or part of the interface
* Middleware is long-lived
* The place for storing request-specific information is cunningly
  named ``request``

WSGI Middleware
===============

* WSGI_ also defines a middleware interface
* The two have similar functions, but are **not** the same

.. _WSGI: http://wsgi.org
