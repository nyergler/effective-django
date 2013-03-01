.. tut::
   :path: /src

.. slideconf::
   :autoslides: False

=======
 Forms
=======


Customizing Forms
=================

.. checkpoint:: confirm_contact_email

* TK Require double-entry of email

.. literalinclude:: /src/contacts/forms.py
   :pyobject: ContactForm

.. literalinclude:: /src/contacts/views.py
   :pyobject: CreateContactView
   :end-before: def get_success_url

.. Combining Forms
.. ===============

.. Single editor for Contact + Addresses



.. .. checkpoint:: combined_contact_editor
