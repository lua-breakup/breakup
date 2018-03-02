local help = require"harmonize.util".help
local commands = {}

commands.__help = "Do not use this, unless you know what this does!"

commands.env = help("Displays the path and cpath.")(
	function(arg)
		print("Path: " .. package.path)
		print("CPath: " .. package.cpath)
	end
)

function commands.addpkg(arg)
	local cache = require"harmonize.storage.cache"
	if cache.containsPackage(arg[1]) then
		if not cache.hasRemote(arg[1], arg[2]) then
			cache.addRemote(arg[1], arg[2])
		end
		cache.update(arg[1], arg[2])
	else
		cache.clonepkg(arg[1], arg[2])
	end
	print("Updated " .. arg[1])
end

function commands.ref(arg)
	local cache = require"harmonize.storage.cache"
	cache.ref(arg[1], arg[2])
end

function commands.install(arg)
	local cache = require"harmonize.storage.cache"
	cache.install(arg[1])
	print("Installed " .. arg[1])
end

return commands
