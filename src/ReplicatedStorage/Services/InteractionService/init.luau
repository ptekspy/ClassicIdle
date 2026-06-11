--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InteractionConfig = require(ReplicatedStorage.Interaction.Config)
local getClosestPoint = require(ReplicatedStorage.Interaction.getClosestPoint)
local PlotService = require(ReplicatedStorage.Services.PlotService)
local RateLimit = require(ReplicatedStorage.Packages.RateLimit)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)

local interactionEvent = RemoteManager.InteractionRequest :: RemoteEvent
local interactionRateLimit = RateLimit.New(8)

local Local = {
	started = false,
}

local InteractionService = {}

local function hasLineOfSight(player: Player, target: BasePart): boolean
	local character = player.Character
	local originPart = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))

	if not originPart or not originPart:IsA("BasePart") then
		return false
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character, workspace:WaitForChild("PlotSpawns") }

	local targetPoint = getClosestPoint(target, originPart.Position)
	local result = workspace:Raycast(originPart.Position, (targetPoint - originPart.Position) * 1.01, raycastParams)

	return result ~= nil and result.Instance == target
end

local function isValidRequest(player: Player, target: BasePart): (boolean, string?, Model?)
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

	if not hasLineOfSight(player, target) then
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

	for partName, definition in InteractionConfig.Definitions do
		local part = plot:FindFirstChild(partName)

		if not part or not part:IsA("BasePart") then
			error(`Plot for {player.Name} must contain a {partName} BasePart`)
		end

		part:SetAttribute(InteractionConfig.Attributes.Id, definition.Id)
		part:SetAttribute(InteractionConfig.Attributes.ActionText, definition.ActionText)
		part:SetAttribute(InteractionConfig.Attributes.ObjectText, definition.ObjectText)
		part:SetAttribute(InteractionConfig.Attributes.MaxDistance, definition.MaxDistance)
		part:SetAttribute(InteractionConfig.Attributes.OwnerUserId, player.UserId)
		CollectionService:AddTag(part, InteractionConfig.Tag)
	end
end

function InteractionService.Start(handler: (Player, string, Model) -> ())
	if Local.started then
		return
	end

	Local.started = true

	interactionEvent.OnServerEvent:Connect(function(player, target)
		if not interactionRateLimit:CheckRate(player) or typeof(target) ~= "Instance" or not target:IsA("BasePart") then
			return
		end

		local isValid, interactionId, plot = isValidRequest(player, target)

		if isValid and interactionId and plot then
			handler(player, interactionId, plot)
		end
	end)
end

return InteractionService
