==================
 Effective Django
==================

.. note::

   There's new content and tutorials coming!

   `Sign up <http://eepurl.com/xY1dn>`_ to be notified with *Effective
   Django* is updated.

.. note::

   `Video of any earlier version of this tutorial <https://www.youtube.com/watch?v=NfsJDPm0X54>`_
   from PyCon is available on YouTube.

Django is a popular, powerful web framework for Python. It has lots of "batteries" included and an active community that make it easy to get up and going. If you want to use Django **effectively**, you need to think about how to leverage those batteries and community resources. Using Django effectively means writing code that not only works, but is maintainable and can grow and evolve as your requirements do. It means using Django in a way that emphasizes writing code that's cohesive, testable, and scalable.

What do each of those words mean?

*Cohesive* code is code that is focused on doing one thing, and one thing alone. It means that when you write a function or a method, that it does one thing and nothing else. It also means that the function or method is self contained.

This is directly related to writing *testable* code: code that's doing too much -- that's not *cohesive* -- is usually difficult to write tests for. The thought that a piece of code is too complex to test is a signal to stop and re-think its architecture. Code that's testable isn't just easy to write tests for; it's also easier to diagnose problems with and maintain.

Finally, we want to write *scalable* code. That doesn't just mean it scales in terms of performance, but that it also scales in terms of your team and your team's understanding. Applications that are well tested are easier for others to understand and modify.

My goal is to convince you of the importance of these principles, and provide examples of how to follow them to build more robust Django applications. In this book we'll walk through building three different applications, moving from the basics of Django to building for production to advanced topics like single page applications. By building these applications you'll learn Django inside and out.

Feedback, suggestions, and questions may be sent to
nathan@yergler.net. You can find (and fork) the source on `github
<http://github.com/nyergler/effective-django>`_.

.. toctree::
   :maxdepth: 2

   environment.rst
   01_intro/index.rst
   02_production/index.rst
   03_advanced/index.rst
   Reference<reference/index.rst>
   acknowledgments.rst


These documents are available in PDF_ and EPub_ format, as well.

.. _PDF: /latex/EffectiveDjango.pdf
.. _EPub: /epub/EffectiveDjango.epub

The sample code for this tutorial is available in the
`effective-django-tutorial`_ git repository.

.. _`effective-django-tutorial`: https://github.com/nyergler/effective-django-tutorial/

"Effective Django" is licensed under the Creative Commons
`Attribution-ShareAlike 4.0 International License`_.

.. _`Attribution-ShareAlike 4.0 International License`: http://creativecommons.org/licenses/by-sa/4.0/
