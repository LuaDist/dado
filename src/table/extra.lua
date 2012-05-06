---------------------------------------------------------------------
-- Table manipulation and transformation functions.
--
-- @class module
-- @name table.extra
-- @release $Id: extra.lua,v 1.6 2011-03-25 21:43:19 tomas Exp $
---------------------------------------------------------------------

local assert, pairs, type = assert, pairs, type

local table   = require"table"
local strformat = require"string".format

module"table.extra"

---------------------------------------------------------------------
-- Builds a list of pairs field=value, separated by commas.
-- The '=' sign could be changed by the kvsep argument.
-- The ',' could also be changed by the pairssep argument.
-- Both the field and the value could be filtered by the kfilter and
--	vfilter respectivelly.
-- @param tab Table of field=value pairs.
-- @param kvsep String with key-value separator (default = '=').
-- @param pairssep String with pairs separator (default = ',').
-- @param kfilter Function to filter the keys (optional).
-- @param vfilter Function to filter the values (optional).
-- @return String with field=value pairs separated by ','.
---------------------------------------------------------------------
function fullconcat (tab, kvsep, pairssep, kfilter, vfilter)
	pairssep = pairssep or ','
	local formatstring = "%s"..(kvsep or '=').."%s"
	local l = {}
	local i = 0
	for key, val in pairs (tab) do
		i = i+1
		l[i] = strformat (formatstring,
			kfilter and kfilter(key) or key,
			vfilter and vfilter(val) or val)
	end
	table.sort (l)
	return table.concat (l, pairssep)
end

---------------------------------------------------------------------
-- Produces the same result as fullconcat, but it checks the arguments'
--	types.
-- @see fullconcat.
-- @param tab Table of field=value pairs.
-- @param kvsep String with key-value separator (default = '=').
-- @param pairssep String with pairs separator (default = ',').
-- @param kfilter Function to filter the keys (optional).
-- @param vfilter Function to filter the values (optional).
-- @return String with field=value pairs separated by ','.
---------------------------------------------------------------------
function pfullconcat (tab, kvsep, pairssep, kfilter, vfilter)
	local tt = type(tab)
	assert (tt == "table",
		"Bad argument #1 to 'pfullconcat' (table expected, got "..tt..")")
	local tkv = type(kvsep)
	assert (tkv == "nil" or tkv == "string" or tkv == "number",
		"Bad argument #2to 'pfullconcat' (string expected, got "..tkv..")")
	local tp = type(pairssep)
	assert (tp == "nil" or tp == "string" or tp == "number",
		"Bad argument #3 to 'pfullconcat' (string expected, got "..tp..")")
	local tkf = type(kfilter)
	assert (tkf == "nil" or tkf == "function",
		"Bad argument #4 to 'pfullconcat' (function expected, got "..tkf..")")
	local tkv = type(vfilter)
	assert (tkv == "nil" or tkv == "function",
		"Bad argument $5 to 'pfullconcat' (function expected, got "..tkv..")")
	pairssep = pairssep or ','
	local formatstring = "%s"..(kvsep or '=').."%s"
	local l = {}
	local i = 0
	for key, val in pairs (tab) do
		local tk = type(key)
		assert (tk == "string" or tk == "number",
			"Bad key type (string expected, got "..tk..")")
		local tv = type(val)
		assert (tv == "string" or tv == "number",
			"Bad value type on key "..key.." (string expected, got "..tv..")")
		i = i+1
		l[i] = strformat (formatstring,
			kfilter and kfilter(key) or key,
			vfilter and vfilter(val) or val)
	end
	table.sort (l)
	return table.concat (l, pairssep)
end

---------------------------------------------------------------------
-- Builds two lists, of keys and of values.
-- @param tab Table of key=value pairs.
-- @param ksep String with key separator (default = ',').
-- @param vsep String with value separator (default = ',').
-- @param kfilter Function to filter the keys (optional).
-- @param vfilter Function to filter the values (optional).
-- @return Two strings; the first with a list of the fields and the
--	second with a list of the values.
---------------------------------------------------------------------
function twostr (tab, ksep, vsep, kfilter, vfilter)
	ksep  = ksep or ','
	vsep  = vsep or ','
	local k, v = {}, {}
	local i = 0
	for key, val in pairs (tab) do
		i = i+1
		k[i] = kfilter and kfilter(key) or key
		v[i] = vfilter and vfilter(val) or val
	end
	return table.concat (k, ksep), table.concat (v, vsep)
end
