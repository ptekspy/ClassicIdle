--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)
local UIState = require(script.Parent.Parent.UI.UIState)

local menuEvent = RemoteManager.MachineMenu :: RemoteEvent
local requestEvent = RemoteManager.MachineRequest :: RemoteEvent
local started = false

local MachineController = {}

local function close()
	UIState.Set("machineMenu", nil)
end

local function show(payload: any)
	if typeof(payload) ~= "table" or typeof(payload.PartId) ~= "string" then
		return
	end

	UIState.Set("machineMenu", {
		payload = payload,
		onClose = close,
		onCollect = function(partId: string)
			requestEvent:FireServer("Collect", partId)
		end,
		onUpgrade = function(partId: string, upgradeType: string)
			requestEvent:FireServer("Upgrade", partId, upgradeType)
		end,
	})
end

function MachineController.Start()
	if started then
		return
	end
	started = true
	menuEvent.OnClientEvent:Connect(show)
end

return MachineController