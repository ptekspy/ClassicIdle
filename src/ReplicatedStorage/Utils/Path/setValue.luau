local SplitPath = require(script.Parent.SplitPath)

local function SetValue(source: any, path: string, value: any): ()
	local parts = SplitPath(path)
	local current = source

	for i = 1, #parts - 1 do
		local key = parts[i]

		if type(current[key]) ~= "table" then
			current[key] = {}
		end

		current = current[key]
	end

	local finalKey = parts[#parts]
	current[finalKey] = value
end

return SetValue
