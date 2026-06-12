--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileStoreTypes = require(ReplicatedStorage.Packages.ProfileStore.Types)
local ReplicaServerTypes = require(ReplicatedStorage.Packages.Replica.Server.Types)
local WorkerTypes = require(ReplicatedStorage.Worker.Types)
local MachineTypes = require(ReplicatedStorage.Machine.Types)
local QuestTypes = require(ReplicatedStorage.Quest.Types)

export type SessionState = "Loading" | "Loaded" | "LoadFailed"

export type PlayerData = {
	Gold: number,
	Wood: number,
	Stone: number,
	Coal: number,
	XP: number,
	StorageLevel: number,
	NPCs: { [string]: WorkerTypes.NPCData },
	Machine: MachineTypes.MachineData,
	Quest: QuestTypes.QuestData,
}

export type PlayerProfile = ProfileStoreTypes.Profile<PlayerData>
export type PlayerDataReplica = ReplicaServerTypes.Replica & {
	Data: PlayerData,
}

return {}
