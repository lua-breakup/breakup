local util = {}

function util.pairsSorted(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
        table.sort(a, f)
        local i = 0
        local iter = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

local function val_to_str(v, indent)
    if type(v) == "string" then
        v = string.gsub(v, "\n", "\\n")
        if string.match(string.gsub(v, "[^'\"]", ""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v, '"', '\\"') .. '"'
    elseif type(v) == "table" then
        return util.tostring(v, indent)
    else
        return tostring(v)
    end
end

local function key_to_str(k)
    if type(k) == "string" and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "[" .. val_to_str(k) .. "]"
    end
end

function util.tostring(tbl, indent)
    if not indent then indent = 1 end
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert(result, string.rep("\t", indent) .. val_to_str(v, indent + 1))
        done[k] = true
    end
    for k, v in util.pairsSorted(tbl) do
        if not done[k] then
            table.insert(result, string.rep("\t", indent) .. key_to_str(k) .. "=" .. val_to_str(v, indent + 1))
        end
    end
    return "{\n" .. table.concat(result, ",\n") .. "\n" .. string.rep("\t", indent - 1) .. "}"
end

function util.split(str,sep)
    local array = {}
    local reg = string.format("([^%s]+)",sep)
    for mem in string.gmatch(str,reg) do
        array[#array + 1] = mem
    end
    return array
end

function util.calleable(func)
    return type(func) == "function" or
          (type(func) == "table" and
            getmetatable(func) and
            util.calleable(getmetatable(func).__call))
end

function util.help(helptext)
    return function(func)
        return setmetatable({__help=helptext}, {__call=function(s, ...) func(...) end})
    end
end

function util.tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function util.gitRemoteName(remote)
    remote = string.gsub(remote, ":", "/")

    local count = 1
    while count ~= 0 do
        remote, count = string.gsub(remote, "//", "/")
    end

    while remote[0] and remote[0] == "/" do
        remote = string.sub(remote, 2)
    end

    return remote
end

function util.runCommand(command)
    local handle = io.popen(command)
    local output = handle:read("*all")
    local result = {handle:close()}
    if result[3] ~= 0 then
        print(output)
    end
    return result
end

return util
