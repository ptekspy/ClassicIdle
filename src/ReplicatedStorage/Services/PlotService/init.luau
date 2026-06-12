--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Packages.Maid)
local PlotConfig = require(ReplicatedStorage.Plot.Config)
local getPlotPart = require(ReplicatedStorage.Plot.getPart)
local validatePlot = require(ReplicatedStorage.Plot.validate)

local assets = ReplicatedStorage:WaitForChild("Assets")
local plotTemplate = assets:WaitForChild("PlotTemplate")

local plotSpawns = workspace:WaitForChild("PlotSpawns")

if not plotTemplate:IsA("Model") then
	error("ReplicatedStorage.Assets.PlotTemplate must be a Model")
end

validatePlot(plotTemplate)

if not plotSpawns:IsA("Folder") then
	error("Workspace.PlotSpawns must be a Folder")
end

local playerPlots = workspace:FindFirstChild("PlayerPlots")

if not playerPlots then
	playerPlots = Instance.new("Folder")
	playerPlots.Name = "PlayerPlots"
	playerPlots.Parent = workspace
end

if not playerPlots:IsA("Folder") then
	error("Workspace.PlayerPlots must be a Folder")
end

local Local = {
	plotsByPlayer = {} :: { [Player]: Model },
	spawnsByPlayer = {} :: { [Player]: BasePart },
	ownersBySpawn = {} :: { [BasePart]: Player },
	maidsByPlayer = {} :: { [Player]: any },
}

local PlotService = {}

function Local.getOrderedSpawns(): { BasePart }
	local spawns = {}

	for _, child in plotSpawns:GetChildren() do
		if child:IsA("BasePart") then
			table.insert(spawns, child)
		end
	end

	table.sort(spawns, function(a, b)
		return a.Name < b.Name
	end)

	return spawns
end

function Local.findAvailableSpawn(): BasePart?
	for _, spawn in Local.getOrderedSpawns() do
		if Local.ownersBySpawn[spawn] == nil then
			return spawn
		end
	end

	return nil
end

function PlotService.TryGet(player: Player): Model?
	return Local.plotsByPlayer[player]
end

function PlotService.Get(player: Player): Model
	local plot = PlotService.TryGet(player)

	if not plot then
		error(`No plot claimed for {player.Name}`)
	end

	return plot
end

function PlotService.IsOwner(player: Player, plot: Model): boolean
	return Local.plotsByPlayer[player] == plot
end

function PlotService.Claim(player: Player): Model?
	local existingPlot = PlotService.TryGet(player)

	if existingPlot then
		return existingPlot
	end

	local spawn = Local.findAvailableSpawn()

	if not spawn then
		return nil
	end

	local plot = plotTemplate:Clone()
	plot.Name = `Plot_{player.UserId}`
	plot:SetAttribute("OwnerUserId", player.UserId)
	plot:SetAttribute("PlotId", spawn.Name)

	Local.plotsByPlayer[player] = plot
	Local.spawnsByPlayer[player] = spawn
	Local.ownersBySpawn[spawn] = player

	local ground = getPlotPart(plot, PlotConfig.Paths.Ground)
	local groundToPivot = ground.CFrame:ToObjectSpace(plot:GetPivot())
	plot:PivotTo(spawn.CFrame * groundToPivot)
	plot.Parent = playerPlots

	local maid = Maid.New(nil)
	Local.maidsByPlayer[player] = maid

	maid:Add(player.CharacterAdded:Connect(function()
		task.defer(function()
			if PlotService.TryGet(player) then
				PlotService.SpawnCharacter(player)
			end
		end)
	end))

	return plot
end

function PlotService.Release(player: Player)
	local plot = Local.plotsByPlayer[player]
	local spawn = Local.spawnsByPlayer[player]
	local maid = Local.maidsByPlayer[player]

	Local.plotsByPlayer[player] = nil
	Local.spawnsByPlayer[player] = nil
	Local.maidsByPlayer[player] = nil

	if maid then
		maid:Cleanup()
	end

	if spawn then
		Local.ownersBySpawn[spawn] = nil
	end

	if plot then
		plot:Destroy()
	end
end

function PlotService.SpawnCharacter(player: Player)
	local plot = PlotService.Get(player)
	local playerSpawn = getPlotPart(plot, PlotConfig.Paths.PlayerSpawn)

	local character = player.Character or player.CharacterAdded:Wait()

	character:PivotTo(playerSpawn.CFrame + Vector3.new(0, 3, 0))
end

return PlotService
