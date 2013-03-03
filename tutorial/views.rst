.. tut::
   :path: /src

.. slideconf::
   :autoslides: False
   :theme: single-level

===============
 Writing Views
===============

.. slide:: Writing Views
   :level: 1

   Handling HTTP Requests from users.

.. rst-class:: include-as-slide, slide-level-2

View Basics
===========

* Views take an HTTP Request and return a Response

  .. blockdiag::

     blockdiag {
        // Set labels to nodes.
        A [label = "User"];
        C [label = "View"];

        A -> C [label = "Request"];
        C -> A [label = "Response"];
     }

* Any callable that takes a Request can be a view
* Like other frameworks, Django can pass values from the URL to the
  view, as well

.. rst-class:: include-as-slide, slide-level-2

Generic & Class Based Views
===========================

* `Generic Views`_ have always provided some basic functionality:
  render a template, redirect, create or edit a model, etc.
* Django 1.3 introduced `Class Based Views`_ (CBV) for the generic views
* Provide higher levels of abstraction and composability
* Also hide a lot of complexity, which can be confusing for the
  newcomer
* Luckily the documentation is **much** better with Django 1.5

.. ifnotslides::

   Django 1.3 introduced class based views, which is what we'll be
   focusing on here. Class based views, or CBVs, can eliminate a lot of
   boilerplate from your views, especially for things like an edit view
   where you want to take different action on a ``GET`` vs ``POST``. They
   give you a lot of power to compose functionality from pieces. The
   downside is that this power comes with some added complexity.


.. rst-class:: include-as-slide, slide-level-2

Class Based Views
=================

The minimal class based view subclasses View_ and implements methods
for the HTTP methods it supports.

::

  from django.http import HttpResponse
  from django.view.generic import View

  class MyView(View):

      def get(self, request, *args, **kwargs):
          return HttpResponse("Hello, World")


Listing Contacts
================

.. slide:: List Views
   :level: 2

   ListView_ provides a view of a set of objects.

   ::

     class ContactsList(ListView):

         model = Contact
         template_name = 'contact_list.html'

         def get_queryset(self):
             ... # defaults to model.objects.all()

         def get_context_object_name(self):
             ... # defaults to <model name>_list

         def get_context_data(self, **kwargs):
             ... # add anything else to the context

         def get_context_data(self, **kwargs):
             ... # add anything else to the context

.. slide:: Edit Views
   :level: 2

   CreateView_, UpdateView_, DeleteView_ manipulate a single object.
   ::

     class UpdateContact(UpdateView):

         model = Contact
         template_name = 'edit_contact.html'

         def get_object(self):
             ... # defaults to looking for a pk or slug kwarg, and
                 # passing that to filter

         def get_context_object_name(self):
             ... # defaults to <model name>

         def get_context_data(self, **kwargs):
             ... # add anything else to the context

         def get_success_url(self):
             ... # where to redirect to on success
                 # defaults to self.get_object().get_absolute_url()

.. slide:: Detail Views
   :level: 2

   DetailView_ provides a view of a single object

   ::

     class ContactView(DetailView):

         model = Contact
         template_name = 'contact.html'

         def get_object(self):
             ... # defaults to looking for a pk or slug kwarg, and
                 # passing that to filter

         def get_context_object_name(self):
             ... # defaults to <model name>

         def get_context_data(self, **kwargs):
             ... # add anything else to the context

.. checkpoint:: contact_list_view

We'll start with a view that presents a list of contacts in the
database.

The basic view implementation is shockingly brief.

.. literalinclude:: /src/contacts/views.py
   :language: python
   :end-before: template_name

The ListView_ that we subclass from is itself composed of several
mixins that provide some behavior, and that composition gives us a lot
of power without a lot of code. In this case we set ``model =
Contact``, which says that this view is going to list *all* the
Contacts in our database.

.. Mapping URLs
.. ------------

.. * Django **URLconfs** define how to map requests to Python code
.. * **URLconfs** are Python modules
.. * In that module there are a few important names:

..   * ``urlpatterns``
..   * ``handler403``
..   * ``handler404``
..   * ``handler500``

.. * As your project grows, the URL conf can begin to import lots and
..   lots of things.
.. * If one of those imports fails, your project will stop working in a
..   slightly mysterious manner.


