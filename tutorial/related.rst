.. tut::
   :path: /src

================
Related Models
================

Adding Relationships
====================

.. checkpoint:: address_model

We have a basic email address book at this point, but there's other
information we might want to track for our contacts. Mailing
addresses, for example. A single Contact may have multiple addresses
associated with them, so we'll store this in a separate table,
allowing us to have multiple addresses for each Contact.

.. literalinclude:: /src/contacts/models.py
   :pyobject: Address

Django provides three types of fields for relating objects to each
other: ``ForeignKey`` for creating one to many relationships,
``ManyToManyField`` for relating many to many, and ``OneToOneField``
for creating a one to one relationship. You define the relationship in
one model, but it's accessible from the other side, as well.

Sync up the database to create the table, and then start the shell so
we can explore this.

::

  $ python manage.py syncdb
  Creating tables ...
  Creating table contacts_address
  Installing custom SQL ...
  Installing indexes ...
  Installed 0 object(s) from 0 fixture(s)
  $ python manage.py shell

XXX

Contact.address_set.all()
.create()
.filter()
Contact.objects.filter(address__type...)

Let's go ahead and add address display to our contacts. We'll add the
list of all Addresses to the Contact detail view.

.. literalinclude:: /src/contacts/templates/contact.html

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

.. sidebar:: Forms, FormSets, ModelForms

   TK: Overview of Forms

Up to this point we've written two models and some simple views.
Behind the scenes, however, Django has been creating a third class of
object for us: Forms. Forms are Django objects that help you take user
input from a request, validate it, and transform it into Python
objects. They also provide some optional helpers for rendering the
form's HTML, which we've also been using.

When you use one of the built-in generic views and give it a model,
Django creates a ModelForm_ for that model. A Model Form uses the model
field definition to figure out what the fields are, and what
validation rules to use. For example, our first and last name fields
both specify a maximum length of 255 characters; if you attempted to
create a Contact with a name longer than that, you'll see an error
message.

The first editing interface we're going to build for Addresses is one
that allows you to edit all the addresses for a Contact at once. To do
this, we'll need to create a FormSet that handles all the Addresses
for a single Contact. The `Inline FormSet`_ does just that.

.. literalinclude:: /src/contacts/forms.py

When we create the view, we'll need to specify that this is the form
we want to use, instead of having Django create one for us.

.. literalinclude:: /src/contacts/views.py
   :pyobject: EditContactAddressView

Note that even though we're editing Addresses with this view, we still
have ``model`` set to ``Contact``. This is because an inline formset
takes the parent object as it's starting point. In the next section
we'll see a more in depth example.

Once again, this needs to be wired up into the URL configuration.

.. literalinclude:: /src/addressbook/urls.py
   :lines: 15-16

And we have a simple template.

.. literalinclude:: /src/contacts/templates/edit_addresses.html

There are two new things in this template, both related to the fact
we're using a formset instead of a form. First, there's a reference to
``form.management_form``. This is a set of hidden fields that provide
some accounting information to Django: how many forms did we start
with, how many empty ones are there, etc. If Django can't find this
information when you POST the form, it will raise an exception.

Second, we're iterating over form instead of just outputting it (``for
address_form in form``). Again, this is because ``form`` here is a
formset instead of a single form. When you iterate over a formset,
you're iterating over the individual forms in it.
