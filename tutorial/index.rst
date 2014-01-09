.. tut::
   :path: ./src

.. slideconf::
   :autoslides: False
   :theme: single-level

===========================
 Effective Django Tutorial
===========================

.. note::

   `Video of this tutorial`_ from PyCon is available on YouTube.

.. _`Video of this tutorial`: https://www.youtube.com/watch?v=NfsJDPm0X54

Django is a popular, powerful web framework for Python. It has lots of
"batteries" included, and makes it easy to get up and going. But all
of the power means you can write low quality code that still seems to
work. So what does *Effective Django* mean? It means using Django in a
way that emphasizes writing code that's cohesive, testable, and
scalable. What do each of those words mean?

Well, "cohesive" code is code that is focused on doing one thing, and
one thing alone. It means that when you write a function or a method,
that it does one thing and does it well.

This is directly related to writing testable code: code that's doing
too much is often difficult to write tests for. When I find myself
thinking, "Well, this piece of code is just too complex to write a
test for, it's not really worth all the effort," that's a signal that
I need to step back and focus on simplifying it. Testable code is code
that makes it straight-forward to write tests for, and that's easy to
diagnose problems with.

Finally, we want to write scalable code. That doesn't just mean it
scales in terms of performance, but that it also scales in terms of
your team and your team's understanding. Applications that are well
tested are easier for others to understand (and easier for them to
modify), which means you're more able to improve your application by
adding engineers.

My goal is to convince you of the importance of these principles, and
provide examples of how to follow them to build more robust Django
applications. I'm going to walk through building a contact management
application iteratively, talking about the choices and testing
strategy as I go.

The sample code for this tutorial is available in the
`effective-django-tutorial`_ git repository.

Slides for the tutorial are available at http://effectivedjango.com/slides/tutorial

.. _`effective-django-tutorial`: https://github.com/nyergler/effective-django-tutorial/

.. slide:: Effective Django
   :level: 1

   .. figure:: /_static/building.jpg
      :class: fill

      CC BY-NC-SA http://www.flickr.com/photos/t_lawrie/278932896/

   http://effectivedjango.com

   Nathan Yergler // nathan@yergler.net // @nyergler

.. slide:: Goals
   :level: 2

   * Build a small Django application
   * Build it effectively
   * Explore some of the new features in Django

.. slide:: Effective?
   :level: 2

   * Cohesive
   * Tested
   * Scalable



.. slide:: Agenda
   :level: 2

   .. toctree::
      :maxdepth: 1

      getting-started.rst
      models.rst
      views.rst
      static.rst
      additional-views.rst
      forms.rst
      related.rst
      authzn.rst

.. ifnotslides::

   .. toctree::
      :maxdepth: 1

      getting-started.rst
      models.rst
      views.rst
      static.rst
      additional-views.rst
      forms.rst
      related.rst
      authzn.rst

"Effective Django" is licensed under the Creative Commons
`Attribution-ShareAlike 4.0 International License`_.

.. _`Attribution-ShareAlike 4.0 International License`: http://creativecommons.org/licenses/by-sa/4.0/
