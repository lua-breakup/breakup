local outputter = {}

local function tl(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

outputter.started = function(results, suites)
	print("Started LuaTest tests")
end

outputter.finished = function(results)
	print("Finished LuaTest tests, taking " .. tostring(results.duration * 1000) .. "ms")
	print(tostring(tl(results.tests) - tl(results.errors)) .. " out of " .. tostring(tl(results.tests)) .. " tests succeeded")
	if tl(results.errors) > 0 then
		print(string.char(27) .. "[31m" .. tostring(tl(results.errors)) .. " tests failed!" .. string.char(27) .. "[0m")
	end
	if tl(results.failed_suites) > 0 then
		print(string.char(27) .. "[31m" .. tostring(tl(results.failed_suites)) .. " suites failed to load!" .. string.char(27) .. "[0m")
	end
end

outputter.suite_started = function(name, suite)
	print("Starting suite " .. name)
end

outputter.suite_load_error = function(name, err)
	print(string.char(27) .. "[31m" .. "Failed to load suite " .. name .. ".\n" .. tostring(err) .. string.char(27) .. "[0m")
end

outputter.suite_finished = function(name, results)
	print("Finished suite " .. name .. ", taking " .. tostring(results.duration * 1000) .. "ms")
end

outputter.test_started = function(name, suite)
	print("Starting test " .. suite.name .. "." .. name)
end

outputter.test_error = function(name, suite, err)
	if err.message ~= nil then
		r = debug.traceback("", 5)
		trace = string.sub(tostring(r), 2)
		print(string.char(27) .. "[31m" .. suite.name .. "." .. name .. " failed: " .. tostring(err.message) .. "\n" .. trace .. string.char(27) .. "[0m")
		return
	end
	r = debug.traceback("", 4)
	trace = string.sub(tostring(r), 2)
  	print(string.char(27) .. "[31m" .. suite.name .. "." .. name .. " failed: " .. tostring(err) .. "\n" .. tostring(trace) .. string.char(27) .. "[0m")
end

outputter.test_finished = function(name, suite, result)
	print("Finished test " .. suite.name .. "." .. name .. ", taking " .. tostring(result.duration * 1000) .. "ms")
end

return outputter