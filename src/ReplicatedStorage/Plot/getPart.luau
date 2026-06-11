--!strict

local resolve = require(script.Parent.resolve)

local function getPart(root: Instance, path: string): BasePart
	local instance = resolve(root, path)

	if not instance:IsA("BasePart") then
		error(`{root:GetFullName()}.{path} must be a BasePart`)
	end

	return instance
end

return getPart