.. rst-class:: include-as-slide, slide-level-2

Defining URLs
-------------

Django looks for the URL configuration in ``urls.py`` in your project.

.. literalinclude:: /src/addressbook/urls.py
   :language: python


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
   * Note that when we're using a class based view, we *must* use the
     real object here, and not the string notation. That's because we
     have to call the class method ``as_view()``, which returns a
     wrapper around our class that Django's URL dispatch can call.

* Giving a URL pattern a name allows you to do a reverse lookup

.. notslides::

   * Useful when linking from one View to another, or redirecting
   * Allows you to manage your URL structure in one place

Creating the Template
---------------------

.. slide:: Django Templates
   :level: 2

   * Django allows you to specify ``TEMPLATE_DIRS`` to look for templates
     in
   * By default it looks for a ``template`` subdirectory in each app
   * Keeping templates within an app makes creating reusable apps easier

Now that we've defined a URL for our list view, we can try it out.
Django includes a server suitable for development purposes that you
can use to easily test your project::

  $ python manage.py runserver
  Validating models...

  0 errors found
  Django version 1.4.3, using settings 'contactmgr.settings'
  Development server is running at http://127.0.0.1:8000/
  Quit the server with CONTROL-C.

If you visit the ``http://localhost:8000/`` in your browser, though,
you'll see an error: ``TemplateDoesNotExist``.

.. image::
   /_static/tutorial/TemplateDoesNotExist.png

Most of Django's generic views (such as ``ListView`` which we're
using) have a predefined template name that they expect to find. We
can see in this error message that this view was expecting to find
``contact_list.html``, which is derives from the model name. Let's go
and create that.

By default Django will look for templates in applications, as well as
in directories you specify in ``settings.TEMPLATE_DIRS``. The generic
views expect that the templates will be found in a directory named
after the application (in this case ``contacts``), and the filename
will contain the model name (in this case ``contact_list.html``). This
works very well when you're distributing a reusable application: the
consumer can create templates that override the defaults, and they're
clearly stored in a directory associated with the application.

For our purposes we don't need that extra layer of directory
structure, so we'll specify the template to use explicitly, using the
``template_name`` property.

.. literalinclude:: /src/contacts/views.py

Now we can just create ``contact_list.html`` in the
``contacts/templates/`` directory.

.. literalinclude:: /src/contacts/templates/contact_list.html

Opening the page in the browser, we should see one contact there, the
one we added earlier through the interactive shell.

Create
======

.. checkpoint:: create_contact_view

Adding information to the database through the interactive shell is
going to get old fast, so let's create a view for adding a new
contact.

Just like the list view, we'll use one of Django's generic views. In
``views.py``, we can add the new view:

.. literalinclude:: /src/contacts/views.py
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

.. literalinclude:: /src/contacts/templates/edit_contact.html

A few things to note:

- The ``form`` in the context is the `Django Form`_ for our model.
  Since we didn't specify one, Django made one for us. How thoughtful.
- If the just do ``{{ form }}`` we'll get table rows; adding
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
  explicit path, we don't have to worry about a link breaking.

Finally, let's configure the URL by adding the following line to our
``urls.py`` file::

    url(r'^new$', contacts.views.CreateContactView.as_view(),
        name='contacts-new',),

You can go to ``http://localhost:8000/new`` to create new contacts

Testing Your Views
==================

.. slide:: Test Client & RequestFactory
   :level: 2

   * Views transform a Request into a Response, but still have logic
   * Test ``Client`` and ``RequestFactory`` are tools to help test them
   * They share a common API, but work slightly differently
   * Test ``Client`` resolves a URL to the view, returns a Response
   * ``RequestFactory`` generates a Request which you can pass to the View
     directly

.. slide:: Test Client vs. RequestFactory
   :level: 2

   ::

     from django.test.client import Client
     from django.test.client import RequestFactory

     client = Client()
     response = client.get('/')

   ::

     factory = RequestFactory()
     request = factory.get('/')

     response = ListContactView.as_view()(request)

So far our views have been pretty minimal: they've leverage Django's
generic views, and contain very little of our own code or logic. One
perspective is that this is how it should be: a view takes a request,
and returns a response, delegating the issue of validating input to
forms, and business logic to model methods. This is a perspective that
I subscribe to. The less logic contained in views, the better.

