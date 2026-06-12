--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ResourceCatalog = require(ReplicatedStorage.Resource.Config)
local ResourceConfig = require(ReplicatedStorage.ResourceNode.Config)
local ResourceTypes = require(ReplicatedStorage.ResourceNode.Types)

type Reservation = ResourceTypes.Reservation
type NodeState = {
	Model: Model,
	ResourceType: ResourceTypes.ResourceType,
	Capacity: number,
	Available: number,
	Reserved: number,
	Reservations: { [string]: Reservation },
	RespawnToken: number,
	OriginalTransparency: { [BasePart]: number },
}

local Local = {
	nodes = {} :: { [Model]: NodeState },
	nodesByType = {} :: { [ResourceTypes.ResourceType]: { [Model]: NodeState } },
	started = false,
}

local ResourceNodeService = {}

local function getNumberAttribute(instance: Instance, name: string, default: number): number
	local value = instance:GetAttribute(name)
	return if typeof(value) == "number" then value else default
end

local function createProgressGui(node: Model): BillboardGui
	local primaryPart = node.PrimaryPart
	if not primaryPart then
		error(`Resource node {node:GetFullName()} must have a PrimaryPart`)
	end

	local existing = primaryPart:FindFirstChild("RespawnProgress")
	if existing and existing:IsA("BillboardGui") then
		return existing
	end

	local gui = Instance.new("BillboardGui")
	gui.Name = "RespawnProgress"
	gui.Size = UDim2.fromOffset(160, 26)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Enabled = false
	gui.Parent = primaryPart

	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	background.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = background

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Color3.fromRGB(95, 220, 110)
	fill.Parent = background

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 8)
	fillCorner.Parent = fill
	return gui
end

local function setDepletedAppearance(state: NodeState, depleted: boolean)
	for part, transparency in state.OriginalTransparency do
		if part.Parent then
			part.Transparency = if depleted then math.max(0.5, transparency) else transparency
		end
	end
end

local function clearReservations(state: NodeState)
	table.clear(state.Reservations)
	state.Reserved = 0
	state.Model:SetAttribute(ResourceConfig.Attributes.ReservedAmount, 0)
end

local function beginRespawn(state: NodeState)
	state.RespawnToken += 1
	local token = state.RespawnToken
	local duration = math.max(
		0.1,
		getNumberAttribute(state.Model, ResourceConfig.Attributes.RespawnSeconds, ResourceConfig.DefaultRespawnSeconds)
	)
	local gui = createProgressGui(state.Model)
	local background = gui:FindFirstChild("Background") :: Frame
	local fill = background:FindFirstChild("Fill") :: Frame

	clearReservations(state)
	setDepletedAppearance(state, true)
	gui.Enabled = true
	fill.Size = UDim2.fromScale(0, 1)
	state.Model:SetAttribute(ResourceConfig.Attributes.IsDepleted, true)

	task.spawn(function()
		local startedAt = os.clock()
		while state.RespawnToken == token and state.Model.Parent and os.clock() - startedAt < duration do
			fill.Size = UDim2.fromScale(math.clamp((os.clock() - startedAt) / duration, 0, 1), 1)
			RunService.Heartbeat:Wait()
		end

		if state.RespawnToken ~= token or not state.Model.Parent then
			return
		end

		state.Available = state.Capacity
		state.Model:SetAttribute(ResourceConfig.Attributes.AvailableAmount, state.Available)
		state.Model:SetAttribute(ResourceConfig.Attributes.IsDepleted, false)
		setDepletedAppearance(state, false)
		fill.Size = UDim2.fromScale(1, 1)
		task.wait(1)
		if state.RespawnToken == token then
			gui.Enabled = false
		end
	end)
end

local function getState(node: Model): NodeState?
	local state = Local.nodes[node]
	if not state or not node.Parent then
		return nil
	end
	return state
end

local function isAvailable(state: NodeState): boolean
	return state.Model.Parent ~= nil
		and state.Model:GetAttribute(ResourceConfig.Attributes.IsDisabled) ~= true
		and state.Available - state.Reserved > 0
end

function ResourceNodeService.Start()
	if Local.started then
		return
	end
	Local.started = true
end

function ResourceNodeService.RegisterNode(node: Model): boolean
	if Local.nodes[node] or not node.PrimaryPart then
		return false
	end

	local resourceType = node:GetAttribute(ResourceConfig.Attributes.ResourceType)
	if typeof(resourceType) ~= "string" or not ResourceCatalog.IsValid(resourceType) then
		return false
	end

	local capacity = math.max(
		1,
		math.floor(getNumberAttribute(node, ResourceConfig.Attributes.Capacity, ResourceConfig.DefaultCapacity))
	)
	local transparencies = {}
	for _, descendant in node:GetDescendants() do
		if descendant:IsA("BasePart") then
			transparencies[descendant] = descendant.Transparency
		end
	end

	local state: NodeState = {
		Model = node,
		ResourceType = resourceType,
		Capacity = capacity,
		Available = capacity,
		Reserved = 0,
		Reservations = {},
		RespawnToken = 0,
		OriginalTransparency = transparencies,
	}
	Local.nodes[node] = state
	Local.nodesByType[resourceType] = Local.nodesByType[resourceType] or {}
	Local.nodesByType[resourceType][node] = state
	node:SetAttribute(ResourceConfig.Attributes.AvailableAmount, capacity)
	node:SetAttribute(ResourceConfig.Attributes.ReservedAmount, 0)
	node:SetAttribute(ResourceConfig.Attributes.IsDepleted, false)
	CollectionService:AddTag(node, ResourceConfig.Tags.Node)
	createProgressGui(node)
	return true
