:orphan:

===================
 Before You Arrive
===================

Thanks for signing up to attend my tutorial, *Effective Django*. To
help things get started smoothly, and avoid possible network issues,
please complete the following beforehand.

If you have questions, you can email me at nathan@yergler.net. If you
have platform specific issues, I'll try and help you figure them out,
and will update this document with any notes.

#. Install Python

   I'll be using Python 2.7; you can download it from the official
   Python website: http://python.org/download/releases/2.7.5/

   The latest release of 2.7 is 2.7.5. If you already have 2.7.x
   installed, that will work fine.

#. Install virtualenv and pip

   ``virtualenv`` is a tool for managing your Python environments. It
   includes ``pip``, a Python package installer, which we'll use to
   retrieve dependencies.

   You can download `virtualenv from PyPI`_ at
   https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.9.1.tar.gz

   After downloading, unpack the archive and run::

     $ python setup.py install

   You may need to run with sudo depending on your system::

     $ sudo python setup.py install

#. Create a working directory for the tutorial, and make it a virtualenv

   You can create this directory anywhere, but this is where we'll be
   working on code during the tutorial.  For example::

     $ cd Documents
     $ mkdir django-tutorial

   Once you've created the directory, create a virtualenv there::

     $ virtualenv ./django-tutorial

#. Active the virtualenv

   On Linux and Mac OS X you can active the virtualenv by running the
   following from the command-line::

     $ cd django-tutorial
     $ source bin/activate

   On Windows you do::

     > cd django-tutorial
     > \Scripts\activate

   The `virtualenv documentation`_ may be useful if you have trouble activating.

#. Install Django

   We'll talk about versions of Django during the tutorial, but in
   order to avoid network bottlenecks from dozens of people in one
   room downloading the source, it's helpful to install it into your
   virtualenv beforehand::

     $ pip install Django

   This will download Django and install it into the virtualenv. Once
   it's installed, you should see a ``django-admin.py`` script in the
   ``bin`` (Linux, Mac OS X) or ``Scripts`` (Windows) directory.

If you have questions, you can email me at nathan@yergler.net. If you
have platform specific issues, I'll try and help you figure them out,
and will update this document with any notes.

See you at the tutorial!

Nathan



.. _`virtualenv documentation`: http://www.virtualenv.org/en/latest/#activate-script
.. _`virtualenv from PyPI`: https://pypi.python.org/pypi/virtualenv
