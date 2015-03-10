.. tut::
   :path: /src

.. slideconf::
   :autoslides: False
   :theme: single-level

=============
 Form Basics
=============

.. slide:: Django Forms
   :level: 1

   Validate user input and return Python objects

.. slide:: Defining Forms
   :level: 2

   Forms are composed of fields, which have a widget.

   .. testcode::

     from django.utils.translation import gettext_lazy as _
     from django import forms

     class ContactForm(forms.Form):

         name = forms.CharField(label=_("Your Name"),
             max_length=255,
             widget=forms.TextInput,
         )

         email = forms.EmailField(label=_("Email address"))

.. slide:: Instantiating a Form
   :level: 2

   Unbound forms don't have data associated with them, but they can
   be rendered::

     form = ContactForm()

   Bound forms have specific data associated, which can be
   validated::

     form = ContactForm(data=request.POST, files=request.FILES)

.. slide:: Accessing Fields
   :level: 2

   Two ways to access fields on a Form instance

   - ``form.fields['name']`` returns the ``Field`` object
   - ``form['name']`` returns a ``BoundField``
   - ``BoundField`` wraps a field and value for HTML output

.. slide:: Validating the Form
   :level: 2

   .. blockdiag::

      blockdiag {
         // Set labels to nodes.
         A [label = "Field Validation"];
         C [label = "Form Validation"];

         A -> C;
      }

   - Only bound forms can be validated
   - Calling ``form.is_valid()`` triggers validation if needed
   - Validated, cleaned data is stored in ``form.cleaned_data``
   - Calling ``form.full_clean()`` performs the full cycle

.. slide:: Field Validation
   :level: 2

   .. blockdiag::

      blockdiag {
         // Set labels to nodes.
         A [label = "for each Field"];

         B [label = "Field.clean"];
         C [label = "Field.to_python"];
         D [label = "Field validators"];

         F [label = ".clean_fieldname()"];

         A -> B;
         B -> C;
         C -> D;

         A -> F;
      }

   - Three phases for Fields: To Python, Validation, and Cleaning
   - If validation raises an Error, cleaning is skipped
   - Validators are callables that can raise a ``ValidationError``
   - Django includes generic ones for some common tasks
   - Examples: URL, Min/Max Value, Min/Max Length, URL, Regex, email

.. slide:: Field Cleaning
   :level: 2

   - ``.clean_fieldname()`` method is called after validators
   - Input has already been converted to Python objects
   - Methods can raise ``ValidationErrors``
   - Methods *must* return the cleaned value

Up until this point we've been using forms without really needing to
be aware of it. A `Django Form`_ is responsible for taking some user
input, validating it, and turning it into Python objects. They also
have some handy rendering methods, but I consider those sugar: the
real power is in making sure that input from your users is what it
says it is.

The `Generic Views`_, specifically the ones we've been using, all
operate on a particular model. Django is able to take the model
definition that we've created and extrapolate a Form from it. Django
can do this because both Models and Forms are constructed of fields
that have a particular type and particular validation rules. Models
use those fields to map data to types that your database understands;
Forms use them to map input to Python types [1]_. Forms that map to a
particular Model are called ModelForms_; you can think of them as
taking user input and transforming it into an instance of a Model.

.. [1] While I'm referring to them both as fields, they're really
   completely different implementations. But the analogy holds.

Adding Fields to the Form
-------------------------

.. checkpoint:: confirm_contact_email

So what if we want to add a field to our form? Say, we want to require
confirmation of the email address. In that case we can create a new
form, and override the default used by our views.

First, in the ``contacts`` app directory, we'll create a new file,
``forms.py``.

.. literalinclude:: /src/contacts/forms.py
   :end-before: def clean

Here we're creating a new ``ModelForm``; we associate the form with
our model in the ``Meta`` inner class.

We're also adding an additional field, ``confirm_email``. This is an
example of a field declaration in a model. The first argument is the
label, and then there are additional keyword arguments; in this case,
we simply mark it required.

Finally, in the constructor we mutate the ``initial`` kwarg.
``initial`` is a dictionary of values that will be used as the default
values for an `unbound form`_. Model Forms have another kwarg,
``instance``, that holds the instance we're editing.

