.. slideconf::
   :autoslides: False
   :theme: single-level

============
Introduction
============

In the past decade the Python community has seen a wealth of riches
spring up in the area of web development. Frameworks and tools have
made it easier than ever to use Python for web applications, with some
focused on particular domains, others on particular footprints, and
still others on particular deployment strategies. Most of these
frameworks have built upon WSGI_, the Web Server Gateway Interface,
which became part of the Python standard library in version TK. WSGI
provides some conventions for applications and servers to communicate
with one another, much as it's spiritual predecessor, CGI_, provided
conventions for executing scripts via a web server.

With the inclusion of WSGI, it's possible to begin developing a web
application by simply picking and choosing pieces that seem best for
the task at hand. Indeed, some projects do just that. So why use a
larger framework like Django_, Pylons_, or `Blue Bream`_? Frameworks
build upon WSGI to provide a reasonable set of defaults, a set of
conventions, for getting started with development and focusing on the
specific problem at hand. It's *possible* to spend time evaluating
libraries that map a URL to a view, but a framework's developers have
already (presumably) done such an evaluation, and chosen one that they
feel will work well with the other parts of the framework. TK:Community

A framework is general purpose by definition, but that doesn't mean
your use of it must be. Put another way, most frameworks support a
variety of databases, platforms, and deployment infrastructures. But
just because you use that framework doesn't mean you need to, as well.
A good framework will help you get up to speed more quickly, and will
let you target things for your environment when needed.

Django is a popular, powerful web framework for Python. It has lots of
"batteries" included, and makes it easy to get up and going. But all
of the power means you can write low quality code that still seems to
work. *Effective Django* development means building applications that
are testable, maintainable, and scalable -- not only in terms of
traffic or load, but in terms of being able to add developers to
projects. When we're talking about Effective Django, we're really
talking about software engineering for web applications. The examples
and the details we're going to talk about are Django specific, but the
ideas and principles are not.

So what does *Effective Django* mean? It means using Django in a way
that emphasizes writing code that's cohesive, testable, and scalable.
What do each of those words mean? Well "cohesive" code is code that is
focused on doing one thing, and one thing alone. It means that when
you write a function or a method, that it does one thing and does it
well. This is directly related to writing testable code: code that's
doing too much is often difficult to write tests for. When I find
myself thinking, "Well, this piece of code is just too complex to
write a test for, it's not really worth all the effort," that's a
signal that I need to step back and focus on simplifying it. Testable
code is code that makes it straight-forward to write tests for, and
that's easy to diagnose problems with. Finally, we want to write
scalable code. That doesn't just mean it scales in terms of
performance, but that it also scales in terms of your team and your
team's understanding. Applications that are well tested are easier for
others to understand (and easier for them to modify), which means
you're more able to improve your application by adding engineers.

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
understanding of how Django's pieces fit together, how to use them to
engineer web applications, and where to look to dig deeper.

.. slide:: Format
   :level: 2

   * Talk / Demonstrate / Practice
   * Please ask questions
   * Two breaks planned
   * Notes, examples, etc available: http://effectivedjango.com

My goal is to convince you of the importance of these principles, and
provide examples of how to follow them to build more robust Django
applications. I'm going to walk through building a contact management
application iteratively, building tests as I go.

.. _WSGI: http://www.python.org/dev/peps/pep-0333/
.. _CGI: http://en.wikipedia.org/wiki/Common_Gateway_Interface
.. _Django: http://djangoproject.com/
.. _Pylons: http://www.pylonsproject.org/
.. _`Blue Bream`: http://bluebream.zope.org/
