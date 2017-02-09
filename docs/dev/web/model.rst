Models
======

Models are defined in ``/lib/gluon/web/model``. Each model defines one or more
forms to display on a page, and how the submitted form data is handled.

Let's start with an example:

.. code-block:: lua

  local f = Form(translate('Hostname'))

  local s = f:section(Section)

  local o = s:option(Value, 'hostname', translate('Hostname'))
  o.default = uci:get_first('system', 'system', 'hostname')
  function o:write(data)
    uci:set('system', uci:get_first('system', 'system'), 'hostname', data)
    uci:commit('system')
  end

  return f

The toplevel element of a model is always a *Form*, but it is also possible for
a model to return multiple forms, which are displayed one below the other.

A *Form* has one or more *Sections*, and each *Section* has different types
of options.

All of these elements have an *id*, which is used to identify them in the HTML
form and handlers. If no ID is given, numerical IDs will be assigned automatically,
but using explicitly named elements is often advisable (and it is required if a
form does not always include the same elements, i.e., some forms, sections or
options are added conditionally). IDs are hierarchical, so in the above example,
the *Value* would get the ID ``1.1.hostname`` (value *hostname* in first section
of first form).

Classes and methods
-------------------

  - *Form* (*title*, *description*, *id*)

    - *Form:section* (*type*, *title*, *description*, *id*)

      Creates a new section of the given type (usually *Section*).

    - *Form:write* ()

      Is called after the form has beed submitted (but only if the data is valid). It
      is called last (after all options' *write* methods) and is usually used
      to commit changed UCI packages.

      The default implementation of *write* doesn't to anything, but it can be
      overridden.

  - *Section* (usually instanciated through *Form:section*)

    - *Section:option* (*type*, *id*, *title*, *description*)

      Creates a new option of the given type. Option types:

        - *Value*: simple text entry
        - *TextValue*: multiline text field
        - *ListValue*: radio buttons or dropdown selection
        - *DynamicList*: variable number of text entry fields
        - *Flag*: checkbox

Most option types share the same properties and methods:

  - *default*: default value
  - *optional*: value may be empty
  - *datatype*: one of the types described in :ref:`web-model-datatypes`

    By default (when *datatype* is *nil*), all values are accepted.

  - *state*: has one of the values *FORM_NODATA*, *FORM_VALID* and *FORM_INVALID*
    when read in a form handler

    An option that has not been submitted because of its dependencies will have
    the state *FORM_NODATA*, *FORM_INVALID* if the submitted value is not valid
    according to the set *datatype*, and *FORM_VALID* otherwise.

  - *data*: can be read in form handlers to get the submitted value

  - *depends* (*self*, *option*, *value*): adds a dependency on another option

    The option will only be shown when the passed option has the given value. This
    is mainly useful when the other value is a *Flag* or *ListValue*.

  - *depends* (*self*, *deps*): adds a dependency on multiple other options

    *deps* must be a table with options as keys and values as values. The option
    will only be shown when all passed options have the corresponding values.

    Multiple alternative dependencies can be added by calling *depends* repeatedly.

  - *value* (*self*, *value*, *text*): adds a choice to a *ListValue*

  - *write* (*self*, *data*): is called with the submitted value when all form data is valid.

    Does not do anything by default, but can be overridden.

The *default* value, the *value* argument to *depends* and the output *data* always have
the same type, which is usually a string (or *nil* for optional values). Exceptions
are:

  - *Flag* uses boolean values
  - *DynamicList* uses a table of strings

Despite its name, the *datatype* setting does not affect the returned value type,
but only defines a validator the check the submitted value with.

For a more complete example that actually makes use of most of these features,
have a look at the model of the *gluon-web-network* package.

.. _web-model-datatypes:

Data types
----------

  - *integer*: an integral number
  - *uinteger*: an integral number greater than or equal to zero
  - *float*: a number
  - *ufloat*: a number greater than or equal to zero
  - *ipaddr*: an IPv4 or IPv6 address
  - *ip4addr*: an IPv4 address
  - *ip6addr*: an IPv6 address
  - *wpakey*: a string usable as a WPA key (either between 8 and 63 characters, or 64 hex digits)
  - *range* (*min*, *max*): a number in the given range (inclusive)
  - *min* (*min*): a number greater than or equal to the given minimum
  - *max* (*max*): a number less than or equal to the given maximum
  - *irange* (*min*, *max*): an integral number in the given range (inclusive)
  - *imin* (*min*): an integral number greater than or equal to the given minimum
  - *imax* (*max*): an integral number less than or equal to the given maximum
  - *minlength* (*min*): a string with the given minimum length
  - *maxlength* (*max*): a string with the given maximum length

Differences from LuCI
---------------------

  - LuCI's *SimpleForm* and *SimpleSection* are called *Form* and *Section*, respectively
  - Is it not possible to add options to a *Form* directly, a *Section* must always
    be created explicitly
  - Many of LuCI's CBI classes have been removed, most importantly the *Map*
  - The *rmempty* option attribute does not exist, use *optional* instead
  - Only the described data types are supported
  - Form handlers work completely differently (in particular, a *Form*'s *handle*
    method should usually not be overridden in *gluon-web*)
