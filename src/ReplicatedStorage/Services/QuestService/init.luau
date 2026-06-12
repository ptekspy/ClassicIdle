--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Services.DataService)
local DisplayService = require(ReplicatedStorage.Services.DisplayService)
local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local QuestConfig = require(ReplicatedStorage.Quest.Config)
local QuestTypes = require(ReplicatedStorage.Quest.Types)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)
local ResourceConfig = require(ReplicatedStorage.Resource.Config)

local questUpdateEvent = RemoteManager.QuestUpdate :: RemoteEvent
local getQuestStateFunction = RemoteManager.GetQuestState :: RemoteFunction

local Local = {
	started = false,
}

local QuestService = {}

local function getStateProgress(data: any, objective: string): number
	if ResourceConfig.IsValid(objective) then
		return EconomyService.GetResourceAmount(data, objective)
	elseif objective == "Gold" then
		return data.Gold
	elseif objective == "StorageLevel" then
		return data.StorageLevel
	elseif objective == "WoodNPCCount" then
		return EconomyService.GetNPCCount(data, "Wood")
	elseif objective == "StoneNPCCount" then
		return EconomyService.GetNPCCount(data, "Stone")
	elseif objective == "CoalNPCCount" then
		return EconomyService.GetNPCCount(data, "Coal")
	elseif objective == "WoodNPCUpgradeLevel" then
		local highest = 0
		for _, npc in data.NPCs do
			if npc.Role == "Wood" then
				highest = math.max(highest, npc.SpeedLevel, npc.AmountLevel)
			end
		end
		return highest
	end

	local resourceId = string.match(objective, "^Resource:(.+)$")
	if resourceId and ResourceConfig.IsValid(resourceId) then
		return EconomyService.GetResourceAmount(data, resourceId)
	end
	local npcRole = string.match(objective, "^NPCCount:(.+)$")
	if npcRole then
		return EconomyService.GetNPCCount(data, npcRole)
	end

	local machinePart = string.match(objective, "^MachinePart:(.+)$")
	if machinePart and data.Machine and data.Machine.Parts[machinePart] then
		return if data.Machine.Parts[machinePart].Built then 1 else 0
	end

	local machineLevel = string.match(objective, "^MachineLevel:(.+)$")
	if machineLevel and data.Machine and data.Machine.Parts[machineLevel] then
		return data.Machine.Parts[machineLevel].Level
	end

	local factoryItem = string.match(objective, "^FactoryPlaced:(.+)$")
	if factoryItem then
		local count = 0
		for _, item in data.Factory.PlacedItems do
			if item.ItemId == factoryItem then
				count += 1
			end
		end
		return count
	end

	return 0
end

local function getProgress(data: any, definition: QuestTypes.QuestDefinition): number
	if definition.ObjectiveType == "State" then
		return getStateProgress(data, definition.Objective)
	end
	return data.Quest.CurrentProgress
end

local function getClientState(data: any): QuestTypes.ClientQuestState
	local definition = QuestConfig.Get(data.Quest.CurrentQuestId)
	if not definition then
		return {
			QuestId = nil,
			Title = nil,
			Description = nil,
			Progress = 0,
			RequiredAmount = 0,
			XPReward = 0,
			WayfindingType = nil,
			WayfindingValue = nil,
			Complete = true,
		}
	end

	return {
		QuestId = definition.QuestId,
		Title = definition.Title,
		Description = definition.Description,
		Progress = math.min(getProgress(data, definition), definition.RequiredAmount),
		RequiredAmount = definition.RequiredAmount,
		XPReward = definition.XPReward,
		WayfindingType = definition.WayfindingType,
		WayfindingValue = definition.WayfindingValue,
		Complete = false,
	}
end

local function publish(player: Player)
	local data = DataService.TryGet(player)
	if data then
		DisplayService.UpdateLeaderstats(player)
		questUpdateEvent:FireClient(player, getClientState(data))
	end
end

local function advanceSatisfied(player: Player)
	local data = DataService.TryGet(player)
	if not data then
		return
	end

	while true do
		local definition = QuestConfig.Get(data.Quest.CurrentQuestId)
		if not definition or getProgress(data, definition) < definition.RequiredAmount then
			break
		end

		if not data.Quest.CompletedQuestIds[definition.QuestId] then
			data.Quest.CompletedQuestIds[definition.QuestId] = true
			data.XP += definition.XPReward
		end

		local nextQuest = QuestConfig.GetNext(definition.QuestId)
		data.Quest.CurrentQuestId = if nextQuest then nextQuest.QuestId else nil
		data.Quest.CurrentProgress = 0
	end

	publish(player)
end

function QuestService.SetupPlayer(player: Player)
	local data = DataService.Get(player)
	if data.Quest.CurrentQuestId ~= nil and QuestConfig.Get(data.Quest.CurrentQuestId) == nil then
		data.Quest.CurrentQuestId = nil
	end

	if data.Quest.CurrentQuestId == nil then
		for _, definition in QuestConfig.Quests do
			if not data.Quest.CompletedQuestIds[definition.QuestId] then
				data.Quest.CurrentQuestId = definition.QuestId
				data.Quest.CurrentProgress = 0
				break
			end
		end
	end
	advanceSatisfied(player)
end

function QuestService.Notify(player: Player, objective: string, amount: number?)
	local data = DataService.TryGet(player)
	local definition = data and QuestConfig.Get(data.Quest.CurrentQuestId) or nil
	if not data or not definition then
		return
	end

	if definition.ObjectiveType == "Event" and definition.Objective == objective then
		data.Quest.CurrentProgress += math.max(0, amount or 1)
	end

	advanceSatisfied(player)
end

function QuestService.Refresh(player: Player)
	advanceSatisfied(player)
end

function QuestService.Start()
	if Local.started then
		return
	end
	Local.started = true

	getQuestStateFunction.OnServerInvoke = function(player)
		local data = DataService.TryGet(player)
		return if data then getClientState(data) else nil
	end
end

return QuestService
