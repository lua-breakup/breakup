local paths = require"harmonize.storage.paths"
local util = require"harmonize.util"

local exports = {}

function exports.clonepkg(pkgname, upstream)
	if util.runCommand("git clone " .. upstream .. " " ..
			paths.packageCachePath(pkgname) .. " 2>&1")[3] ~= 0 then
		error("Failed to clone pkg")
	end

	if util.runCommand(
			"cd " .. paths.packageCachePath(pkgname) ..
			" && git remote rename origin " ..
			util.gitRemoteName(upstream) .. " 2>&1")[3] ~= 0 then
		error("Failed to rename remote")
	end
end

function exports.addRemote(pkgname, upstream)
	if util.runCommand("cd " .. paths.packageCachePath(pkgname) ..
			" && git remote add " .. util.gitRemoteName(upstream) ..
			" " .. upstream .. " 2>&1")[3] ~= 0 then
		error("Failed to add remote")
	end
end

function exports.update(pkgname, upstream)
	if util.runCommand("cd " .. paths.packageCachePath(pkgname) ..
			" && git pull " .. util.gitRemoteName(upstream) ..
			" 2>&1")[3] ~= 0 then
		error("Failed to update")
	end
end

function exports.hasRemote(pkgname, upstream)
	return util.runCommand(
			"cd " .. paths.packageCachePath(pkgname) ..
			"&& git remote show " .. util.gitRemoteName(upstream) ..
			" 2>&1")[3] == 0
end

function exports.containsPackage(pkgname)
	return util.runCommand("[ -e " .. paths.packageCachePath(pkgname) ..
			" ]")[3] == 0
end

function exports.ref(pkgname, ref)
	if util.runCommand("cd " .. paths.packageCachePath(pkgname) ..
			" && git checkout " .. ref .. " 2>&1")[3] ~= 0 then
		error("Failed to checkout")
	end
end

function exports.install(pkgname)
	if util.runCommand("cp -R " .. paths.packageCachePath(pkgname) ..
			"/" .. pkgname .. " " .. paths.root ..
			"/harmonize_modules 2>&1")[3] ~= 0 then
		error("Failed to copy package")
	end

	if util.runCommand("cp " .. paths.packageCachePath(pkgname) ..
			"/pkg.lua " .. paths.root .. "/harmonize_modules/"
			.. pkgname .. "/pkg.lua 2>&1")[3] ~= 0 then
		error("Failed to copy pkg.lua")
	end
end

return exports
