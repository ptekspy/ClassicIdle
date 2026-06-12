--!strict

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local UIState = require(script.Parent.Parent.UI.UIState)

local PlotConfig = require(ReplicatedStorage.Plot.Config)
local ResourceCatalog = require(ReplicatedStorage.Resource.Config)
local ResourceConfig = require(ReplicatedStorage.ResourceNode.Config)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)

local player = Players.LocalPlayer
local questUpdateEvent = RemoteManager.QuestUpdate :: RemoteEvent
local getQuestStateFunction = RemoteManager.GetQuestState :: RemoteFunction

local Local = {
	currentState = nil :: any,
	lastResolve = 0,
	started = false,
	targetAttachment = nil :: Attachment?,
	targetInstance = nil :: Instance?,
}

local QuestController = {}

local objectiveCosts = {
	HireWoodNPC = 10,
	BuildStoneWorkerHome = 50,
	UpgradeWoodNPC = 10,
	HireStoneNPC = 25,
	UpgradeStorage = 50,
	BuildConveyor1 = 100,
	BuildUpgrader1 = 25,
	BuildCoalProcessor = 100,
	BuildConveyor2 = 0,
	BuildUpgrader2 = 150,
	BuildCollectionPoint = 0,
	UpgradeConveyor1 = 50,
	HireCoalNPC = 500,
}


local highlight = Instance.new("Highlight")
highlight.Name = "QuestTargetHighlight"
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.FillColor = Color3.fromRGB(100, 225, 120)
highlight.FillTransparency = 0.75
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.OutlineTransparency = 0
highlight.Enabled = false
highlight.Parent = workspace

local beam = Instance.new("Beam")
beam.Name = "QuestWayfindingBeam"
beam.Color = ColorSequence.new(Color3.fromRGB(100, 225, 120))
beam.FaceCamera = true
beam.LightEmission = 1
beam.Transparency = NumberSequence.new(0.15)
beam.Width0 = 0.18
beam.Width1 = 0.18
beam.Enabled = false
beam.Parent = workspace

local function getOwnedPlot(): Model?
	local plots = workspace:FindFirstChild("PlayerPlots")
	if not plots then
		return nil
	end

	for _, child in plots:GetChildren() do
		if child:IsA("Model") and child:GetAttribute("OwnerUserId") == player.UserId then
			return child
		end
	end
	return nil
end

local function resolvePath(root: Instance, path: string): Instance?
	local current: Instance? = root
	for segment in string.gmatch(path, "[^%.]+") do
		current = current and current:FindFirstChild(segment) or nil
	end
	return current
end

local function resolveEarningTarget(plot: Model, leaderstats: Instance?): Instance?
	local hasResources = false
	if leaderstats then
		for _, resourceName in ResourceCatalog.Order do
			local value = leaderstats:FindFirstChild(resourceName)
			hasResources = hasResources
				or (value and (value:IsA("IntValue") or value:IsA("NumberValue")) and value.Value > 0) == true
		end
	end
	return if hasResources then resolvePath(plot, PlotConfig.Paths.SellTouchPad) else nil
end

local function resolveResourceTarget(resourceType: string): Model?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local best: Model?
	local bestDistance = math.huge
	for _, instance in CollectionService:GetTagged(ResourceConfig.Tags.Node) do
		if
			not instance:IsA("Model")
			or instance:GetAttribute(ResourceConfig.Attributes.ResourceType) ~= resourceType
			or instance:GetAttribute(ResourceConfig.Attributes.IsDepleted) == true
			or instance:GetAttribute(ResourceConfig.Attributes.IsDisabled) == true
			or (
				(instance:GetAttribute(ResourceConfig.Attributes.AvailableAmount) or 0)
				- (instance:GetAttribute(ResourceConfig.Attributes.ReservedAmount) or 0)
				<= 0
			)
		then
			continue
		end
		local distance = if root and root:IsA("BasePart")
			then (instance:GetPivot().Position - root.Position).Magnitude
			else 0
		if distance < bestDistance then
			bestDistance = distance
			best = instance
		end
	end
	return best
end

