--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Services.DataService.Types)
local WorkerTypes = require(ReplicatedStorage.Worker.Types)

local Local = {
	WOOD_SELL_PRICE = 1,
	STONE_SELL_PRICE = 3,
	COAL_SELL_PRICE = 10,
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
	return data.Wood + data.Stone + data.Coal
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
	resourceType: WorkerTypes.ResourceType,
	amount: number
): number
	local acceptedAmount = EconomyService.GetAcceptedResourceAmount(data, amount)

	if acceptedAmount <= 0 then
		return 0
	end

	if resourceType == "Wood" then
		data.Wood += acceptedAmount
	elseif resourceType == "Stone" then
		data.Stone += acceptedAmount
	else
		data.Coal += acceptedAmount
	end

	return acceptedAmount
end

function EconomyService.RemoveResource(
	data: PlayerTypes.PlayerData,
	resourceType: WorkerTypes.ResourceType,
	amount: number
): boolean
	local available = if resourceType == "Wood"
		then data.Wood
		elseif resourceType == "Stone" then data.Stone
		else data.Coal

	if amount < 0 or available < amount then
		return false
	end

	if resourceType == "Wood" then
		data.Wood -= amount
	elseif resourceType == "Stone" then
		data.Stone -= amount
	else
		data.Coal -= amount
	end

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
	return data.Wood * Local.WOOD_SELL_PRICE + data.Stone * Local.STONE_SELL_PRICE + data.Coal * Local.COAL_SELL_PRICE
end

function EconomyService.SellAllWood(data: PlayerTypes.PlayerData): number
	local earned = data.Wood * Local.WOOD_SELL_PRICE
	data.Wood = 0
	data.Gold += earned
	return earned
end

function EconomyService.SellAllStone(data: PlayerTypes.PlayerData): number
	local earned = data.Stone * Local.STONE_SELL_PRICE
	data.Stone = 0
	data.Gold += earned
	return earned
end

function EconomyService.SellAllCoal(data: PlayerTypes.PlayerData): number
	local earned = data.Coal * Local.COAL_SELL_PRICE
	data.Coal = 0
	data.Gold += earned
	return earned
end

return EconomyService
