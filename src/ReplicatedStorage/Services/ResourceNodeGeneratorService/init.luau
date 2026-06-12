--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InteractionConfig = require(ReplicatedStorage.Interaction.Config)
local ResourceCatalog = require(ReplicatedStorage.Resource.Config)
local ResourceConfig = require(ReplicatedStorage.ResourceNode.Config)
local ResourceNodeService = require(ReplicatedStorage.Services.ResourceNodeService)

local Local = {
	started = false,
}

local ResourceNodeGeneratorService = {}

type ZoneEntry = {
	Zone: Model,
	ZoneId: string,
}

local function getNumber(instance: Instance, name: string, default: number): number
	local value = instance:GetAttribute(name)
	return if typeof(value) == "number" then value else default
end

local function hasValidNumber(zone: Model, name: string, minimum: number): boolean
	local value = zone:GetAttribute(name)
	return value == nil or (typeof(value) == "number" and value >= minimum)
end

local function hasValidNumbers(zone: Model): boolean
	return hasValidNumber(zone, "NodeCount", 0)
		and hasValidNumber(zone, "MinimumSpacing", 1)
		and hasValidNumber(zone, "GenerationSeed", -math.huge)
		and hasValidNumber(zone, "MaxPlacementAttempts", 0)
		and hasValidNumber(zone, "Capacity", 1)
		and hasValidNumber(zone, "RespawnSeconds", 0.1)
		and hasValidNumber(zone, "NodeLevel", 1)
end

local function clearGenerated(nodesFolder: Folder)
	for _, descendant in nodesFolder:GetDescendants() do
		if descendant:IsA("Model") and descendant:GetAttribute(ResourceConfig.Attributes.IsGenerated) == true then
			ResourceNodeService.UnregisterNode(descendant)
			descendant:Destroy()
		end
	end
end

local function setInteractionAttributes(node: Model, resourceType: string)
	local definition = ResourceCatalog.Get(resourceType)
	if not definition or not definition.ManualCollection.Enabled then
		return
	end
	node:SetAttribute(InteractionConfig.Attributes.Id, "CollectResourceNode")
	node:SetAttribute(InteractionConfig.Attributes.Scope, InteractionConfig.Scopes.Shared)
	node:SetAttribute(InteractionConfig.Attributes.ActionText, definition.ManualCollection.ActionText)
	node:SetAttribute(InteractionConfig.Attributes.ObjectText, definition.ManualCollection.ObjectText)
	node:SetAttribute(InteractionConfig.Attributes.MaxDistance, 10)
	node:SetAttribute(InteractionConfig.Attributes.OwnerUserId, nil)
	CollectionService:AddTag(node, InteractionConfig.Tag)
end

local function placeNode(node: Model, bounds: BasePart, x: number, z: number, rotation: number)
	node:PivotTo(CFrame.new(x, bounds.Position.Y, z) * CFrame.Angles(0, rotation, 0))
	local boxCFrame, boxSize = node:GetBoundingBox()
	local surfaceY = bounds.Position.Y - bounds.Size.Y * 0.5
	local bottomY = boxCFrame.Position.Y - boxSize.Y * 0.5
	node:PivotTo(node:GetPivot() + Vector3.new(0, surfaceY - bottomY, 0))
end

local function getDestination(nodesFolder: Folder, resourceType: string): Folder?
	local existing = nodesFolder:FindFirstChild(resourceType)
	if existing then
		return if existing:IsA("Folder") then existing else nil
	end
	local destination = Instance.new("Folder")
	destination.Name = resourceType
	destination.Parent = nodesFolder
	return destination
end

