.. tut::
   :path: /projects/addressbook

===============
 Writing Views
===============

View Basics
===========

Django Views take an `HTTP Request`_ and return an `HTTP Response`_ to
the user.

  .. blockdiag::

     blockdiag {
        // Set labels to nodes.
        A [label = "User"];
        C [label = "View"];

        A -> C [label = "Request"];
        C -> A [label = "Response"];
     }

Any Python callable can be a view. The only hard and fast requirement
is that it takes the request object (customarily named ``request``) as
its first argument. This means that a minimalist view is super
simple::



  from django.http import HttpResponse

  def hello_world(request):
      return HttpResponse("Hello, World")

Of course, like most frameworks, Django also allows you to pass
arguments to the view from the URL. We'll cover this as we build up
our application.

.. _`HTTP Request`: https://docs.djangoproject.com/en/1.5/ref/request-response/#httprequest-objects
.. _`HTTP Response`: https://docs.djangoproject.com/en/1.5/ref/request-response/#httpresponse-objects


Generic & Class Based Views
===========================

* `Generic Views`_ have always provided some basic functionality:
  render a template, redirect, create or edit a model, etc.
* Django 1.3 introduced `Class Based Views`_ (CBV) for the generic views
* Provide higher levels of abstraction and composability
* Also hide a lot of complexity, which can be confusing for the
  newcomer
* Luckily the documentation is **much** better with Django 1.5


Class Based Views
=================

The minimal class based view subclasses View_ and implements methods
for the HTTP methods it supports. Here's the class-based version of
the minimalist "Hello, World" view we previously wrote.

::

  from django.http import HttpResponse
  from django.views.generic import View

  class MyView(View):

      def get(self, request, *args, **kwargs):
          return HttpResponse("Hello, World")

In a class based view, HTTP methods map to class method names. In this
case, we've defined a handler for ``GET`` requests with the ``get``
method. Just like the function implementation, it takes ``request`` as
its first argument, and returns an HTTP Response.

.. sidebar:: Permissive Signatures

   You may notice that it has a couple of extra arguments in its
   signature, compared to the view we saw previously, specifically
   ``*args`` and ``**kwargs``. Class based views were first introduced
   as a way to make Django's "generic" views more flexible. That meant
   they were used in many different contexts, with potentially
   different arguments extracted from the URLs. As I've been writing
   class based views over the past year, I've continued to write them
   with permissive signatures, as I've found they're often useful in
   ways I didn't initially expect.

Listing Contacts
================

.. checkpoint:: contact_list_view

We'll start with a view that presents a list of contacts in the
database.

The basic view implementation is shockingly brief. We can write the
view in just a few lines in the ``views.py`` file in our ``contacts``
application.

.. literalinclude:: /projects/addressbook/contacts/views.py
   :language: python
   :end-before: template_name

The ListView_ that we subclass from is itself composed of several
mixins that provide some behavior, and that composition gives us a lot
of power without a lot of code. In this case we set ``model =
Contact``, which says that this view is going to list *all* the
Contacts in our database.


Defining URLs
=============

The URL configuration tells Django how to match a request's path to
your Python code. Django looks for the URL configuration, defined as
``urlpatterns``, in the ``urls.py`` file in your project.

Let's add a URL mapping for our contact list view in
``addressbook/urls.py``.

.. literalinclude:: /projects/addressbook/addressbook/urls.py
   :language: python


* Use of the ``url()`` function is not strictly required, but I like
  it: when you start adding more information to the URL pattern, it
  lets you use named parameters, making everything more clear.
* The first parameter is a regular expression. Note the trailing
  ``$``; why might that be important?
* The second parameter is the view callable. It can either be the
  actual callable (imported manually), or a string describing it. If
  it's a string, Django will import the module (up to the final dot),
  and then calls the final segment when a request matches.
* Note that when we're using a class based view, we *must* use the
  real object here, and not the string notation. That's because we
  have to call the class method ``as_view()``, which returns a wrapper
  around our class that Django's URL dispatch can call.
* Giving a URL pattern a name allows you to do a reverse lookup
* The URL name is useful when linking from one View to another, or
  redirecting, as it allows you to manage your URL structure in one
  place

While the ``urlpatterns`` name **must** be defined, Django also allows
you to define a few other values in the URL configuration for
exceptional cases. These include ``handler403``, ``handler404``, and
``handler500``, which tell Django what view to use when an HTTP error
occurs. See the `Django urlconf documentation`_ for details.

.. _`Django urlconf documentation`: https://docs.djangoproject.com/en/1.5/ref/urls/#handler403

.. admonition:: URL Configuration Import Errors

   Django loads the URL configuration very early during startup, and
   will attempt to import things it finds here. If one of the imports
   fails, however, the error message can be somewhat opaque. If your
   project stops working with an import-related exception, try to
   import the URL configuration in the interactive shell. That usually
   makes it clear where the problem lies.


Creating the Template
=====================

