--!strict

local function getPart(partName: string, parent: Instance): BasePart
	local part = parent:WaitForChild(partName)

	if not part:IsA("BasePart") then
		error(`{partName} must be a BasePart`)
	end

	return part
end

return getPart
