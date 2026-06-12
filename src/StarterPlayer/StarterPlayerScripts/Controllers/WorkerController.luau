--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)
local UIState = require(script.Parent.Parent.UI.UIState)

local menuEvent = RemoteManager.WorkerMenu :: RemoteEvent
local requestEvent = RemoteManager.WorkerRequest :: RemoteEvent
local started = false

local WorkerController = {}

local function close()
	UIState.Set("workerMenu", nil)
end

local function showMenu(payload: any)
	if typeof(payload) ~= "table" or typeof(payload.Kind) ~= "string" then
		return
	end

	UIState.Set("workerMenu", {
		payload = payload,
		onClose = close,
		onBuy = function(role: string)
			requestEvent:FireServer("Buy", role)
		end,
		onUpgrade = function(npcId: string, upgradeType: string)
			requestEvent:FireServer("Upgrade", npcId, upgradeType)
		end,
	})
end

function WorkerController.Start()
	if started then
		return
	end
	started = true
	menuEvent.OnClientEvent:Connect(showMenu)
end

return WorkerController