---------------------------------------------------------------------
-- Compose SQL statements.
--
-- @release $Id: sql.lua,v 1.5 2008/04/09 03:16:15 tomas Exp $
---------------------------------------------------------------------

-- Stores all names inherited in locals
local check  = require"check"
local string = require"string"
local gsub, strfind, strformat = string.gsub, string.find, string.format
local table  = require"table.extra"
local tabfullconcat, tabtwostr = table.fullconcat, table.twostr

module"dado.sql"

_COPYRIGHT = "Copyright (C) 2008 PUC-Rio"
_DESCRIPTION = "SQL is a collection of functions to create SQL statements"
_VERSION = "Dado SQL 1.0.0"

---------------------------------------------------------------------
-- Quote a value to be included in an SQL statement.
-- The exception is when the string is surrounded by "()";
-- in this case it won't be quoted.
-- @param s String or number.
-- @param quote String with quote character (default = "'").
-- @param sub String with escape character (default = "\\").
-- @return String with prepared value.
---------------------------------------------------------------------
function quote (s, quote, sub)
    check.str (s, 1)
    check.optstr (quote, 2)
    check.optstr (sub, 3)
    quote = quote or "'"
    if strfind (s, "^%(.*%)$") then
        return s
    else
        return quote..escape (s, quote, sub)..quote
    end
end

---------------------------------------------------------------------
-- Escape a character or a character class in a string.
-- @param s String to be processed.
-- @param char String with gsub's character class to be escaped inside
--  the string (default = "%s").
-- @param sub String with escape character (default = "\\").
-- @return String or nil if no string was given.
---------------------------------------------------------------------
function escape (s, char, sub)
    if not s then return end
    check.str (s, 1)
    check.optstr (char, 2)
    check.optstr (sub, 3)
    char = char or "%s"
    sub = sub or "\\"
    s = gsub (s, "("..char..")", sub.."%1")
    return s
end

---------------------------------------------------------------------
-- Builds a string with a SELECT command.
-- The existing arguments will be concatenated together to form the
-- SQL statement.
-- The string "select " is added as a prefix.
-- If the tabname is given, the string " from " is added as a prefix.
-- If the cond is given, the string " where " is added as a prefix.
-- @param columns String with columns list.
-- @param tabname String with table name (optional).
-- @param cond String with where-clause (optional).
-- @param extra String with extra SQL text (optional).
-- @return String with SELECT command.
---------------------------------------------------------------------
function select (columns, tabname, cond, extra)
	check.str (columns, 1, "sql.select")
	check.optstr (tabname, 2, "sql.select")
	check.optstr (cond, 3, "sql.select")
	check.optstr (extra, 4, "sql.select")
	tabname  = tabname and (" from "..tabname) or ""
	cond     = cond and (" where "..cond) or ""
	extra    = extra and (" "..extra) or ""
	return strformat ("select %s%s%s%s", columns, tabname, cond, extra)
end

---------------------------------------------------------------------
-- Builds a string with a SELECT command to be inserted into another
-- SQL query.
-- @param columns String with columns list.
-- @param tabname String with table name.
-- @param cond String with where-clause (and following SQL text).
-- @param extra String with extra SQL text.
-- @return String with SELECT command.
---------------------------------------------------------------------
function subselect (columns, tabname, cond, extra)
	return "("..select (columns, tabname, cond, extra)..")"
end

---------------------------------------------------------------------
-- Builds a string with an INSERT command.
-- @param tabname String with table name.
-- @param contents Table of elements to be inserted.
-- @return String with INSERT command.
---------------------------------------------------------------------
function insert (tabname, contents)
	check.str (tabname, 1, "sql.insert")
	return strformat ("insert into %s (%s) values (%s)",
		tabname, tabtwostr (contents, ',', ',', nil, quote))
end

---------------------------------------------------------------------
-- Builds a string with an UPDATE command.
-- @param tabname String with table name.
-- @param contents Table of elements to be updated.
-- @param cond String with where-clause (and following SQL text).
-- @return String with UPDATE command.
---------------------------------------------------------------------
function update (tabname, contents, cond)
	check.str (tabname, 1, "sql.update")
	check.table (contents, 2, "sql.update")
	check.optstr (cond, 3, "sql.update")
	cond = cond and (" where "..cond) or ""
	return strformat ("update %s set %s%s", tabname,
		tabfullconcat (contents, '=', ',', nil, quote),
		cond)
end

---------------------------------------------------------------------
-- Builds a string with a DELETE command.
-- @param tabname String with table name.
-- @param cond String with where-clause (and following SQL text).
-- @return String with DELETE command.
---------------------------------------------------------------------
function delete (tabname, cond)
	check.str (tabname, 1, "sql.delete")
	check.optstr (cond, 2, "sql.delete")
	cond = cond and (" where "..cond) or ""
	return strformat ("delete from %s%s", tabname, cond)
end
