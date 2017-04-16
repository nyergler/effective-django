===============
 Writing Views
===============

Django Views are responsible for processing HTTP requests from the browser. Views take an `HTTP Request`_ and return an `HTTP Response`_ to
the user. In this section you'll learn the basics of Django views and use some of the scaffolding Django provides to list and create Contacts.

View Basics
===========

Any Python callable can be a view. The only hard and fast requirement
is that it takes the request object (customarily named ``request``) as
its first argument. This means that a minimalist view is super
simple.

.. code-block:: python

  from django.http import HttpResponse

  def hello_world(request):
      return HttpResponse("Hello, World")

Of course, like most frameworks, Django also allows you to pass
arguments to the view from the URL. We'll cover this as we build up
our application.

.. _`HTTP Request`: https://docs.djangoproject.com/en/1.11/ref/request-response/#httprequest-objects
.. _`HTTP Response`: https://docs.djangoproject.com/en/1.11/ref/request-response/#httpresponse-objects

Class Based Views
=================

"Class based views" are a way to write views as Python classes rather than functions. This in and of itself isn't that interesting, but Django provides some ready made classes that are easily extended to handle situations with a minmum of code.

The minimal class based view subclasses View_ and implements methods for the HTTP methods it supports. Here's the class-based version of the minimalist "Hello, World" view we previously wrote.

.. code-block:: python

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

For our contact manager we'll start with a view that presents a list of contacts in the database.

The basic view implementation is shockingly brief. We can write the
view in just a few lines in the ``views.py`` file in our ``contacts``
application.

.. code-block:: python

  from django.views.generic import ListView
  from contacts.models import Contact

  class ListContactView(ListView):
      model = Contact

The ListView_ that we subclass from is itself composed of several mixins that provide some behavior, and that composition gives us a lot of power without a lot of code. In this case we set ``model = Contact``, which says that this view is going to list *all* the Contacts in our database.

Defining URLs
=============

The URL configuration tells Django how to match a request's path to
your Python code. Django looks for the URL configuration, defined as
``urlpatterns``, in the ``urls.py`` file in your project.

Let's add a URL mapping for our contact list view in ``addressbook/urls.py``.

.. code-block:: python

  from django.conf.urls import url
  from django.contrib import admin
  from contacts.views import ListContactView


  urlpatterns = [
      url(r'^admin/', admin.site.urls),
      url(r'^$', ListContactView.as_view(),
          name='contacts-list',),
  ]

The ``admin.site.urls`` URL was included for us by Django. We'll talk more about what that does in the `next section`_.

``urlpatterns`` is a list of _routes_ that map a URL to a view. Let's go through the parameters we used one by one.

The first parameter is a `regular expression`_; any request whose URL matches the regular expression will be routed to the view. We want to show the contact list at the root of our application, so we specify ``^$``. (Why might the trailing ``$`` be important here?)

The second parameter, ``ListContactView.as_view()``, specifies the view to call when the URL matches the regular expression. This can either be the actual callable that you've important (as we did here), or a string specifying the full Python package path to the view. Note that for class based views we *must* import the object and use it here. That's because we have to call the class method ``as_view()``; this method returns a function that handles instantiating our class and invoking with the request.

The third argument, ``name='contacts-list'``, specifies the "name" for this route. As we'll see later, this is useful when we link from one view to another, or need to redirect; it allows us to use ``contacts-list`` instead of specifying the actual URL, so it's much easier to move things around later.

While the ``urlpatterns`` name **must** be defined in ``urls.py``, Django also allows you to define a few other values in the URL configuration for exceptional cases. These include ``handler403``, ``handler404``, and
``handler500``, which tell Django what view to use when an HTTP error
occurs. See the `Django urlconf documentation`_ for details.

.. _`Django urlconf documentation`: https://docs.djangoproject.com/en/1.11/ref/urls/

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
   /_static/01/template_not_found.PNG

Most of Django's generic views (such as ``ListView`` which we're
using) have a predefined template name that they expect to find. We
can see in this error message that this view was expecting to find
``contact_list.html``, which is derived from the model name. Let's go
and create that.

By default Django will look for templates in applications. You can also specify additional directories to look in by adding them to the ``DIRS`` setting of the template engine.

