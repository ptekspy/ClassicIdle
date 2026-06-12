--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local PlayerTypes = require(ReplicatedStorage.Services.DataService.Types)
local WorkerTypes = require(ReplicatedStorage.Worker.Types)

local UnlockService = {}

function UnlockService.CanUseManualTree(_data: PlayerTypes.PlayerData): boolean
	return true
end

function UnlockService.CanUseManualRock(data: PlayerTypes.PlayerData): boolean
	return EconomyService.HasNPC(data, "Wood")
end

function UnlockService.CanUnlockConveyor1(data: PlayerTypes.PlayerData): boolean
	return EconomyService.HasNPC(data, "Stone")
end

function UnlockService.CanBuyStorageUpgrade(_data: PlayerTypes.PlayerData): boolean
	return true
end

function UnlockService.CanBuyNPCRole(data: PlayerTypes.PlayerData, role: WorkerTypes.Role): boolean
	if role == "Wood" then
		return true
	elseif role == "Stone" then
		return EconomyService.HasNPC(data, "Wood")
	end

	return false
end

return UnlockService
