local SplitPath = require(script.Parent.SplitPath)

local function GetValue(source: any, path: string): any
	local current = source

	for _, key in ipairs(SplitPath(path)) do
		if type(current) ~= "table" then
			return nil
		end

		current = current[key]

		if current == nil then
			return nil
		end
	end

	return current
end

return GetValue
