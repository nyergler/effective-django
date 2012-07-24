.. slideconf::
   :theme: single-level

===================
 Class Based Views
===================

Class Based Views
=================

* New in Django 1.3 (generic views)
* Allow "composing" a View from pieces
* Intended to allow more flexible reuse
* Base View plus a set of "mixins" provide composable functionality
* Lots of power, lots of [potential] complexity

Using Class Based Views
=======================

* Subclass ``View``
* Define a method name that matches the HTTP method you're
  implementing

.. testcode::

  from django.views.generic import View

  class ContactList(View):

      def get(self):

          return HttpResponse("You have no contacts")

Using a Template
----------------

.. testcode::

  from django.views.generic import TemplateView

  class ContactList(View):

      template_name = 'index.html' # or define get_template_names()

      def get_context_data(self, **kwargs):

          context = super(ContactList, self).\
              get_context_data(**kwargs)
          context['first_names'] = ['Nathan', 'Richard']

          return context


Configuring URLs
----------------

* Django URLConf needs a callable, not a class
* ``View`` provides as ``as_view`` method

::

  urlpatterns = patterns('',
          (r'^index/$', ContactList.as_view()),
      )

* ``kwargs`` passed to ``as_view`` are assigned as properties
* Arguments captured in the URL pattern are available as ``.args`` and
  ``.kwargs``


Idiomatic Class Based Views
===========================

* Number of mixins can be confusing
* However there are a few common idioms
* Many times you don't wind up defining the HTTP methods directly,
  just the things you need

Template Views
--------------

TemplateView

* ``get_context_data()``
* ``template_name``, ``get_template_names()``
* ``response_class``
* ``render_to_response()``

Forms in Views
--------------

ProcessFormView

* ``form_class``
* ``get_success_url()``
* ``form_valid(form)``
* ``form_invalid(form)``

Editing Views
-------------

CreateView, UpdateView

* Includes Form processing

* ``model``
* ``get_object()``

HTTP Methods
============

* The ``http_method_names`` property defines a list of supported
  methods
* In Django 1.4 this is::

    http_method_names = ['get', 'post', 'put', 'delete', 'head',
                         'options', 'trace']

* If you want to support something like HTTP ``PATCH``, you need to
  add it to that list
* Views will look for a class method with the same name

Writing Composable Views
========================

* Think about the extension points you need
* Call ``super()`` in your methods: this allows others to mix your
  View with others

Example
-------

.. testcode::

   class EventsPageMixin(object):
       """View mixin to include the Event in template context."""

       def get_event(self):

           if not hasattr(self, 'event'):
               self.event = get_event()

           return self.event

       def get_context_data(self, **kwargs):

           context = super(EventsPageMixin, self).\
               get_context_data(**kwargs)

           context['event'] = self.get_event()

           return context

.. notslides::

   * No actual view logic
   * Subclasses ``object``, not ``View``
   * Calls ``super`` on overridden methods

Next
====

:doc:`orm`
