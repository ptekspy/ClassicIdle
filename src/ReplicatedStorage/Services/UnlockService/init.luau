--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Services.DataService.Types)

local Local = {}
local UnlockService = {}

function UnlockService.CanUseManualTree(_data: PlayerTypes.PlayerData): boolean
	return true
end

function UnlockService.CanBuyAutoChopper(_data: PlayerTypes.PlayerData): boolean
	return true
end

function UnlockService.CanUseManualRock(data: PlayerTypes.PlayerData): boolean
	return data.AutoChopperLevel >= 1
end

function UnlockService.CanBuyAutoMiner(data: PlayerTypes.PlayerData): boolean
	return data.AutoChopperLevel >= 1
end

function UnlockService.CanBuyStorageUpgrade(_data: PlayerTypes.PlayerData): boolean
	return true
end

function UnlockService.CanBuyAutoProcessor(data: PlayerTypes.PlayerData): boolean
	return data.AutoMinerLevel >= 1
end

function UnlockService.CanUseCoalProcessor(data: PlayerTypes.PlayerData): boolean
	return data.AutoMinerLevel >= 1
end

return UnlockService