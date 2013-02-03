.. slideconf::
   :theme: single-level

==================
 Effective Django
==================

.. note::

   These documents are a combination of the notes and examples
   developed for talks prepared for PyCon 2012, PyOhio 2012, and PyCon
   2013, and for Eventbrite web engineering. I'm still working on
   fleshing them out into a single document, but I hope you find them
   useful.

   Feedback, suggestions, and questions may be sent to
   nathan+ed@yergler.net. You can find (and fork) the source on
   `github <http://github.com/nyergler/effective-django>`_.

.. notslides::

   Django is a popular, powerful web framework for Python. It has lots
   of "batteries" included, and makes it easy to get up and going. But
   all of the power means you can write low quality code that still
   seems to work. *Effective Django* development means building
   applications that are testable, maintainable, and scalable.

   Testable, Maintainable, and Scalable all build upon one another. An
   application that is testable (and has tests) will be more
   maintainable. Developers will be able to make changes with
   confidence, without worrying that they don't understand the
   behavior of the code. And an application which is maintainable will
   be scalable, not only in terms of traffic or load, but in terms of
   being able to add developers to projects.

   Part of being able to effectively use Django is understanding
   what's available to you, and what the restrictions are. Frameworks
   are necessarily general purpose tools, which is great: the
   abstractions and tools they provide allow us to begin working
   immediately, without delving into the details. At some point,
   however, it's useful to understand what the framework is doing for
   you. Whether you're trying to stretch in a way the framework didn't
   imagine, or you're just trying to diagnose a mysterious bug, you
   have to look inside the black box and gain a deeper
   understanding.

   After reading *Effective Django* you should have an understanding
   of how Django's pieces fit together, how to use them to build
   maintainable and scalable applications, and where you'd begin to
   look when you need to stretch beyond the standard confines of Django.

.. slides::

   .. figure:: /_static/building.jpg
      :class: fill

      CC BY-NC-SA http://www.flickr.com/photos/t_lawrie/278932896/

   http://effectivedjango.com

   Nathan Yergler // nathan@yergler.net // @nyergler


   What do you mean, "Effective"?
   ==============================

   * Testable
   * Maintainable
   * Scalable

A Mental Model
==============

.. Table::
   :class: context-table

   +-------------------------+---------------------------------+
   |        **Views**        |   Convert Request to Response   |
   +-------------------------+---------------------------------+
   |        **Forms**        | Convert input to Python objects |
   +-------------------------+---------------------------------+
   |       **Models**        |     Data and business logic     |
   +-------------------------+---------------------------------+

Contents
========

.. toctree::
   :maxdepth: 1

   gettingstarted.rst
   views.rst
   testing.rst
   middleware.rst
   Databases & Models <orm.rst>
   classbasedviews.rst
   Forms <forms.rst>
   conclusion.rst


You can find the source to these documents on `github`_.

.. _`github`: http://github.com/nyergler/effective-django
