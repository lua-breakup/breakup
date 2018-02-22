local function is_switch(argument)
    return string.sub(argument, 0, 2) == "--"
end

local function string_split(str, sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   str:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

local function switch_value(argument)
    return string_split(argument, '=')[2]
end

local function switch_name(argument)
    return string.sub(string_split(argument, '=')[1], 3)
end

local function argparse(arg)
	local args = {}
	for k,v in ipairs(arg) do
	    if switch_value(v) ~= nil then
	        args[switch_name(v)] = switch_value(v)
	    else
	        args[switch_name(v)] = true
	    end
	end
	return args
end

return {
	name='breakup',
	description='Breakup is an advanced testing framework for Lua.',
	authors={
		'Rolf van Kleef <breakup@rolfvankleef.nl>',
	},
	license='Apache 2.0',
	dependencies={},
	main='runner',
	scripts={
		test=function(...)
			local args = argparse({...})
			local runner = require"runner"
			if args.outputter then
		        runner.hooks = require ("outputters/"..args.outputter)
		    else
		        runner.hooks = require "outputters/default"
		    end
		    runner:add_suite("assertions_test")
		    local results = runner:run()
		    os.exit(#results.errors + #results.failed_suites)
		end,
	},
}