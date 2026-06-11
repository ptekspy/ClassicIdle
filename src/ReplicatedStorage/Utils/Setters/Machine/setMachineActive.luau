--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getPart = require(ReplicatedStorage.Utils.Getters.getPart)

local function setMachineActive(
	machineName: string,
	isActive: boolean,
	plot: Model
)
	local machine = getPart(machineName, plot)

	if isActive then
		machine.Transparency = 0
		machine.CanCollide = true
	else
		machine.Transparency = 0.55
		machine.CanCollide = false
	end
end

return setMachineActive
