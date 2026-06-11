--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Services.DataService.Types)

local Local = {
    WOOD_SELL_PRICE = 1,
    STONE_SELL_PRICE = 3,
    COAL_SELL_PRICE = 10,
    AUTO_CHOPPER_BASE_COST = 10,
    AUTO_MINER_BASE_COST = 25,
    AUTO_PROCESSOR_BASE_COST = 100,
    BASE_STORAGE_CAPACITY = 25,
    STORAGE_CAPACITY_PER_LEVEL = 25,
    STORAGE_UPGRADE_BASE_COST = 50,
    COAL_RECIPE_WOOD = 2,
    COAL_RECIPE_STONE = 1,
    COAL_RECIPE_OUTPUT = 1,
}

local EconomyService = {}

function EconomyService.GetAutoChopperCost(data: PlayerTypes.PlayerData): number
	return Local.AUTO_CHOPPER_BASE_COST * math.max(1, data.AutoChopperLevel + 1)
end

function EconomyService.GetAutoMinerCost(data: PlayerTypes.PlayerData): number
	return Local.AUTO_MINER_BASE_COST * math.max(1, data.AutoMinerLevel + 1)
end

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
	local capacity = EconomyService.GetStorageCapacity(data)
	local used = EconomyService.GetUsedStorage(data)

	return math.max(0, capacity - used)
end

function EconomyService.GetAcceptedResourceAmount(data: PlayerTypes.PlayerData, requestedAmount: number): number
	local remaining = EconomyService.GetRemainingStorage(data)

	return math.clamp(requestedAmount, 0, remaining)
end

function EconomyService.IsStorageFull(data: PlayerTypes.PlayerData): boolean
	return EconomyService.GetRemainingStorage(data) <= 0
end

function EconomyService.AddWood(data: PlayerTypes.PlayerData, amount: number): number
	local acceptedAmount = EconomyService.GetAcceptedResourceAmount(data, amount)

	if acceptedAmount <= 0 then
		return 0
	end

	data.Wood += acceptedAmount
	return acceptedAmount
end

function EconomyService.AddStone(data: PlayerTypes.PlayerData, amount: number): number
	local acceptedAmount = EconomyService.GetAcceptedResourceAmount(data, amount)

	if acceptedAmount <= 0 then
		return 0
	end

	data.Stone += acceptedAmount
	return acceptedAmount
end

function EconomyService.AddCoal(data: PlayerTypes.PlayerData, amount: number): number
	local acceptedAmount = EconomyService.GetAcceptedResourceAmount(data, amount)

	if acceptedAmount <= 0 then
		return 0
	end

	data.Coal += acceptedAmount
	return acceptedAmount
end

function EconomyService.CanProcessCoal(data: PlayerTypes.PlayerData): boolean
	return data.Wood >= Local.COAL_RECIPE_WOOD and data.Stone >= Local.COAL_RECIPE_STONE
end

function EconomyService.ProcessCoal(data: PlayerTypes.PlayerData): boolean
	if not EconomyService.CanProcessCoal(data) then
		return false
	end

	local acceptedAmount = EconomyService.GetAcceptedResourceAmount(data, Local.COAL_RECIPE_OUTPUT)

	if acceptedAmount < Local.COAL_RECIPE_OUTPUT then
		return false
	end

	data.Wood -= Local.COAL_RECIPE_WOOD
	data.Stone -= Local.COAL_RECIPE_STONE
	data.Coal += Local.COAL_RECIPE_OUTPUT

	return true
end

function EconomyService.GetCoalRecipeText(): string
	return `{Local.COAL_RECIPE_WOOD} Wood + {Local.COAL_RECIPE_STONE} Stone`
end

function EconomyService.SellAllWood(data: PlayerTypes.PlayerData): number
	local woodToSell = data.Wood

	if woodToSell <= 0 then
		return 0
	end

	local goldEarned = woodToSell * Local.WOOD_SELL_PRICE

	data.Wood = 0
	data.Gold += goldEarned

	return goldEarned
end

function EconomyService.SellAllStone(data: PlayerTypes.PlayerData): number
	local stoneToSell = data.Stone

	if stoneToSell <= 0 then
		return 0
	end

	local goldEarned = stoneToSell * Local.STONE_SELL_PRICE

	data.Stone = 0
	data.Gold += goldEarned

	return goldEarned
end

function EconomyService.SellAllCoal(data: PlayerTypes.PlayerData): number
	local coalToSell = data.Coal

	if coalToSell <= 0 then
		return 0
	end

	local goldEarned = coalToSell * Local.COAL_SELL_PRICE

	data.Coal = 0
	data.Gold += goldEarned

	return goldEarned
end

function EconomyService.BuyAutoChopper(data: PlayerTypes.PlayerData): boolean
	local cost = EconomyService.GetAutoChopperCost(data)

	if data.Gold < cost then
		return false
	end

	data.Gold -= cost
	data.AutoChopperLevel += 1

	return true
end

function EconomyService.BuyAutoMiner(data: PlayerTypes.PlayerData): boolean
	local cost = EconomyService.GetAutoMinerCost(data)

	if data.Gold < cost then
		return false
	end

	data.Gold -= cost
	data.AutoMinerLevel += 1

	return true
end

function EconomyService.BuyStorageUpgrade(data: PlayerTypes.PlayerData): boolean
	local cost = EconomyService.GetStorageUpgradeCost(data)

	if data.Gold < cost then
		return false
	end

	data.Gold -= cost
	data.StorageLevel += 1

	return true
end

function EconomyService.GetAutoProcessorCost(data: PlayerTypes.PlayerData): number
	return Local.AUTO_PROCESSOR_BASE_COST * math.max(1, data.AutoProcessorLevel + 1)
end

function EconomyService.BuyAutoProcessor(data: PlayerTypes.PlayerData): boolean
	local cost = EconomyService.GetAutoProcessorCost(data)

	if data.Gold < cost then
		return false
	end

	data.Gold -= cost
	data.AutoProcessorLevel += 1

	return true
end

return EconomyService