Overriding the Default Form
---------------------------

We've defined a form with the extra field, but we still need to tell
our view to use it. You can do this in a couple of ways, but the
simplest is to set the ``form_class`` property on the View class.
We'll add that property to our ``CreateContactView`` and
``UpdateContactView`` in ``views.py``.

.. literalinclude:: /src/contacts/views.py
   :prepend: import forms
             ...
   :pyobject: CreateContactView
   :end-before: def get_success_url

.. literalinclude:: /src/contacts/views.py
   :pyobject: UpdateContactView
   :end-before: def get_success_url

If we fire up the server and visit the edit or create pages, we'll see
the additional field. We can see that it's required, but there's no
validation that the two fields match. To support that we'll need to
add some custom validation to the Form.

Customizing Validation
----------------------

Forms have two different phases of validation: field and form. All the
fields are validated and converted to Python objects (if possible)
before form validation begins.

Field validation takes place for an individual field: things like
minimum and maximum length, making sure it looks like a URL, and date
range validation are all examples of field validation. Django doesn't
guarantee that field validation happens in any order, so you can't
count on other fields being available for comparison during this
phase.

Form validation, on the other hand, happens after all fields have been
validated and converted to Python objects, and gives you the
opportunity to do things like make sure passwords match, or in this
case, email addresses.

Form validation takes place in a form's ``clean()`` method.

.. literalinclude:: /src/contacts/forms.py
   :prepend: class ContactForm(forms.ModelForm):
              ...
   :language: python
   :pyobject: ContactForm.clean
   :end-before: inlineformset

When you enter the ``clean`` method, all of the fields that validated
are available in the ``cleaned_data`` dictionary. The ``clean`` method
may add, remove, or modify values, but **must** return the dictionary
of cleaned data. ``clean`` may also raise a ``ValidationError`` if it
encounters an error. This will be available as part of the forms'
``errors`` property, and is shown by default when you render the form.

Note that I said ``cleaned_data`` contains all the fields *that
validated*. That's because form-level validation **always** happens,
even if no fields were successfully validated. That's why in the clean
method we use ``cleaned_data.get('email')`` instead of
``cleaned_data['email']``.

If you visit the create or update views now, we'll see an extra field
there. Try to make a change, or create a contact, without entering the
email address twice.

Controlling Form Rendering
--------------------------

.. checkpoint:: custom_form_rendering

.. slide:: Rendering Forms
   :level: 2

   Three primary "whole-form" output modes:

   - ``form.as_p()``, ``form.as_ul()``, ``form.as_table()``

   ::

     <tr><th><label for="id_name">Name:</label></th>
       <td><input id="id_name" type="text" name="name" maxlength="255" /></td></tr>
     <tr><th><label for="id_email">Email:</label></th>
       <td><input id="id_email" type="text" name="email" maxlength="Email address" /></td></tr>
     <tr><th><label for="id_confirm_email">Confirm email:</label></th>
       <td><input id="id_confirm_email" type="text" name="confirm_email" maxlength="Confirm" /></td></tr>

Our templates until now look pretty magical when it comes to forms:
the extent of our HTML tags has been something like::

  <form action="{{ action }}" method="POST">
    {% csrf_token %}
    <ul>
      {{ form.as_ul }}
    </ul>
    <input type="submit" value="Save" />
  </form>

We're living at the whim of ``form.as_ul``, and it's likely we want
something different.

Forms have three pre-baked output formats: ``as_ul``, ``as_p``, and
``as_table``. If ``as_ul`` outputs the form elements as the items in
an unordered list, it's not too mysterious what ``as_p`` and
``as_table`` do.

.. slide:: Controlling Form Output
   :level: 2

   ::

      {% for field in form %}
      {{ field.label_tag }}: {{ field }}
      {{ field.errors }}
      {% endfor %}
      {{ field.non_field_errors }}

   Additional rendering properties:

   - ``field.label``
   - ``field.label_tag``
   - ``field.auto_id``
   - ``field.help_text``

Often, though, you need more control. For those cases, you can take
full control. First, a form is iterable; try replacing your call to
``{{form.as_ul}}`` with this::

      {% for field in form %}
      {{ field }}
      {% endfor %}

