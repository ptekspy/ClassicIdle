--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Services = ReplicatedStorage:WaitForChild("Services")

local DataService = require(Services:WaitForChild("DataService"))
local DisplayService = require(Services:WaitForChild("DisplayService"))
local InteractionService = require(Services:WaitForChild("InteractionService"))
local PlotService = require(Services:WaitForChild("PlotService"))
local QuestService = require(Services:WaitForChild("QuestService"))
local WorldService = require(Services:WaitForChild("WorldService"))

local function onPlayerAdded(player: Player)
	if not DataService.Load(player) then
		return
	end

	local plot = PlotService.Claim(player)

	if not plot then
		DataService.Release(player)
		player:Kick("No plots are currently available.")
		return
	end

	InteractionService.RegisterPlot(player, plot)
	DisplayService.SetupLeaderstats(player)
	WorldService.SetupPlayer(player, plot)
	QuestService.SetupPlayer(player)
	DisplayService.UpdateAll(player, plot)
	WorldService.UpdateUnlocks(player, plot)
	PlotService.SpawnCharacter(player)
end

local function onPlayerRemoving(player: Player)
	WorldService.CleanupPlayer(player)
	PlotService.Release(player)
	DataService.Release(player)
end

InteractionService.Start(WorldService.HandleInteraction)
WorldService.Start()
QuestService.Start()

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end
