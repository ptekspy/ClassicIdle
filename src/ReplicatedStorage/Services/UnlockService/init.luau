--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local PlayerTypes = require(ReplicatedStorage.Services.DataService.Types)
local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local WorkerTypes = require(ReplicatedStorage.Worker.Types)

local UnlockService = {}

function UnlockService.CanUseManualTree(_data: PlayerTypes.PlayerData): boolean
	return true
end

function UnlockService.CanUseManualRock(data: PlayerTypes.PlayerData): boolean
	return EconomyService.HasNPC(data, "Wood")
end

function UnlockService.CanCollectResource(data: PlayerTypes.PlayerData, resourceType: string): boolean
	local definition = ResourceConfig.Get(resourceType)
	if not definition or not definition.ManualCollection.Enabled then
		return false
	end
	local unlock = definition.ManualCollection.Unlock
	if not unlock then
		return true
	end
	local requiredRole = string.match(unlock, "^RequiresWorker:(.+)$")
	return requiredRole ~= nil and EconomyService.HasNPC(data, requiredRole)
end

function UnlockService.CanUnlockConveyor1(data: PlayerTypes.PlayerData): boolean
	return EconomyService.HasNPC(data, "Stone")
end

function UnlockService.CanBuyStorageUpgrade(_data: PlayerTypes.PlayerData): boolean
	return true
end

function UnlockService.CanBuyNPCRole(data: PlayerTypes.PlayerData, role: WorkerTypes.Role): boolean
	local definition = ResourceConfig.Get(role)
	local worker = definition and definition.Worker
	if not worker then
		return false
	end
	if not worker.Unlock then
		return true
	end
	local requiredRole = string.match(worker.Unlock, "^RequiresWorker:(.+)$")
	if requiredRole then
		return EconomyService.HasNPC(data, requiredRole)
	end
	local requiredItem = string.match(worker.Unlock, "^RequiresFactoryItem:(.+)$")
	if requiredItem then
		for _, item in data.Factory.PlacedItems do
			if item.ItemId == requiredItem then
				return true
			end
		end
	end
	return false
end

return UnlockService