local function generateZone(zone: Model, zoneId: string, templates: Folder, nodesFolder: Folder)
	local bounds = zone:FindFirstChild("Bounds")
	local resourceType = zone:GetAttribute(ResourceConfig.Attributes.ResourceType)
	local templateName = zone:GetAttribute("TemplateName")
	if not bounds or not bounds:IsA("BasePart") then
		warn(`Skipping ResourceZone {zone:GetFullName()}: missing valid Bounds`)
		return
	end
	if typeof(resourceType) ~= "string" or not ResourceCatalog.IsValid(resourceType) then
		warn(`Skipping ResourceZone {zone:GetFullName()}: unknown ResourceType`)
		return
	end
	if typeof(templateName) ~= "string" or templateName == "" then
		warn(`Skipping ResourceZone {zone:GetFullName()}: missing TemplateName`)
		return
	end
	if not hasValidNumbers(zone) then
		warn(`Skipping ResourceZone {zone:GetFullName()}: invalid numeric generation attribute`)
		return
	end

	local template = templates:FindFirstChild(templateName)
	if not template or not template:IsA("Model") or not template.PrimaryPart then
		warn(`Skipping ResourceZone {zone:GetFullName()}: missing valid template {templateName}`)
		return
	end
	local destination = getDestination(nodesFolder, resourceType)
	if not destination then
		warn(`Skipping ResourceZone {zone:GetFullName()}: ResourceNodes.{resourceType} is not a Folder`)
		return
	end

	local nodeCount = math.max(0, math.floor(getNumber(zone, "NodeCount", ResourceConfig.DefaultNodeCount)))
	local spacing = math.max(1, getNumber(zone, "MinimumSpacing", ResourceConfig.DefaultMinimumSpacing))
	local seed = math.floor(getNumber(zone, "GenerationSeed", 1))
	local maxCandidates =
		math.max(nodeCount, math.floor(getNumber(zone, "MaxPlacementAttempts", ResourceConfig.DefaultMaxPlacementAttempts)))
	local random = Random.new(seed)
	local positions = {}
	local halfX = math.max(0, bounds.Size.X * 0.5 - ResourceConfig.PlacementMargin)
	local halfZ = math.max(0, bounds.Size.Z * 0.5 - ResourceConfig.PlacementMargin)
	local width = halfX * 2
	local depth = halfZ * 2
	local columns = math.max(1, math.floor(width / spacing) + 1)
	local rows = math.max(1, math.floor(depth / spacing) + 1)
	local stepX = if columns > 1 then width / (columns - 1) else 0
	local stepZ = if rows > 1 then depth / (rows - 1) else 0
	local candidates = {}

	for row = 1, rows do
		for column = 1, columns do
			if #candidates >= maxCandidates then
				break
			end
			local x = if columns > 1 then -halfX + (column - 1) * stepX else 0
			local z = if rows > 1 then -halfZ + (row - 1) * stepZ else 0
			table.insert(candidates, bounds.CFrame:PointToWorldSpace(Vector3.new(x, 0, z)))
		end
	end
	for index = #candidates, 2, -1 do
		local swapIndex = random:NextInteger(1, index)
		candidates[index], candidates[swapIndex] = candidates[swapIndex], candidates[index]
	end
	for index = 1, math.min(nodeCount, #candidates) do
		table.insert(positions, candidates[index])
	end

	for index, position in positions do
		local node = template:Clone()
		local indexText = string.format("%02d", index)
		node.Name = `{zoneId}_{indexText}`
		node:SetAttribute(ResourceConfig.Attributes.ResourceType, resourceType)
		node:SetAttribute(ResourceConfig.Attributes.Capacity, getNumber(zone, "Capacity", ResourceConfig.DefaultCapacity))
		node:SetAttribute(ResourceConfig.Attributes.RespawnSeconds, getNumber(zone, "RespawnSeconds", ResourceConfig.DefaultRespawnSeconds))
		node:SetAttribute(ResourceConfig.Attributes.NodeLevel, getNumber(zone, "NodeLevel", ResourceConfig.DefaultNodeLevel))
		node:SetAttribute(ResourceConfig.Attributes.IsGenerated, true)
		node:SetAttribute(ResourceConfig.Attributes.ZoneId, zoneId)
		node:SetAttribute(ResourceConfig.Attributes.GeneratedNodeId, `{zoneId}:{indexText}`)
		node.Parent = destination
		placeNode(node, bounds, position.X, position.Z, random:NextNumber(0, math.pi * 2))
		setInteractionAttributes(node, resourceType)
		ResourceNodeService.RegisterNode(node)
	end

	if #positions < nodeCount then
		warn(`Generated {#positions}/{nodeCount} nodes for {zone:GetFullName()}; zone is too small for configured spacing`)
	end
end

function ResourceNodeGeneratorService.Start()
	if Local.started then
		return
	end
	Local.started = true

	local shared = workspace:FindFirstChild(ResourceConfig.World.SharedFolder)
	local zones = shared and shared:FindFirstChild(ResourceConfig.World.ZonesFolder)
	local nodes = shared and shared:FindFirstChild(ResourceConfig.World.NodesFolder)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local templates = assets and assets:FindFirstChild(ResourceConfig.World.TemplatesFolder)
	if not shared or not shared:IsA("Folder") or not zones or not zones:IsA("Folder") then
		warn("Resource generation skipped: missing Workspace.Shared.ResourceZones")
		return
	end
	if not nodes or not nodes:IsA("Folder") or not templates or not templates:IsA("Folder") then
		warn("Resource generation skipped: missing ResourceNodes or ResourceNodeTemplates Folder")
		return
	end

	clearGenerated(nodes)
	local validZones = {} :: { ZoneEntry }
	local seenZoneIds = {} :: { [string]: boolean }
	for _, zone in zones:GetChildren() do
		if zone:IsA("Model") and CollectionService:HasTag(zone, ResourceConfig.Tags.Zone) then
			local zoneId = zone:GetAttribute(ResourceConfig.Attributes.ZoneId)
			if typeof(zoneId) ~= "string" or zoneId == "" then
				warn(`Skipping ResourceZone {zone:GetFullName()}: missing unique ZoneId`)
			elseif seenZoneIds[zoneId] then
				warn(`Skipping ResourceZone {zone:GetFullName()}: duplicate ZoneId {zoneId}`)
			else
				seenZoneIds[zoneId] = true
				table.insert(validZones, { Zone = zone, ZoneId = zoneId })
			end
		end
	end
	table.sort(validZones, function(a, b)
		return a.ZoneId < b.ZoneId
	end)
	for _, entry in validZones do
		generateZone(entry.Zone, entry.ZoneId, templates, nodes)
	end
end

return ResourceNodeGeneratorService
