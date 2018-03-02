local help = require"harmonize.util".help

local function table_size(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

return help("Run the command in pkg.lua.\n\nUsage: run <command> <args...>")(function(arg)
	local pkg = require"pkg"
    if type(pkg.scripts) ~= 'table' then
        print("Package doesn't have any scripts.")
        return 2
    end
    if not arg[1] or not pkg.scripts[arg[1]] then
        if table_size(pkg.scripts) == 0 then
            print("Package doesn't have any scripts.")
            return 2
        end
        print("Please specify run valid script.")
        return 1
    end

    if type(pkg.scripts[arg[1]]) == 'function' then
        return pkg.scripts[arg[1]](unpack(arg, 2))
    end
end)