local outputter = {}

local e = function(str)
	str = tostring(str)
	str = str:gsub("|", "||")
	str = str:gsub("'", "|'")
	str = str:gsub("\n", "|n")
	str = str:gsub("\r", "|r")
	str = str:gsub("%[", "|[")
	str = str:gsub("]", "|]")
	return str
end

outputter.started = function(results, suites)
	print("##teamcity[blockOpened name='Breakup']")
end

outputter.finished = function(results)
	print("##teamcity[blockClosed name='Breakup']")
end

outputter.suite_started = function(name, suite)
	print("##teamcity[testSuiteStarted name='" .. e(name) .. "']")
end

outputter.suite_load_error = function(name, err)
	print("##teamcity[buildProblem description='Suite " .. e(name) .. " failed to load.|n'" .. e(err) .. "]")
end

outputter.suite_finished = function(name, result)
	print("##teamcity[testSuiteFinished name='".. e(name) .. "']")
end

outputter.test_started = function(name, suite)
	print("##teamcity[testStarted name='" .. e(suite.name) .. "." .. e(name) .. "' captureStandardOutput='true']")
end

outputter.test_error = function(name, suite, err)
	if err.message ~= nil then
		trace = string.sub(e(debug.traceback("", 5)), 3)
		if err.expected ~= nil or err.got ~= nil then
			print("##teamcity[testFailed name='" .. e(suite.name) .. "." .. e(name) .. "' message='" .. e(err.message) .. "' details='" .. trace .. "', expected='" .. e(err.expected) .. "' actual='" .. e(err.got) .. "']")
		else
			print("##teamcity[testFailed name='" .. e(suite.name) .. "." .. e(name) .. "' message='" .. e(err.message) .. "' details='" .. trace .. "']")
		end
		return
	end
	trace = string.sub(e(debug.traceback("", 5)), 3)
  	print("##teamcity[testFailed name='" .. e(suite.name) .. "." .. e(name) .. "' message='" .. e(err) .. "' details='" .. trace .. "']")
end

outputter.test_finished = function(name, suite, result)
	print("##teamcity[testFinished name='" .. e(suite.name) .. "." .. e(name) .. "' duration='" .. e(result.duration) .. "']")
end

return outputter
