--!strict

local resolve = require(script.Parent.resolve)

local function getModel(root: Instance, path: string): Model
	local instance = resolve(root, path)

	if not instance:IsA("Model") then
		error(`{root:GetFullName()}.{path} must be a Model`)
	end

	return instance
end

return getModel
