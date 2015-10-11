local function loadvar(varname)
   local ok, val = pcall(assert(loadstring('return site.' .. varname)))
   if ok then
      return val
   else
      return nil
   end
end

local function assert_type(var, t, msg)
   assert(type(var) == t, msg)
end


function assert_uci_name(var)
   -- We don't use character classes like %w here to be independent of the locale
   assert(var:match('^[0-9a-zA-Z_]+$'), "site.conf error: `" .. var .. "' is not a valid config section name (only alphanumeric characters and the underscore are allowed)")
end


function need_string(varname, required)
   local var = loadvar(varname)

   if required == false and var == nil then
      return nil
   end

   assert_type(var, 'string', "site.conf error: expected `" .. varname .. "' to be a string")
   return var
end

function need_string_match(varname, pat, required)
   local var = need_string(varname, required)

   if not var then
      return nil
   end

   assert(var:match(pat), "site.conf error: expected `" .. varname .. "' to match pattern `" .. pat .. "'")

   return var
end

function need_number(varname, required)
   local var = loadvar(varname)

   if required == false and var == nil then
      return nil
   end

   assert_type(var, 'number', "site.conf error: expected `" .. varname .. "' to be a number")

   return var
end

function need_boolean(varname, required)
   local var = loadvar(varname)

   if required == false and var == nil then
      return nil
   end

   assert_type(var, 'boolean', "site.conf error: expected `" .. varname .. "' to be a boolean")

   return var
end

function need_array(varname, subcheck, required)
   local var = loadvar(varname)

   if required == false and var == nil then
      return nil
   end

   assert_type(var, 'table', "site.conf error: expected `" .. varname .. "' to be an array")

   for _, e in ipairs(var) do
      subcheck(e)
   end

   return var
end

function need_table(varname, subcheck, required)
   local var = loadvar(varname)

   if required == false and var == nil then
      return nil
   end

   assert_type(var, 'table', "site.conf error: expected `" .. varname .. "' to be a table")

   if subcheck then
      for k, v in pairs(var) do
         subcheck(k, v)
      end
   end

   return var
end

function need_string_array(varname, required)
   return assert(pcall(need_array, varname, function(e) assert_type(e, 'string') end, required),
		 "site.conf error: expected `" .. varname .. "' to be a string array")
end
