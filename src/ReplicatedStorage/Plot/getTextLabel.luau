--!strict

local resolve = require(script.Parent.resolve)

local function getTextLabel(root: Instance, path: string): TextLabel
	local instance = resolve(root, path)

	if not instance:IsA("TextLabel") then
		error(`{root:GetFullName()}.{path} must be a TextLabel`)
	end

	return instance
end

return getTextLabel