Now that we've defined a URL for our list view, we can try it out.
Django includes a server suitable for development purposes that you
can use to easily test your project::

  $ python manage.py runserver
  Validating models...

  0 errors found
  Django version 1.4.3, using settings 'addressbook.settings'
  Development server is running at http://127.0.0.1:8000/
  Quit the server with CONTROL-C.

If you visit the ``http://localhost:8000/`` in your browser, though,
you'll see an error: ``TemplateDoesNotExist``.

.. image::
   /_static/tutorial/TemplateDoesNotExist.png

Most of Django's generic views (such as ``ListView`` which we're
using) have a predefined template name that they expect to find. We
can see in this error message that this view was expecting to find
``contact_list.html``, which is derived from the model name. Let's go
and create that.

By default Django will look for templates in applications, as well as
in directories you specify in ``settings.TEMPLATE_DIRS``. The generic
views expect that the templates will be found in a directory named
after the application (in this case ``contacts``), and the filename
will contain the model name (in this case ``contact_list.html``). This
works very well when you're distributing a reusable application: the
consumer can create templates that override the defaults, and they're
clearly stored in a directory associated with the application.

For our purposes, however, we don't need that extra layer of directory
structure, so we'll specify the template to use explicitly, using the
``template_name`` property. Let's add that one line to ``views.py``.

.. literalinclude:: /projects/addressbook/contacts/views.py

Create a ``templates`` subdirectory in our ``contacts`` application,
and create ``contact_list.html`` there.

.. literalinclude:: /projects/addressbook/contacts/templates/contact_list.html
   :language: html

Opening the page in the browser, we should see one contact there, the
one we added earlier through the interactive shell.

Creating Contacts
=================

.. checkpoint:: create_contact_view

Adding information to the database through the interactive shell is
going to get old fast, so let's create a view for adding a new
contact.

Just like the list view, we'll use one of Django's generic views. In
``views.py``, we can add the new view:

.. literalinclude:: /projects/addressbook/contacts/views.py
   :prepend: from django.core.urlresolvers import reverse
             from django.views.generic import CreateView
             ...
   :pyobject: CreateContactView

Most generic views that do form processing have the concept of the
"success URL": where to redirect the user when the form is
successfully submitted. The form processing views all adhere to the
practice of POST-redirect-GET for submitting changes, so that
refreshing the final page won't result in form re-submission. You can
either define this as a class property, or override the
``get_success_url()`` method, as we're doing here. In this case we're
using the ``reverse`` function to calculate the URL of the contact
list.

.. sidebar:: Context Variables in Class Based Views

   The collection of values available to a template when it's rendered
   is referred to as the Context. The Context is a combination of
   information supplied by the view and information from `context
   processors`_.

   When you're using built in generic views, it's not obvious what
   values are available to the context. With some practice you'll
   discover they're pretty consistent -- ``form``, ``object``, and
   ``object_list`` are often used -- but that doesn't help when you're
   just starting off. Luckily, the documentation for this is much
   improved with Django 1.5.

   In class based views, the ``get_context_data()`` method is used to
   add information to the context. If you override this method, you
   usually want to accept ``**kwargs``, and call the super class.

The template is slightly more involved than the list template, but not
much. Our ``edit_contact.html`` will look something like this.

.. literalinclude:: /projects/addressbook/contacts/templates/edit_contact.html
   :language: html

A few things to note:

- The ``form`` in the context is the `Django Form`_ for our model.
  Since we didn't specify one, Django made one for us. How thoughtful.
- If we just write ``{{ form }}`` we'll get table rows; adding
  ``.as_ul`` formats the inputs for an unordered list. Try ``.as_p``
  instead to see what you get.
- When we output the form, it only includes our fields, not the
  surrounding ``<form>`` tag or the submit button, so we have to add
  those.
- The ``{% csrf_token %}`` tag inserts a hidden input that Django uses
  to verify that the request came from your project, and isn't a
  forged cross-site request. Try omitting it: you can still access the
  page, but when you go to submit the form, you'll get an error.
- We're using the ``url`` template tag to generate the link back to
  the contact list. Note that ``contacts-list`` is the name of our
  view from the URL configuration. By using ``url`` instead of an
  explicit path, we don't have to worry about a link breaking. ``url``
  in templates is equivalent to ``reverse`` in Python code.

You can configure the URL by adding the following line to our
``urls.py`` file::

    url(r'^new$', contacts.views.CreateContactView.as_view(),
        name='contacts-new',),

Now you can go to ``http://localhost:8000/new`` to create new contacts.

To complete the story, let's add a link to `contact_list.html`.

.. literalinclude:: /projects/addressbook/contacts/templates/contact_list.html
   :language: html


Testing Your Views
==================

So far our views have been pretty minimal: they leverage Django's
generic views, and contain very little of our own code or logic. One
perspective is that this is how it should be: a view takes a request,
and returns a response, delegating the issue of validating input to
forms, and business logic to model methods. This is a perspective that
I subscribe to. The less logic contained in views, the better.

