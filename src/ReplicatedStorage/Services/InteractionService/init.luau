--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InteractionConfig = require(ReplicatedStorage.Interaction.Config)
local getClosestPoint = require(ReplicatedStorage.Interaction.getClosestPoint)
local getPlotModel = require(ReplicatedStorage.Plot.getModel)
local getPlotPart = require(ReplicatedStorage.Plot.getPart)
local PlotService = require(ReplicatedStorage.Services.PlotService)
local RateLimit = require(ReplicatedStorage.Packages.RateLimit)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)

local interactionEvent = RemoteManager.InteractionRequest :: RemoteEvent
local interactionRateLimit = RateLimit.New(8)

local Local = {
	started = false,
}

local InteractionService = {}

local function isValidRequest(player: Player, target: Model): (boolean, string?, Model?)
	if not target:IsDescendantOf(workspace) or not CollectionService:HasTag(target, InteractionConfig.Tag) then
		return false
	end

	local interactionId = target:GetAttribute(InteractionConfig.Attributes.Id)
	local ownerUserId = target:GetAttribute(InteractionConfig.Attributes.OwnerUserId)
	local maxDistance = target:GetAttribute(InteractionConfig.Attributes.MaxDistance)
	local plot = PlotService.TryGet(player)

	if typeof(interactionId) ~= "string" or typeof(ownerUserId) ~= "number" or typeof(maxDistance) ~= "number" then
		return false
	end

	if ownerUserId ~= player.UserId or not plot or not target:IsDescendantOf(plot) then
		return false
	end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not rootPart or not rootPart:IsA("BasePart") then
		return false
	end

	local closestPoint = getClosestPoint(target, rootPart.Position)

	if (rootPart.Position - closestPoint).Magnitude > maxDistance then
		return false
	end

	return true, interactionId, plot
end

function InteractionService.RegisterPlot(player: Player, plot: Model)
	for _, descendant in plot:GetDescendants() do
		if descendant:IsA("ProximityPrompt") then
			descendant.Enabled = false
		end
	end

	for _, definition in InteractionConfig.Definitions do
		getPlotPart(plot, definition.Path)
		local target = getPlotModel(plot, definition.TargetPath)

		target:SetAttribute(InteractionConfig.Attributes.Id, definition.Id)
		target:SetAttribute(InteractionConfig.Attributes.ActionText, definition.ActionText)
		target:SetAttribute(InteractionConfig.Attributes.ObjectText, definition.ObjectText)
		target:SetAttribute(InteractionConfig.Attributes.MaxDistance, definition.MaxDistance)
		target:SetAttribute(InteractionConfig.Attributes.OwnerUserId, player.UserId)
		CollectionService:AddTag(target, InteractionConfig.Tag)
	end
end

function InteractionService.Start(handler: (Player, string, Model, Model) -> ())
	if Local.started then
		return
	end

	Local.started = true

	interactionEvent.OnServerEvent:Connect(function(player, target)
		if not interactionRateLimit:CheckRate(player) or typeof(target) ~= "Instance" or not target:IsA("Model") then
			return
		end

		local isValid, interactionId, plot = isValidRequest(player, target)

		if isValid and interactionId and plot then
			handler(player, interactionId, plot, target)
		end
	end)
end

return InteractionService
