======================
Effective Django Forms
======================

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

.. Why use Forms?
.. --------------

.. - Data type coercion
.. - Validation
.. - Consistent HTML output

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

Initial Data
------------

.. testcode::

   form = ContactForm(
       initial={
           'name': 'First and Last Name',
       },
   )

.. doctest::

   >>> form['name'].value()
   'First and Last Name'


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

``.clean_email()``
------------------

.. testcode::

  class ContactForm(forms.Form):
      name = forms.CharField(
          label=_("Name"),
          max_length=255,
      )

      email = forms.EmailField(
          label=_("Email address"),
      )

      def clean_email(self):

          if (self.cleaned_data.get('email', '')
              .endswith('hotmail.com')):

              raise ValidationError("Invalid email address.")

          return self.cleaned_data.get('email', '')

Form Validation
---------------

- ``.clean()`` performs cross-field validation
- Called even if errors were raised by Fields
- *Must* return the cleaned data dictionary
- ``ValidationErrors`` raised by ``.clean()`` will be grouped in
  ``form.non_field_errors()`` by default.

``.clean()`` example
--------------------

.. testcode::

  class ContactForm(forms.Form):
      name = forms.CharField(
          label=_("Name"),
          max_length=255,
      )

      email = forms.EmailField(label=_("Email address"))
      confirm_email = forms.EmailField(label=_("Confirm"))

      def clean(self):
          if (self.cleaned_data.get('email') !=
              self.cleaned_data.get('confirm_email')):

              raise ValidationError("Email addresses do not match.")

          return self.cleaned_data

Initial != Default Data
-----------------------

- Initial data is used as a starting point
- It does not automatically propagate to ``cleaned_data``
- Defaults for non-required fields should be specified when
  accessing the dict::

    self.cleaned_data.get('name', 'default')

Passing Extra Information
-------------------------

- Sometimes you need extra information in a form
- Pass as a keyword argument, and pop in __init__

.. testcode::

   class MyForm(forms.Form):
       def __init__(self, *args, **kwargs):
           self._user = kwargs.pop('user')
           super(MyForm, self).__init__(*args, **kwargs)

Tracking Changes
----------------

- Forms use initial data to track changed fields
- ``form.has_changed()``
- ``form.changed_data``
- Fields can render a hidden input with the initial value, as well::

    >>> changed_date = forms.DateField(show_hidden_initial=True)
    >>> print form['changed_date']
    '<input type="text" name="changed_date" id="id_changed_date" /><input type="hidden" name="initial-changed_date" id="initial-id_changed_date" />'


Testing
=======

Testing Forms
-------------

- Remember what Forms are for
- Testing strategies

 * Initial states
 * Field Validation
 * Final state of ``cleaned_data``

Unit Tests
----------

.. testcode::

   import unittest

   class FormTests(unittest.TestCase):
       def test_validation(self):
           form_data = {
               'name': 'X' * 300,
           }

           form = ContactForm(data=form_data)
           self.assertFalse(form.is_valid())

Test Data
---------

.. testcode::

   from rebar.testing import flatten_to_dict

   form_data = flatten_to_dict(ContactForm())
   form_data.update({
           'name': 'X' * 300,
       })
   form = ContactForm(data=form_data)
   assert(not form.is_valid())


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
- ``field.html_name``
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


Customizing Error Messages
--------------------------

Built in validators have default error messages

.. doctest::

   >>> generic = forms.CharField()
   >>> generic.clean('')
   Traceback (most recent call last):
     ...
   ValidationError: [u'This field is required.']

``error_messages`` lets you customize those messages

.. doctest::

   >>> name = forms.CharField(
   ...   error_messages={'required': 'Please enter your name'})
   >>> name.clean('')
   Traceback (most recent call last):
     ...
   ValidationError: [u'Please enter your name']

Error Class
-----------

- ``ValidationErrors`` raised are wrapped in a class
- This class controls HTML formatting
- By default, ``ErrorList`` is used: outputs as ``<ul>``
- Specify the ``error_class`` kwarg when constructing the form to
  override

Error Class
-----------

.. testcode::

   from django.forms.util import ErrorList

   class ParagraphErrorList(ErrorList):
       def __unicode__(self):
           return self.as_paragraphs()

       def as_paragraphs(self):
           return "<p>%s</p>" % (
               ",".join(e for e in self.errors)
           )

   form = ContactForm(data=form_data, error_class=ParagraphErrorList)

