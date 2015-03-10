.. tut::
   :path: /src

.. slideconf::
   :autoslides: False
   :theme: single-level

=============
Using Models
=============

.. slide:: Django Models
   :level: 1

   Storing and manipulating data with the Django ORM.


.. checkpoint:: contact_model

Configuring the Database
========================

.. slide:: Configuring Databases
   :level: 2

   .. literalinclude:: /src/addressbook/settings.py
      :language: python
      :lines: 12-21

Django includes support out of the box for MySQL, PostgreSQL, SQLite3,
and Oracle. SQLite3_ is included with Python starting with version
2.5, so we'll use it for our project for simplicity. If you were going
to use MySQL, for example, you'd need to add `mysql-python`_ to your
``requirements.txt`` file.

To enable SQLite as the database, edit the ``DATABASES`` definition in
``addressbook/settings.py``. The ``settings.py`` file contains the
Django configuration for our project. There are some settings that you
must specify -- like the ``DATABASES`` configuration -- and others
that are optional. Django fills in some defaults when it generates the
project scaffolding, and the documentation contains a `full list of
settings`_. You can also add your own settings here, if needed.

For SQLite we need to set the engine and then give it a name. The
SQLite backend uses the ``NAME`` as the filename for the database.

.. literalinclude:: /src/addressbook/settings.py
   :language: python
   :lines: 12-21

Note that the database engine is specified as a string, and not a
direct reference to the Python object. This is because the settings
file needs to be easily importable, without triggering any side
effects. You should avoid adding imports to the settings file.

You rarely need to import the settings file directly; Django imports
it for you, and makes it available as ``django.conf.settings``. You
typically import your settings from ``django.conf``::

  from django.conf import settings

Creating a Model
================

.. slide:: Defining Models
   :level: 2

   Models are created in the ``models`` module of a Django app and
   subclass Model_

   .. literalinclude:: /src/contacts/models.py
      :language: python
      :end-before: __str__

Django models map (roughly) to a database table, and provide a place
to encapsulate business logic. All models subclass the base Model_
class, and contain field definitions. Let's start by creating a simple
Contact model for our application in ``contacts/models.py``.


.. literalinclude:: /src/contacts/models.py
   :language: python

Django provides a set of fields_ that map to data types and different
validation rules. For example, the ``EmailField`` here maps to the
same column type as the ``CharField``, but adds validation for the
data.

Once you've created a model, you need to update your database with the
new tables. Django's ``syncdb`` command looks for models that are
installed and creates tables for them if needed.

::

  (tutorial)$ python ./manage.py syncdb

  Creating tables ...
  Creating table auth_permission
  Creating table auth_group_permissions
  Creating table auth_group
  Creating table auth_user_user_permissions
  Creating table auth_user_groups
  Creating table auth_user
  Creating table django_content_type
  Creating table django_session
  Creating table django_site

  ...

Our contact table isn't anywhere to be seen. The reason is that we
need to tell the Project to use the Application.

The ``INSTALLED_APPS`` setting lists the applications that the project
uses. These are listed as strings that map to Python packages. Django
will import each and looks for a ``models`` module there. Add our
Contacts app to the project's ``INSTALLED_APPS`` setting:

.. literalinclude:: /src/addressbook/settings.py
   :language: python
   :lines: 111-123

Then run ``syncdb`` again::

  (tutorial)$ python ./manage.py syncdb
  Creating tables ...
  Creating table contacts_contact
  Installing custom SQL ...
  Installing indexes ...
  Installed 0 object(s) from 0 fixture(s)

Note that Django created a table named ``contacts_contact``: by
default Django will name your tables using a combination of the
application name and model name. You can override that with the
`model Meta`_ options.


Interacting with the Model
==========================

.. slide:: Instantiating Models
   :level: 2

   ::

     nathan = Contact()
     nathan.first_name = 'Nathan'
     nathan.last_name = 'Yergler'
     nathan.save()

   ::

     nathan = Contact.objects.create(
         first_name='Nathan',
         last_name='Yergler')

   ::

     nathan = Contact(
         first_name='Nathan',
         last_name='Yergler')
     nathan.save()

Now that the model has been synced to the database we can interact
with it using the interactive shell.

::

  (tutorial)$ python ./manage.py shell
  Python 2.7.3 (default, Aug  9 2012, 17:23:57)
  [GCC 4.7.1 20120720 (Red Hat 4.7.1-5)] on linux2
  Type "help", "copyright", "credits" or "license" for more information.
  (InteractiveConsole)
  >>> from contacts.models import Contact
  >>> Contact.objects.all()
  []
  >>> Contact.objects.create(first_name='Nathan', last_name='Yergler')
  <Contact: Nathan Yergler>
  >>> Contact.objects.all()
  [<Contact: Nathan Yergler>]
  >>> nathan = Contact.objects.get(first_name='Nathan')
  >>> nathan
  <Contact: Nathan Yergler>
  >>> print nathan
  Nathan Yergler
  >>> nathan.id
  1

