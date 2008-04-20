---------------------------------------------------------------------
-- General validation functions.
--
-- @class module
-- @name check
-- @release $Id: check.lua,v 1.5 2008/04/09 03:16:15 tomas Exp $
---------------------------------------------------------------------

-- Stores all names inherited in locals
local error, tonumber, type = error, tonumber, type
local debug = require"debug"
local string = require"string"

module"check"

_COPYRIGHT = "Copyright (C) 2008 PUC-Rio"
_DESCRIPTION = "Check is a library of general validation functions"
_VERSION = "Check 1.0.0"

local errmsg = "bad argument #%d to `%s' (%s expected, got %s)"

--
-- Builds an assertion function for a given type.
-- @param expected String with the name of the type to be checked.
-- @return Function which checks if a value is of a certain type.
--
local function build_assert (expected)
	return function (v, n, f)
		if not f then
			f = debug.getinfo (2, "n").name
		end
		local t = type (v)
		if t ~= expected then
			error (string.format (errmsg, n, f, expected, t), 3)
		end
	end
end

--
-- Builds an assertion function which accepts nil for a given type.
-- @param func String with the name of the assertion function.
-- @return Function which checks if a value is nil or of a certain type.
--
local function build_optassert (func)
	return function (v, n, f)
		if not v then
			return
		end
		if not f then
			f = debug.getinfo (4, "n").name
		end
		_M[func] (v, n, f)
	end
end

---------------------------------------------------------------------
-- Asserts that value is a number or a string which can be coerced to
--	a number.
-- @param v Value to be checked.
-- @param n Number of argument.
-- @param f Function name.
---------------------------------------------------------------------
function num (v, n, f)
	if not f and debug then
		f = debug.getinfo (2, "n").name
	end
	if not tonumber (v) then
		error (string.format (errmsg, n, f, "number", type(v)), 3)
	end
end

---------------------------------------------------------------------
-- Asserts that value is a string or a number.
-- @param v Value to be checked.
-- @param n Number of argument.
-- @param f Function name.
---------------------------------------------------------------------
function str (v, n, f)
	if not f then
		f = debug.getinfo (2, "n").name
	end
	local t = type (v)
	if t ~= "string" and t ~= "number" then
		error (string.format (errmsg, n, f, "string", t), 3)
	end
end

---------------------------------------------------------------------
-- Asserts that value is an optional string.
-- @class function
-- @name optstr
-- @param v Value to be checked.
-- @param n Number of argument.
-- @param f Function name.
-- @see str

optstr = build_optassert ("str")

---------------------------------------------------------------------
-- Asserts that value is a table.
-- @class function
-- @name table
-- @param v Value to be checked.
-- @param n Number of argument.
-- @param f Function name.
---------------------------------------------------------------------
table = build_assert ("table")

---------------------------------------------------------------------
-- Asserts that value is an optional table.
-- @class function
-- @name opttable
-- @param v Value to be checked.
-- @param n Number of argument.
-- @param f Function name.
-- @see table

opttable = build_optassert ("table")

---------------------------------------------------------------------
-- Asserts that value is a userdata.
-- @class function
-- @name udata
-- @param v Value to be checked.
-- @param n Number of argument.
-- @param f Function name.
---------------------------------------------------------------------
udata = build_assert ("userdata")

---------------------------------------------------------------------
-- Asserts that value is a function.
-- @class function
-- @name func
-- @param v Value to be checked.
-- @param n Number of argument.
-- @param f Function name.
---------------------------------------------------------------------
func = build_assert ("function")

---------------------------------------------------------------------
-- Asserts that value is an optional function.
-- @class function
-- @name optfunc
-- @param v Value to be checked.
-- @param n Number of argument.
-- @param f Function name.
-- @see func
---------------------------------------------------------------------
optfunc = build_optassert ("func")
