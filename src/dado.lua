--------------------------------------------------------------------------------
-- Dado is a set of facilities implemented over LuaSQL connection objects.
-- The module's goal is to simplify the most used database operations.
--
-- Version 1.4.2.
--
-- @class module
-- @name dado
-- @release $Id: dado.lua,v 1.17 2012/11/14 18:09:46 tomas Exp $
--------------------------------------------------------------------------------

local strformat = require"string".format
local sql       = require"dado.sql"

local error, pcall, require, setmetatable, tostring = error, pcall, require, setmetatable, tostring

--=-----------------------------------------------------------------------------
local _M = {
	_COPYRIGHT = "Copyright (C) 2012 PUC-Rio",
	_DESCRIPTION = "Dado is a set of facilities implemented over LuaSQL connection objects",
	_VERSION = "Dado 1.4.2",
}

--------------------------------------------------------------------------------
-- Executes a SQL statement raising an error if something goes wrong.
-- @param self Dado Object.
-- @param stmt String with SQL statement.
-- @return Cursor or number of rows affected by the command
--	(it never returns nil,errmsg).
--------------------------------------------------------------------------------
function _M.assertexec (self, stmt)
	local cur, msg = self.conn:execute (stmt)
	return cur or error (msg.." SQL = { "..stmt.." }", 2)
end

--------------------------------------------------------------------------------
-- Commits the current transaction.
-- @param self Dado Object.
--------------------------------------------------------------------------------
function _M.commit (self)
	return self.conn:commit ()
end

--------------------------------------------------------------------------------
-- Rolls back the current transaction.
-- @param self Dado Object.
--------------------------------------------------------------------------------
function _M.rollback (self)
	return self.conn:rollback ()
end

--------------------------------------------------------------------------------
-- Turn autocommit mode on or off.
-- @param self Dado Object.
-- @param bool Boolean indicating to turn autocommit on (true) or off (false).
--------------------------------------------------------------------------------
function _M.setautocommit (self, bool)
	return self.conn:setautocommit (bool)
end

--------------------------------------------------------------------------------
-- Obtains next value from a sequence.
-- @param self Dado Object.
-- @param seq String with sequence name (complete name or just the name of the
--	table).
-- @param field String (optional) with the name of the primary key associated
--	with the sequence.
-- @return String with next sequence value.
--------------------------------------------------------------------------------
function _M.nextval (self, seq, field)
	if field then
		seq = strformat ("%s_%s_seq", seq, field)
	end
	local cur = self:assertexec ("select nextval('"..seq.."')")
	return cur:fetch(), nil, cur:close()
end

--------------------------------------------------------------------------------
-- Deletes a row.
-- @param self Dado Object.
-- @param tabname String with table name.
-- @param cond String with where-clause (and following SQL text).
-- @see dado.sql.delete
-- @return Number of rows affected.
--------------------------------------------------------------------------------
function _M.delete (self, tabname, cond)
	return self:assertexec (sql.delete (tabname, cond))
end

--------------------------------------------------------------------------------
-- Inserts a new row.
-- @param self Dado Object.
-- @param tabname String with table name.
-- @param contents Table with field-value pairs.
-- @see dado.sql.insert
-- @return Number of rows affected.
--------------------------------------------------------------------------------
function _M.insert (self, tabname, contents)
	return self:assertexec (sql.insert (tabname, contents))
end

--------------------------------------------------------------------------------
-- Updates existing rows.
-- @param self Dado Object.
-- @param tabname String with table name.
-- @param contents Table with field-value pairs.
-- @param cond String with where-clause (and following SQL text).
-- @see dado.sql.update
-- @return Number of rows affected.
--------------------------------------------------------------------------------
function _M.update (self, tabname, contents, cond)
	return self:assertexec (sql.update (tabname, contents, cond))
end

--------------------------------------------------------------------------------
-- Retrieves rows.
-- Creates an iterator over the result of a query.
-- This iterator could be used in for-loops.
-- @param self Dado Object.
-- @param columns String with fields list.
-- @param tabname String with table name.
-- @param cond String with where-clause (and following SQL text).
-- @param extra String with extra SQL text (to be used when there is no
--	where-clause).
-- @param mode String indicating fetch mode
--	(this argument also indicates whether the function should return
--	a table or the values directly).
-- @see dado.sql.select
-- @return Iterator over the result set.
-- @return Cursor object (to allow explicit closing).
--------------------------------------------------------------------------------
function _M.select (self, columns, tabname, cond, extra, mode)
	local stmt = sql.select (columns, tabname, cond, extra)
	local cur = self:assertexec (stmt)
	return function ()
		-- This table must be created inside this function or it could
		-- make `selectall' to return the same row every time.
		local t
		if mode then t = {} end
		return cur:fetch (t, mode)
	end, cur
end

--------------------------------------------------------------------------------
-- Retrieves all rows.
-- @param self Dado Object.
-- @param columns String with fields list.
-- @param tabname String with table name.
-- @param cond String with where-clause (and following SQL text).
-- @param extra String with extra SQL text.
-- @param mode String indicating fetch mode (default == 'a').
-- @see dado.sql.select
-- @return Table with the entire result set.
--------------------------------------------------------------------------------
function _M.selectall (self, columns, tabname, cond, extra, mode)
	mode = mode or "a"
	local rs = {}
	local i = 0
	for row in self:select (columns, tabname, cond, extra, mode) do
		i = i+1
		rs[i] = row
	end
	return rs
end


local mt = { __index = _M, }

--------------------------------------------------------------------------------
-- Wraps a database connection into a connection object.
-- @param conn Object with LuaSQL database connection.
-- @param key String with the key to the database object in the cache.
-- @return Dado Connection.
--------------------------------------------------------------------------------
function _M.wrap_connection (conn, key)
	local obj = { conn = conn, key = key, }
	setmetatable (obj, mt)
	return obj
end

local cache = {}

local function makekey (dbname, dbuser, dbpass)
	return strformat ("%s-%s-%s", dbname, tostring(dbuser), tostring(dbpass))
end

--------------------------------------------------------------------------------
-- Tries to use a connection in the cache or opens a new one.
-- @param dbname String with database name.
-- @param dbuser String with database username (optional).
-- @param dbpass String with database user password (optional).
-- @param driver String with LuaSQL's driver (default = "postgres").
-- @return Connection.
--------------------------------------------------------------------------------
function _M.connect (dbname, dbuser, dbpass, driver, ...)
	driver = driver or "postgres"

	-- Creating new object
	local key = makekey (dbname, dbuser, dbpass)
	local conn = cache[key]
	if not conn then
		-- Opening database connection
		local ok, luasql = pcall (require, "luasql."..driver)
		if not ok then
			error ("Could not load LuaSQL driver `"..driver.."'. Maybe it is not installed properly.\nLuaSQL: "..tostring(luasql))
		end
		local env, err = luasql[driver] ()
		if not env then error (err, 2) end
		conn, err = env:connect (dbname, dbuser, dbpass, ...)
		if not conn then error (err, 2) end
		-- Storing connection on the cache
		cache[key] = conn
	end
	return _M.wrap_connection (conn, key)
end

--------------------------------------------------------------------------------
-- Closes the connection and invalidates the object.
-- @param self Dado Object.
--------------------------------------------------------------------------------
function _M.close (self)
	if self.key then
		cache[self.key] = nil
	end
	self.conn:close ()
	self.conn = nil
	setmetatable (self, nil)
end

--=-----------------------------------------------------------------------------
return _M
