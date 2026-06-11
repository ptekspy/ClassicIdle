--!strict

local function resolve(root: Instance, path: string): Instance
	local current = root

	for segment in string.gmatch(path, "[^%.]+") do
		local child = current:FindFirstChild(segment)

		if not child then
			error(`{root:GetFullName()} must contain {path}`)
		end

		current = child
	end

	return current
end

return resolve
