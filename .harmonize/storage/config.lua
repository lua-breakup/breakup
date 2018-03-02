local paths = require"harmonize.storage.paths"
local util = require"harmonize.util"

local exports = {}

exports.config = nil

function exports.load(force)
	if exports.config and not force then return end

	local file = io.open(paths.configFile)
	if not file then
		exports.config = {}
		return
	end

	local content = file:read("*all")
	file:close()
	exports.config = loadstring(content)()
end

function exports.save()
	local strep = "return " .. util.tostring(exports.config) .. "\n"
	local file = io.open(paths.configFile, "w")

	if not file then
		error("Failed to open file.")
	end

	file:write(strep)
	file:close()
end

return exports
