==================
 Effective Django
==================

This is the repository for the text `Effective Django`_, an ongoing
work in progress by Nathan Yergler. The sample code is maintained in
the `effective-django-tutorial`_ repository.

*Effective Django* is authored using `ReStructured Text`_ and Sphinx_.
If you're interested in building HTML, PDF, ePub, or other generated
formats, you can do so by:

#. If you want to build PDF or ePub output, make sure LaTeX is
   installed on your machine. If you only care about HTML output, you
   can skip this step.

   For Macs, it is recommended you use `MacTeX`_

   ::
      $ brew install Caskroom/cask/mactex

   If you're building on Ubuntu, you should install the `texlive` and
   `texlive-latex-extra` packages.

   ::
      $ sudo apt-get install texlive texlive-latex-extra

#. Check out this repository::

     $ git clone --recursive https://github.com/nyergler/effective-django.git

   Note that in order to build *Effective Django*, the sample code
   must be cloned into the ``src`` submodule. Using ``--recursive``
   will accomplish that.

#. Create a virtualenv_ and install the dependencies::

     $ virtualenv .
     $ . bin/activate
     $ pip install -r requirements.txt

#. Run ``make``::

     $ make all

   The output will be in the ``_build`` sub-directory.

   To only build HTML, specify the target explicitly::

     $ make html

Run ``make`` without any parameters for a list of possible targets.

.. _`Effective Django`: http://effectivedjango.com/
.. _`effective-django-tutorial`: https://github.com/nyergler/effective-django-tutorial
.. _`ReStructured Text`: http://docutils.sf.net/
.. _Sphinx: http://sphinx-doc.org/
.. _`MacTeX`: http://tug.org/mactex/
.. _virtualenv: http://www.virtualenv.org/
