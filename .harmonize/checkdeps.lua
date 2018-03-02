local sysdep_defs_base = {
	lua=function()
		return _VERSION:sub(5)
	end,
	git=function()
		local handle = io.popen("git --version")
		local result = handle:read("*l")
		return result:sub(13)
	end,
}

local function string_split(pString, pPattern)
	local Table = {}
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(Table,cap)
		end
		last_end = e+1
		s, e, cap = pString:find(fpat, last_end)
	end
	if last_end <= #pString then
		cap = pString:sub(last_end)
		table.insert(Table, cap)
	end
	return Table
end

local function chd(pkglist, deps, required_by, found, results, optional, dev, devenv)
	if not deps then return {} end
	local results = results or {}
	local found = found or {}
	local result = {
		missing={},
		wrong_version={},
		present={},
	}
	for k,v in pairs(deps) do
		local version
		if pkglist[k] then
			version = pkglist[k].version
			pkglist[k].required_by[#pkglist[k].required_by + 1] = {
				pkg = required_by,
				version = v,
				optional = optional,
				dev = dev,
			}
			pkglist[k].dev = dev and pkglist[k].dev
		else
			local ok, dep = pcall(require, k .. ".pkg")
			pkglist[k] = {
				required_by = {
					{pkg = required_by, version = v, required = required, optional = optional},
				},
				dev = dev,
				optional = optional,
				err = false
			}
			if ok then
				version = dep.version
				pkglist[k].version = version
				pkglist[k].err = pkglist[k].err or version == nil

				chd(pkglist, dep.dependencies, dep, found, results, false, false, devenv)
				chd(pkglist, dep.devDependencies, dep, found, results, false, true, devenv)
				chd(pkglist, dep.recommendedDependencies, dep, found, results, true, false, devenv)
			else
				local sysdep_def = (required_by.sysdep_defs or {})[k]
				local ver
				if sysdep_def then
					ver = sysdep_def()
				elseif sysdep_defs_base[k] then
					ver = sysdep_defs_base[k]()
				end
				if ver then
					if type(ver) == 'boolean' then
						if ver then
							version = "?"
							pkglist[k].version = "?"
							pkglist[k].err = false
						else
							version = "X"
							pkglist[k].version = "X"
							pkglist[k].err = not optional and (not dev or (dev and devenv))
						end
					else
						version = ver
						pkglist[k].version = ver
						pkglist[k].err = false
					end
				else
					pkglist[k].err = not optional and (not dev or (dev and devenv))
				end
			end
		end

		if version and version ~= "?" and version ~= "X" then
			local versions = require"harmonize.versions"
			local constraints = {}
			for _, constr in pairs(string_split(v, ",")) do
				ctrs, err = versions.parse_constraint(constr)
				constraints[#constraints + 1] = ctrs
			end
			if versions.match_constraints(versions.parse_version(version), constraints) then
				pkglist[k].err = pkglist[k].err or false
				result.present[#result.present + 1] = {
					name=k,
					required_version=v,
					version=version,
					optional=optional,
					dev=dev,
				}
			else
				pkglist[k].err = pkglist[k].err or not optional and (not dev or (dev and devenv))
				result.wrong_version[#result.wrong_version + 1] = {
					name=k,
					required_version=v,
					version=version,
					optional=optional,
					dev=dev,
				}
			end
		elseif version and version == "?" then
			pkglist[k].err = pkglist[k].err or false
			result.present[#result.present + 1] = {
				name=k,
				required_version=v,
				version=version,
				optional=optional,
				dev=dev,
			}
		elseif version and version == "X" then
			pkglist[k].err = pkglist[k].err or (not optional and (not dev or (dev and devenv)))
			result.missing[#result.missing + 1] = {
				name=k,
				required_version=v,
				version=version,
				optional=optional,
				dev=dev,
			}
		else
			pkglist[k].err = pkglist[k].err or (not optional and (not dev or (dev and devenv)))
			result.missing[#result.missing + 1] = {
				name=k,
				required_version=v,
				optional=optional,
				dev=dev,
			}
		end
	end
	if results[required_by] then
		for k, v  in pairs(result) do
			for _, dep in pairs(v) do
				results[required_by][k][#results[required_by][k] + 1] = dep
			end
		end
	else
		results[required_by] = result
	end
	return results
end

local exports = {}

function exports.get(pkg, dev)
	local found = {}
	local results = {}
	local deps = {}
	chd(deps, pkg.dependencies, pkg, found, results, false, false, dev)
	chd(deps, pkg.devDependencies, pkg, found, results, false, true, dev)
	chd(deps, pkg.recommendedDependencies, pkg, found, results, true, false, dev)

	return deps, results
end

function exports.check(pkg, dev)
	local deps = exports.get(pkg, dev)
	local pairsSorted = (require"harmonize.util").pairsSorted

	for k, v in pairsSorted(deps) do
		local ostr = k
		local required = (not v.optional) and ((not v.dev) or args.dev)
		if v.version then ostr = ostr .. "@" .. v.version end
		ostr = ostr .. "\t"
		if v.version == nil then
			if required then ostr = ostr .. " MISSING" else ostr = ostr .. " missing optional" end
			if v.dev and required then ostr = ostr .. " DEV" elseif v.dev then ostr = ostr .. " dev" end
		elseif v.err then
			ostr = ostr .. " VERSION MISMATCH"
		end
		ostr = ostr .. " package required by:"
		for _, pkg in pairsSorted(v.required_by) do
			ostr = ostr .. " " .. pkg.pkg.name .. ","
		end
		ostr = ostr:sub(1, -2)
		print(ostr)
	end
end


return exports