Multiple Forms
--------------

Avoid potential name collisions with ``prefix``:

.. testcode::

   contact_form = ContactForm(prefix='contact')

Adds the prefix to HTML name and ID::

   <tr><th><label for="id_contact-name">Name:</label></th>
     <td><input id="id_contact-name" type="text" name="contact-name"
          maxlength="255" /></td></tr>
   <tr><th><label for="id_contact-email">Email:</label></th>
     <td><input id="id_contact-email" type="text" name="contact-email"
          maxlength="Email address" /></td></tr>
   <tr><th><label for="id_contact-confirm_email">Confirm
        email:</label></th>
     <td><input id="id_contact-confirm_email" type="text"
          name="contact-confirm_email" maxlength="Confirm" /></td></tr>

Forms for Models
================

Model Forms
-----------

- ModelForms map a Model to a Form
- Validation includes Model validators by default
- Supports creating and editing instances
- Key differences from Forms:

  - A field for the Primary Key (usually ``id``)
  - ``.save()`` method
  - ``.instance`` property

Model Forms
-----------

::

   from django.db import models
   from django import forms

   class Contact(models.Model):
       name = models.CharField(max_length=100)
       email = models.EmailField()
       notes = models.TextField()

   class ContactForm(forms.ModelForm):
       class Meta:
           model = Contact

Limiting Fields
---------------

- You don't need to expose all the fields in your form
- You can either specify fields to expose, or fields to exclude

::

      class ContactForm(forms.ModelForm):

          class Meta:
              model = Contact
              fields = ('name', 'email',)



      class ContactForm(forms.ModelForm):

          class Meta:
              model = Contact
              exclude = ('notes',)

Overriding Fields
-----------------

- Django will generate fields and widgets based on the model
- These can be overridden, as well

::

      class ContactForm(forms.ModelForm):

          name = forms.CharField(widget=forms.TextInput)

          class Meta:
              model = Contact


Instantiating Model Forms
-------------------------

::

   model_form = ContactForm()

   model_form = ContactForm(
       instance=Contact.objects.get(id=2)
       )

ModelForm.is_valid()
--------------------

.. blockdiag::

   blockdiag {
      // Set labels to nodes.
      A [label = "Field Validation"];
      C [label = "Form Validation"];
      D [label = "_post_clean()"];

      A -> C -> D;
   }

- Model Forms have an additional method, ``_post_clean()``
- Sets cleaned fields on the Model instance
- Called *regardless* of whether the form is valid

Testing
-------

::

   class ModelFormTests(unittest.TestCase):
       def test_validation(self):
           form_data = {
               'name': 'Test Name',
           }

           form = ContactForm(data=form_data)
           self.assert_(form.is_valid())
           self.assertEqual(form.instance.name, 'Test Name')

           form.save()

           self.assertEqual(
               Contact.objects.get(id=form.instance.id).name,
               'Test Name'
           )


Form Sets
=========

Form Sets
---------

- Handles multiple copies of the same form
- Adds a unique prefix to each form::

    form-1-name

- Support for insertion, deletion, and ordering


Defining Form Sets
------------------

.. testcode::

   from django.forms import formsets

   ContactFormSet = formsets.formset_factory(
       ContactForm,
   )

.. testcode::
   :hide:

   request = request_factory.post(
       '/',
       rebar.testing.flatten_to_dict(ContactFormSet()),
   )

.. testcode::

   formset = ContactFormSet(data=request.POST)

Factory kwargs:

- ``can_delete``
- ``extra``
- ``max_num``

Using Form Sets
---------------

::

   <form action=”” method=”POST”>
   {% formset %}
   </form>

Or more control over output::

   <form action=”.” method=”POST”>
   {% formset.management_form %}
   {% for form in formset %}
      {% form %}
   {% endfor %}
   </form>

Management Form
---------------

- ``formset.management_form`` provides fields for tracking the member
  forms

  - ``TOTAL_FORMS``
  - ``INITIAL_FORMS``
  - ``MAX_NUM_FORMS``

- Management form data **must** be present to validate a Form Set

formset.is_valid()
------------------

.. blockdiag::

   blockdiag {
      // Set labels to nodes.
      A [label = "Clean Fields"];
      B [label = "Clean Form"];
      C [label = "Clean FormSet"];

      A -> B -> C;
      B -> A;
   }

