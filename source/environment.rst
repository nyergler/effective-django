============================
Your Development Environment
============================


When thinking about your development environment, there are three
important things to keep in mind: isolation, determinism, and
similarity. They're each important, and they work in concert with one
another.

**Isolation** means that you're not inadvertently leveraging tools
or packages installed outside the environment. This is particularly
important when it comes to something like Python packages with C
extensions: if you're using something installed at the system level
and don't know it, you can find that when you go to deploy or share
your code that it doesn't operate the way you expect. A tool like
virtualenv_ can help create that sort of environment.

Your environment is **deterministic** if you're confident about
what versions of your dependencies you're relying on, and can
reproduce that environment reliably.

Finally, **similarity** to your production or deployment
environment means you're running on the same OS, preferably the
same release, and that you're using the same tools to configure
your development environment that you use to configure your
deployment environment. This is by no means a requirement, but as
you build bigger, more complex software, it's helpful to be
confident that any problem you see in production is reproducable in
your development environment, and limit the scope of investigation
to code you wrote.

.. _virtualenv: http://www.virtualenv.org/

Isolation
---------

* We want to avoid using unknown dependencies, or unknown versions
* virtualenv_ provides an easy way to work on a project without your
  system's ``site-packages``

Determinism
-----------

* Determinism is all about dependency management
* Choose a tool, use it in development and production

  * pip, specifically a `requirements files`_
  * buildout_
  * install_requires_ in setup.py

* Identify specific versions of dependencies

You can specify versions either by the version for a package on
PyPI, or a specific revision (SHA in git, revision number in
Subversion, etc). This ensures that you're getting the exact
version you're testing with.

.. _`requirements files`: http://www.pip-installer.org/en/latest/requirements.html
.. _buildout: http://www.buildout.org/
.. _install_requires: http://pythonhosted.org/distribute/setuptools.html#declaring-dependencies

Similarity
----------

* Working in an environment similar to where you deploy eliminates
  variables when trying to diagnose an issue
* If you're building something that requires additional services, this
  becomes even more important.
* Vagrant_ is a tool for managing virtual machines, lets you easily
  create an environment separate from your day to day work.

.. _Vagrant: http://vagrantup.com/

Review
======

* Make sure your development environment is deterministic and as
  similar to where you'll deploy as possible
