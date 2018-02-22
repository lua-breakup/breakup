local has_socket, socket = pcall(require, "socket")
local has_posix, posix = pcall(require, "posix")
local has_luacov, luacov = pcall(require, "luacov.runner")
local now = 
    has_socket and socket.gettime or
    has_posix and posix.gettimeofday and
        function ()
            local s, us = posix.gettimeofday()
            return s + us / 1000000
        end or
    function () return os.time(os.date("!*t")) end

local framework = {}

framework.hooks = {}
framework.suites = {}
framework.failed_suites = {}

local function to_suite(path, mod)
    if type(mod) ~= "table" then
        error("Module is not a table")
    end
    local suite = {}
    suite.name = path
    suite.tests = {}

    for name, value in pairs(mod) do
        if type(value) == "function" then
            if name == "setup" then
                suite.setup = value
            elseif name=="teardown" then
                suite.teardown = value
            else
                suite.tests[name] = function(...) value(mod, ...) end
            end
        end
    end
    return suite
end

function concat_tables(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function framework:scan_test_files()

end

function framework:create_error_handler(name, suite)
  return function (e)
    if self.hooks.test_error then self.hooks.test_error(name, suite, e) end
    if type(e) == "table" and e.msg ~= nil then
        return e
    end
    local msg = tostring(e)
    local traceback = string.sub(debug.traceback("", 3), 2)
    return { message=msg, details=traceback }
  end
end

function framework:add_suite(path)
    xpcall(function()
        mod, e = require(path)
        self.suites[path] = to_suite(path, mod)
    end, function(err)
        if self.hooks.suite_load_error then self.hooks.suite_load_error(path, err) end
        self.failed_suites[#self.failed_suites+1] = path
    end)
end

function framework:run_test(suite, name, test)
    if self.hooks.test_started then self.hooks.test_started(name, suite) end
    local result = {}
    result.start_time = now()

    local handler = self:create_error_handler(name, suite)
    local ok = true
    if suite.setup then
        ok, err = xpcall(suite.setup, handler)
    end
    if ok then
        ok, err = xpcall(test, handler)
    end
    if suite.teardown then
        if ok then
            ok, err = xpcall(suite.teardown, handler)
        else
            pcall(suite.teardown)
        end
    end

    result.ok = ok
    result.err = err
    result.end_time = now()
    result.duration = result.end_time - result.start_time
    if self.hooks.test_finished then self.hooks.test_finished(name, suite, result) end
    return result
end

function framework:run_suite(name, suite)
    if self.hooks.suite_started then self.hooks.suite_started(name, suite) end
    local result = {}
    result.start_time = now()
    result.tests = {}
    result.errors = {}

    for tname, test in pairs(suite.tests) do
        result.tests[tname] = self:run_test(suite, tname, test)
        if not result.tests[tname].ok then
            result.errors[#result.errors + 1] = tname
        end
    end

    result.end_time = now()
    result.duration = result.end_time - result.start_time
    if self.hooks.suite_finished then self.hooks.suite_finished(name, result) end
    return result
end

function framework:run(coverage)
    if self.hooks.started then self.hooks.started(self.suites, self.failed_suites) end
    self.coverage = (coverage and has_luacov and true) or false
    local result = {}
    result.start_time = now()
    result.suites = {}
    result.tests = {}
    result.errors = {}
    result.loaded_suites = self.suites
    result.failed_suites = self.failed_suites

    if self.coverage then
        if type(coverage) == 'string' then
            luacov.load_config({statsfile=coverage})
        end
        luacov.init()
    end
    for sname, suite in pairs(self.suites) do
        result.suites[sname] = self:run_suite(sname, suite)
        for k,v in pairs(result.suites[sname].tests) do
            result.tests[sname .. "." .. k] = v
        end
        concat_tables(result.errors, result.suites[sname].errors)
    end

    result.end_time = now()
    result.duration = result.end_time - result.start_time
    if self.coverage then
        result.coverage = luacov.data
    end
    if self.hooks.finished then self.hooks.finished(result) end
    return result
end

return framework