.. slideconf::
   :theme: single-level

==================
 Effective Django
==================

.. notslides::

   Django is a popular, powerful web framework for Python. It has lots
   of "batteries" included, and makes it easy to get up and going. But
   all of the power means you can write low quality code that still
   seems to work. *Effective Django* development means building
   applications that are testable, maintainable, and scalable -- not
   only in terms of traffic or load, but in terms of being able to add
   developers to projects.

   Part of being able to effectively use Django is understanding
   what's available to you, and what the restrictions are. Frameworks
   are necessarily general purpose tools, which is great: the
   abstractions and tools they provide allow us to begin working
   immediately, without delving into the details. At some point,
   however, it's useful to understand what the framework is doing for
   you. Whether you're trying to stretch in a way the framework didn't
   imagine, or you're just trying to diagnose a mysterious bug, you
   have to look inside the black box and gain a deeper
   understanding. After reading *Effective Django* you should have an
   understanding of how Django's pieces fit together, and where you'd
   begin to look.

.. slides::

   Effective?
   ==========

   * Testable
   * Maintainable
   * Scalable

   .. Testable
   .. ========

   .. Fly what you test, test what you fly.

   .. Scalable
   .. ========

   .. Overhead kills performance, as well as productivity.

   .. Maintainable
   .. ============

   .. XXX

Everything In Its Right Place
-----------------------------

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
   middleware.rst
   testing.rst

   ORM <orm.rst>

   Forms <forms.rst>
   conclusion.rst
