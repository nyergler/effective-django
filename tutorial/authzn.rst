.. tut::
   :path: /src

=========================================
 Handling Authentication & Authorization
=========================================

.. warning::

   This page is a work in progress; errors may exist, and additional
   contect is forthcoming.

So far we've built a simple contact manager, and added support for a
related model (Addresses). This has shown how to use many of the
basics, but there are a few more things you'd want before exposing
this to the outside world. One of those is authentication and
authorization. Django includes support that works for many projects,
which is what we'll use.

Authentication
==============

.. checkpoint:: authentication

In order to use the included authentication support, the
``django.contrib.auth`` and ``django.contrib.sessions`` applications
needs to be included in your project.

Django enables thes by default when you create a project, as you can
see in ``addressbook/settings.py``.

.. literalinclude:: /src/addressbook/settings.py
   :lines: 118-130

In addition to installing the application, the middleware needs to be
installed, as well.

.. literalinclude:: /src/addressbook/settings.py
   :lines: 96-104


If you'll recall, during the first run of ``syncdb``, Django asked if
we wanted to create a superuser account. It did so because we had the
application installed already.

The stock Django auth model supports Users_, Groups_, and
Permissions_. This is usually sufficient unless you're integrating
with an existing authentication backend.

``django.contrib.auth`` provides a set of views to support the basic
authentication actions such as login, logout, password reset, etc.
Note that it includes *views*, but not *templates*. We'll need to
provide those for our project.

For this example we'll just add support for login and logout views in
our project. First, add the views to ``addressbook/urls.py``.

.. literalinclude:: /src/addressbook/urls.py
   :lines: 7-9

Both the login_ and logout_ view have default template names
(``registration/login.html`` and ``registration/logged_out.html``,
respectively). Because these views are specific to our project and not
our re-usable Contacts application, we'll create a new
``templates/registration`` directory inside of ``addressbook``::

  $ mkdir -p addressbook/templates/registration

And tell Django to look in that directory for templates by setting
``TEMPLATE_DIRS`` in ``addressbook/settings.py``.

.. literalinclude:: /src/addressbook/settings.py
   :lines: 111-116

Within that directory, first create ``login.html``.

.. literalinclude:: /src/addressbook/templates/registration/login.html
   :language: html

The login template inherits from our ``base.html`` template, and shows
the login form provided by the view. The hidden ``next`` field allows
the view to redirect the user to the page requested, if the login
request was triggered by a permission failure.

.. sidebar:: Why no name for the URL patterns?

   XXX

The logout template, ``logged_out.html``, is simpler.

.. literalinclude:: /src/addressbook/templates/registration/logged_out.html
   :language: html

All it needs to do is provide a message to let the user know the
logout was successful.

.. sidebar:: Creating an Admin User

   XXX

If you run your development server now using ``runserver`` and visit
``http://localhost:8000/login``, you'll see the login page. If you
login with bogus credentials, you should see an error message. So
let's try logging in with the super user credential you created earlier.

.. image::
   /_static/tutorial/authz-login-pagenotfound.png

Wait, what? Why is it visiitng ``/accounts/profile``? We never typed
that. The login view wants to redirect the user to a fixed URL after a
successful login, and the default is ``/accounts/profile``. To
override that, we'll set the ``LOGIN_REDIRECT_URL`` value in
``addressbook/settings.py`` so that once a user logs in they'll be
redirected to the list of contacts.

.. literalinclude:: /src/addressbook/settings.py
   :lines: 161

Now that we can log in and log out, it'd be nice to show the logged in
user in the header and links to login/logout in the header. We'll add
that to our ``base.html`` template, since we want that to show up
everywhere.

.. literalinclude:: /src/contacts/templates/base.html
   :language: html
   :lines: 8-17


Authorization
=============

.. checkpoint:: authorization

Having support for login and logout is nice, but we're not actually
using it right now. So we want to first make our Contact views only
available to authenticated users, and then we'll go on to associated
contacts with specific Users, so the application could be used for
multiple users.

Django includes a suite a functions and decorators that help you guard
a view based on authentication/authorization. One of the most commonly
used is `login_required`_. Unfortunately, applying view decorators to
class based views remains `a little cumbersome`_. There are
essentially two methods: decorating the URL configuration, and
decorating the class. I'll show how to decorate the class.

Class based views have a ``dispatch()`` method that's called when an
URL pattern matches. The ``dispatch()`` method looks up the
appropriate method on the class based on the HTTP method and then
calls it. Because we want to protect the views for all HTTP methods,
we'll override and decorate that.

In ``contacts/views.py`` we'll create a class mixin that ensures the
user is logged in.

.. literalinclude:: /src/contacts/views.py
   :lines: 1-2, 16-21

This is a *mixin* because it doesn't provide a full implementation of
a view on its own; it needs to be *mixed* with another view to have an
effect.

Once we have it, we can add it to the class declarations in
``contacts/views.py``. Each view will have our new ``LoggedInMixin``
added as the first superclass. For example, ``ListContactView`` will
look as follows.

.. literalinclude:: /src/contacts/views.py
   :pyobject: ListContactView

Just as ``LOGIN_REDIRECT_URL`` tells Django where to send people
*after* they log in, there's a setting to control where to send them
when they *need* to login. However, this can also be a view name, so
we don't have to bake an explicit URL into the settings.

.. literalinclude:: /src/addressbook/settings.py
   :lines: 162

Checking Ownership
------------------

Checking that you're logged in is well and good, but to make this
suitable for multiple users we need to add the concept of ownership.
There are three steps for

#. Record the Owner of each Contact
#. Only show Contacts the logged in user owns in the list
#. Set the Owner when creating a new one

First, we'll go ahead and add the concept of an Owner to the Contact
model.

In ``contacts/models.py``, we add an import and another field to our
model.

.. literalinclude:: /src/contacts/models.py
   :prepend: from django.contrib.auth.models import User
     ...
   :pyobject: Contact

Because Django doesn't support migrations out of the box, we'll need
to blow away the database and re-run syncdb.

XXX Perfect segue for talking about South

Now we need to limit the contact list to only the contacts the logged
in User owns. This gets us into overriding methods that the base view
classes have been handling for us.

.. literalinclude:: /src/contacts/views.py
   :pyobject: ListContactView


.. _`login_required`: https://docs.djangoproject.com/en/1.5/topics/auth/default/#django.contrib.auth.decorators.login_required
.. _`a little cumbersome`: https://docs.djangoproject.com/en/1.5/topics/class-based-views/intro/#decorating-class-based-views
