.. tut::
   :path: /src

=========================================
 Handling Authentication & Authorization
=========================================

So far we've built a simple contact manager, and added support for a
related model (Addresses). This has shown how to use many of the
basics, but there are a few more things you'd want before exposing
this to the outside world. One of those is authentication and
authorization. Django includes support that works for many projects,
which is what we'll use.

Authentication
==============

.. checkpoint:: login-logout

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

.. checkpoint:: master