end

function ResourceNodeService.UnregisterNode(node: Model)
	local state = Local.nodes[node]
	if not state then
		return
	end
	state.RespawnToken += 1
	Local.nodes[node] = nil
	local nodesByType = Local.nodesByType[state.ResourceType]
	if nodesByType then
		nodesByType[node] = nil
	end
	CollectionService:RemoveTag(node, ResourceConfig.Tags.Node)
end

function ResourceNodeService.IsRegistered(node: Model): boolean
	return getState(node) ~= nil
end

function ResourceNodeService.GetResourceType(node: Model): ResourceTypes.ResourceType?
	local state = getState(node)
	return if state then state.ResourceType else nil
end

function ResourceNodeService.FindNearest(resourceType: ResourceTypes.ResourceType, origin: Vector3): Model?
	local bestNode: Model?
	local bestDistance = math.huge
	local nodesByType = Local.nodesByType[resourceType]
	if not nodesByType then
		return nil
	end
	for node, state in nodesByType do
		if not isAvailable(state) then
			continue
		end
		local distance = (node:GetPivot().Position - origin).Magnitude
		if distance < bestDistance then
			bestDistance = distance
			bestNode = node
		end
	end
	return bestNode
end

function ResourceNodeService.FindAndReserve(
	resourceType: ResourceTypes.ResourceType,
	origin: Vector3,
	requestedAmount: number,
	reservationOwner: Instance
): (Model?, Reservation?)
	local node = ResourceNodeService.FindNearest(resourceType, origin)
	local state = node and getState(node)
	if not node or not state then
		return nil, nil
	end

	local amount = math.min(math.max(0, math.floor(requestedAmount)), state.Available - state.Reserved)
	if amount <= 0 then
		return nil, nil
	end

	local reservation: Reservation = {
		Id = HttpService:GenerateGUID(false),
		Node = node,
		Owner = reservationOwner,
		Amount = amount,
	}
	state.Reservations[reservation.Id] = reservation
	state.Reserved += amount
	node:SetAttribute(ResourceConfig.Attributes.ReservedAmount, state.Reserved)
	return node, reservation
end

function ResourceNodeService.ReleaseReservation(reservation: Reservation)
	local state = getState(reservation.Node)
	if not state or state.Reservations[reservation.Id] ~= reservation then
		return
	end
	state.Reservations[reservation.Id] = nil
	state.Reserved = math.max(0, state.Reserved - reservation.Amount)
	reservation.Node:SetAttribute(ResourceConfig.Attributes.ReservedAmount, state.Reserved)
end

function ResourceNodeService.CollectReserved(reservation: Reservation): number
	local state = getState(reservation.Node)
	if not state or state.Reservations[reservation.Id] ~= reservation then
		return 0
	end

	state.Reservations[reservation.Id] = nil
	local collected = math.min(reservation.Amount, state.Reserved, state.Available)
	state.Reserved -= collected
	state.Available -= collected
	reservation.Node:SetAttribute(ResourceConfig.Attributes.ReservedAmount, state.Reserved)
	reservation.Node:SetAttribute(ResourceConfig.Attributes.AvailableAmount, state.Available)
	if state.Available <= 0 then
		beginRespawn(state)
	end
	return collected
end

function ResourceNodeService.TryCollect(node: Model, requestedAmount: number): number
	local state = getState(node)
	if not state or not isAvailable(state) then
		return 0
	end

	local collected = math.min(math.max(0, math.floor(requestedAmount)), state.Available - state.Reserved)
	state.Available -= collected
	node:SetAttribute(ResourceConfig.Attributes.AvailableAmount, state.Available)
	if state.Available <= 0 and collected > 0 then
		beginRespawn(state)
	end
	return collected
end

function ResourceNodeService.GetApproachPosition(node: Model, origin: Vector3): Vector3
	local boxCFrame, boxSize = node:GetBoundingBox()
	local direction = Vector3.new(origin.X - boxCFrame.Position.X, 0, origin.Z - boxCFrame.Position.Z)
	if direction.Magnitude < 0.1 then
		direction = Vector3.new(0, 0, 1)
	end
	local radius = math.max(boxSize.X, boxSize.Z) * 0.5 + ResourceConfig.ApproachDistance
	return Vector3.new(boxCFrame.Position.X, boxCFrame.Position.Y - boxSize.Y * 0.5, boxCFrame.Position.Z)
		+ direction.Unit * radius
end

function ResourceNodeService.Reset()
	for node in Local.nodes do
		ResourceNodeService.UnregisterNode(node)
	end
end

return ResourceNodeService
