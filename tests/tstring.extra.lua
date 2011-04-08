#!/usr/local/bin/lua

local str = require"string.extra"

local t = str.toarray"a b c"
assert(t[1] == "a")
assert(t[2] == "b")
assert(t[3] == "c")
t = str.toarray ("d e", " ", t)
assert(t[1] == "a")
assert(t[2] == "b")
assert(t[3] == "c")
assert(t[4] == "d")
assert(t[5] == "e")

local t = str.torecord"a b c"
assert(t.a == 1)
assert(t.b == 3)
assert(t.c == 5)
t = str.torecord ("d e", " ", t)
assert(t.a == 1)
assert(t.b == 3)
assert(t.c == 5)
assert(t.d == 1)
assert(t.e == 3)

local n = { "n1", "n2", "n3", "n4", }
local t = {}
local i = 0
str.split ('a;b;"c;d";e', function (s)
	i = i+1
	t[i] = s
	t[n[i]] = s
end)
for i = 1, #n do
	assert(t[i] == t[n[i]])
end
assert(t[1] == "a")
assert(t[2] == "b")
assert(t[3] == "c;d")
assert(t[4] == "e")

print"Ok!"
