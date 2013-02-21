.. tut::
   :path: /src

======================
 Adding Relationships
======================

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


So how do we go about editing addresses for our contacts? You can
imagine creating another CreateView like we did for Contacts, but the
question remains: how do we wire the new Address to our Contact? We
could conceivably just pass the Contact's ID through the the HTML, but
we'd still need to validate that it hadn't been tampered with when we
go to create the Address.

To deal with this, we'll create a form that understands the
relationship between Contacts and Addresses.

.. checkpoint:: master

:: address_form_and_view

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

These generated model forms are great, but they don't know
