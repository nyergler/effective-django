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

.. _`effective-django-tutorial`: https://github.com/nyergler/effective-django-tutorial/

Feedback, suggestions, and questions may be sent to
nathan@yergler.net. You can find (and fork) the source on `github
<http://github.com/nyergler/effective-django>`_.

.. toctree::
   :maxdepth: 2

   getting-started.rst
   01_intro/index.rst
   02_production/index.rst
   03_advanced/index.rst
   Reference<reference/index.rst>
   acknowledgments.rst


These documents are available in PDF_ and EPub_ format, as well.

.. _PDF: /latex/EffectiveDjango.pdf
.. _EPub: /epub/EffectiveDjango.epub

"Effective Django" is licensed under the Creative Commons
`Attribution-ShareAlike 4.0 International License`_.

.. _`Attribution-ShareAlike 4.0 International License`: http://creativecommons.org/licenses/by-sa/4.0/