As you can see, ``field`` renders as the input for each field in the
form. When you iterate over a Form, you're iterating over a sequence
of `BoundField`_ objects. A ``BoundField`` wraps the field definition
from your Form (or derived from the ModelForm) along with any data and
error state it may be bound to. This means it has some properties that
are handy for customizing rendering.

In addition to supporting iteration, you can access an individual
BoundField directly, treating the Form like a dictionary::

  {{ form.email }}

.. sidebar:: Dictionary!?!

   That may not look like a dictionary access, but remember that Django
   templates are quite restrictive in their syntax. Writing ``foo.bar``
   will look for a property ``bar`` on ``foo``, and if it's callable,
   call it. If it doesn't find a property, it'll map that to something
   like ``foo['bar']``. So when it comes to writing Django templates,
   dictionary elements act just like properties.

Consider the following alternative to ``edit_contact.html``.

.. literalinclude:: /src/contacts/templates/edit_contact_custom.html
   :language: html

In this example we see a few different things at work:

* ``field.auto_id`` to get the automatically generated field ID
* Combining that ID with ``_container`` and ``_errors`` to give our
  related elements names that consistently match
* Using ``field.label_tag`` to generate the label. ``label_tag`` adds
  the appropriate ``for`` property to the tag, too. For the
  ``last_name`` field, this looks like::

    <label for="id_last_name">Last name</label>

* Using ``field.errors`` to show the errors in a specific place. The
  Django Form documentation has details on further customizing `how
  errors are displayed`_.
* Finally, ``field.help_text``. You can specify a ``help_text``
  keyword argument to each field when creating your form, which is
  accessible here. Defining that text in the Form definition is
  desirable because you can easily mark it up for translation.

Testing Forms
-------------

.. checkpoint:: contact_form_test

It's easy to imagine how you'd use the ``LiveServerTestCase`` to write
an integration test for a Form. But that wouldn't just be testing the
Form, that'd be testing the View, the URL configuration, and probably
the Model (in this case, at least). We've built some custom logic into
our form's validator, and it's important to test that and that alone.
Integration tests are invaluable, but when they fail there's more than
one suspect. I like tests that fail with a single suspect.

Writing unit tests for a Form usually means crafting some dictionary
of form data that meets the starting condition for your test. Some
Forms can be complex or long, so we can use a helper to generate the
starting point from the Form's initial data.

**Rebar** is a collection of utilities for working with Forms. We'll
install Rebar so we can use the testing utilities.

::

  (tutorial)$ pip install rebar

Then we can write a unit test that tests two cases: success (email
addresses match) and failure (they do not).

.. literalinclude:: /src/contacts/tests.py
   :prepend: from rebar.testing import flatten_to_dict
             from contacts import forms
             ...
   :pyobject: EditContactFormTests

An interesting thing to note here is the use of the ``is_valid()``
method. We could just as easily introspect the ``errors`` property
that we used in our template above, but in this case we just need a
Boolean answer: is the form valid, or not? Note that we do need to
provide a first and last name, as well, since those are required
fields.

Review
------

* Forms take user input, validate it, and convert it to Python objects
* Forms are composed of Fields, just like Models
* Fields have validation built in
* You can customize per-field validation, as well as form validation
* If you need to compare fields to one another, you need to implement
  the ``clean`` method
* Forms are iterable over, and support dictionary-like access to, the
  bound fields
* A Bound Field has properties and methods for performing fine-grained
  customization of rendering.
* Forms are unit testable; Rebar has some utilities to help with
  testing large forms.

.. _`Django Form`: https://docs.djangoproject.com/en/1.5/topics/forms/
.. _`Generic Views`: https://docs.djangoproject.com/en/1.5/topics/class-based-views/
.. _ModelForms: https://docs.djangoproject.com/en/1.5/topics/forms/modelforms
.. _`unbound form`: https://docs.djangoproject.com/en/1.5/ref/forms/api/#ref-forms-api-bound-unbound
.. _`BoundField`: https://docs.djangoproject.com/en/1.5/ref/forms/api/#django.forms.BoundField
.. _`how errors are displayed`: https://docs.djangoproject.com/en/1.5/ref/forms/api/#how-errors-are-displayed
