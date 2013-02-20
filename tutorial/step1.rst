.. tut::
   :path: /src

.. slideconf::
   :autoslides: False

.. checkpoint:: contact_model

Configuring the Database
========================

Django includes support out of the box for MySQL, PostgreSQL, SQLite3,
and Oracle. We'll use SQLite_ for our project for simplicity. If you
were going to use MySQL, you'd need to add TK:mysql-python to your
``requirements.txt`` file.

To enable SQLite as the database, edit the ``DATABASES`` definition in
``contactmgr/settings.py``. The ``settings.py`` file contains the
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
it for you, and makes it available as ``django.conf.settings``. See
TK :doc:`/settings.rst` for more details.


Creating a Model
================

Django models map (roughly) to a database table, and provide a place
to encapsulate business logic. All models subclass the base TK:Model
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

  $ python ./manage.py syncdb

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

  $ python ./manage.py syncdb
  Creating tables ...
  Creating table contacts_contact
  Installing custom SQL ...
  Installing indexes ...
  Installed 0 object(s) from 0 fixture(s)

Note that Django created a table named ``contacts_contact``: by
default Django will name your tables using a combination of the
application name and model name. You can override that with the
TK:model Meta options.


Interacting with the Model
--------------------------

Now that the model has been synced to the database we can interact
with it using the interactive shell.

::

  $ python ./manage.py shell
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

There are a few interesting things to notice here.

First, the ``shell`` manage command gives us a interactive shell with
the Python path set up correctly for Django.

Second, there's this ``objects`` property on our model class. That's
the model's Manager_. The default model manager provides querying
functionality, and can be customized.

Third, there's this ``id`` field that we didn't define. Django adds
and ``id`` field as the primary key for your model, unless you
`specify a primary key`_.

Writing a Test
--------------

.. ifnotslides::

   We have one method defined on our model -- ``__str__`` -- and this
   is a good time to start writing tests. A model's ``__str__`` method
   will get used in quite a few places, and it's entirely conceivable
   it'd be exposed to end users. So it's worth writing a test so we
   understand how we expect it to operate.

.. literalinclude:: /src/contacts/tests.py
   :language: python
   :pyobject: ContactTests

.. slide:: Running the Tests

You can run the tests for your application using ``manage.py``::

  $ python manage.py test

If you run this now, you'll see that around 420 tests run. That's
surprising, since we've only written one. That's because by default
Django runs the tests for all installed applications. When we added
the ``contacts`` app to our project, there were several Django apps
there by default. The extra 419 tests come from those.

If you want to run the tests for a specific app, just specify the app
name on the command line::

  $ python manage.py test contacts
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
a new database, and runs ``syncdb`` on it. Additionally, it resets it
between each test, so that data generated or changed in one test won't
break or influence another.

TK:Review
---------