.. code-block:: python

  TEMPLATES = [
      {
          'BACKEND': 'django.template.backends.django.DjangoTemplates',
          'DIRS': [],
          'APP_DIRS': True,
          'OPTIONS': {
              'context_processors': [
                  'django.template.context_processors.debug',
                  'django.template.context_processors.request',
                  'django.contrib.auth.context_processors.auth',
                  'django.contrib.messages.context_processors.messages',
              ],
          },
      },
  ]

The generic views also expect that the templates will be found in a sub-directory named after the application; in this case ``contacts``. This approach works well when you're distributing a reusable application: the consumer can create templates which override any defaults you ship, and they're clearly stored in a directory associated with the application.

For our purposes, however, we don't need that extra layer of directory
structure, so we'll specify the template to use explicitly, using the
``template_name`` property. Let's add that one line to ``views.py``.

.. code-block:: python

  from django.views.generic import ListView
  from contacts.models import Contact

  class ListContactView(ListView):
      model = Contact
      template_name = 'contact_list.html'


Create a ``templates`` subdirectory in our ``contacts`` application,
and create ``contact_list.html`` there.

.. code-block:: django

  <html>
  <body>
    <h1>Contacts</h1>

    <ul>
      {% for contact in object_list %}
      <li class="contact">
        <a href="{{ contact.get_absolute_url }}">{{ contact }}</a>
        (<a href="{% url "contacts-edit" pk=contact.id %}">edit</a>)
      </li>
      {% endfor %}
    </ul>
  </body>
  </html>

Opening the page in the browser, we should see one contact there, the
one we added earlier through the interactive shell.

Creating Contacts
=================

With our contact list view we can see the contact we `created through the interactive shell`_, but adding all our data through that interface is going to get old fast. Next we'll create a view for adding new contacts to the database.

Just like the list view, we'll use one of Django's generic views. In
``views.py``, we can add the new view:

.. code-block:: python

  from django.views.generic import CreateView
  from django.core.urlresolvers import reverse


  class CreateContactView(CreateView):
      model = Contact
      template_name = 'edit_contact.html'

      def get_success_url(self):
          return reverse('contacts-list')


Most generic views that handle user input have the concept of the "success URL": where to send the user when the data is successfully processed.  The form processing views all adhere to the practice of POST-redirect-GET for submitting changes, so that refreshing the final page won't result in form re-submission.

You can either define this as a class property, or override the ``get_success_url()`` method, as we're doing here. In this case we're using the ``reverse`` function to calculate the URL of the contact list.

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

.. code-block:: django

  <html>
  <body>
    <h1>Add Contact</h1>

    <form action="{{ action }}" method="POST">
      {% csrf_token %}
      <ul>
        {{ form.as_ul }}
      </ul>
      <input id="save_contact" type="submit" value="Save" />
    </form>

    <a href="{% url "contacts-list" %}">back to list</a>
  </body>
  </html>

There are a few things in this template that we haven't seen before. First, the ``form`` variable is the `Django Form`_ for our model. Since we didn't specify one, Django created one on the fly for us; how thoughtful. We wrote ``{{ form.as_ul }}`` to output the model fields as a list; if we had just used ``{{ form }}``, Django would have formatted the fields in a ``<table>``; try replacing ``.as_ul`` with ``.as_p`` and see what happens.

.. sidebar:: Calling Methods in Django TEMPLATES

  TK: No ``()`` required.

The Form object only includes the fields we specify in our model, so we have to manually add the surrounding ``<form>`` tag and submit button.

We also add ``{% csrf_token %}`` within the form. This tag inserts a hidden input that Django uses to verify the request came from your project, and isn't a forged cross-site request. (Try omitting it and creating a contact to see what happens without.) We'll talk more about this later when we talk about `security`_ and `cross-site request forgery`_.

Finally, we're using the ``url`` template tag to create a link back to our contact list. Note that ``contacts-list`` is the name of our view from the URL configuration. By using ``url`` insetad of an explicit path, we don't have to worry about a link breaking if we move things around. ``url`` is the template equivalent to the ``reverse`` function we used in our view's ``get_success_url()`` earlier.

