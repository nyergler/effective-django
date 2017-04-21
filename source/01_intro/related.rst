.. tut::
   :path: /projects/addressbook

==============
Related Models
==============

Adding Relationships
====================

.. checkpoint:: address_model

We have a basic email address book at this point, but there's other
information we might want to track for our contacts. Mailing
addresses, for example. A single Contact may have multiple addresses
associated with them, so we'll store this in a separate table,
allowing us to have multiple addresses for each Contact.

.. literalinclude:: /projects/addressbook/contacts/models.py
   :pyobject: Address

Django provides three types of fields for relating objects to each
other: ``ForeignKey`` for creating one to many relationships,
``ManyToManyField`` for relating many to many, and ``OneToOneField``
for creating a one to one relationship. You define the relationship in
one model, but it's accessible from the other side, as well.

Sync up the database to create the table, and then start the shell so
we can explore this.

::

  (tutorial)$ python manage.py syncdb
  Creating tables ...
  Creating table contacts_address
  Installing custom SQL ...
  Installing indexes ...
  Installed 0 object(s) from 0 fixture(s)

Now that we have the model created, we can again play with it using
the interactive shell.

::

  (tutorial)$ python manage.py shell
  Python 2.7.3 (default, Aug  9 2012, 17:23:57)
  [GCC 4.7.1 20120720 (Red Hat 4.7.1-5)] on linux2
  Type "help", "copyright", "credits" or "license" for more information.
  (InteractiveConsole)
  >>> from contacts.models import Contact, Address
  >>> nathan = Contact.objects.create(first_name='Nathan', email='nathan@yergler.net')
  >>> nathan.address_set.all()
  []
  >>> nathan.address_set.create(address_type='home',
  ... city='San Francisco', state='CA', postal_code='94107')
  <Address: Address object>
  >>> nathan.address_set.create(address_type='college',
  ... address='354 S. Grant St.', city='West Lafayette', state='IN',
  ... postal_code='47906')
  <Address: Address object>
  >>> nathan.address_set.all()
  [<Address: Address object>, <Address: Address object>]
  >>> nathan.address_set.filter(address_type='college')
  <Address: Address object>
  >>> Address.objects.filter(contact__first_name='Nathan')
  [<Address: Address object>, <Address: Address object>]

As you can see, even though we defined the relationship between
Contacts and Addresses on the Address model, Django gives us a way to
access things in the reverse direction. We can also use the double
underscore notation to filter Addresses or Contacts based on the
related objects.

Let's go ahead and add address display to our contacts. We'll add the
list of all Addresses to the Contact detail view in ``contact.html``.

.. literalinclude:: /projects/addressbook/contacts/templates/contact.html

Editing Related Objects
=======================

So how do we go about editing addresses for our contacts? You can
imagine creating another CreateView like we did for Contacts, but the
question remains: how do we wire the new Address to our Contact? We
could conceivably just pass the Contact's ID through the the HTML, but
we'd still need to validate that it hadn't been tampered with when we
go to create the Address.

To deal with this, we'll create a form that understands the
relationship between Contacts and Addresses.

.. checkpoint:: edit_addresses

The editing interface we're going to build for Addresses is one that
allows you to edit all the addresses for a Contact at once. To do
this, we'll need to create a FormSet_ that handles all the Addresses
for a single Contact. A FormSet is an object that manages multiple
copies of the same Form (or ModelForm) in a single page. The `Inline
FormSet`_ does this for a set of objects (in this case Addresses) that
share a common related object (in this case the Contact).

Because formsets are somewhat complex objects, Django provides factory
functions that create the class for you. We'll add a call to the
factory to our ``forms.py`` file.

.. literalinclude:: /projects/addressbook/contacts/forms.py
   :lines: 3-8,40-

When we create the view, we'll need to specify that this is the form
we want to use, instead of having Django create one for us.

.. literalinclude:: /projects/addressbook/contacts/views.py
   :pyobject: EditContactAddressView

Note that even though we're editing Addresses with this view, we still
have ``model`` set to ``Contact``. This is because an inline formset
takes the parent object as its starting point.

Once again, this needs to be wired up into the URL configuration.

.. literalinclude:: /projects/addressbook/addressbook/urls.py
   :lines: 16-17

And we have a simple template.

.. literalinclude:: /projects/addressbook/contacts/templates/edit_addresses.html
   :language: django

There are two new things in this template, both related to the fact
we're using a formset instead of a form. First, there's a reference to
``form.management_form``. This is a set of hidden fields that provide
some accounting information to Django: how many forms did we start
with, how many empty ones are there, etc. If Django can't find this
information when you POST the form, it will raise an exception.

Second, we're iterating over form instead of just outputting it (``for
address_form in form``). Again, this is because ``form`` here is a
formset instead of a single form. When you iterate over a formset,
you're iterating over the individual forms in it. These individual
forms are just "normal" ``ModelForm`` instances for each Address, so
you can apply the same output techniques you would normally use.

.. _FormSet: https://docs.djangoproject.com/en/1.11/topics/forms/formsets/
.. _`Inline FormSet`: https://docs.djangoproject.com/en/1.11/topics/forms/modelforms/#inline-formsets
