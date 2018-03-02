local util = require"harmonize.util"

local registry = {}
registry.commands = {
	__help = "Usage: help <command...>",

	dep = require"harmonize.commands.deps",
	run = require"harmonize.commands.run",
	debug = require"harmonize.commands.debug",
	config = require"harmonize.commands.config",
	help = require"harmonize.commands.help",
}

local function get(commands, args)
	if #args == 0 then
		print("Failed to parse command line.")
		return 1
	end
	local command = commands[args[1]] 
	local command_str = args[1]
	args = {unpack(args, 2)}
	if util.calleable(command) then
		return command(args)
	elseif type(command) == "table" then
		return get(command, args)
	else
		print("Couldn't find command.")
		return 2
	end
end

function registry.run(args)
	return get(registry.commands, args)
end

return registry
