--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileStoreTypes = require(ReplicatedStorage.Packages.ProfileStore.Types)
local ReplicaServerTypes = require(ReplicatedStorage.Packages.Replica.Server.Types)
local WorkerTypes = require(ReplicatedStorage.Worker.Types)
local FactoryTypes = require(ReplicatedStorage.Factory.Types)
local QuestTypes = require(ReplicatedStorage.Quest.Types)
local ResourceTypes = require(ReplicatedStorage.Resource.Types)

export type SessionState = "Loading" | "Loaded" | "LoadFailed"

export type PlayerData = {
	DataVersion: number,
	Gold: number,
	Resources: { [ResourceTypes.ResourceId]: number },
	XP: number,
	StorageLevel: number,
	NPCs: { [string]: WorkerTypes.NPCData },
	Factory: FactoryTypes.FactoryData,
	Quest: QuestTypes.QuestData,
}

export type PlayerProfile = ProfileStoreTypes.Profile<PlayerData>
export type PlayerDataReplica = ReplicaServerTypes.Replica & {
	Data: PlayerData,
}

return {}
