.. tut::
   :path: /src

.. slideconf::
   :autoslides: True
   :theme: slides

=======
 Forms
=======


Form Basics
===========

Forms in Context
----------------

.. Table::
   :class: context-table

   +-------------------------+---------------------------------+
   |        **Views**        |   Convert Request to Response   |
   +-------------------------+---------------------------------+
   |        **Forms**        | Convert input to Python objects |
   +-------------------------+---------------------------------+
   |       **Models**        |     Data and business logic     |
   +-------------------------+---------------------------------+

Defining Forms
--------------

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

Instantiating a Form
--------------------

Unbound forms don't have data associated with them, but they can
be rendered::

  form = ContactForm()

Bound forms have specific data associated, which can be
validated::

  form = ContactForm(data=request.POST, files=request.FILES)

Accessing Fields
----------------

Two ways to access fields on a Form instance

- ``form.fields['name']`` returns the ``Field`` object
- ``form['name']`` returns a ``BoundField``
- ``BoundField`` wraps a field and value for HTML output

Validation
==========

Validating the Form
-------------------

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

Field Validation
----------------

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

Field Cleaning
--------------

- ``.clean_fieldname()`` method is called after validators
- Input has already been converted to Python objects
- Methods can raise ``ValidationErrors``
- Methods *must* return the cleaned value

Rendering Forms
===============

Idiomatic Form Usage
--------------------

.. testcode::

   from django.views.generic.edit import FormMixin, ProcessFormView

   class ContactView(FormMixin, ProcessFormView):
       form_class = ContactForm
       success_url = '/contact/sent'

       def form_valid(self, form):
           # do something -- save, send, etc
           pass

       def form_invalid(self, form):
           # do something -- log the error, etc -- if needed
           pass

Form Output
-----------

Three primary "whole-form" output modes:

- ``form.as_p()``, ``form.as_ul()``, ``form.as_table()``

::

  <tr><th><label for="id_name">Name:</label></th>
    <td><input id="id_name" type="text" name="name" maxlength="255" /></td></tr>
  <tr><th><label for="id_email">Email:</label></th>
    <td><input id="id_email" type="text" name="email" maxlength="Email address" /></td></tr>
  <tr><th><label for="id_confirm_email">Confirm email:</label></th>
    <td><input id="id_confirm_email" type="text" name="confirm_email" maxlength="Confirm" /></td></tr>



Controlling Form Output
-----------------------

::

   {% for field in form %}
   {{ field.label_tag }}: {{ field }}
   {{ field.errors }}
   {% endfor %}
   {{ field.non_field_errors }}

Additional rendering properties:

- ``field.label``
- ``field.label_tag``
- ``field.html_id``
- ``field.help_text``

Customizing Rendering
---------------------

You can specify additional attributes for widgets as part of the form
definition.

.. testcode::

   class ContactForm(forms.Form):
       name = forms.CharField(
           max_length=255,
           widget=forms.Textarea(
               attrs={'class': 'custom'},
           ),
       )

You can also specify form-wide CSS classes to add for error and
required states.

.. testcode::

   class ContactForm(forms.Form):
       error_css_class = 'error'
       required_css_class = 'required'


Customizing Forms in Generic Views
==================================

Adding Fields
-------------

.. checkpoint:: confirm_contact_email

* Thus far we've been having Django create Forms for us
* These Model Forms are derived from the Model definition.
* If we want to require confirmation of email addresses, we need to
  add a field to our form
* We also need to set the initial state of that field, and confirm
  that the fields match

Defining the Form
-----------------

.. literalinclude:: /src/contacts/forms.py
   :pyobject: ContactForm
   :end-before: def clean

Overriding the Default Form
---------------------------

.. literalinclude:: /src/contacts/views.py
   :pyobject: CreateContactView
   :end-before: def get_success_url

Customizing Validation
----------------------

.. literalinclude:: /src/contacts/forms.py
   :prepend: class ContactForm(forms.ModelForm):
              ...
   :language: python
   :pyobject: ContactForm.clean
   :end-before: inlineformset
