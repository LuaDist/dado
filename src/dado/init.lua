---------------------------------------------------------------------
-- Dado is a set of facilities implemented over LuaSQL connection objects.
-- This module's goal is to simplify the most used database operations.
--
-- @release $Id: init.lua,v 1.5 2008/04/20 21:27:42 tomas Exp $
---------------------------------------------------------------------

-- Stores all dependencies in locals
local strformat = require"string".format
local check     = require"check"
local sql       = require"dado.sql"

local error, require, setmetatable, tostring = error, require, setmetatable, tostring

module"dado"

_COPYRIGHT = "Copyright (C) 2008 PUC-Rio"
_DESCRIPTION = "Dado is a set of facilities implemented over LuaSQL connection objects"
_VERSION = "Dado 1.0.0"

local cache = {}
local mt = { __index = _M, }

--
local function makekey (dbname, dbuser, dbpass)
	return strformat ("%s-%s-%s", dbname, tostring(dbuser), tostring(dbpass))
end

---------------------------------------------------------------------
-- Tries to use a connection in the cache or opens a new one.
-- @param dbname String with database name.
-- @param dbuser String with database username (optional).
-- @param dbpass String with database user password (optional).
-- @param driver String with LuaSQL's driver (default = "postgres").
-- @return Connection.
---------------------------------------------------------------------
function connect (dbname, dbuser, dbpass, driver, ...)
	check.str (dbname, 1, "connect")
	check.optstr (dbuser, 2, "connect")
	check.optstr (dbpass, 3, "connect")
	check.optstr (driver, 4, "connect")
	driver = driver or "postgres"

	-- Creating new object
	local key = makekey (dbname, dbuser, dbpass)
	local obj = { conn = cache[key], key = key, }
	setmetatable (obj, mt)
	if not obj.conn then
		-- Opening database connection
		local luasql = require("luasql."..driver)
		local env, err = luasql[driver] ()
		if not env then error (err, 2) end
		obj.conn, err = env:connect (dbname, dbuser, dbpass, ...)
		if not obj.conn then error (err, 2) end
		-- Storing connection on the cache
		cache[key] = obj.conn
	end
	return obj
end

---------------------------------------------------------------------
-- Closes the connection and invalidates the object.
---------------------------------------------------------------------
function close (self)
	cache[self.key] = nil
	self.conn:close ()
	self.conn = nil
	setmetatable (self, nil)
end

---------------------------------------------------------------------
-- Turn autocommit mode on or off.
---------------------------------------------------------------------
function setautocommit (self, bool)
	return self.conn:setautocommit (bool)
end

---------------------------------------------------------------------
-- Commits the current transaction.
---------------------------------------------------------------------
function commit (self)
	return self.conn:commit ()
end

---------------------------------------------------------------------
-- Rolls back the current transaction.
---------------------------------------------------------------------
function rollback (self)
	return self.conn:rollback ()
end

---------------------------------------------------------------------
-- Executes a SQL statement raising an error if something goes wrong.
-- @param stmt String with SQL statement.
-- @return Cursor or number of rows affected by the command
--	(it never returns nil,errmsg).
---------------------------------------------------------------------
function assertexec (self, stmt)
	check.str (stmt, 1)
	local cur, msg = self.conn:execute (stmt)
	return cur or error (msg.." SQL = { "..stmt.." }", 2)
end

---------------------------------------------------------------------
-- Obtains next value from a sequence.
-- @param seq String with sequence name.
-- @param field String (optional) with the name of the field associated
--	with the sequence.
-- @return String with next sequence value.
---------------------------------------------------------------------
function nextval (self, seq, field)
	check.str (seq, 1, "db.nextval")
	check.optstr (field, 2, "db.nextval")
	if field then
		seq = strformat ("%s_%s_seq", seq, field)
	end
	local cur = assertexec (self, "select nextval('"..seq.."')")
	return cur:fetch(), nil, cur:close()
end

---------------------------------------------------------------------
-- Deletes a row.
-- @param tabname String with table name.
-- @param cond String with where-clause (and following SQL text).
-- @see dado.sql.delete
-- @return Number of rows affected.
---------------------------------------------------------------------
function delete (self, tabname, cond)
	return assertexec (self, sql.delete (tabname, cond))
end

---------------------------------------------------------------------
-- Inserts a new row.
-- @param tabname String with table name.
-- @param contents Table with field-value pairs.
-- @see dado.sql.insert
-- @return Number of rows affected.
---------------------------------------------------------------------
function insert (self, tabname, contents)
	return assertexec (self, sql.insert (tabname, contents))
end

---------------------------------------------------------------------
-- Updates existing rows.
-- @param tabname String with table name.
-- @param contents Table with field-value pairs.
-- @param cond String with where-clause (and following SQL text).
-- @see dado.sql.update
-- @return Number of rows affected.
---------------------------------------------------------------------
function update (self, tabname, contents, cond)
	return assertexec (self, sql.update (tabname, contents, cond))
end

---------------------------------------------------------------------
-- Retrieves rows.
-- Creates an iterator over the result of a query.
-- This iterator could be used in for-loops.
-- @param tabname String with table name.
-- @param columns String with fields list.
-- @param cond String with where-clause (and following SQL text).
-- @param extra String with extra SQL text (to be used when there is no
--	where-clause).
-- @param mode String indicating fetch mode
--	(this argument also indicates whether the function should return
--	a table or the values directly).
-- @see dado.sql.select
-- @return Iterator over the result set.
---------------------------------------------------------------------
function select (self, columns, tabname, cond, extra, mode)
	check.optstr (mode, 5)
	local stmt = sql.select (columns, tabname, cond, extra)
	local cur = assertexec (self, stmt)
	return function ()
		-- This table must be created inside this function or it could
		-- make `selectall' to return the same row every time.
		local t
		if mode then t = {} end
		return cur:fetch (t, mode)
	end
end

---------------------------------------------------------------------
-- Retrieves all rows.
-- @param tabname String with table name.
-- @param columns String with fields list.
-- @param cond String with where-clause (and following SQL text).
-- @param extra String with extra SQL text.
-- @see dado.sql.select
-- @return Table with the entire result set.
---------------------------------------------------------------------
function selectall (self, columns, tabname, cond, extra)
	local rs = {}
	local i = 0
	for row in select (self, columns, tabname, cond, extra, "a") do
		i = i+1
		rs[i] = row
	end
	return rs
end
