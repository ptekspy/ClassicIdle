local function SplitPath(path: string): { string }
	local parts = {}

	for part in string.gmatch(path, "[^%.]+") do
		table.insert(parts, part)
	end

	return parts
end

return SplitPath