You can configure the URL by adding the following line to our ``urls.py`` file.

.. code-block:: python

  from contacts.views import CreateContactView

  ...

    url(r'^new$', CreateContactView.as_view(),
        name='contacts-new',),

Now you can go to ``http://localhost:8000/new`` to create new contacts.

To complete the story, let's add a link to add contacts from our contact list. Add the following HTML to the ``contact_list.html`` template to show that link.

.. code-block:: django

  <a href="{% url "contacts-new" %}">Add a contact</a>


Testing Your Views
==================

So far our views have been pretty minimal: they leverage Django's generic views, and contain very little of our own code or logic. One perspective is that this is how it should be: a view takes a request, and returns a response, delegating the issue of validating input to forms, and business logic to model methods (TK: `service layer`_). This is a perspective that I subscribe to: the less logic contained in views, the better.

However, there is code in views that should be tested, either by unit tests or integration tests. The distinction is important: unit tests are focused on testing a single piece of functionality, usually only a single function or method. When you're writing a unit test, the assumption is that everything else has its own tests and is working properly. Integration tests attempt to test the system from end to end, so you can ensure that the points of integration are functioning properly. Most systems have both.

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

In practice, RequestFactory tests are usually somewhat faster than the TestClient. This isn't a big deal when you have five tests, but it is when you have 500 or 5,000. Let's look at the same test written with each tool.

.. code-block:: python

  from django.test.client import Client
  from django.test.client import RequestFactory

  from contacts.views import ListContactView

  class ContactListViewTests(TestCase):
      """Contact list view tests."""

      def test_contacts_in_the_context(self):

          client = Client()
          response = client.get('/')

          self.assertEquals(list(response.context['object_list']), [])

          Contact.objects.create(first_name='foo', last_name='bar')
          response = client.get('/')
          self.assertEquals(response.context['object_list'].count(), 1)

      def test_contacts_in_the_context_request_factory(self):

          factory = RequestFactory()
          request = factory.get('/')

          response = ListContactView.as_view()(request)

          self.assertEquals(list(response.context_data['object_list']), [])

          Contact.objects.create(first_name='foo', last_name='bar')
          response = ListContactView.as_view()(request)
          self.assertEquals(response.context_data['object_list'].count(), 1)


As you can see the tests are almost identical: they both get a response and make assertions about the context. The primary difference is that the Request Factory test manually instantiates the ``ListContactView``.

Integration Tests
=================

Django 1.4 added a new ``TestCase`` base class, the LiveServerTestCase_. This is very much what it sounds like: a test case that runs against a live server. By default Django will start the development server for you when it runs these tests, but they can also be run against another server.

Selenium_ is a tool for writing tests that drive a web browser, and that's what we'll use for our integration tests. By using Selenium, you're able to automate different browers (Chrome, Firefox, etc), and interact with your full application much as the user would. Before writing tests to use it, we'll need to install the Python implementation.

.. code-block:: console

  (addresses) $ pip install selenium
  Collecting selenium
    Downloading selenium-3.3.3-py2.py3-none-any.whl (931kB)
      100% |████████████████████████████████| 931kB 1.1MB/s
  Installing collected packages: selenium
  Successfully installed selenium-3.3.3

We're going to write three tests for our views:

- one that creates a Contact and makes sure it's listed
- one that makes sure our "add contact" link is visible and linked on the list page
- and one that actually exercises the add contact form, filling it in and submitting it.

The tests we're writing use `Selenium Webdriver`_. Webdriver starts a browser for us and sends it the interactions we specify, returning the results. In these tests we're using the Firefox webdriver, but webdrivers exist for Chrome, Internet Explorer, and PhantomJS (which is useful if you need to run these tests in a headless environment).

.. todo:: W3C Webdriver

.. _`Selenium Webdriver`: http://www.seleniumhq.org/projects/webdriver/

