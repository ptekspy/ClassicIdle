--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlotConfig = require(ReplicatedStorage.Plot.Config)
local WorkerConfig = require(ReplicatedStorage.Worker.Config)
local WorkerTypes = require(ReplicatedStorage.Worker.Types)
local getPlotModel = require(ReplicatedStorage.Plot.getModel)

type NodeState = {
	Model: Model,
	ResourceType: WorkerTypes.ResourceType,
	Capacity: number,
	Available: number,
	Reserved: number,
	RespawnToken: number,
	OriginalTransparency: { [BasePart]: number },
}

local Local = {
	TAG = "ResourceNode",
	nodesByPlot = {} :: { [Model]: { [Model]: NodeState } },
}

local ResourceNodeService = {}

local function createProgressGui(node: Model): BillboardGui
	local primaryPart = node.PrimaryPart :: BasePart
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

local function beginRespawn(state: NodeState)
	state.RespawnToken += 1
	local token = state.RespawnToken
	local durationAttribute = state.Model:GetAttribute("RespawnSeconds")
	local duration = if typeof(durationAttribute) == "number" then math.max(0.1, durationAttribute) else WorkerConfig.DefaultRespawnSeconds
	local gui = createProgressGui(state.Model)
	local background = gui:FindFirstChild("Background") :: Frame
	local fill = background:FindFirstChild("Fill") :: Frame

	setDepletedAppearance(state, true)
	gui.Enabled = true
	fill.Size = UDim2.fromScale(0, 1)
	state.Model:SetAttribute("IsDepleted", true)

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
		state.Reserved = 0
		state.Model:SetAttribute("AvailableAmount", state.Available)
		state.Model:SetAttribute("ReservedAmount", 0)
		state.Model:SetAttribute("IsDepleted", false)
		setDepletedAppearance(state, false)
		fill.Size = UDim2.fromScale(1, 1)
		task.wait(1)

		if state.RespawnToken == token then
			gui.Enabled = false
		end
	end)
end

local function registerNode(plot: Model, node: Model, resourceType: WorkerTypes.ResourceType)
	local capacityAttribute = node:GetAttribute("Capacity")
	local capacity = if typeof(capacityAttribute) == "number" then math.max(1, math.floor(capacityAttribute)) else WorkerConfig.DefaultCapacity
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
		RespawnToken = 0,
		OriginalTransparency = transparencies,
	}

	Local.nodesByPlot[plot][node] = state
	node:SetAttribute("AvailableAmount", capacity)
	node:SetAttribute("ReservedAmount", 0)
	node:SetAttribute("IsDepleted", false)
	CollectionService:AddTag(node, Local.TAG)
	createProgressGui(node)
end

function ResourceNodeService.SetupPlot(plot: Model)
	ResourceNodeService.CleanupPlot(plot)
	Local.nodesByPlot[plot] = {}
	registerNode(plot, getPlotModel(plot, PlotConfig.Paths.ManualTreeTarget), "Wood")
	registerNode(plot, getPlotModel(plot, PlotConfig.Paths.ManualRockTarget), "Stone")
end

function ResourceNodeService.FindAndReserve(
	plot: Model,
	resourceType: WorkerTypes.ResourceType,
	origin: Vector3,
	requestedAmount: number
): (Model?, number)
	local nodes = Local.nodesByPlot[plot]
	local bestState: NodeState?
	local bestDistance = math.huge

	if not nodes then
		return nil, 0
	end

	for _, state in nodes do
		local available = state.Available - state.Reserved

		if state.ResourceType ~= resourceType or available <= 0 or not state.Model.Parent then
			continue
		end

		local distance = (state.Model:GetPivot().Position - origin).Magnitude

		if distance < bestDistance then
			bestDistance = distance
			bestState = state
		end
	end

	if not bestState then
		return nil, 0
	end

	local amount = math.min(math.max(0, math.floor(requestedAmount)), bestState.Available - bestState.Reserved)
	bestState.Reserved += amount
	bestState.Model:SetAttribute("ReservedAmount", bestState.Reserved)
	return bestState.Model, amount
end

function ResourceNodeService.Release(plot: Model, node: Model, amount: number)
	local state = Local.nodesByPlot[plot] and Local.nodesByPlot[plot][node]

	if not state then
		return
	end

	state.Reserved = math.max(0, state.Reserved - amount)
	node:SetAttribute("ReservedAmount", state.Reserved)
end

function ResourceNodeService.CollectReserved(plot: Model, node: Model, amount: number): number
	local state = Local.nodesByPlot[plot] and Local.nodesByPlot[plot][node]

	if not state or not node.Parent then
		return 0
	end

	local collected = math.min(math.max(0, math.floor(amount)), state.Reserved, state.Available)
	state.Reserved -= collected
	state.Available -= collected
	node:SetAttribute("ReservedAmount", state.Reserved)
	node:SetAttribute("AvailableAmount", state.Available)

	if state.Available <= 0 then
		beginRespawn(state)
	end

	return collected
end

function ResourceNodeService.TryCollect(plot: Model, node: Model, requestedAmount: number): number
	local state = Local.nodesByPlot[plot] and Local.nodesByPlot[plot][node]

	if not state then
		return 0
	end

	local collected = math.min(math.max(0, math.floor(requestedAmount)), state.Available - state.Reserved)
	state.Available -= collected
	node:SetAttribute("AvailableAmount", state.Available)

	if state.Available <= 0 and collected > 0 then
		beginRespawn(state)
	end

	return collected
end

function ResourceNodeService.CleanupPlot(plot: Model)
	local nodes = Local.nodesByPlot[plot]
	Local.nodesByPlot[plot] = nil

	if not nodes then
		return
	end

	for _, state in nodes do
		state.RespawnToken += 1
		CollectionService:RemoveTag(state.Model, Local.TAG)
	end
end

return ResourceNodeService
