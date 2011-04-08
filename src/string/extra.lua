---------------------------------------------------------------------
-- String manipulation functions.
--
-- @class module
-- @name string.extra
-- @release $Id: extra.lua,v 1.1 2009-10-01 13:48:31 tomas Exp $
---------------------------------------------------------------------

local string = require"string"

module"string.extra"

---------------------------------------------------------------------
-- Removes spaces from the beginning and from the end of a string.
-- Also removes space multiplicity (by substituting it by a single space).
-- @param s String to be processed.
-- @return String or nil if no string was given.
---------------------------------------------------------------------
function rmsp (s)
	if not s then return end
	s = string.gsub (s, "^%s*(.-)%s*$", "%1")
	s = string.gsub (s, "%s%s+", " ")
	return s
end

---------------------------------------------------------------------
-- Removes leading, trailing and redundant spaces from a string and
-- returns the result if it's not empty. nil is returned otherwise.
-- @param s String to be processed.
-- @return String or nil, if it results in an empty string.
-- @see string.extra.rmsp
---------------------------------------------------------------------
function notempty(s)
	s = rmsp(s)
	if s == "" then
		return nil
	end
	return s
end

---------------------------------------------------------------------
-- Splits a string into a table producing a record.
-- The fields of the record are the strings;
-- the values are its initial position in the original string.
-- @param s String to be processed.
-- @param sep String with the separator character (optional).
-- @param dest Table to receive the result (optional).
-- @return Table representing a record.
---------------------------------------------------------------------
function torecord (s, sep, dest)
	if not s then return end
	sep = sep or ' '
	if not dest then
		dest = {}
	end
	string.gsub (s, "()([^"..sep.."]+)", function (pos, word)
		dest[word] = pos
	end)
	return dest
end

---------------------------------------------------------------------
-- Splits a string into a table producing an array.
-- @param s String to be processed.
-- @param sep String with the separator character (optional).
-- @param dest Table to receive the result (optional).
-- @return Table representing a record.
---------------------------------------------------------------------
function toarray (s, sep, dest)
	if not s then return end
	sep = sep or ' '
	if not dest then
		dest = {}
	end
	local i = #dest
	string.gsub (s..sep, "([^"..sep.."]+)"..sep, function (word)
		i = i+1
		dest[i] = word
	end)
	return dest
end

---------------------------------------------------------------------
-- Applies a function to the substrings of a given string.
-- It also takes care of separator inside quoted strings.
-- @param s String to be processed.
-- @param f Function to process each substring.
-- @param sep String with the separator character (default = ';').
---------------------------------------------------------------------
function split (s, f, sep)
	sep = sep or ';'
	-- changes the separator by '\1'
	s = string.gsub (s, '"([^"]*)"', function (s)
		return string.gsub (s, sep, "\1") or ""
	end)
	for w in string.gmatch (s..sep, "([^"..sep.."]*)"..sep) do
		-- removes the quotes
		w = string.gsub (w, '^"(.*)"$', "%1")
		-- restores the separator
		w = string.gsub (w, "\1", sep)
		f (w)
	end
end