local function getTargetPart(target: Instance?): BasePart?
	if not target then
		return nil
	elseif target:IsA("BasePart") then
		return target
	elseif target:IsA("Model") then
		return target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function resolveTarget(): Instance?
	local state = Local.currentState
	local plot = getOwnedPlot()
	if not state or not plot or state.Complete then
		return nil
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local gold = leaderstats and leaderstats:FindFirstChild("Gold")
	local objectiveCost = objectiveCosts[state.QuestId]
	if objectiveCost and gold and gold:IsA("NumberValue") and gold.Value < objectiveCost then
		return resolveEarningTarget(plot, leaderstats) or resolveResourceTarget("Wood")
	end

	if state.QuestId == "ProduceCoal" and leaderstats then
		local wood = leaderstats:FindFirstChild("Wood")
		local stone = leaderstats:FindFirstChild("Stone")
		if wood and (wood:IsA("IntValue") or wood:IsA("NumberValue")) and wood.Value < 2 then
			return resolveResourceTarget("Wood")
		elseif stone and (stone:IsA("IntValue") or stone:IsA("NumberValue")) and stone.Value < 1 then
			return resolveResourceTarget("Stone")
		end
	end

	if state.WayfindingType == "Earning" then
		return resolveEarningTarget(plot, leaderstats) or resolveResourceTarget("Wood")
	elseif state.WayfindingType == "ResourceType" then
		return resolveResourceTarget(state.WayfindingValue)
	elseif state.WayfindingType == "PlotPath" then
		local path = PlotConfig.Paths[state.WayfindingValue]
		return if path then resolvePath(plot, path) else nil
	elseif state.WayfindingType == "MachinePart" then
		return resolvePath(plot, `Machine.{state.WayfindingValue}`)
	elseif state.WayfindingType == "FactoryItem" then
		local grid = plot:FindFirstChild("BuildGrid")
		local placed = grid and grid:FindFirstChild("PlacedItems")
		if placed then
			for _, model in placed:GetChildren() do
				if model:IsA("Model") and model:GetAttribute("BuildItemId") == state.WayfindingValue then
					return model
				end
			end
		end
		return resolvePath(plot, "BuildGrid.Bounds")
	elseif state.WayfindingType == "WorkerRole" then
		local workers = plot:FindFirstChild("Workers")
		if workers then
			for _, worker in workers:GetChildren() do
				if worker:IsA("Model") and worker:GetAttribute("Role") == state.WayfindingValue then
					return worker
				end
			end
		end
	end
	return nil
end

local function clearTarget()
	highlight.Adornee = nil
	highlight.Enabled = false
	UIState.Set("questMarker", nil)
	beam.Attachment0 = nil
	beam.Attachment1 = nil
	beam.Enabled = false
	if Local.targetAttachment then
		Local.targetAttachment:Destroy()
		Local.targetAttachment = nil
	end
	Local.targetInstance = nil
end

local function updateTarget()
	local target = resolveTarget()
	if target == Local.targetInstance then
		return
	end

	clearTarget()
	local targetPart = getTargetPart(target)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not target or not targetPart or not root or not root:IsA("BasePart") then
		return
	end

	local rootAttachment = root:FindFirstChild("QuestWayfindingAttachment")
	if not rootAttachment then
		rootAttachment = Instance.new("Attachment")
		rootAttachment.Name = "QuestWayfindingAttachment"
		rootAttachment.Parent = root
	end

	local targetAttachment = Instance.new("Attachment")
	targetAttachment.Name = "QuestWayfindingTarget"
	targetAttachment.Parent = targetPart
	Local.targetAttachment = targetAttachment
	Local.targetInstance = target

	highlight.Adornee = target
	highlight.Enabled = true
	UIState.Set("questMarker", targetPart)
	beam.Attachment0 = rootAttachment :: Attachment
	beam.Attachment1 = targetAttachment
	beam.Enabled = true
end

local function showState(state: any)
	if typeof(state) ~= "table" then
		return
	end
	Local.currentState = state
	UIState.Set("quest", state)
	if state.Complete then
		clearTarget()
		return
	end
	
	updateTarget()
end

function QuestController.Start()
	if Local.started then
		return
	end
	Local.started = true

	questUpdateEvent.OnClientEvent:Connect(showState)
	player.CharacterAdded:Connect(function()
		clearTarget()
	end)
	RunService.Heartbeat:Connect(function()
		if os.clock() - Local.lastResolve >= 0.5 then
			Local.lastResolve = os.clock()
			updateTarget()
		end
	end)

	task.spawn(function()
		local ok, state = pcall(function()
			return getQuestStateFunction:InvokeServer()
		end)
		if ok then
			showState(state)
		end
	end)
end

return QuestController
