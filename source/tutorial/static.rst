.. tut::
   :path: /projects/addressbook

===================
Using Static Assets
===================

.. checkpoint:: static_files

Now that we have a basic application where we can add contacts and
list them, it's reasonable to think about how we'd make this look more
appealing. Most modern web applications are a combination of server
side code/views, and client side, static assets, such as JavaScript
and CSS. Regardless of whether you choose JavaScript or CoffeeScript,
CSS or SASS, Django provides support for integrating static assets
into your project.


Adding Static Files
===================

Django distinguishes between "static" and "media" files. The former
are static assets included with your app or project. The latter are
files uploaded by users using one of the file storage backends. Django
includes a contrib app, ``django.contrib.staticfiles`` for managing
static files and, importantly, generating the URLs to them. You could,
of course, simply hard code the URLs to your static assets, and that'd
probably work for a while. But if you want to move your static assets
to their own server, or to a CDN, using generated URLs let's you make
that change without needing to update your templates.
``django.contrib.staticfiles`` is enabled by default when you create a
new project, so you can just start using it.

We're going to add Bootstrap_ to our project for some basic styling.
You can download the Bootstrap files from its website,
http://getbootstrap.com.

.. _Bootstrap: http://getbootstrap.com

Django supports adding static files at both the application and
project level. Where you add them sort of depends on how tied to your
specific assembly of apps they are. That is, are they reusable for
anyone using your app, or are they specific to your particular
deployment?

App specific static files are stored in the ``static`` subdirectory
within the app. Django will also look in any directories listed in the
``STATICFILES_DIRS`` setting. Let's update our project settings to
specify a static files directory.

.. literalinclude:: /src/addressbook/settings.py
   :language: python
   :prepend: import os.path
             ...
   :lines: 67-77

Note that we use ``os.path`` to construct the absolute path. This
ensures Django can locate the files unambiguously.

Let's go ahead and create the static directory in our project and
unpack Bootstrap into it.

::

   (tutorial)$ mkdir addressbook/static
   (tutorial)$ cd addressbook/static
   (tutorial)$ unzip ~/Downloads/bootstrap.zip
   Archive:  /Users/nathan/Downloads/bootstrap.zip
     creating: bootstrap/
     creating: bootstrap/css/
    inflating: bootstrap/css/bootstrap-responsive.css
    inflating: bootstrap/css/bootstrap-responsive.min.css
    inflating: bootstrap/css/bootstrap.css
    inflating: bootstrap/css/bootstrap.min.css
     creating: bootstrap/img/
    inflating: bootstrap/img/glyphicons-halflings-white.png
    inflating: bootstrap/img/glyphicons-halflings.png
     creating: bootstrap/js/
    inflating: bootstrap/js/bootstrap.js
    inflating: bootstrap/js/bootstrap.min.js


Referring to Static Files in Templates
======================================

The Django staticfiles app includes a `template tag`_ that make it
easy to refer to static files within your templates. You load template
tag libraries using the ``load`` tag.

.. _`template tag`: https://docs.djangoproject.com/en/1.5/ref/templates/builtins/

::

  {% load staticfiles %}

After loading the static files library, you can refer to the file
using the ``static`` tag.

::

  <link href="{% static 'bootstrap/css/bootstrap.min.css' %}"
        rel="stylesheet" media="screen">

Note that the path we specify is *relative* to the static files
directory. Django is going to join this path with the ``STATIC_URL``
setting to generate the actual URL to use.

The `STATIC_URL setting`_ tells Django what the root URL for your
static files is. By default it's set to ``/static/``.

.. _`STATIC_URL setting`: https://docs.djangoproject.com/en/1.5/ref/settings/#std:setting-STATIC_URL

Simple Template Inclusion
=========================

We want to add the Boostrap CSS to all of our templates, but we'd like
to avoid repeating ourself: if we add it to each template
individually, when we want to make changes (for example, to add
another stylesheet) we have to make them to all the files. To solve
this, we'll create a base template that the others will inherit from.

Let's create ``base.html`` in the ``templates`` directory of our
``contacts`` app.

.. literalinclude:: /src/contacts/templates/base.html

``base.html`` defines the common structure for our pages, and includes
a ``block`` tag, which other templates can fill in.

We'll update ``contact_list.html`` to extend from ``base.html`` and
fill in the ``content`` block.

.. literalinclude:: /src/contacts/templates/contact_list.html

Serving Static Files
====================

We've told Django where we store our static files, and we've told it
what URL structure to use, but we haven't actually connected the two
together. Django doesn't serve static files by default, and for good
reason: using an application server to serve static resources is going
to be ineffecient, at best. The Django documentation on `deploying
static files`_ does a good job of walking through the options for
getting your static files onto your CDN or static file server.

For development, however, it's convenient to do it all with one
process, so there's a helper. We'll update our ``addressbook/urls.py``
file to include the ``staticfiles_urlpatterns`` helper.

.. literalinclude:: /src/addressbook/urls.py

Now we can run the server and see our newly Boostrapped templates in
action.

.. image::
   /_static/tutorial/boostrapped.png

Review
======

* Django distinguishes between static site files, and user uploaded
  media
* The ``staticfiles`` app is included to help manage static files and
  serve them during development
* Static files can be included with apps, or with the project. Choose
  where you put them based on whether you expect all users of your app
  to need them.
* Templates can extend one another, using ``block`` tags.

.. _`deploying static files`: https://docs.djangoproject.com/en/1.5/howto/static-files/deployment/
