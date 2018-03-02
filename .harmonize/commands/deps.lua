local pairsSorted = (require"harmonize.util").pairsSorted
local help = require"harmonize.util".help

local commands = {}

commands.__help = "Control and view dependencies."

commands.check = help("Print dependency information to stdout.")(function(arg)
	local pkg = require"pkg"
    local checkdeps = require"harmonize.checkdeps"
    local argparse = require"argparse.parse"
    local args = argparse(arg)
	checkdeps.check(pkg, args.dev)
end)

commands.lock = help("Create a lockfile from the currently installed packages.")(function(arg)
	local pkg = require"pkg"
    local checkdeps = require"harmonize.checkdeps"
    local argparse = require"argparse.parse"
    local args = argparse(arg)
    local deps = checkdeps.get(pkg, args.dev)

    local file = io.open("harmonize.lock", "w")

    if deps["harmonize"] == nil then
        file:write("harmonize@" .. (require"harmonize.pkg").version .. "\n")
    end

    for k,v in pairsSorted(deps) do
    	if v.version then file:write(k .. "@" .. v.version .. "\n") end
    end

    file:close()
end)

commands.tree = help("Print a DOT-compatible dependency tree to stdout.")(function(arg)
    local pkg = require"pkg"
    local checkdeps = require"harmonize.checkdeps"
    local argparse = require"argparse.parse"
    local args = argparse(arg)
    local deps = checkdeps.get(pkg, args.dev)

    print("digraph G{nodesep=0.6;")
    for k,v in pairsSorted(deps) do
        if not v.version then print(k .. "[label=\"" .. k .. " (Missing)\"]") end
        if v.err and v.version then print(k .. "[label=\"" .. k .. " (Wrong version)\"") end
        for _, req in ipairs(v.required_by) do
            local label = ""
            if req.dev then label = label .. "dev " end
            if req.optional then label = label .. "optional" end
            print(
                "\"" .. req.pkg.name .. (req.pkg.version and ("@" .. tostring(req.pkg.version)) or "") .. "\" -> \"" ..
                k .. (v.version and ("@" .. tostring(v.version)) or "") .. "\"[label=\"" .. label .. "\"]"
            )
        end
    end
    print("}")
end)

return commands