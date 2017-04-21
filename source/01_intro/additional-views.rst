.. tut::
   :path: /projects/addressbook
   :href: https://github.com/nyergler/effective-django-tutorial/blob/{checkpoint}/{path}


========================
Additional Generic Views
========================

Edit Views
==========

.. checkpoint:: edit_contact_view

In addition to creating Contacts, we'll of course want to edit them.
As with the List and Create views, Django has a generic view we can
use as a starting point.

.. tut:diff:: /projects/addressbook/contacts/views.py

.. literalinclude:: /projects/addressbook/contacts/views.py
   :prepend: from django.views.generic import UpdateView
             ...
   :pyobject: UpdateContactView
   :end-before: def get_context_data

* we can re-use the same template
* but how does it know which contact to load?
* we need to either: provide a pk/slug, or override get_object().
* we'll provide pk in the URL

.. tut:diff:: /projects/addressbook/addressbook/urls.py

We'll update the contact list to include an edit link next to each
contact.

.. tut:literalinclude:: /projects/addressbook/contacts/templates/contact_list.html
   :language: django

Note the use of ``pk=contact.id`` in the ``{% url %}`` tag to specify
the arguments to fill into the URL pattern.

If you run the server now, you'll see an edit link. Go ahead and click
it, and try to make a change. You'll notice that instead of editing
the existing record, it creates a new one. Sad face.

If we look at the source of the edit HTML, we can easily see the
reason: the form targets ``/new``, not our edit URL. To fix this --
and still allow re-using the template -- we're going to add some
information to the `template context`_.

The template context is the information available to a template when
it's rendered. This is a combination of information you provide in
your view -- either directly or indirectly -- and information added by
`context processors`_, such as the location for static media and
current locale. In order to use the same template for add and edit,
we'll add information about where the form should redirect to the
context.

.. tut:literalinclude:: /projects/addressbook/contacts/views.py
   :pyobject: CreateContactView

.. tut:literalinclude:: /projects/addressbook/contacts/views.py
   :pyobject: UpdateContactView

We also update the template to use that value for the action and
change the title based on whether or not we've previously saved.

.. literalinclude:: /projects/addressbook/contacts/templates/edit_contact.html
   :lines: 5-11
   :language: django

You may wonder where the ``contact`` value in the contact comes from.
The class based views that wrap a single object (those that take
a primary key or slug) expose that to the context in two different
ways: as a variable named ``object``, and as a variable named after
the model class. The latter often makes your templates easier to read
and understand later. (You can customize this name by overriding
``get_context_object_name`` on your view.)

.. sidebar:: Made a Change? Run the Tests.

   We've just made a change to our ``CreateContactView``, which means
   this is a perfect time to run the tests we wrote. Do they still pass?
   If not, did we introduce a bug, or did the behavior change in a way
   that we expected?

   (Hint: We changed how the contact list is rendered, so our tests
   that just expect the name there are going to fail. This is a case
   where you'd need to update the test case, but it also demonstrates
   how integration tests can be fragile.)

Deleting Contacts
=================

.. checkpoint:: delete_contact_view

The final view for our basic set of views is delete. The generic
deletion view is very similar to the edit view: it wraps a single
object and requires that you provide a URL to redirect to on success.
When it processes a HTTP GET request, it displays a confirmation page,
and when it receives an HTTP DELETE or POST, it deletes the object and
redirects to the success URL.

We add the view definition to ``views.py``:

.. tut:diff:: /projects/addressbook/contacts/views.py

And create the template, ``delete_contact.html``, in our ``templates``
directory.

.. tut:literalinclude:: /projects/addressbook/contacts/templates/delete_contact.html
   :language: django

Of course we need to add this to the URL definitions:

.. tut:diff:: /projects/addressbook/addressbook/urls.py

And we'll add the link to delete to the edit page.

.. tut:literalinclude:: /projects/addressbook/contacts/templates/edit_contact.html
   :lines: 19-21

Detail View
===========

.. checkpoint:: contact_detail_view

Finally, let's go ahead and add a detail view for our Contacts. This
will show the details of the Contact: not much right now, but we'll
build on this shortly. Django includes a generic ``DetailView``: think
of it as the single serving ``ListView``.

.. literalinclude:: /projects/addressbook/contacts/views.py
   :prepend: from django.views.generic import DetailView
             ...
   :pyobject: ContactView

.. tut:diff:: /projects/addressbook/contacts/views.py

Again, the template is pretty straight forward; we create
``contact.html`` in the ``templates`` directory.

.. tut:literalinclude:: /projects/addressbook/contacts/templates/contact.html
   :language: html

And add the URL mapping:

.. tut:literalinclude:: /projects/addressbook/addressbook/urls.py
   :lines: 10-11

.. tut:diff:: /projects/addressbook/addressbook/urls.py

We're also going to add a method to our Contact model,
``get_absolute_url``. ``get_absolute_url`` is a Django convention for
obtaining the URL of a single model instance. In this case it's just
going to be a call to ``reverse``, but by providing this method, our
model will play nicely with other parts of Django.

.. tut:diff:: /projects/addressbook/contacts/models.py

.. literalinclude:: /projects/addressbook/contacts/models.py
   :prepend: class Contact(models.Model):
             ...
   :pyobject: Contact.get_absolute_url

And we'll add the link to the contact from the contact list.

.. tut:literalinclude:: /projects/addressbook/contacts/templates/contact_list.html
   :lines: 7-12
   :language: django


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
.. _LiveServerTestCase: https://docs.djangoproject.com/en/1.11/topics/testing/overview/#liveservertestcase
.. _Selenium: http://seleniumhq.org/