- Performs validation on each member form
- Calls ``.clean()`` method on the FormSet
- ``formset.clean()`` can be overridden to validate across Forms
- Errors raised are collected in ``formset.non_form_errors()``

FormSet.clean()
---------------

.. testcode::

   from django.forms import formsets

   class BaseContactFormSet(formsets.BaseFormSet):
       def clean(self):
           names = []
           for form in self.forms:
               if form.cleaned_data.get('name') in names:
                   raise ValidationError()
               names.append(form.cleaned_data.get('name'))

   ContactFormSet = formsets.formset_factory(
       ContactForm,
       formset=BaseContactFormSet
   )

Insertion
---------

- FormSets use the ``management_form`` to determine how many forms to
  build
- You can add more by creating a new form and incrementing
  ``TOTAL_FORM_COUNT``
- ``formset.empty_form`` provides an empty copy of the form with
  ``__prefix__`` as the index

.. Insertion HTML
.. --------------

.. XXX

Deletion
--------

- When deletion is enabled, additional ``DELETE`` field is added to
  each form
- Forms flagged for deletion are available using the
  ``.deleted_forms`` property
- Deleted forms are **not** validated

::

   ContactFormSet = formsets.formset_factory(
       ContactForm, can_delete=True,
   )


Ordering Forms
--------------

- When ordering is enabled, additional ``ORDER`` field is added to
  each form
- Forms are available (in order) using the ``.ordered_forms`` property

::

   ContactFormSet = formsets.formset_factory(
       ContactForm,
       can_order=True,
   )

Testing
-------

- FormSets can be tested in the same way as Forms
- Helpers to generate test form data:

  - ``flatten_to_dict`` works with FormSets just like Forms
  - ``empty_form_data`` takes a FormSet and index, returns a dict of data
    for an empty form:

.. testcode::

      from rebar.testing import flatten_to_dict, empty_form_data

      formset = ContactFormSet()
      form_data = flatten_to_dict(formset)
      form_data.update(
          empty_form_data(formset, len(formset))
      )


Model Form Sets
---------------

- ModelFormSets:FormSets :: ModelForms:Forms
- ``queryset`` argument specifies initial set of objects
- ``.save()`` returns the list of saved instances
- If ``can_delete`` is ``True``, ``.save()`` also deletes the models
  flagged for deletion

Advanced & Miscellaneous Detritus
=================================

Localizing Fields
-----------------

- Django's i18n/l10n framework supports localized input formats
- For example: 10,00 vs. 10.00

Enable in ``settings.py``::

   USE_L10N = True
   USE_THOUSAND_SEPARATOR = True # optional

Localizing Fields Example
-------------------------

And then use the ``localize`` kwarg

.. testsetup:: l10n

   from django.conf import settings
   settings.USE_L10N = True

.. doctest:: l10n

  >>> from django import forms
  >>> class DateForm(forms.Form):
  ...     pycon_ends = forms.DateField(localize=True)

  >>> DateForm({'pycon_ends': '3/15/2012'}).is_valid()
  True
  >>> DateForm({'pycon_ends': '15/3/2012'}).is_valid()
  False

  >>> from django.utils import translation
  >>> translation.activate('en_GB')
  >>> DateForm({'pycon_ends':'15/3/2012'}).is_valid()
  True

Dynamic Forms
-------------

- Declarative syntax is just sugar
- Forms use a metaclass to populate ``form.fields``
- After ``__init__`` finishes, you can manipulate ``form.fields``
  without impacting other instances


State Validators
----------------

- Validation isn't necessarily all or nothing
- State Validators define validation for specific states, on top of
  basic validation
- Your application can take action based on whether the form is valid,
  or valid for a particular state


State Validators
----------------

.. testcode::

   from django import forms
   from rebar.validators import StateValidator, StateValidatorFormMixin

   class PublishValidator(StateValidator):
       validators = {
           'title': lambda x: bool(x),
        }

   class EventForm(StateValidatorFormMixin, forms.Form):
       state_validators = {
           'publish': PublishValidator,
       }
       title = forms.CharField(required=False)

State Validators
----------------

::

   >>> form = EventForm(data={})
   >>> form.is_valid()
   True
   >>> form.is_valid('publish')
   False
   >>> form.errors('publish')
   {'title': 'This field is required'}
