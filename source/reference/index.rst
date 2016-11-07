=========================
Effective Django (legacy)
=========================

Django is a popular, powerful web framework for Python. It has lots of
"batteries" included, and makes it easy to get up and going. But all
of the power means you can write low quality code that still seems to
work. *Effective Django* development means building applications that
are testable, maintainable, and scalable -- not only in terms of
traffic or load, but in terms of being able to add developers to
projects. After reading *Effective Django* you should have an
understanding of how Django's pieces fit together, how to use them to
engineer web applications, and where to look to dig deeper.


Contents
========

.. toctree::
   :maxdepth: 2

   intro.rst
   testing.rst
   middleware.rst
   Databases & Models <orm.rst>
   classbasedviews.rst
   Forms <forms.rst>
   further-reading.rst

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
