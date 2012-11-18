#!/usr/local/bin/lua

local dado = require"dado"
local dbname = arg[1] or "luasql-test"
local user = arg[2]
local pass = arg[3]
local driver = arg[4]

db = dado.connect (dbname, user, pass, driver)
assert (type(db) == "table", "Nao consegui criar a conexao")
assert (type(db.conn) == "userdata")
assert (string.find (tostring(db.conn), "connection"))
local mt = getmetatable(db)
assert (type(mt) == "table")
assert (type(mt.__index) == "table")
assert (mt.__index.select)
io.write"."

-- Teste de encerramento e reabertura da conexao
db2 = dado.connect (dbname, user, pass, driver)
assert (db.conn == db2.conn)
db:close()
assert (db.conn == nil)
db2 = dado.connect (dbname, user, pass, driver)
assert (db2.conn)
db = dado.connect (dbname, user, pass, driver)
io.write"."

-- Elimina a tabela de teste
db.conn:execute ("drop table tabela")
io.write"."

-- Criando a tabela de teste
assert (db:assertexec ([[
create table tabela (
	chave integer,
	campo1 varchar(10),
	campo2 varchar(10),
	data   date,
	primary key (chave)
)]]))
io.write"."

-- Dados para o teste
dados = {
	{ campo1 = "val1", campo2 = "val21", },
	{ campo1 = "val2", campo2 = "val22", },
	{ campo1 = "val3", campo2 = "val32", },
}

-- Preenchendo a tabela
for indice, registro in ipairs(dados) do
	assert (false == pcall (db.insert, db, "tabela", registro))
	registro.chave = indice
    assert (1 == db:insert ("tabela", registro))
end
io.write"."

-- Consulta
local contador = 0
local select_iter, cur = db:select ("campo1, campo2", "tabela", "chave >= 1")
assert (type(select_iter) == "function")
assert (cur, "Select didn't returned a cursor")
assert (tostring(cur):find"ursor", "Select didn't returned a cursor object ("..tostring(cur)..")")
for campo1, campo2 in select_iter do
	contador = contador + 1
	assert (campo1 == dados[contador].campo1)
	assert (campo2 == dados[contador].campo2)
end
cur:close()
io.write"."

-- Teste de valores especiais para datas
local n = #dados + 1
db:insert ("tabela", {
	campo1 = "val"..n,
	chave = n,
	data = "(CURRENT_TIMESTAMP)",
})
io.write"."

-- Redefinindo a `assertexec'
local log_table = {}
local lc = 0
local function log (s) lc = lc+1 log_table[lc] = s end
local old_assertexec = assert(dado.assertexec, "Cannot find function `assertexec'.  Maybe this is a version mistaken!")
dado.assertexec = function (self, stmt)
	log (stmt)
	return old_assertexec (self, stmt)
end
assert (log_table[1] == nil)
assert (db:select ("*", "tabela")())
assert (log_table[1] == "select * from tabela", ">>"..tostring(log_table[1]))
io.write"."

-- Wrapping an already open connection
local luasql = require("luasql."..driver)
driver = driver or "postgres"
local env = luasql[driver]()
local conn = env:connect(dbname, user, pass)
local new_db = dado.wrap_connection(conn)
io.write"."

assert (type(new_db) == "table", "Nao consegui criar a conexao")
assert (type(new_db.conn) == "userdata")
assert (string.find (tostring(new_db.conn), "connection"))
local mt = getmetatable(new_db)
assert (type(mt) == "table")
assert (type(mt.__index) == "table")
assert (mt.__index == dado)
io.write"."

new_db:close()
assert (new_db.conn == nil)
io.write"."

print" Ok!"
