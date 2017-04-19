===================
 Testing in Django
===================

Testing Django
==============

* There are Unit Tests and there are Integration tests
* Unit Tests should not rely on external services
* Unit Tests should be *fast*

Writing a Unit Test
===================

* Django bundles ``unittest2`` as ``django.utils.unittest``

::

  import django.http
  import django.utils.unittest as unittest2

  class LocaleMiddlewareTests(unittest2.TestCase):

      def test_request_not_processed(self):

          middleware = LocaleMiddle()
          response = django.http.HttpResponse()
          middleware.process_response(none, response)

          self.assertFalse(response.cookies)

Test Client
===========

* Django TestClient acts like a browser. Sort of.
* Allows you to make a request against your application and inspect
  the response
* The TestClient is *slow* (compared to plain unit tests)

.. testcode::

   from django.test.client import Client

   c = Client()

   response = c.get('/login')
   self.assertEqual(response.status_code, 200)

   response = c.post('/login/', {'username': 'john', 'password': 'smith'})

Request Factory
===============

* Django 1.3 introduced ``RequestFactory``, with an API similar to
  Test Client
* Easy way to generate ``Request`` objects, which can be passed to
  views
* Note that middleware is **not** run on these Requests

Running Tests
=============

* Django only looks in apps with ``models.py`` for tests

::

   $ ./manage.py test

* Easy to replace the test runner with something like ``nose`` if you
  so desire


Further Reading
===============

* `Django Testing Documentation`_
* `Django 1.1 Testing & Debugging`_


.. _`Django Testing Documentation`: https://docs.djangoproject.com/en/1.4/topics/testing/
.. _`Django 1.1 Testing & Debugging`: http://www.packtpub.com/django-1-1-testing-and-debugging/book
