function makePath(...)
	return table.concat({...}, package.config:sub(1,1))
end

local funcs = {}

function funcs.storageDir()
	if os.getenv("HOME") then
		return makePath(os.getenv("HOME"), ".local", "harmonize")
	elseif os.getenv("APPDATA") then
		return makePath(os.getenv("APPDATA"), "local", "harmonize")
	else
		error("Failed to determine storage directory on this system.")
	end
end

function funcs.packageCacheDir()
	return makePath(funcs.storageDir(), "cache")
end

function funcs.packageCachePath()
	return function(pkgname)
		return funcs.packageCacheDir() .. "/" .. pkgname
	end
end

function funcs.configFile()
	return makePath(funcs.storageDir(), "config.lua")
end

function funcs.root()
	return "."
end

return setmetatable({},
	{
		__index = function(self, key)
			if funcs[key] then
				return funcs[key]()
			end
		end
	})
