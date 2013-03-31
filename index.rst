.. slideconf::
   :autoslides: True
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
   nathan@yergler.net. You can find (and fork) the source on `github
   <http://github.com/nyergler/effective-django>`_.

   These documents are available in PDF_ and EPub_ format, as well.

.. _PDF: /latex/EffectiveDjango.pdf
.. _EPub: /epub/EffectiveDjango.epub

Django is a popular, powerful web framework for Python. It has lots of
"batteries" included, and makes it easy to get up and going. But all
of the power means you can write low quality code that still seems to
work. *Effective Django* development means building applications that
are testable, maintainable, and scalable -- not only in terms of
traffic or load, but in terms of being able to add developers to
projects. After reading *Effective Django* you should have an
understanding of how Django's pieces fit together, how to use them to
engineer web applications, and where to look to dig deeper.

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

Contents
========

.. toctree::
   :maxdepth: 2

   intro.rst
   tutorial/index.rst
   testing.rst
   middleware.rst
   Databases & Models <orm.rst>
   classbasedviews.rst
   Forms <forms.rst>
   conclusion.rst


Everything In Its Right Place
=============================

.. Table::
   :class: context-table

   +-------------------------+---------------------------------+
   |        **Views**        |   Convert Request to Response   |
   +-------------------------+---------------------------------+
   |        **Forms**        | Convert input to Python objects |
   +-------------------------+---------------------------------+
   |       **Models**        |     Data and business logic     |
   +-------------------------+---------------------------------+
