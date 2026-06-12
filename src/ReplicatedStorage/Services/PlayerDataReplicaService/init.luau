--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Services.DataService)
local Replica = require(ReplicatedStorage.Packages.Replica.Server)

local PLAYER_DATA_TOKEN = Replica.Token("PlayerData")
local replicas = {} :: { [Player]: any }

local PlayerDataReplicaService = {}

local function deepCopy(value: any): any
	if typeof(value) ~= "table" then
		return value
	end

	local result = {}
	for key, child in value do
		result[deepCopy(key)] = deepCopy(child)
	end
	return result
end

local function snapshot(player: Player): any
	return deepCopy(DataService.Get(player))
end

function PlayerDataReplicaService.Create(player: Player)
	if replicas[player] then
		return
	end

	local replica = Replica.New({
		Token = PLAYER_DATA_TOKEN,
		Tags = { UserId = player.UserId },
		Data = snapshot(player),
	})

	replicas[player] = replica
	if Replica.ReadyPlayers[player] then
		replica:Subscribe(player)
	end
end

function PlayerDataReplicaService.Sync(player: Player)
	local replica = replicas[player]
	local data = DataService.TryGet(player)
	if not replica or not data then
		return
	end

	replica:SetValues({}, deepCopy(data))
end

function PlayerDataReplicaService.Destroy(player: Player)
	local replica = replicas[player]
	replicas[player] = nil
	if replica then
		replica:Destroy()
	end
end

Replica.NewReadyPlayer:Connect(function(player)
	local replica = replicas[player]
	if replica then
		replica:Subscribe(player)
	end
end)

return PlayerDataReplicaService