#!/usr/local/bin/lua5.1

--local arg = { ... }
local path = arg[0]:sub (1, arg[0]:find"/")

io.write("string.extra ... ")
assert(loadfile(path.."tstring.extra.lua"))()
io.write("table.extra ... ")
assert(loadfile(path.."ttable.extra.lua"))()
io.write("sql ... ")
assert(loadfile(path.."tsql.lua"))()
io.write("dado ... ")
assert(loadfile(path.."tdado.lua"))()
io.write("dbobj ... ")
assert(loadfile(path.."tdbobj.lua"))()