.. code-block:: python

  from django.test import LiveServerTestCase
  from selenium.webdriver.firefox.webdriver import WebDriver


  class ContactListIntegrationTests(LiveServerTestCase):

      @classmethod
      def setUpClass(cls):
          super(ContactListIntegrationTests, cls).setUpClass()
          cls.selenium = WebDriver()

      @classmethod
      def tearDownClass(cls):
          cls.selenium.quit()
          super(ContactListIntegrationTests, cls).tearDownClass()

      def test_contact_listed(self):

          # create a test contact
          Contact.objects.create(first_name='foo', last_name='bar')

          # make sure it's listed as <first> <last> on the list
          self.selenium.get('%s%s' % (self.live_server_url, '/'))
          self.assertTrue(
              self.selenium.find_elements_by_css_selector('.contact')[0]
              .text.startswith('foo bar'),
          )

      def test_add_contact_linked(self):

          # fetch our root page
          self.selenium.get('%s%s' % (self.live_server_url, '/'))

          # make sure the "add contact" link exists
          self.assert_(
              self.selenium.find_element_by_link_text('add contact')
          )

      def test_add_contact(self):

          self.selenium.get('%s%s' % (self.live_server_url, '/'))
          self.selenium.find_element_by_link_text('add contact').click()

          self.selenium.find_element_by_id('id_first_name').send_keys('test')
          self.selenium.find_element_by_id('id_last_name').send_keys('contact')
          self.selenium.find_element_by_id('id_email').send_keys(
              'test@example.com')
          self.selenium.find_element_by_id('id_confirm_email').send_keys(
              'test@example.com')

          self.selenium.find_element_by_id("save_contact").click()

          self.assertTrue(
              self.selenium.find_elements_by_css_selector('.contact')[0].text
              .startswith('test contact'),
          )

.. todo:: Missing geckodriver

  If you attempt to run these tests and receive an error message saying geckodriver is missing, you'll need to `download it<https://github.com/mozilla/geckodriver/releases>`_ and ensure it's on the PATH.

In our example we're using CSS Selectors to locate elements in the
DOM, but you can also use Xpath. For many people it's a matter of
preference, but I've found that CSS Selectors are slightly less
brittle: if I change the markup, I'm likely to leave classes on
important elements in place, even if their relative position in the
DOM changes.

.. todo::

  If you run these tests you'll notice that they take longer to run than the unit tests we wrote previously. Include recommendations on split runs.

Review
======

* Views take a Request and return a Response
* Django's class-based views allow you to create simple views with very little effort.
* URLs are defined in the ``urls.py`` file in your _project_.
* Naming URLs allows you to generate the URL for a view.
* RequestFactory_ creates Requests for testing Views
  with
* LiveServerTestCase_ provides basis for writing integration tests


.. _`Generic Views`: https://docs.djangoproject.com/en/1.11/topics/class-based-views/generic-display/
.. _`Class Based Views`: https://docs.djangoproject.com/en/1.11/topics/class-based-views/
.. _View: https://docs.djangoproject.com/en/1.11/ref/class-based-views/base/#view
.. _ListView: https://docs.djangoproject.com/en/1.11/ref/class-based-views/generic-display/#listview
.. _UpdateView: https://docs.djangoproject.com/en/1.11/ref/class-based-views/generic-editing/#updateview
.. _CreateView: https://docs.djangoproject.com/en/1.11/ref/class-based-views/generic-editing/#createview
.. _DeleteView: https://docs.djangoproject.com/en/1.11/ref/class-based-views/generic-editing/#deleteview
.. _DetailView: https://docs.djangoproject.com/en/1.11/ref/class-based-views/generic-display/#detailview
.. _`context processors`: https://docs.djangoproject.com/en/1.11/ref/templates/api/#subclassing-context-requestcontext
.. _`Django Form`: https://docs.djangoproject.com/en/1.11/topics/forms/
.. _HttpRequest: https://docs.djangoproject.com/en/1.11/ref/request-response/#httprequest-objects
.. _HttpResponse: https://docs.djangoproject.com/en/1.11/ref/request-response/#httpresponse-objects
.. _Client: https://docs.djangoproject.com/en/1.11/topics/testing/overview/#module-django.test.client
.. _RequestFactory: https://docs.djangoproject.com/en/1.11/topics/testing/advanced/#django.test.client.RequestFactory
.. _LiveServerTestCase: https://docs.djangoproject.com/en/1.11/topics/testing/tools/#liveservertestcase
.. _Selenium: http://seleniumhq.org/
