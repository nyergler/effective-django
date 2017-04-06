=============
Using Models
=============

In this section you'll learn how to configure Django to connect to a database, as well as the basics of creating Python classes (models) that represent information in the database.

Configuring the Database
========================

Django includes support out of the box for MySQL, PostgreSQL, SQLite3, and Oracle. SQLite3_ is included with Python, so we'll use it for our project for simplicity. If you were going to use MySQL, for example, you'd need to add `mysql-python`_ to your ``requirements.txt`` file. We'll discuss using databases like MySQL and Postgres in Deploying_.

You can find the database configuration in ``addressbook/settings.py``. The ``settings.py`` file contains the
Django configuration for our project. There are some settings that you
must specify -- like the ``DATABASES`` configuration, for example -- and others
that are optional. Django fills in some defaults when it generates the
project scaffolding, and the documentation contains a `full list of
settings`_. You can also add your own settings here, if needed.

Django defaults to SQLite, so we'll just look at the database configuration to make sure we understand it.

.. code-block:: python

  DATABASES = {
      'default': {
          'ENGINE': 'django.db.backends.sqlite3',
          'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
      }
  }

Here we see that the ``default`` database is configured with the SQLite3 engine and will be named ``db.sqlite3`` in the project directory (``BASE_DIR``, defined near the top of ``settings.py``).

Note that the database engine is specified as a string, and not a
direct reference to the Python object. This is because the settings
file needs to be easily importable, without triggering any side
effects. **You should avoid adding imports to the settings file.**

You rarely need to import the settings file directly; Django imports
it for you, and makes it available as ``django.conf.settings``. You
typically import your settings from ``django.conf``::

  from django.conf import settings

By referring to ``django.conf.settings`` your code doesn't need to bake in assumptions about package names, etc: you can write Django _applications_ that can plug into different _projects_ in the future.

Creating a Model
================

Django models map (roughly) to a database table, and provide a place
to encapsulate business logic. All models subclass the base Model_
class, and contain field definitions. Let's start by creating a simple
Contact model for our application in ``contacts/models.py``.

.. code-block:: python

  from django.db import models


  class Contact(models.Model):

      first_name = models.CharField(
          max_length=255,
      )
      last_name = models.CharField(
          max_length=255,
      )

      email = models.EmailField()

      def __str__(self):
          return ' '.join([
              self.first_name,
              self.last_name,
          ])

Django provides a set of fields_ that map to data types and different
validation rules. For example, the ``EmailField`` here maps to the
same column type as the ``CharField``, but adds validation for the
data.

Once you've created or updated a model, you need to update your database with the changes. Django's ``makemigrations`` command creates new migrations based on your code changes. The ``migrate`` command runs pending migrations.

Before we create the migration for our Contact model, let's run the pending migrations. These are migrations included with the apps Django installs by default.

.. code-block:: console

  (addresses) $ python manage.py migrate
  Operations to perform:
    Apply all migrations: admin, auth, contenttypes, sessions
  Running migrations:
    Applying contenttypes.0001_initial... OK
    Applying auth.0001_initial... OK
    Applying admin.0001_initial... OK
    Applying admin.0002_logentry_remove_auto_add... OK
    Applying contenttypes.0002_remove_content_type_name... OK
    Applying auth.0002_alter_permission_name_max_length... OK
    Applying auth.0003_alter_user_email_max_length... OK
    Applying auth.0004_alter_user_username_opts... OK
    Applying auth.0005_alter_user_last_login_null... OK
    Applying auth.0006_require_contenttypes_0002... OK
    Applying auth.0007_alter_validators_add_error_messages... OK
    Applying auth.0008_alter_user_username_max_length... OK
    Applying sessions.0001_initial... OK


Now we're ready to generate our new migration.

.. code-block:: console

  (addresses) $ python manage.py makemigrations
  No changes detected

That's not quite what we expected: we definitely created a new model. Our Contact model isn't detected here because we haven't told the *Project* to use the *Application* yet.

The ``INSTALLED_APPS`` setting lists the applications that the project uses. These are listed as strings that map to Python packages. Django will import each and looks for a ``models`` module there. Add our Contacts app to the project's ``INSTALLED_APPS`` setting in ``settings.py``:

.. code-block:: python

  INSTALLED_APPS = [
      'django.contrib.admin',
      'django.contrib.auth',
      'django.contrib.contenttypes',
      'django.contrib.sessions',
      'django.contrib.messages',
      'django.contrib.staticfiles',
      'contacts',
  ]

Then run ``makemigrations`` again.

.. code-block:: console

  (addresses) $ python manage.py makemigrations
  Migrations for 'contacts':
    contacts\migrations\0001_initial.py
      - Create model Contact

Now run ``migrate`` again to actually create the table.

.. code-block:: console

  (addresses) $ python manage.py migrate
  Operations to perform:
    Apply all migrations: admin, auth, contacts, contenttypes, sessions
  Running migrations:
    Applying contacts.0001_initial... OK

Note that Django created a table named ``contacts_contact`` for the Contacts model: by default Django will name your tables using a combination of the application name and model name. You can override that with the `model Meta`_ options.


Interacting with the Model
==========================

Now that the model has been synced to the database we can interact
with it using the interactive shell.

.. code-block:: console

  (addresses)$ python ./manage.py shell
  Python 3.6.0 (v3.6.0:41df79263a11, Dec 23 2016, 07:18:10) [MSC v.1900 32 bit (Intel)] on win32
  Type "help", "copyright", "credits" or "license" for more information.
  (InteractiveConsole)
  >>> from contacts.models import Contact
  >>> Contact.objects.all()
  <QuerySet []>
  >>> Contact.objects.create(first_name='Nathan', last_name='Yergler')
  <Contact: Nathan Yergler>
  >>> Contact.objects.all()
  <QuerySet [<Contact: Nathan Yergler>]>
  >>> nathan = Contact.objects.get(first_name='Nathan')
  >>> nathan
  <Contact: Nathan Yergler>
  >>> print(nathan)
  Nathan Yergler
  >>> nathan.id
  1
  >>>

There are a few new things here. First, the ``manage.py shell`` command gives us a interactive shell with Python's path set up correctly for Django. If you try to run Python and just import your application, an Exception will be raised because Django doesn't know which settings  to use, and therefore can't map Model instances to the database.

Second, there's this ``objects`` property on our model class. That's the model's Manager_. If a single instance of a Model represents a row in the database, the Manager represents the table. The default model manager provides querying functionality, and can be customized. When we call ``all()`` or ``filter()`` or the Manager, a QuerySet_ is returned. A QuerySet is iterable, and loads data from the database as needed.

Finally, there's this ``id`` field that we didn't define. Django adds
an ``id`` field as the primary key for your model, unless you `specify
a primary key`_.

Writing a Test
==============

We have one method defined on our model, ``__str__``, and this is a
good time to start writing tests. The ``__str__`` method of a model
will get used in quite a few places, and it's entirely conceivable
it'd be exposed to end users. It's worth writing a test so we
understand how we expect it to operate.

Django creates a ``tests.py`` file when it creates the application, so we'll add our first test to that file in the contacts app.

.. code-block:: python

  from django.test import TestCase

  from .models import Contact

  class ContactTests(TestCase):
      """Contact model tests."""

      def test_str(self):

          contact = Contact(first_name='John', last_name='Smith')

          self.assertEquals(
              str(contact),
              'John Smith',
          )


You can run the tests for your application using ``manage.py``::

  (addresses)$ python manage.py test
  Creating test database for alias 'default'...
  System check identified no issues (0 silenced).
  .
  ----------------------------------------------------------------------
  Ran 1 test in 0.000s

  OK
  Destroying test database for alias 'default'...


One thing to note before moving on is the first and
last line of output: "Creating test database" and "Destroying test
database". Some tests need access to a database, and because we don't
want to mingle test data with "real" data (for a variety of reasons,
not the least of which is determinism), Django helpfully creates a
test database for us before running the tests. Essentially it creates
a new database, and runs ``migrate`` on it. If you subclass from
Django's ``TestCase`` (which we are), Django also resets any default
data after running each TestCase, so that changes in one test won't
break or influence another.

Review
======

* Models define the fields in a table, and can contain business logic.
* The ``makemigrations`` manage command creates migrations based on your Python models
* The ``migrate`` manage command runs any pending migrations
* The model Manager_ allows you to operate on the collection of
  instances: querying, creating, etc.
* Write unit tests for methods you add to the model
* The ``test`` manage command runs the unit tests


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
