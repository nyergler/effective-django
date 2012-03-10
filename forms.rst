======================
Effective Django Forms
======================

Nathan R. Yergler
PyCON 2012 // 10 March 2012


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

Why use Forms?
--------------

- Data type coercion
- Validation
- Consistent HTML output

Defining Forms
--------------

Forms are composed of fields, which have a widget::

  from django import forms

  class ContactForm(forms.Form):

      name = forms.CharField(
          _("Your Name"),
          max_length=255,
          widget=forms.TextInput,
      )

      email = forms.EmailField(
          _("Email address"),
      )

Django provides you with a default widget if you don't specify one.

Instantiating a Form
--------------------

.. container:: build

   .. container:: unbound

      Unbound forms don't have data associated with them, but they can
      be rendered.

      >>> form = ContactForm()

   .. container:: bound

      Bound forms have specific data associated, which can be
      validated.

      >>> form = ContactForm(data=request.POST, files=request.FILES)


Accessing Fields
----------------

Two ways to access fields on a Form instance

- ``form.fields['name']`` returns the ``Field`` object
- ``form['name']`` returns a ``BoundField``
- ``BoundField`` wraps a field and value for HTML output

Initial Data
------------

::

   form = ContactForm(
       initial={
           'name': 'First and Last Name',
       },
   )

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
      B [label = "Field Cleaning"];
      C [label = "Form Cleaning"];

      A -> B -> C;
   }

- Only bound forms can be validated
- Calling ``form.is_valid()`` triggers validation if needed
- Validated, cleaned data is stored in ``form.cleaned_data``
- Calling ``form.full_clean()`` performs the full cycle

Field Validators
----------------

- Validators are callables that can raise a ``ValidationError``
- Django includes generic ones for some common tasks
- Can be shared between Models and Forms
- Examples: URL, Min/Max Value, Min/Max Length, URL, Regex, email

.clean_*()
----------

- ``.clean_fieldname()`` method is called after validators
- Input has already been converted to Python objects
- Methods can raise ``ValidationErrors``
- Methods *must* return the cleaned value

.clean_name()
-------------

::

  class ContactForm(forms.Form):
      name = forms.CharField(
          _("Name"),
          max_length=255,
      )

      email = forms.EmailField(
          _("Email address"),
      )

      def clean_email(self):

          if (self.cleaned_data.get('email', '')
              .endswith('hotmail.com')):

              raise ValidationError("Invalid email address.")

          return self.cleaned_data.get('email', '')

.clean()
--------

- Performs cross-field validation
- *Must* return the cleaned data dictionary
- ``ValidationErrors`` raised by ``.clean()`` will be grouped in
  ``form.non_field_errors()`` by default.
- XXX Example

Initial != Default Data
-----------------------

- Initial data is used as a starting point
- It does not automatically propagate to ``cleaned_data``
- Defaults for non-required fields should be specified when
  accessing the dict::

    self.cleaned_data.get('name', 'default')

Tracking Changes
----------------

- Forms use initial data to track changed fields
- ``form.has_changed()``
- ``form.changed_fields``
- Fields can render a hidden input with the initial value, as well::

    changed = DateField(show_hidden_initial=True)

    XXX Html Output example

Testing
=======

Testing Forms
-------------

- Forms: Raw input -> Validation Python objects
- Testing strategies

 * Initial states
 * Field Validation
 * Final state of cleaned_data

Unit Tests
----------

::

   class FormTests(unittest.TestCase):
       def test_validation(self):
           form_data = {
               ‘name’: ‘X’ * 300,
           }

           form = ContactForm(data=form_data)
           self.assertFalse(form.is_valid())

Test Data
---------

::

   from rebar.testing import flatten_to_dict

   form_data = flatten_to_dict(ContactForm())
   form_data.update({
           ‘name’: ‘X’ * 300,
       })
   form = ContactForm(data=form_data)
   self.assertFalse(form.is_valid())


Rendering Forms
===============

Idiomatic Form Usage
--------------------

::

   from django.views.generic.edit import ProcessFormView

   class ContactView(ProcessFormView):
       form = ContactForm
       success_url = ‘/contact/sent’

Form Output
-----------

XXX Output example

::

   {{ form.as_p }}

   {{ form.as_ul }}

   {{ form.as_table }}

More GranularOutput
-------------------

::

   {% for field in form %}
   {{ field.label_tag }}: {{ field }}
   {{ field.errors }}
   {% endfor %}
   {{ field.non_field_errors }}

Additional rendering properties:

- field.label
- field.label_tag
- field.html_id
- field.help_text

Customizing Rendering
---------------------

You can specify additional attributes for widgets as part of the form
definition.

::

   class ContactForm(forms.Form):
       name = forms.CharField(
           max_length=255,
           widget=forms.Textarea(
               attrs={‘class’: ‘custom’},
           ),
       )

You can also specify form-wide CSS classes to add for error and
required states.

::

   class ContactForm(forms.Form):
       error_css_class = ‘error’
       required_css_class = ‘required’


Customizing Error Messages
--------------------------

