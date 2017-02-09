Controllers
===========

Controllers live in ``/lib/gluon/web/controller``. They define which pages ("routes")
exist under the ``/cgi-bin/gluon`` path, and what code is run when these pages are requested.

Controller scripts mostly consist of calls of the `entry` function, which each define
one route:

.. code-block:: lua

  entry({"admin"}, alias("admin", "info"), _("Advanced settings"), 10)
  entry({"admin", "info"}, template("admin/info"), _("Information"), 1)

The entry function expects 4 arguments:

  - `path`: Components of the path to define a route for.

    The above example defines routes for the paths ``admin`` and ``admin/info``.

  - `target`: Dispatcher for the route. See the following section for details.
  - `title`: Page title (also used in navigation). The underscore function is used

  - `order`: Sort index in navigation (defaults to 100)

Navigation indexes are automatically generated for each path level. Pages can be
hidden from the navigation by setting the `hidden` property of the node object
returned by `entry`:

.. code-block:: lua

  entry({"hidden"}, alias("foo"), _("I'm hidden!")).hidden = true


Dispatchers
-----------

  - *alias* (*path*, ...): Redirects to a different page. The path components are
    passed as individual arguments.
  - *call* (*func*, ...): Runs a Lua function for custom request handling. The given
    function is called with the HTTP object and the template renderer as first
    two arguments, followed by all additional arguments passed to `call`.
  - *template* (*view*): Renders the given view. See :doc:`view`.
  - *model* (*name*): Displays and evaluates a form as defined by the given model. See the
    :doc:`model` page for an explanation of gluon-web models.


.. _web-controller-http:

The HTTP object
---------------

The HTTP object provides information about the HTTP requests and allows to add
data to the reply. Using it directly is rarely necessary when gluon-web
models and views are used.

Useful functions:

  - *getenv* (*key*): Returns a value from the CGI environment passed by the webserver.
  - *formvalue* (*key*): Returns a value passed in a query string or in the content
    of a POST request. If multiple values with the same name have been passed, only
    the first is returned.
  - *formvaluetable* (*key*): Similar to *formvalue*, but returns a table of all
    values for the given key.
  - *status* (*code*, *message*): Writes the HTTP status to the reply. Has no effect
    if a status has already been sent or non-header data has been written.
  - *header* (*key*, *value*): Adds an HTTP header to the reply to be sent to to
    the client. Has no effect when non-header data has already been written.
  - *prepare_content* (*mime*): Sets the *Content-Type* header to the given MIME
    type, potentially setting additional headers or modifying the MIME type to
    accommodate browser quirks
  - *write* (*data*, ...): Sends the given data to the client. If headers have not
    been sent, it will be done before the data is written.


HTTP functions are called in method syntax, for example:

.. code-block:: lua

  http:write('Output!')


.. _web-controller-template-renderer:

The template renderer
---------------------

The template renderer allows to render templates (views). The most useful functions
are:

  - *render* (*view*, *scope*): Renders the given view, optionally passing a table
    with additional variables to make available in the template.
  - *render_string* (*str*, *scope*): Same as *render*, but the template is passed
    directly instead of being loaded from the view directory.

The renderer functions are called in property syntax, for example:

.. code-block:: lua

  renderer.render('layout')


Differences from LuCI
---------------------

  - Controllers must not use the *module* function to define a Lua module (*gluon-web*
    will set up a proper environment for each controller itself)
  - Entries are defined at top level, not inside an *index* function
  - The *alias* dispatcher triggers an HTTP redirect instead of directly running
    the dispatcher of the aliased route.
  - The *call* dispatcher is passed a function instead of a string with a function
    name.
  - The *cbi* dispatcher of LuCI has been renamed to *model*.
  - The HTTP POST handler support the multipart/form-data encoding only, so
    ``enctype="multipart/form-data"`` must be included in all *<form>* HTML
    elements.
  - Other dispatchers like *form* are not provided.
