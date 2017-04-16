===================
Using Static Assets
===================

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

App static files are stored in the ``static`` subdirectory within the app. Django will also look in any directories listed in the ``STATICFILES_DIRS`` setting. Let's update our project settings to specify a static files directory.

.. code-block:: python

  STATIC_URL = '/static/'
  STATICFILES_DIRS = [
      os.path.join(BASE_DIR, "static"),
  ]

Note that we use ``os.path`` to construct the absolute path. This
ensures Django can locate the files unambiguously and that we don't need to worry about where we've checked out our code.

The `STATIC_URL setting`_ tells Django what the root URL for your static files is. By default it's set to ``/static/``.

.. _`STATIC_URL setting`: https://docs.djangoproject.com/en/1.11/ref/settings/#std:setting-STATIC_URL

Let's go ahead and create the static directory in our project and
unpack Bootstrap into it.

.. code-block:: console

(addresses) $ ~/p/effdj-projects/addresses$ mkdir addressbook/static
(addresses) $ ~/p/effdj-projects/addresses$ cd addressbook/static/
(addresses) $ ~/p/effdj-projects/addresses/addressbook/static$ unzip ~/downloads/bootstrap-3.3.7-dist.zip
Archive:  ~/downloads/bootstrap-3.3.7-dist.zip
   creating: bootstrap-3.3.7-dist/css/
  inflating: bootstrap-3.3.7-dist/css/bootstrap-theme.css
  inflating: bootstrap-3.3.7-dist/css/bootstrap-theme.css.map
  inflating: bootstrap-3.3.7-dist/css/bootstrap-theme.min.css
  inflating: bootstrap-3.3.7-dist/css/bootstrap-theme.min.css.map
  inflating: bootstrap-3.3.7-dist/css/bootstrap.css
  inflating: bootstrap-3.3.7-dist/css/bootstrap.css.map
  inflating: bootstrap-3.3.7-dist/css/bootstrap.min.css
  inflating: bootstrap-3.3.7-dist/css/bootstrap.min.css.map
   creating: bootstrap-3.3.7-dist/fonts/
  inflating: bootstrap-3.3.7-dist/fonts/glyphicons-halflings-regular.eot
  inflating: bootstrap-3.3.7-dist/fonts/glyphicons-halflings-regular.svg
  inflating: bootstrap-3.3.7-dist/fonts/glyphicons-halflings-regular.ttf
  inflating: bootstrap-3.3.7-dist/fonts/glyphicons-halflings-regular.woff
  inflating: bootstrap-3.3.7-dist/fonts/glyphicons-halflings-regular.woff2
   creating: bootstrap-3.3.7-dist/js/
  inflating: bootstrap-3.3.7-dist/js/bootstrap.js
  inflating: bootstrap-3.3.7-dist/js/bootstrap.min.js
  inflating: bootstrap-3.3.7-dist/js/npm.js

Referring to Static Files in Templates
======================================

The Django staticfiles app includes a `template tag`_ that make it
easy to refer to static files within your templates. You load template
tag libraries using the ``load`` tag.

.. _`template tag`: https://docs.djangoproject.com/en/1.11/ref/templates/builtins/

::

  {% load staticfiles %}

After loading the static files library, you can refer to the file
using the ``static`` tag.

::

  <link href="{% static 'bootstrap-3.3.7-dist/css/bootstrap.min.css' %}"
        rel="stylesheet" media="screen">

Note that the path we specify is *relative* to the static files directory. Django will join this path with the ``STATIC_URL`` setting to generate the actual URL to use.


Simple Template Inclusion
=========================

We want to add the Boostrap CSS to all of our templates, but we'd like
to avoid repeating ourself: if we add it to each template
individually, when we want to make changes (for example, to add
another stylesheet) we have to make them to all the files. To solve
this, we'll create a base template that the others will inherit from.

Let's create ``base.html`` in the ``templates`` directory of our
``contacts`` app.

.. code-block:: django

  {% load staticfiles %}
  <html>
    <head>
      <link href="{% static 'bootstrap-3.3.7/css/bootstrap.min.css' %}"
            rel="stylesheet" media="screen">
    </head>

    <body>
      {% block content %}
      {% endblock %}

      <script src="{% static 'bootstrap-3.3.7/js/bootstrap.min.js' %}"></script>
    </body>
  </html>


``base.html`` defines the common structure for our pages, and includes
a ``block`` tag, which other templates can fill in.

We'll update ``contact_list.html`` to extend from ``base.html`` and
fill in the ``content`` block.

.. code-block:: django

  {% extends "base.html" %}

  {% block content %}
  <h1>Contacts</h1>

  <ul>
    {% for contact in object_list %}
      <li class="contact">{{ contact }}</li>
    {% endfor %}
  </ul>

  <a href="{% url "contacts-new" %}">add contact</a>
  {% endblock %}

Note that the ``block`` tag is used to both _define_ the block, as well as placee content into it. Django matches blocks based on their name (``content`` in this case); if a block is omitted in a template, the content from the "parent" template will be used instead.


Serving Static Files
====================

We've told Django where we store our static files, and we've told it
what URL structure to use, but we haven't actually connected the two
together. For the purposes of debugging, we actually don't have to do anything: when you run the Django server in debug mode (``DEBUG=True`` in ``settings.py``), Django will automatically add the correct URLs for serving static files.

This is not suitable for production, however, as the Django server is written with serving the application in mind, not static files. The Django documentation on `deploying static files`_ does a good job of walking through the options for getting your static files onto your CDN or static file server, and we'll cover more of that in the section on Deploying_.

Now we can run the server and see our newly Boostrapped templates in
action.

.. TODO:: Replace image here

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

.. _`deploying static files`: https://docs.djangoproject.com/en/1.11/howto/static-files/deployment/