- Built in validators have default error messages

::

   >>> generic = forms.CharField()
   >>> generic.clean('')
   Traceback (most recent call last):
     ...
   ValidationError: [u'This field is required.']

- ``error_messages`` parameter lets you customize those messages

::

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
- By default, ErrorList is used: outputs as ``<ul>``
- Specify the error_class parameter to override

Error Class
-----------

::

   from django.forms.util import ErrorList

   class ParagraphErrorList(ErrorList):
       def __unicode__(self):
           return self.as_paragraphs()

       def as_paragraphs(self):
           return “<p>%s</p>” % (
               “,”.join(e for e in self.errors)
           )

   form = ContactForm(data=form_data, error_class=ParagraphErrorList)

Multiple Forms
--------------

- Avoid potential name collisions with prefix
- Adds the prefix to HTML name and ID

::

   contact_form = ContactForm(prefix=‘contact’)

XXX HTML example

Forms for Models
================

Model Forms
-----------

- ModelForms map a Model to a Form
- Validation includes Model validators by default
- Supports creating and editing instances
- Key differences from Forms:
  - ``.save()`` method
  - ``.instance`` property

Model Forms
-----------

::

   class Contact(models.Model):
       name = models.CharField(
           max_length=255)
       email = models.EmailField()
       notes = models.TextField()

   class ContactForm(ModelForm):
       class Meta:
           model=Contact

Overriding Fields
-----------------

XXX

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
      B [label = "Field Cleaning"];
      C [label = "Form Cleaning"];
      D [label = "_post_clean()"];

      A -> B -> C -> D;
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
               ‘name’: ‘Test Name’,
           }

           form = ContactForm(data=form_data)
           self.assert_(form.is_valid())
           self.assertEqual(
               form.instance.name,
               ‘Test Name’
           )

           form.save()

           self.assertEqual(
               Contact.objects.get(id=form.instance.id).name,
               ‘Test Name’
           )


Formsets
========

Form Sets
---------

- Handles multiple copies of the same form
- Adds a unique prefix to each form::
    form-1-name

- Support for creation and deletion
- Basic ordering support

Defining Form Sets
------------------

::

   from django.forms import formsets

   ContactFormSet = formsets.formset_factory(
       ContactForm,
   )

   formset = ContactFormSet(data=request.POST)

Using Form Sets
---------------

::

   <form action=”” method=”POST”>
   {% formset %}
   </form>

Or more granular output::

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

  - TOTAL_FORMS
  - INITIAL_FORMS
  - MAX_NUM_FORMS

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

::

   class BaseContactFormSet(formsets.FormSet):
       def clean(self):
           names = []
           for form in self.forms:
               if form.cleaned_data.get(‘name’) in names:
                   raise ValidationError()
               names.append(form.cleaned_data.get(‘name’))

   ContactFormSet = formset_factory(
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
  ``__empty__`` as the index

Insertion HTML
--------------

XXX

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
  - ``empty_dict`` takes a FormSet and index, returns a dict of data
    for an empty form::

      XXX is this true?

      formset = ContactFormSet()
      form_data = flatten_to_dict(formset)
      form_data.update(
          empty_form(formset, len(formset))
      )


Model Form Sets
---------------

- ModelFormSets:FormSets :: ModelForms:Forms
- ``queryset`` argument specifies initial set of objects
- ``.save()`` returns the list of saved instances
- If ``can_delete`` is ``True``, ``.save()`` also deletes the models
  flagged for deletion

Advanced
========

Passing Extra Information
-------------------------

- Sometimes you need extra information in a form
- Pass as a keyword argument, and pop in __init__

::

   class MyForm(Form):
       def __init__(self, *args, **kwargs):
           self.user = kwargs.pop(‘user’)
           super(MyForm, self).__init__(*args, **kwargs)

Localizing Fields
-----------------

- Django’s i18n/l10n framework supports localized input formats
- For example: 10,00 vs. 10.00

::

   USE_I18N = True
   USE_L10N = True
   localize=True

- XXX Example / Verify

Dynamic Forms
-------------

- Declarative syntax is just sugar
- Forms use a metaclass to populate ``form.fields``
- After ``__init__`` finishes, you can manipulate ``form.fields``
  without impacting other instances

Form Groups
-----------


XXX


State Validators
----------------

- Validation isn’t necessarily all or nothing
- State Validators define validation for specific states, on top of
  basic validation
- Your application can take action based on whether the form is valid,
  or valid for a particular state


State Validators
----------------

::

   class PublishValidator(StateValidator):
       validators = {
           ‘title’: lambda x: bool(x),
        }

   class EventForm(StateValidatorFormMixin,
       Form):
       state_validators = {
           ‘publish’: PublishValidator,
       }
       title = forms.CharField(required=False)

State Validators
----------------

::

   >>> form = EventForm(data={})
   >>> form.is_valid()
   True
   >>> form.is_valid(‘publish’)
   False
   >>> form.errors('publish')
   {'title': 'This field is required'}


The End
=======

http://effectivedjango.com/forms
