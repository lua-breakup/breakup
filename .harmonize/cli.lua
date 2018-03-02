if love then
    arg = {unpack(arg, 2)}
end

local pkgname = arg[1]
if pkgname == "" then
	if love then
		-- Use löve's shutdown hook to ensure proper cleanup of resources.
		love.event.quit()
		return
	end
	os.exit(0)
end
arg = {unpack(arg, 2)}

local old_require = require
require = function(mod)
	if mod == pkgname .. ".pkg" then
		return old_require"pkg"
	end
	return old_require(mod)
end

if love then
	love.event.quit((require"harmonize.commands").run(arg))
else
	os.exit((require"harmonize.commands").run(arg))
end
