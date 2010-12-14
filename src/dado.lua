--------------------------------------------------------------------------------
-- Dado is a set of facilities implemented over LuaSQL connection objects.
-- The module's goal is to simplify the most used database operations.
--
-- @release $Id: dado.lua,v 1.4 2010-10-04 17:39:52 tomas Exp $
--------------------------------------------------------------------------------

local strformat = require"string".format
local sql       = require"dado.sql"

local error, pcall, require, setmetatable, tostring = error, pcall, require, setmetatable, tostring

module"dado"

_COPYRIGHT = "Copyright (C) 2010 PUC-Rio"
_DESCRIPTION = "Dado is a set of facilities implemented over LuaSQL connection objects"
_VERSION = "Dado 1.3.1"

local mt = { __index = _M, }

--------------------------------------------------------------------------------
-- Wraps a database connection into a connection object.
-- @param conn Object with LuaSQL database connection.
-- @param key String with the key to the database object in the cache.
-- @return Dado Connection.
--------------------------------------------------------------------------------
function wrap_connection (conn, key)
	local obj = { conn = conn, key = key, }
	setmetatable (obj, mt)
	return obj
end

local cache = {}

--
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
function connect (dbname, dbuser, dbpass, driver, ...)
	driver = driver or "postgres"

	-- Creating new object
	local key = makekey (dbname, dbuser, dbpass)
	local conn = cache[key]
	if not conn then
		-- Opening database connection
		local ok, luasql = pcall (require, "luasql."..driver)
		if not ok then
			error ("Could not load LuaSQL driver `"..driver.."'. Maybe it is not installed properly.\nLuaSQL: "..luasql)
		end
		local env, err = luasql[driver] ()
		if not env then error (err, 2) end
		conn, err = env:connect (dbname, dbuser, dbpass, ...)
		if not conn then error (err, 2) end
		-- Storing connection on the cache
		cache[key] = conn
	end
	return wrap_connection (conn, key)
end

--------------------------------------------------------------------------------
-- Closes the connection and invalidates the object.
--------------------------------------------------------------------------------
function close (self)
	if self.key then
		cache[self.key] = nil
	end
	self.conn:close ()
	self.conn = nil
	setmetatable (self, nil)
end

--------------------------------------------------------------------------------
-- Turn autocommit mode on or off.
--------------------------------------------------------------------------------
function setautocommit (self, bool)
	return self.conn:setautocommit (bool)
end

--------------------------------------------------------------------------------
-- Commits the current transaction.
--------------------------------------------------------------------------------
function commit (self)
	return self.conn:commit ()
end

--------------------------------------------------------------------------------
-- Rolls back the current transaction.
--------------------------------------------------------------------------------
function rollback (self)
	return self.conn:rollback ()
end

--------------------------------------------------------------------------------
-- Executes a SQL statement raising an error if something goes wrong.
-- @param stmt String with SQL statement.
-- @return Cursor or number of rows affected by the command
--	(it never returns nil,errmsg).
--------------------------------------------------------------------------------
function assertexec (self, stmt)
	local cur, msg = self.conn:execute (stmt)
	return cur or error (msg.." SQL = { "..stmt.." }", 2)
end

--------------------------------------------------------------------------------
-- Obtains next value from a sequence.
-- @param seq String with sequence name.
-- @param field String (optional) with the name of the field associated
--	with the sequence.
-- @return String with next sequence value.
--------------------------------------------------------------------------------
function nextval (self, seq, field)
	if field then
		seq = strformat ("%s_%s_seq", seq, field)
	end
	local cur = assertexec (self, "select nextval('"..seq.."')")
	return cur:fetch(), nil, cur:close()
end

--------------------------------------------------------------------------------
-- Deletes a row.
-- @param tabname String with table name.
-- @param cond String with where-clause (and following SQL text).
-- @see dado.sql.delete
-- @return Number of rows affected.
--------------------------------------------------------------------------------
function delete (self, tabname, cond)
	return assertexec (self, sql.delete (tabname, cond))
end

--------------------------------------------------------------------------------
-- Inserts a new row.
-- @param tabname String with table name.
-- @param contents Table with field-value pairs.
-- @see dado.sql.insert
-- @return Number of rows affected.
--------------------------------------------------------------------------------
function insert (self, tabname, contents)
	return assertexec (self, sql.insert (tabname, contents))
end

--------------------------------------------------------------------------------
-- Updates existing rows.
-- @param tabname String with table name.
-- @param contents Table with field-value pairs.
-- @param cond String with where-clause (and following SQL text).
-- @see dado.sql.update
-- @return Number of rows affected.
--------------------------------------------------------------------------------
function update (self, tabname, contents, cond)
	return assertexec (self, sql.update (tabname, contents, cond))
end

--------------------------------------------------------------------------------
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
-- @return Cursor object (to allow explicit closing).
--------------------------------------------------------------------------------
function select (self, columns, tabname, cond, extra, mode)
	local stmt = sql.select (columns, tabname, cond, extra)
	local cur = assertexec (self, stmt)
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
-- @param tabname String with table name.
-- @param columns String with fields list.
-- @param cond String with where-clause (and following SQL text).
-- @param extra String with extra SQL text.
-- @see dado.sql.select
-- @return Table with the entire result set.
--------------------------------------------------------------------------------
function selectall (self, columns, tabname, cond, extra)
	local rs = {}
	local i = 0
	for row in select (self, columns, tabname, cond, extra, "a") do
		i = i+1
		rs[i] = row
	end
	return rs
end
