--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getPart = require(ReplicatedStorage.Utils.Getters.getPart)

local function getPrompt(partName: string, parent: Instance): ProximityPrompt
	local part = getPart(partName, parent)
	local prompt = part:WaitForChild("ProximityPrompt")

	if not prompt:IsA("ProximityPrompt") then
		error(`{partName} does not contain a ProximityPrompt`)
	end

	return prompt
end

return getPrompt