However, there is code in views that should be tested, either by unit
tests or integration tests. The distinction is important: unit tests
are focused on testing a single unit of functionality. When you're
writing a unit test, the assumption is that everything else has its
own tests and is working properly. Integration tests attempt to test
the system from end to end, so you can ensure that the points of
integration are functioning properly. Most systems have both.

Django has two tools that are helpful for writing unit tests for
views: the Test Client_ and the RequestFactory_. They have similar
APIs, but approach things differently. The ``TestClient`` takes a URL
to retrieve, and resolves it against your project's URL configuration.
It then creates a test request, and passes that request through your
view, returning the Response. The fact that it requires you to specify
the URL ties your test to the URL configuration of your project.

The ``RequestFactory`` has the same API: you specify the URL you want
to retrieve and any parameters or form data. But it doesn't actually
resolve that URL: it just returns the Request object. You can then
manually pass it to your view and test the result.

In practice, RequestFactory tests are usually somewhat faster than the
TestClient. This isn't a big deal when you have five tests, but it is
when you have 500 or 5,000. Let's look at the same test written with
each tool.

.. checkpoint:: view_tests

.. literalinclude:: /projects/addressbook/contacts/tests.py
   :prepend: from django.test.client import Client
             from django.test.client import RequestFactory
             ...
             from contacts.views import ListContactView
             ...
   :pyobject: ContactListViewTests


Integration Tests
=================

Django 1.4 adds a new ``TestCase`` base class, the
LiveServerTestCase_. This is very much what it sounds like: a test
case that runs against a live server. By default Django will start the
development server for you when it runs these tests, but they can also
be run against another server.

Selenium_ is a tool for writing tests that drive a web browser, and
that's what we'll use for our integration tests. By using Selenium,
you're able to automate different browers (Chrome, Firefox, etc), and
interact with your full application much as the user would. Before
writing tests to use it, we'll need to install the Python implementation.

::

  (tutorial)$ pip install selenium

We're going to write a couple of tests for our views:

- one that creates a Contact and makes sure it's listed
- one that makes sure our "add contact" link is visible and linked on
  the list page
- and one that actually exercises the add contact form, filling it in
  and submitting it.

.. literalinclude:: /projects/addressbook/contacts/tests.py
   :prepend: from django.test import LiveServerTestCase
             from selenium.webdriver.firefox.webdriver import WebDriver
             ...
   :pyobject: ContactListIntegrationTests

Note that Selenium allows us to find elements in the page, inspect
their state, click them, and send keystrokes. In short, it's like
we're controlling the browser. In fact, if you run the tests now,
you'll see a browser open when the tests run.

In our example we're using CSS Selectors to locate elements in the
DOM, but you can also use Xpath. For many people it's a matter of
preference, but I've found that using CSS Selectors is often less
brittle: if I change the markup, I'm likely to leave classes on
important elements in place, even if their relative position in the
DOM changes.

Review
======

* Views take an HttpRequest_ and turn it into an HttpResponse_
* Generic class-based views introduced with Django 1.3
* These let you create reusable, composable views
* URLs are defined in ``urls.py`` in your project
* Naming URLs lets you calculate the URL to a view
* RequestFactory_ creates Requests for testing Views
  with
* LiveServerTestCase_ provides basis for writing integration tests


.. _`Generic Views`: https://docs.djangoproject.com/en/1.5/topics/class-based-views/generic-display/
.. _`Class Based Views`: https://docs.djangoproject.com/en/1.5/topics/class-based-views/
.. _View: https://docs.djangoproject.com/en/1.5/ref/class-based-views/base/#view
.. _ListView: https://docs.djangoproject.com/en/1.5/ref/class-based-views/generic-display/#listview
.. _UpdateView: https://docs.djangoproject.com/en/1.5/ref/class-based-views/generic-editing/#updateview
.. _CreateView: https://docs.djangoproject.com/en/1.5/ref/class-based-views/generic-editing/#createview
.. _DeleteView: https://docs.djangoproject.com/en/1.5/ref/class-based-views/generic-editing/#deleteview
.. _DetailView: https://docs.djangoproject.com/en/1.5/ref/class-based-views/generic-display/#detailview
.. _`context processors`: https://docs.djangoproject.com/en/1.5/ref/templates/api/#subclassing-context-requestcontext
.. _`Django Form`: https://docs.djangoproject.com/en/1.5/topics/forms/
.. _HttpRequest: https://docs.djangoproject.com/en/1.5/ref/request-response/#httprequest-objects
.. _HttpResponse: https://docs.djangoproject.com/en/1.5/ref/request-response/#httpresponse-objects
.. _Client: https://docs.djangoproject.com/en/1.5/topics/testing/overview/#module-django.test.client
.. _RequestFactory: https://docs.djangoproject.com/en/1.5/topics/testing/advanced/#django.test.client.RequestFactory
.. _LiveServerTestCase: https://docs.djangoproject.com/en/1.5/topics/testing/overview/#liveservertestcase
.. _Selenium: http://seleniumhq.org/
