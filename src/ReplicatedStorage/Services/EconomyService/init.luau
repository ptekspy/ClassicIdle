--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Services.DataService.Types)
local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local ResourceTypes = require(ReplicatedStorage.Resource.Types)
local WorkerTypes = require(ReplicatedStorage.Worker.Types)

local Local = {
	BASE_STORAGE_CAPACITY = 25,
	STORAGE_CAPACITY_PER_LEVEL = 25,
	STORAGE_UPGRADE_BASE_COST = 50,
}

local EconomyService = {}

function EconomyService.GetStorageUpgradeCost(data: PlayerTypes.PlayerData): number
	return Local.STORAGE_UPGRADE_BASE_COST * data.StorageLevel
end

function EconomyService.GetStorageCapacity(data: PlayerTypes.PlayerData): number
	return Local.BASE_STORAGE_CAPACITY + ((data.StorageLevel - 1) * Local.STORAGE_CAPACITY_PER_LEVEL)
end

function EconomyService.GetUsedStorage(data: PlayerTypes.PlayerData): number
	local total = 0
	for _, amount in data.Resources do
		total += math.max(0, amount)
	end
	return total
end

function EconomyService.GetRemainingStorage(data: PlayerTypes.PlayerData): number
	return math.max(0, EconomyService.GetStorageCapacity(data) - EconomyService.GetUsedStorage(data))
end

function EconomyService.GetAcceptedResourceAmount(data: PlayerTypes.PlayerData, requestedAmount: number): number
	return math.clamp(requestedAmount, 0, EconomyService.GetRemainingStorage(data))
end

function EconomyService.IsStorageFull(data: PlayerTypes.PlayerData): boolean
	return EconomyService.GetRemainingStorage(data) <= 0
end

function EconomyService.AddResource(
	data: PlayerTypes.PlayerData,
	resourceType: ResourceTypes.ResourceId,
	amount: number
): number
	if not ResourceConfig.IsValid(resourceType) then
		return 0
	end
	local acceptedAmount = EconomyService.GetAcceptedResourceAmount(data, amount)

	if acceptedAmount <= 0 then
		return 0
	end

	data.Resources[resourceType] = (data.Resources[resourceType] or 0) + acceptedAmount

	return acceptedAmount
end

function EconomyService.RemoveResource(
	data: PlayerTypes.PlayerData,
	resourceType: ResourceTypes.ResourceId,
	amount: number
): boolean
	if not ResourceConfig.IsValid(resourceType) then
		return false
	end
	local available = data.Resources[resourceType] or 0

	if amount < 0 or available < amount then
		return false
	end

	data.Resources[resourceType] = available - amount

	return true
end

function EconomyService.AddWood(data: PlayerTypes.PlayerData, amount: number): number
	return EconomyService.AddResource(data, "Wood", amount)
end

function EconomyService.AddStone(data: PlayerTypes.PlayerData, amount: number): number
	return EconomyService.AddResource(data, "Stone", amount)
end

function EconomyService.AddCoal(data: PlayerTypes.PlayerData, amount: number): number
	return EconomyService.AddResource(data, "Coal", amount)
end

function EconomyService.GetResourceAmount(data: PlayerTypes.PlayerData, resourceType: ResourceTypes.ResourceId): number
	return data.Resources[resourceType] or 0
end

function EconomyService.GetNPCCount(data: PlayerTypes.PlayerData, role: WorkerTypes.Role?): number
	local count = 0

	for _, npc in data.NPCs do
		if role == nil or npc.Role == role then
			count += 1
		end
	end

	return count
end

function EconomyService.HasNPC(data: PlayerTypes.PlayerData, role: WorkerTypes.Role): boolean
	return EconomyService.GetNPCCount(data, role) > 0
end

function EconomyService.GetNPCPurchaseCost(data: PlayerTypes.PlayerData, role: WorkerTypes.Role): number
	local WorkerConfig = require(ReplicatedStorage.Worker.Config)
	return WorkerConfig.Roles[role].BaseCost * (EconomyService.GetNPCCount(data, role) + 1)
end

function EconomyService.GetNPCUpgradeCost(npc: WorkerTypes.NPCData, upgradeType: WorkerTypes.UpgradeType): number
	local WorkerConfig = require(ReplicatedStorage.Worker.Config)
	local level = if upgradeType == "Speed" then npc.SpeedLevel else npc.AmountLevel
	return WorkerConfig.Roles[npc.Role].BaseCost * level
end

function EconomyService.GetNPCSpeed(npc: WorkerTypes.NPCData): number
	return 10 + ((npc.SpeedLevel - 1) * 2)
end

function EconomyService.GetNPCAmount(npc: WorkerTypes.NPCData): number
	return math.max(1, npc.AmountLevel)
end

function EconomyService.TrySpendGold(data: PlayerTypes.PlayerData, amount: number): boolean
	if amount < 0 or data.Gold < amount then
		return false
	end

	data.Gold -= amount
	return true
end

function EconomyService.BuyStorageUpgrade(data: PlayerTypes.PlayerData): boolean
	local cost = EconomyService.GetStorageUpgradeCost(data)

	if not EconomyService.TrySpendGold(data, cost) then
		return false
	end

	data.StorageLevel += 1
	return true
end

function EconomyService.GetTotalSellValue(data: PlayerTypes.PlayerData): number
	local total = 0
	for resourceId, amount in data.Resources do
		local definition = ResourceConfig.Get(resourceId)
		if definition then
			total += amount * definition.SellPrice
		end
	end
	return total
end

function EconomyService.SellResource(data: PlayerTypes.PlayerData, resourceType: ResourceTypes.ResourceId): number
	local definition = ResourceConfig.Get(resourceType)
	if not definition then
		return 0
	end
	local earned = (data.Resources[resourceType] or 0) * definition.SellPrice
	data.Resources[resourceType] = 0
	data.Gold += earned
	return earned
end

function EconomyService.SellAllResources(data: PlayerTypes.PlayerData): (number, { [ResourceTypes.ResourceId]: number })
	local total = 0
	local sold = {} :: { [ResourceTypes.ResourceId]: number }
	for _, resourceId in ResourceConfig.Order do
		local amount = data.Resources[resourceId] or 0
		if amount > 0 then
			sold[resourceId] = amount
			total += EconomyService.SellResource(data, resourceId)
		end
	end
	return total, sold
end

function EconomyService.SellAllWood(data: PlayerTypes.PlayerData): number
	return EconomyService.SellResource(data, "Wood")
end

function EconomyService.SellAllStone(data: PlayerTypes.PlayerData): number
	return EconomyService.SellResource(data, "Stone")
end

function EconomyService.SellAllCoal(data: PlayerTypes.PlayerData): number
	return EconomyService.SellResource(data, "Coal")
end

return EconomyService
