--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileStoreTypes = require(ReplicatedStorage.Packages.ProfileStore.Types)
local ReplicaServerTypes = require(ReplicatedStorage.Packages.Replica.Server.Types)


export type SessionState = "Loading" | "Loaded" | "LoadFailed"

export type PlayerData = {
	Gold: number,
	Wood: number,
	Stone: number,
	Coal: number,
	AutoChopperLevel: number,
	AutoMinerLevel: number,
	AutoProcessorLevel: number,
	StorageLevel: number,
}

export type PlayerProfile = ProfileStoreTypes.Profile<PlayerData>
export type PlayerDataReplica = ReplicaServerTypes.Replica & {
	Data: PlayerData,
}

return {}