--!strict

local resolve = require(script.Parent.resolve)

local function getBillboardGui(root: Instance, path: string): BillboardGui
	local instance = resolve(root, path)

	if not instance:IsA("BillboardGui") then
		error(`{root:GetFullName()}.{path} must be a BillboardGui`)
	end

	return instance
end

return getBillboardGui
