--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileStoreTypes = require(ReplicatedStorage.Packages.ProfileStore.Types)
local ReplicaServerTypes = require(ReplicatedStorage.Packages.Replica.Server.Types)
local WorkerTypes = require(ReplicatedStorage.Worker.Types)


export type SessionState = "Loading" | "Loaded" | "LoadFailed"

export type PlayerData = {
	Gold: number,
	Wood: number,
	Stone: number,
	Coal: number,
	StorageLevel: number,
	NPCs: { [string]: WorkerTypes.NPCData },
}

export type PlayerProfile = ProfileStoreTypes.Profile<PlayerData>
export type PlayerDataReplica = ReplicaServerTypes.Replica & {
	Data: PlayerData,
}

return {}
