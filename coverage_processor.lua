local reporter = {}
local scanner = (require"luacov/reporter").LineScanner

function reporter.process(data)
	result = {}
	for name, r in pairs(data) do
		result[name] = reporter.process_file(name, r)
	end
	return result
end

function reporter.process_file(filename, result)
	if filename == nil then return nil end
	local file, err = io.open(filename)

	if not file then return nil end

	local s = scanner:new()
	local hits, misses = 0, 0
	local covered = {}
	local line_nr = 1

	while true do
		local line = file:read("*l")
		if not line then break end
		local always_excluded, excluded_when_not_hit = scanner:consume(line)
      	local hit = result[line_nr] or 0
		local included = not always_excluded and (not excluded_when_not_hit or hits ~= 0)
		if included then
			if hit == 0 then
				covered[line_nr] = false
				misses = misses + 1
			else
				covered[line_nr] = true
				hits = hits + 1
			end
		end
		line_nr = line_nr + 1
	end

	file:close()
	return { hits=hits, misses=misses, total=hits+misses, covered=covered }
end

return reporter