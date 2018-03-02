local help = require"harmonize.util".help
local util = require"harmonize.util"

local function show_help(arg, cur, depth)
	if not depth then depth = 0 end
	local command = cur[arg[1]] 
	local arg_len = #arg
	arg = {unpack(arg, 2)}

	if util.calleable(command) then
		if type(command) == "table" then
			if command.__help then
				print(command.__help)
				return
			end
		end
		print("Command has no help.")
	elseif type(command) == "table" then
		show_help(arg, command)
	elseif arg_len == 0 then
		if cur.__help then
			if depth == 0 then
				print(cur.__help .. "\n")
			else
				io.stdout:write(util.split(cur.__help, "\n")[1])
			end
		end
		if depth == 0 then print("Available commands:") else print("") end
		if util.tableLength(cur) > (cur.__help and 1 or 0) then print() end
		for k, v in util.pairsSorted(cur) do
			if k ~= "__help" then
				if type(v) == "table" then
					io.stdout:write(string.rep("\t", depth) .. k .. "\t")
					show_help({}, cur[k], depth + 1)
				elseif v.__help then
					io.stdout:write(string.rep("\t", depth) .. k .. "\t" .. v.__help)
				else
					io.stdout:write(string.rep("\t", depth) .. k)
				end
			end
		end
		if util.tableLength(cur) > (cur.__help and 1 or 0) then print() end
	else
		print("Couldn't find command.")
		return 2
	end
end

return help("Shows help for command, if provided.\n\nUsage: help <command>")(function(arg)
	local commands = require"harmonize.commands".commands
	show_help(arg, commands)
end)