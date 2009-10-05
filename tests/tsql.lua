#!/usr/local/bin/lua5.1

local sql = require"dado.sql"

-- assert
assert (sql.escape([[a'b]], "'") == [[a\'b]])
assert (sql.escape([[a'b]], "'") == [[a\'b]])

-- quote
assert (sql.quote([[a'b]]) == [['a\'b']])
assert (sql.quote([[a\'b]]) == [['a\\\'b']])
assert (sql.quote([[\'b\']]) == [['\\\'b\\\'']])

-- select
assert (sql.select("a", "t") == "select a from t")
assert (sql.select("a", "t", "w") == "select a from t where w")
assert (sql.select("a", "t", nil, "e") == "select a from t e")
assert (sql.select("a", "t", "w", "e") == "select a from t where w e")

-- insert
assert (sql.insert("t", { a = 1 }) == "insert into t (a) values ('1')")
local stmt = sql.insert("t", { a = 1, b = "qw" })
assert (stmt == "insert into t (a,b) values ('1','qw')" or
        stmt == "insert into t (b,a) values ('qw','1')")

-- update
assert (sql.update("t", { a = 1 }) == "update t set a='1'")
local stmt = sql.update("t", { a = 1, b = "qw" })
assert (stmt == "update t set a='1',b='qw'")
--assert (stmt == "update t set a='1',b='qw'" or
        --stmt == "update t set b='qw',a='1'")

-- delete
assert (sql.delete("t") == "delete from t")
assert (sql.delete("t", "a=1") == "delete from t where a=1")

print"Ok!"
