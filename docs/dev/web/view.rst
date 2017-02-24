Views
=====

The template parser reads views from ``/lib/gluon/web/view``. Writing own view
should be avoided in favour of using :doc:`model` with their predefined views.

Views are partial HTML pages, with additional template tags that allow
to embed Lua code and translation strings. The following tags are defined:

  - ``<%`` ... ``%>`` evaluates the enclosed Lua expression.
  - ``<%=`` ... ``%>`` evaluates the enclosed Lua expression and prints its value.
  - ``<%+`` ... ``%>`` includes another template.
  - ``<%:`` ... ``%>`` translates the enclosed string using the loaded i18n catalog.
  - ``<%_`` ... ``%>`` translates the enclosed string *without escaping HTML entities*
    in the translation. This only makes sense when the i18n catalog contains HTML code.
  - ``<%#`` ... ``%>`` is a comment.

All of these also come in the whitespace-stripping variants ``<%-`` and ``-%>`` that
remove all whitespace before or after the tag.

Complex combinations of HTML and Lua code are possible, for example:

.. code-block:: text

  <div>
    <% if foo then %>
      Content
    <% end %>
  </div>


Variables and functions
-----------------------

Many call sites define additional variables (for example, model templates can
access the model as *self* and a unique element ID as *id*), but the following
variables and functions should always be available for the embedded Lua code:

  - *renderer*: :ref:`web-controller-template-renderer`
  - *http*: :ref:`web-controller-http`
  - *request*: Table containing the path components of the current page
  - *url* (*path*): returns the URL for the given path, which is passed as a table of path components.
  - *attr* (*key*, *value*): Returns a string of the form ``key="value"``
    (with a leading space character before the key).

    *value* is converted to a string (tables are serialized as JSON) and HTML entities
    are escaped. Returns an empty string when *value* is *nil* or *false*.
  - *include* (*template*): Includes another template.
  - *node* (*path*, ...): Returns the controller node for the given page (passed as
    one argument per path component).

    Use ``node(unpack(request))`` to get the node for the current page.
  - *pcdata* (*str*): Escapes HTML entities in the passed string.
  - *urlencode* (*str*): Escapes the passed string for use in an URL.
  - *translate*, *_translate* and *translatef*: see :doc:`i18n`
