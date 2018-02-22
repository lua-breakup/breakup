local function cm(expected, got, prefix, postfix)
	local output = "Expected "
	if prefix ~= nil then
		output = output .. tostring(prefix)
	end
	if type(expected) == "string" then
		output = output .. "\""
	end
	output = output .. tostring(expected)
	if type(expected) == "string" then
		output = output .. "\""
	end
	if postfix ~= nil then
		output = output .. tostring(postfix)
	end
	output = output .. " but got "
	if type(got) == "string" then
		output = output .. "\""
	end
	output = output .. tostring(got)
	if type(got) == "string" then
		output = output .. "\""
	end
	output = output .. "."
	return output
end

local function error_table(expected, got, msg)
	return {
		expected = expected,
		got = got,
		message = msg or cm(expected, got, nil, nil)
	}
end

local function error_table_adv(expected, got, msg, prefix, postfix)
	if prefix == nil and postfix == nil then
		return {
			expected = expected,
			got = got,
			message = msg or cm(expected, got, prefix, postfix)
		}
	else
		if prefix == nil then prefix = "" end
		if postfix == nil then postfix = "" end
		return {
			expected = tostring(prefix) .. tostring(expected) .. tostring(postfix),
			got = got,
			message = msg or cm(expected, got, prefix, postfix)
		}
	end
end

local function tol_or_msg(t, m)
	if not t and not m then
		return 0, nil
	elseif type(t) == "string" then
		return 0, t
	elseif type(t) == "number" then
		return t, m
	else
		error("Neither a numeric tolerance nor string")
	end
end

local function table_size(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local assertions = {}

function assertions.assert_true(got, msg)
	if got ~= true then
		error(error_table(true, got, msg))
	end
end

function assertions.assert_false(got, msg)
	if got ~= false then
		error(error_table(false, got, msg))
	end
end

function assertions.assert_nil(got, msg)
	if got ~= nil then
		error(error_table(nil, got, msg))
	end
end

function assertions.assert_equal(exp, got, tol, msg)
	tol, msg = tol_or_msg(tol, msg)
	if tol ~= 0 and type(exp) == 'number' and type(got) == 'number' and math.abs(exp - got) <= tol then
		return
	elseif exp == got then
		return
	end
	if type(exp) == "number" and type(got) == "number" then
		error(error_table_adv(exp, got, msg, nil, " +/- " .. tostring(tol)))
	else
		error(error_table(exp, got, msg))
	end
end

function assertions.assert_gt(lim, val, msg)
	if type(lim) ~= "number" or type(val) ~= "number" then
		error(error_table_adv("number", type(val), msg, "type ", nil))
	end
	if not (val > lim) then
		error(error_table_adv(lim, val, msg, "> ", nil))
	end
end

function assertions.assert_gte(lim, val, msg)
	if type(lim) ~= "number" or type(val) ~= "number" then
		error(error_table_adv("number", type(val), msg, "type ", nil))
	end
	if not (val >= lim) then
		error(error_table_adv(lim, val, msg, ">= ", nil))
	end
end

function assertions.assert_lt(lim, val, msg)
	if type(lim) ~= "number" or type(val) ~= "number" then
		error(error_table_adv("number", type(val), msg, "type ", nil))
	end
	if not (val < lim) then
		error(error_table_adv(lim, val, msg, "< ", nil))
	end
end

function assertions.assert_lte(lim, val, msg)
	if type(lim) ~= "number" or type(val) ~= "number" then
		error(error_table_adv("number", type(val), msg, "type ", nil))
	end
	if not (val <= lim) then
		error(error_table_adv(lim, val, msg, "<= ", nil))
	end
end

function assertions.assert_len(len, val, msg)
	if type(val) == 'string' or type(val) == 'table' then
		if #val ~= len then
			error(error_table_adv(len, #val, msg, "length "))
		end
		return
	end
	error(error_table_adv("string or table", type(val), msg, "type ", nil))
end

function assertions.assert_map_size(len, val, msg)
	if type(val) ~= 'table'  then
		error(error_table_adv("table", type(val), msg, "type ", nil))
	end
	if table_size(val) ~= len then
		error(error_table_adv(len, table_size(val), msg, "size "))
	end
end

function assertions.assert_match(pat, s, msg)
	if type(s) ~= "string" or not s:match(pat) then
		error(error_table_adv(pat, s, msg, "string matching ", nil))
	end
end

function assertions.assert_error(f, msg)
	ok, err = pcall(f)
	if err == nil then
		error({
			expected = "an error",
			got = "no error",
			message = msg or "Expected an error, but got none"
		})
	end
	return err
end

function assertions.fail(msg)
	error({
		message = msg
	})
end

return assertions
