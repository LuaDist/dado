#!/usr/local/bin/lua5.1
---------------------------------------------------------------------
-- Remove usage of module `check'.
--
-- @release $Id: rm_check.lua,v 1.5 2007/07/20 19:51:12 tomas Exp $
---------------------------------------------------------------------

function remove_check (file)
	-- loads content
	local fh, err = assert (io.open (file))
	if not fh then
		print ("[ERROR] "..err)
		return
	end
	local tudo = fh:read ("*a")
	fh:close ()
	local n1, n2
	-- removes references to check library and functions
	tudo, n1 = string.gsub (tudo, '[^\n]*require%s*%(?"check"%)?\r?\n', '')
	tudo, n2 = string.gsub (tudo, '[\t ]*check%.[^\n]*\n', '')
	if n1 > 0 or n2 > 0 then
		-- saves new file
		local fh = assert (io.open (file, "w+"))
		fh:write (tudo)
		fh:close ()
	end
end

if not next (arg, nil) then
	print"rm_check [arquivos]"
	return
end

for _, file in ipairs (arg) do
	remove_check (file)
end
