--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local Types = require(script.Parent.Types)

local resources = {}
for _, resourceId in ResourceConfig.Order do
	resources[resourceId] = 0
end

local DEFAULT_DATA: Types.PlayerData = {
	DataVersion = 1,
	Gold = 0,
	Resources = resources,
	XP = 0,
	StorageLevel = 1,
	NPCs = {},
	Quest = {
		CurrentQuestId = "ManualWood1",
		CompletedQuestIds = {},
		CurrentProgress = 0,
	},
	Factory = {
		Inventory = {
			WorkerHome = 1,
		},
		PlacedItems = {},
	},
}

return DEFAULT_DATA
