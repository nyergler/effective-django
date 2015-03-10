======================
 Effective Django ORM
======================

Configuring the Database
========================

Writing Models
==============

.. testcode::

   from django.db import models

   class Address(models.Model):

       address = models.CharField(max_length=255, blank=True)
       city = models.CharField(max_length=150, blank=True)
       state = models.CharField(max_length=2, blank=True)
       zip = models.CharField(max_length=15, blank=True)

   class Contact(models.Model):

       first_name = models.CharField(max_length=255, blank=True)
       last_name = models.CharField(max_length=255, blank=True)

       birthdate = models.DateField(auto_now_add=True)
       phone = models.CharField(max_length=25, blank=True)
       email = models.EMailField(blank=True)

       address = models.ForeignKey(Address, null=True)

Working with Models
===================

.. testcode::

   nathan = Contact()
   nathan.first_name = 'Nathan'
   nathan.last_name = 'Yergler'
   nathan.save()

What Goes in Models
===================

* Models should encapsulate business logic
* Encourages testable, composable code
* If logic operates on a "set" of Models, put it in the Manager

Saving Data
===========

* Starting in Django 1.5, calling ``.save()`` only updates the fields
  that have changed.
* Prior to 1.5, ``.save()`` updated the entire model, making it easy
  to overwrite changes
* `django-dirtyfields`_ lets you track which fields have been changed
  if you're stuck on an older version of Django (but does not change
  ``.save()`` behavior on its own)

Managers
========

* Models get a manager injected as ``.objects``
* Managers allow you to operate over collections of your model
* Default manager emulates part of the ``QuerySet`` API for
  convenience

.. testcode::

   Contact.objects.filter(last_name__iexact='yergler')
   Contact.objects.filter(address__state='OH')

Custom Managers
---------------

* You can override the default Manager, or add additional ones
* Operations on sets of Model instances belongs here
* Subclass from ``models.Manager`` to get queryset emulation

.. testcode::

   class ContactManager(models.Manager):

       def with_email(self):
           return self.filter(email__ne = '')

   class Contact(models.Model):
       ...

       objects = ContactManager()

.. testcode::

   contacts.objects.with_email().filter(email__endswith='osu.edu')

Low-level Managers
------------------

* Sometimes you want to heavily customize the manager without
  re-implementing everything
* ``Manager.get_query_set()``
  allows you to customize the basic QuerySet used by Manager methods

Testing
=======

What to Test
------------

* Business logic methods
* Customized Manager methods

Writing a Test
--------------

.. testcode::

   def test_with_email():

       # make a couple Contacts
       Contact.objects.create(first_name='Nathan')
       Contact.objects.create(email='nathan@eventbrite.com')

       self.assertEqual(
           len(Contact.objects.with_email()), 1
       )


Test Objects
------------

* Creating objects for tests is time consuming
* Unnecessarily involves the database
* `factory boy`_ provides an easy way to make model factories

FactoryBoy Example
------------------

.. testcode::

   import factory
   from models import Contact

   class ContactFactory(factory.Factory):
       FACTORY_FOR = Contact

       first_name = 'John'
       last_name = 'Doe'

   # Returns a Contact instance that's not saved
   contact = ContactFactory.build()
   contact = ContactFactory.build(last_name='Yergler')

   # Returns a saved Contact instance
   contact = ContactFactory.create()

SubFactories for Related Objects
--------------------------------

.. testcode::

   class AddressFactory(factory.Factory):
       FACTORY_FOR = Address

       contact = factory.SubFactory(ContactFactory)

.. testcode::

   address = AddressFactory(city='Columbus', state='OH')
   address.contact.first_name

.. testoutput::

   'John'

Querying Your Data
==================

* Query Sets are chainable

.. testcode::

   Contact.objects.filter(state='OH').filter(email__ne='')

* Multiple filters are collapsed into SQL "and" conditions

OR conditions in Queries
------------------------

If you need to do "or" conditions, you can use ``Q`` objects

.. testcode::

   from django.db.models import Q

   Contact.objects.filter(
       Q(state='OH') | Q(email__endswith='osu.edu')
   )

.. F objects let you refer to fields in the same object
.. ----------------------------------------------------

.. XXX


ORM Performance
===============


Instantiation is Expensive
--------------------------

::

   for user in Users.objects.filter(is_active=True):
       send_email(user.email)

* QuerySets are lazy, but have non-trivial overhead when evaluated
* If a query returns 1000s of rows, users will notice this
* ``.values()`` and ``.values_list()`` avoid instantiation

Avoiding Instantiation
----------------------

::

   user_emails = Users.objects.\
       filter(is_active=True).\
       values_list('email', flat=True)

   for email in user_emails:
       send_email(email)


Traversing Relationships
------------------------

* Traversing foreign keys can incur additional queries
* ``select_related`` queries for foreign keys in the initial query

.. testcode::

   Contact.objects.\
       select_related('address').\
       filter(last_name = 'Yergler')


Query Performance
-----------------

* QuerySets maintain state in memory
* Chaining triggers cloning, duplicating that state
* Unfortunately, QuerySets maintain a *lot* of state
* If possible, don't chain more than one filter

Falling Back to Raw SQL
-----------------------

* Django has to be database agnostic, you don't
* Sometimes the clearest thing to do is write a SQL statement
* The ``.raw()`` method lets you do this

.. testcode::

   Contact.objects.raw('SELECT * FROM contacts WHERE last_name = %s', [lname])

* Must retrieve the primary key
* Omitted fields will be "deferred"
* **DO NOT** use string formatting in ``raw()`` calls

Other Manager Operations
------------------------

Managers have some additional helpers for operating on the table or
collection:

* ``get_or_create``
* ``update``
* ``delete``
* ``bulk_insert``


Read Repeatable
---------------

MySQL's default transaction isolation for InnoDB **breaks**
Django's ``get_or_create`` when running at scale

::

    def get_or_create(self, **kwargs):

        try:
            return self.get(**lookup), False
        except self.model.DoesNotExist:
            try:
                obj = self.model(**params)
                obj.save(force_insert=True, using=self.db)
                return obj, True
            except IntegrityError, e:
                try:
                    return self.get(**lookup), False
                except self.model.DoesNotExist:
                    raise e


.. _`django-dirtyfields`: http://pypi.python.org/pypi/django-dirtyfields/
.. _`factory boy`: http://pypi.python.org/pypi/factory_boy