There are a few new things here. First, the ``manage.py shell``
command gives us a interactive shell with the Python path set up
correctly for Django. If you try to run Python and just import your
application, an Exception will be raised because Django doesn't know
which ``settings`` to use, and therefore can't map Model instances to
the database.

Second, there's this ``objects`` property on our model class. That's
the model's Manager_. If a single instance of a Model is analogous to
a row in the database, the Manager is analogous to the table. The
default model manager provides querying functionality, and can be
customized. When we call ``all()`` or ``filter()`` or the Manager, a
QuerySet is returned. A QuerySet is iterable, and loads data from the
database as needed.

Finally, there's this ``id`` field that we didn't define. Django adds
an ``id`` field as the primary key for your model, unless you `specify
a primary key`_.


.. slide:: Model Managers
   :level: 2

   * A model instance maps to a row
   * The model Manager_ maps to the table
   * Every model has a default manager, ``objects``
   * Operations that deal with more than one instance, or at the
     "collection" level, usually map to the Manager

.. slide:: Querying with Managers
   :level: 2

   * The ``filter`` Manager method lets you perform queries::

       Contact.objects.filter(last_name='Yergler')

   * ``filter`` returns a QuerySet_, an iterable over the result.
   * You can also assert you only expect one::

       Contact.objects.get(first_name='Nathan')

   * If more than one is returned, an Exception will be raised
   * The full query_ reference is pretty good on this topic.

Writing a Test
==============

.. slide:: Testing Models
   :level: 2

   * Business logic is usually added as methods on a Model.
   * Important to write unit tests for those methods as you add them.
   * We'll write an example test for the methods we add.


We have one method defined on our model, ``__str__``, and this is a
good time to start writing tests. The ``__str__`` method of a model
will get used in quite a few places, and it's entirely conceivable
it'd be exposed to end users. It's worth writing a test so we
understand how we expect it to operate. Django creates a ``tests.py``
file when it creates the application, so we'll add our first test to
that file in the contacts app.

.. literalinclude:: /src/contacts/tests.py
   :language: python
   :prepend: from contacts.models import Contact
             ...
   :pyobject: ContactTests

.. slide:: Running the Tests
   :level: 2

   You can run the tests for your application using ``manage.py``::

     (tutorial)$ python manage.py test


You can run the tests for your application using ``manage.py``::

  (tutorial)$ python manage.py test

If you run this now, you'll see that around 420 tests run. That's
surprising, since we've only written one. That's because by default
Django runs the tests for all installed applications. When we added
the ``contacts`` app to our project, there were several Django apps
there by default. The extra 419 tests come from those.

If you want to run the tests for a specific app, just specify the app
name on the command line::

  (tutorial)$ python manage.py test contacts
  Creating test database for alias 'default'...
  ..
  ----------------------------------------------------------------------
  Ran 2 tests in 0.000s

  OK
  Destroying test database for alias 'default'...
  $

One other interesting thing to note before moving on is the first and
last line of output: "Creating test database" and "Destroying test
database". Some tests need access to a database, and because we don't
want to mingle test data with "real" data (for a variety of reasons,
not the least of which is determinism), Django helpfully creates a
test database for us before running the tests. Essentially it creates
a new database, and runs ``syncdb`` on it. If you subclass from
Django's ``TestCase`` (which we are), Django also resets any default
data after running each TestCase, so that changes in one test won't
break or influence another.

.. rst-class:: include-as-slide, slide-level-2

Review
======

* Models define the fields in a table, and can contain business logic.
* The ``syncdb`` manage command creates the tables in your database from
  models
* The model Manager allows you to operate on the collection of
  instances: querying, creating, etc.
* Write unit tests for methods you add to the model
* The ``test`` manage command runs the unit tests

.. ifslides::

   * Next: :doc:`views`

.. _QuerySet: https://docs.djangoproject.com/en/1.5/ref/models/querysets/#django.db.models.query.QuerySet
.. _query: https://docs.djangoproject.com/en/1.5/topics/db/queries/
.. _SQLite3: http://docs.python.org/2/library/sqlite3.html
.. _mysql-python: https://pypi.python.org/pypi/MySQL-python
.. _`full list of settings`: https://docs.djangoproject.com/en/1.5/ref/settings/
.. _Model: https://docs.djangoproject.com/en/1.5/ref/models/instances/#django.db.models.Model
.. _Manager: https://docs.djangoproject.com/en/1.5/topics/db/managers/
.. _`specify a primary key`: https://docs.djangoproject.com/en/1.5/topics/db/models/#automatic-primary-key-fields
.. _fields: https://docs.djangoproject.com/en/1.5/ref/models/fields/
.. _`model Meta`: https://docs.djangoproject.com/en/1.5/ref/models/options/