However, there is code in views that should be tested, either by unit
tests or integration tests. The distinction is important: unit tests
are focused on testing a single unit of functionality. Whey you're
writing a unit test, the assumption is that everything else has its
own tests, and is working properly. Integration tests attempt to test
the system from end to end, so you can ensure that the points of
integration are functioning properly. Most complex systems have both.

Django has two tools that are helpful for writing view unit tests: the
Test Client_ and the RequestFactory_. They have similar APIs, but
approach things differently. The ``TestClient`` takes a URL to retrieve,
and resolves it against your projects URL configuration. It then
creates a test request, and passes that request object through your
view. The fact that it requires you to specify the URL ties your test
to the URL configuration of your project.

The ``RequestFactory`` has the same API: you specify the URL you want
to retrieve and any parameters or form data. But it doesn't actually
resolve that URL: it just returns the Request object. You can then
manually pass it to your view and test the result.

In practice, RequestFactory tests are usually somewhat faster than the
TestClient. This isn't a big deal when you have five tests, but it is
when you have 500 or 5,000. Let's look at the same test written with
each tool.

.. checkpoint:: view_tests

.. literalinclude:: /src/contacts/tests.py
   :prepend: from django.test.client import Client
             from django.test.client import RequestFactory
             ...
   :pyobject: ContactListViewTests


"Live Server" Tests
-------------------

.. slide:: Live Server Tests
   :level: 2

   * Django 1.4 added the LiveServerTestCase_
   * Makes writing integration tests with something like Selenium_
     easier
   * By default it spins up the server for you (similar to ``runserver``)
   * You can also point it to a deployed instance elsewhere

Django 1.4 adds a new ``TestCase`` base class, the
LiveServerTestCase_. This is very much what it sounds like: a test
case that runs against a live server. By default Django will start the
development server for you when it runs these tests, but they can also
be run against another server. Selenium_ is a package commonly used
for writing tests that drive a web browser, and that's what we'll use
for our integration tests.

::

  $ pip install selenium

Our initial tests are going to be pretty simple, because our project is
simple right now: it'll just make sure we can get the list page.

.. literalinclude:: /src/contacts/tests.py
   :prepend: from django.test import LiveServerTestCase
             from selenium.webdriver.firefox.webdriver import WebDriver
             ...
   :pyobject: ContactListIntegrationTests


.. checkpoint:: edit_contact_view

Update
======

The Update view will let us edit a contact in the address book, and as
with the previous two, there's a generic class based view for this.

.. literalinclude:: /src/contacts/views.py
   :pyobject: UpdateContactView
   :end-before: def get_context_data

* we can re-use the same template
* but how does it know which contact to load?
* we need to either: provide a pk/slug, or override get_object().
* we'll provide pk in the URL

.. literalinclude:: /src/addressbook/urls.py
   :lines: 11-12

We'll update the contact list to include an edit link next to each
contact.

.. literalinclude:: /src/contacts/templates/contact_list.html

* note the use of "kwargs" in the {% url %} tag

If you run the server now, you'll see an edit link. Go ahead and click
it, and try to make a change. You'll notice that instead of editing
the existing record, it creates a new one. Sad face. If we look at the
source of the edit HTML, we can easily see the reason: the form
targets ``/new``, not our edit URL. To fix this -- and still allow
re-using the template -- we're going to add some information to the
template context.

The template context is the information available to a template when
it's rendered. This is a combination of information you provide in
your view -- either directly or indirectly -- and information added by
`context processors`_, such as the location for static media and
current locale. In order to use the same template for add and edit,
we'll add information about where the form should redirect to the
context.

.. literalinclude:: /src/contacts/views.py
   :pyobject: CreateContactView

.. literalinclude:: /src/contacts/views.py
   :pyobject: UpdateContactView

We also update the template to use that value for the action and
change the title based on whether or not we've previously saved.

.. literalinclude:: /src/contacts/templates/edit_contact.html
   :lines: 1-7

You may wonder where the ``contact`` value in the contact comes from:
the class based views that wrap a single object (those that take
a primary key or slug) expose that to the context in two different
ways: as a variable named ``object``, and as a variable named after
the model class. The latter often makes your templates easier to read
and understand later. You can customize this name by overriding
``get_context_object_name`` on your view.

