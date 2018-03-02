local util = require"harmonize.util"
local help = util.help
local config = require"harmonize.storage.config"

local commands = {}

local function setConfig(key, value)
	config.load()

	local p = util.split(key, "\\.")
	local currObj = config.config
	for k = 1, (#p - 1) do
		if type(currObj[p[k]]) ~= "table" then
			currObj[p[k]] = {}
		end
		currObj = currObj[p[k]]
	end
	currObj[p[#p]] = value
	config.save()
end

local function serializeTable(t, indent)
	local result = ""
	for k,v in util.pairsSorted(t) do
		if type(v) == "table" then
			result = result .. string.rep("\t", indent) .. k .. "\n" .. serializeTable(v, indent + 1) .. "\n"
		else
			result = result .. string.rep("\t", indent) .. k .. "\t" .. tostring(v) .. "\n"
		end
	end
	return result
end

commands.show = help("Display all configuration parameters.")(function(arg)
	config.load()
	print(serializeTable(config.config, 0))
end)

commands.set = {}

commands.set.__help = "Set config values."

commands.set.string = help("Set the provided key to the value\n\nUsage: config set dot.separated.key \"string_value\"")(function(arg)
	if #arg < 2 then return 2 end
	setConfig(arg[1], arg[2])
end)

commands.set.number = help("Set the provided key to the value\n\nUsage: config set dot.separated.key 100")(function(arg)
	if #arg < 2 then return 2 end
	setConfig(arg[1], tonumber(arg[1]))
end)

return commands