Delete
======

.. checkpoint:: delete_contact_view

The final view for our basic set of CRUD views is delete. The generic
deletion view is very similar to the edit view: it wraps a single
object and requires that you provide a URL to redirect to on success.
When it processes a HTTP GET request, it displays a confirmation page, and
when it receives an HTTP DELETE or POST, it deletes the object and
redirects to the success URL.

.. literalinclude:: /src/contacts/views.py
   :pyobject: DeleteContactView

.. literalinclude:: /src/contacts/templates/delete_contact.html

Of course we need to add this to the URL definitions:

.. literalinclude:: /src/addressbook/urls.py
   :lines: 13-14

And we'll add the link to delete to the edit page.

.. literalinclude:: /src/contacts/templates/edit_contact.html
   :lines: 15-17

Detail
======

.. checkpoint:: contact_detail_view

Finally, let's go ahead and add a detail view for our Contacts. This
will show the details of the Contact -- not much right now, but we'll
build on this shortly. Django includes another generic view

.. literalinclude:: /src/contacts/views.py
   :pyobject: ContactView

.. literalinclude:: /src/contacts/templates/contact.html

Of course we need to add this to the URL definitions:

.. literalinclude:: /src/addressbook/urls.py
   :lines: 9-10

We're also going to add a method to our Contact model,
``get_absolute_url``.  ``get_absolute_url`` is a Django convention for
obtaining the URL of a single model instance. In this case it's just
going to be a call to reverse, but by providing this method, our model
will play nicely with other parts of Django.

.. literalinclude:: /src/contacts/models.py
   :pyobject: Contact.get_absolute_url

And we'll add the link to the contact from the contact list.

.. literalinclude:: /src/contacts/templates/contact_list.html
   :lines: 5-9


.. rst-class:: include-as-slide, slide-level-2

Review
======

* Views take an HttpRequest_ and turn it into an HttpResponse_
* Django introduced generic class-based views with Django 1.3
* These let you create reusable, composable views
* URLs are defined in the ``urls.py`` file in your project
* Naming URLs lets you calculate the URL for redirection, linking,
  etc, making it easier to change URLs, if needed
* RequestFactory_ allows you to create Requests for testing Views
  with
* LiveServerTestCase_ provides the infrastructure for writing
  integration tests

.. ifslides::

   * Next: :doc:`forms`


.. _`Generic Views`: https://docs.djangoproject.com/en/1.5/topics/class-based-views/generic-display/
.. _`Class Based Views`: https://docs.djangoproject.com/en/1.5/topics/class-based-views/
.. _View: https://docs.djangoproject.com/en/1.5/ref/class-based-views/base/#view
.. _ListView: https://docs.djangoproject.com/en/1.5/ref/class-based-views/generic-display/#listview
.. _UpdateView: https://docs.djangoproject.com/en/1.5/ref/class-based-views/generic-editing/#updateview
.. _CreateView: https://docs.djangoproject.com/en/1.5/ref/class-based-views/generic-editing/#createview
.. _DeleteView: https://docs.djangoproject.com/en/1.5/ref/class-based-views/generic-editing/#deleteview
.. _DetailView: https://docs.djangoproject.com/en/1.5/ref/class-based-views/generic-display/#detailview
.. _`context processors`: https://docs.djangoproject.com/en/1.5/ref/templates/api/#subclassing-context-requestcontext
.. _`Django Form`: https://docs.djangoproject.com/en/1.5/topics/forms/i
.. _HttpRequest: https://docs.djangoproject.com/en/1.5/ref/request-response/#httprequest-objects
.. _HttpResponse: https://docs.djangoproject.com/en/1.5/ref/request-response/#httpresponse-objects
.. _Client: https://docs.djangoproject.com/en/1.5/topics/testing/overview/#module-django.test.client
.. _RequestFactory: https://docs.djangoproject.com/en/1.5/topics/testing/advanced/#django.test.client.RequestFactory
.. _LiveServerTestCase: https://docs.djangoproject.com/en/1.5/topics/testing/overview/#liveservertestcase
.. _Selenium: http://seleniumhq.org/
