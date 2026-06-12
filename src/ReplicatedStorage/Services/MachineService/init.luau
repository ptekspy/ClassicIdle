--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataService = require(ReplicatedStorage.Services.DataService)
local DisplayService = require(ReplicatedStorage.Services.DisplayService)
local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local FeedbackService = require(ReplicatedStorage.Services.FeedbackService)
local InteractionService = require(ReplicatedStorage.Services.InteractionService)
local MachineConfig = require(ReplicatedStorage.Machine.Config)
local MachineTypes = require(ReplicatedStorage.Machine.Types)
local PlotService = require(ReplicatedStorage.Services.PlotService)
local QuestService = require(ReplicatedStorage.Services.QuestService)
local RateLimit = require(ReplicatedStorage.Packages.RateLimit)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)
local UnlockService = require(ReplicatedStorage.Services.UnlockService)
local getClosestPoint = require(ReplicatedStorage.Interaction.getClosestPoint)

type RuntimeMachine = {
	Active: boolean,
	Connection: RBXScriptConnection?,
	PieceVisuals: { [string]: BasePart },
	Player: Player,
	Plot: Model,
}

local machineMenuEvent = RemoteManager.MachineMenu :: RemoteEvent
local machineRequestEvent = RemoteManager.MachineRequest :: RemoteEvent
local machineRateLimit = RateLimit.New(10)

local Local = {
	runtimes = {} :: { [Player]: RuntimeMachine },
	started = false,
}

local MachineService = {}

local function getMachine(plot: Model): Folder?
	local machine = plot:FindFirstChild("Machine")
	return if machine and machine:IsA("Folder") then machine else nil
end

local function getPartModel(plot: Model, partId: MachineTypes.MachinePartId): Model?
	local machine = getMachine(plot)
	local model = machine and machine:FindFirstChild(partId)
	return if model and model:IsA("Model") then model else nil
end

local function getMarker(plot: Model, partId: string, markerName: string): BasePart?
	local machine = getMachine(plot)
	local parent = machine and machine:FindFirstChild(partId)
	local markers = parent and parent:FindFirstChild("Markers")
	local marker = markers and markers:FindFirstChild(markerName)
	return if marker and marker:IsA("BasePart") then marker else nil
end

local function getRuntimePieces(plot: Model): Folder?
	local machine = getMachine(plot)
	local folder = machine and machine:FindFirstChild("RuntimePieces")
	return if folder and folder:IsA("Folder") then folder else nil
end

local function isComplete(data: any): boolean
	for _, partId in MachineConfig.PartOrder do
		if not data.Machine.Parts[partId].Built then
			return false
		end
	end
	return true
end

local function getNextPart(data: any): MachineTypes.MachinePartId?
	for _, partId in MachineConfig.PartOrder do
		if not data.Machine.Parts[partId].Built then
			return partId
		end
	end
	return nil
end

local function canPreview(data: any, partId: MachineTypes.MachinePartId): boolean
	if partId == "Conveyor1" then
		return UnlockService.CanUnlockConveyor1(data)
	end
	return data.Machine.Parts.Conveyor1.Built
end

local function getState(data: any, partId: MachineTypes.MachinePartId): MachineTypes.MachinePartState
	if data.Machine.Parts[partId].Built then
		return if isComplete(data) then "Active" else "Built"
	end
	return if canPreview(data, partId) then "Preview" else "Locked"
end

local function setVisualState(model: Model, state: MachineTypes.MachinePartState)
	model:SetAttribute("MachineState", state)
	local visuals = model:FindFirstChild("Visuals")

	if visuals then
		for _, descendant in visuals:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Transparency = if state == "Locked" then 1 elseif state == "Preview" then 0.8 else 0
			end
		end
	end

	local highlight = model:FindFirstChild("MachinePreviewHighlight")
	if state == "Preview" then
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "MachinePreviewHighlight"
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillTransparency = 1
			highlight.OutlineColor = Color3.fromRGB(25, 25, 25)
			highlight.OutlineTransparency = 0.1
			highlight.Parent = model
		end
	elseif highlight then
		highlight:Destroy()
	end
end

local function round(value: number): number
	return math.round(value * 100) / 100
end

local function getPartLevel(data: any, partId: MachineTypes.MachinePartId): number
	return math.max(1, data.Machine.Parts[partId].Level)
end

local function getMenu(data: any, partId: MachineTypes.MachinePartId)
	local definition = MachineConfig.Parts[partId]
	local level = getPartLevel(data, partId)
	local payload: any = {
		Kind = "Manage",
		PartId = partId,
		DisplayName = definition.DisplayName,
		Upgradeable = definition.Upgradeable,
		Level = level,
		UpgradeCost = MachineConfig.GetUpgradeCost(partId, level),
	}

	if partId == "Conveyor1" or partId == "Conveyor2" then
		payload.StatName = "Speed"
		payload.CurrentValue = MachineConfig.GetConveyorSpeed(level)
		payload.NextValue = MachineConfig.GetConveyorSpeed(level + 1)
	elseif partId == "Upgrader1" or partId == "Upgrader2" then
		payload.StatName = "Multiplier"
		payload.CurrentValue = MachineConfig.GetUpgraderMultiplier(level)
		payload.NextValue = MachineConfig.GetUpgraderMultiplier(level + 1)
	elseif partId == "CoalProcessor" then
		local processor = data.Machine.Processor
		payload.Kind = "Processor"
		payload.ProcessingTimeLevel = processor.ProcessingTimeLevel
		payload.ProcessingTime = MachineConfig.GetProcessorDuration(processor.ProcessingTimeLevel)
		payload.NextProcessingTime = MachineConfig.GetProcessorDuration(processor.ProcessingTimeLevel + 1)
		payload.ProcessingTimeCost = MachineConfig.GetUpgradeCost(partId, processor.ProcessingTimeLevel)
		payload.OutputMultiplierLevel = processor.OutputMultiplierLevel
		payload.OutputMultiplier = MachineConfig.GetProcessorOutputMultiplier(processor.OutputMultiplierLevel)
		payload.NextOutputMultiplier = MachineConfig.GetProcessorOutputMultiplier(processor.OutputMultiplierLevel + 1)
		payload.OutputMultiplierCost = MachineConfig.GetUpgradeCost(partId, processor.OutputMultiplierLevel)
	elseif partId == "CollectionPoint" then
		payload.StatName = "Capacity"
		payload.CurrentValue = MachineConfig.GetCollectionCapacity(level)
		payload.NextValue = MachineConfig.GetCollectionCapacity(level + 1)
	end

	return payload
end

function MachineService.RefreshPresentation(player: Player, plot: Model)
	local data = DataService.TryGet(player)
	if not data then
		return
	end

	local nextPart = getNextPart(data)
	for _, partId in MachineConfig.PartOrder do
		local model = getPartModel(plot, partId)
		if not model then
			continue
		end

		local state = getState(data, partId)
		setVisualState(model, state)
		InteractionService.UnregisterTarget(model)

		if state == "Preview" and partId == nextPart then
			local cost = MachineConfig.Parts[partId].PurchaseCost
			InteractionService.RegisterTarget(
				player,
				model,
				"BuyMachinePart",
				"Purchase",
				`{MachineConfig.Parts[partId].DisplayName} - {cost} Gold`
			)
		elseif state == "Built" or state == "Active" then
			if partId == "CollectionPoint" then
				local capacity = MachineConfig.GetCollectionCapacity(getPartLevel(data, "CollectionPoint"))
				InteractionService.RegisterTarget(
					player,
					model,
					"ManageMachinePart",
					"Manage / Collect",
					`{round(data.Machine.CollectionStored)}/{capacity} Coal`
				)
			else
				InteractionService.RegisterTarget(
					player,
					model,
					"ManageMachinePart",
					"Manage",
					MachineConfig.Parts[partId].DisplayName
				)
			end
		end
	end
end

local function getPieceAppearance(resourceType: MachineTypes.ResourceType): (Vector3, Color3, Enum.Material)
	if resourceType == "Wood" then
		return Vector3.new(1.6, 0.8, 1), Color3.fromRGB(120, 72, 35), Enum.Material.Wood
	elseif resourceType == "Stone" then
		return Vector3.new(1.2, 1.2, 1.2), Color3.fromRGB(100, 100, 100), Enum.Material.Slate
	end
	return Vector3.new(1.1, 1.1, 1.1), Color3.fromRGB(20, 20, 20), Enum.Material.Basalt
end

local function createPieceVisual(runtime: RuntimeMachine, piece: MachineTypes.MachinePieceData): BasePart?
	local folder = getRuntimePieces(runtime.Plot)
	if not folder then
		return nil
	end

	local size, color, material = getPieceAppearance(piece.ResourceType)
	local visual = Instance.new("Part")
	visual.Name = piece.Id
	visual.Size = size
	visual.Color = color
	visual.Material = material
	visual.Anchored = true
	visual.CanCollide = false
	visual.CanTouch = false
	visual.CanQuery = false
	visual:SetAttribute("ResourceType", piece.ResourceType)
	visual:SetAttribute("Amount", piece.Amount)
	visual:SetAttribute("Multiplier", piece.Multiplier)
	visual:SetAttribute("PieceStage", piece.Stage)
	visual.Parent = folder
	runtime.PieceVisuals[piece.Id] = visual
	return visual
end

local function destroyPiece(runtime: RuntimeMachine, data: any, pieceId: string)
	data.Machine.Pieces[pieceId] = nil
	local visual = runtime.PieceVisuals[pieceId]
	runtime.PieceVisuals[pieceId] = nil
	if visual then
		visual:Destroy()
	end
end

local function createPiece(
	runtime: RuntimeMachine,
	data: any,
	resourceType: MachineTypes.ResourceType,
	multiplier: number,
	stage: MachineTypes.PieceStage
)
	local id = HttpService:GenerateGUID(false)
	local piece: MachineTypes.MachinePieceData = {
		Id = id,
		ResourceType = resourceType,
		Amount = 1,
		Multiplier = multiplier,
		Stage = stage,
		Progress = 0,
	}
	data.Machine.Pieces[id] = piece
	createPieceVisual(runtime, piece)
end

local function getPath(runtime: RuntimeMachine, piece: MachineTypes.MachinePieceData): (BasePart?, BasePart?, number)
	local data = DataService.TryGet(runtime.Player)
	if not data then
		return nil, nil, 0
	end
	if piece.Stage == "InputConveyor" then
		return getMarker(runtime.Plot, "Conveyor1", "PathStart"),
			getMarker(runtime.Plot, "Conveyor1", "PathEnd"),
			MachineConfig.GetConveyorSpeed(getPartLevel(data, "Conveyor1"))
	elseif piece.Stage == "InputUpgrader" then
		return getMarker(runtime.Plot, "Upgrader1", "PathStart"),
			getMarker(runtime.Plot, "CoalProcessor", "Input"),
			MachineConfig.GetConveyorSpeed(getPartLevel(data, "Conveyor1"))
	elseif piece.Stage == "OutputConveyor" then
		return getMarker(runtime.Plot, "Conveyor2", "PathStart"),
			getMarker(runtime.Plot, "Conveyor2", "PathEnd"),
			MachineConfig.GetConveyorSpeed(getPartLevel(data, "Conveyor2"))
	elseif piece.Stage == "OutputUpgrader" then
		return getMarker(runtime.Plot, "Upgrader2", "PathStart"),
			getMarker(runtime.Plot, "Upgrader2", "PathEnd"),
			MachineConfig.GetConveyorSpeed(getPartLevel(data, "Conveyor2"))
	end
	local marker = getMarker(runtime.Plot, "CollectionPoint", "Input")
	return marker, marker, 0
end

local function countInputs(data: any, resourceType: string): number
	local buffer = if resourceType == "Wood"
		then data.Machine.Processor.WoodBuffer
		else data.Machine.Processor.StoneBuffer
	local count = #buffer
	for _, piece in data.Machine.Pieces do
		if
			piece.ResourceType == resourceType and (piece.Stage == "InputConveyor" or piece.Stage == "InputUpgrader")
		then
			count += 1
		end
	end
	return count
end

local function outputBlocked(data: any): boolean
	for _, piece in data.Machine.Pieces do
		if piece.Stage == "CollectionWait" then
			return true
		end
	end
	return data.Machine.CollectionStored >= MachineConfig.GetCollectionCapacity(getPartLevel(data, "CollectionPoint"))
end

local function dispatchInput(runtime: RuntimeMachine, data: any)
	if outputBlocked(data) then
		return
	end
	if countInputs(data, "Wood") < MachineConfig.RecipeWood and EconomyService.RemoveResource(data, "Wood", 1) then
		createPiece(runtime, data, "Wood", 1, "InputConveyor")
		DisplayService.UpdateAll(runtime.Player, runtime.Plot)
	elseif
		countInputs(data, "Stone") < MachineConfig.RecipeStone and EconomyService.RemoveResource(data, "Stone", 1)
	then
		createPiece(runtime, data, "Stone", 1, "InputConveyor")
		DisplayService.UpdateAll(runtime.Player, runtime.Plot)
	end
end

local function bufferInput(runtime: RuntimeMachine, data: any, piece: MachineTypes.MachinePieceData)
	if piece.ResourceType == "Wood" then
		table.insert(data.Machine.Processor.WoodBuffer, piece.Multiplier)
	elseif piece.ResourceType == "Stone" then
		table.insert(data.Machine.Processor.StoneBuffer, piece.Multiplier)
	end
	destroyPiece(runtime, data, piece.Id)
	DisplayService.UpdateAll(runtime.Player, runtime.Plot)
end

local function advancePiece(runtime: RuntimeMachine, data: any, piece: MachineTypes.MachinePieceData)
	if piece.Stage == "InputConveyor" then
		piece.Stage = "InputUpgrader"
		piece.Progress = 0
	elseif piece.Stage == "InputUpgrader" then
		piece.Multiplier *= MachineConfig.GetUpgraderMultiplier(getPartLevel(data, "Upgrader1"))
		bufferInput(runtime, data, piece)
	elseif piece.Stage == "OutputConveyor" then
		piece.Stage = "OutputUpgrader"
		piece.Progress = 0
	elseif piece.Stage == "OutputUpgrader" then
		piece.Multiplier *= MachineConfig.GetUpgraderMultiplier(getPartLevel(data, "Upgrader2"))
		piece.Stage = "CollectionWait"
		piece.Progress = 0
	end
end

local function updatePieces(runtime: RuntimeMachine, data: any, deltaTime: number)
	local pieces = {}
	for _, piece in data.Machine.Pieces do
		table.insert(pieces, piece)
	end

	for _, piece in pieces do
		local startMarker, endMarker, speed = getPath(runtime, piece)
		local visual = runtime.PieceVisuals[piece.Id] or createPieceVisual(runtime, piece)
		if not startMarker or not endMarker or not visual then
			continue
		end

		if piece.Stage == "CollectionWait" then
			visual.Position = startMarker.Position
			local value = piece.Amount * piece.Multiplier
			local capacity = MachineConfig.GetCollectionCapacity(getPartLevel(data, "CollectionPoint"))
			if data.Machine.CollectionStored + value <= capacity then
				data.Machine.CollectionStored += value
				destroyPiece(runtime, data, piece.Id)
				QuestService.Notify(runtime.Player, "CoalReachedCollection", value)
				MachineService.RefreshPresentation(runtime.Player, runtime.Plot)
				DisplayService.UpdateAll(runtime.Player, runtime.Plot)
			end
			continue
		end

		local distance = (endMarker.Position - startMarker.Position).Magnitude
		if distance <= 0 then
			piece.Progress = 1
		else
			piece.Progress = math.clamp(piece.Progress + deltaTime * speed / distance, 0, 1)
		end
		visual.Position = startMarker.Position:Lerp(endMarker.Position, piece.Progress)
		visual:SetAttribute("Multiplier", piece.Multiplier)
		visual:SetAttribute("PieceStage", piece.Stage)
		if piece.Progress >= 1 then
			advancePiece(runtime, data, piece)
		end
	end
end

local function updateProcessor(runtime: RuntimeMachine, data: any, deltaTime: number)
	local processor = data.Machine.Processor
	if processor.IsProcessing then
		processor.ProcessingRemaining = math.max(0, processor.ProcessingRemaining - deltaTime)
		if processor.ProcessingRemaining <= 0 then
			processor.IsProcessing = false
			createPiece(runtime, data, "Coal", processor.PendingOutputMultiplier, "OutputConveyor")
			processor.PendingOutputMultiplier = 0
			DisplayService.UpdateAll(runtime.Player, runtime.Plot)
		end
		return
	end

	if
		outputBlocked(data)
		or #processor.WoodBuffer < MachineConfig.RecipeWood
		or #processor.StoneBuffer < MachineConfig.RecipeStone
	then
		return
	end

	local sum = 0
	for _ = 1, MachineConfig.RecipeWood do
		sum += table.remove(processor.WoodBuffer, 1) :: number
	end
	for _ = 1, MachineConfig.RecipeStone do
		sum += table.remove(processor.StoneBuffer, 1) :: number
	end
	processor.PendingOutputMultiplier = sum
		* MachineConfig.GetProcessorOutputMultiplier(processor.OutputMultiplierLevel)
	processor.ProcessingRemaining = MachineConfig.GetProcessorDuration(processor.ProcessingTimeLevel)
	processor.IsProcessing = true
	DisplayService.UpdateAll(runtime.Player, runtime.Plot)
end

local function tick(runtime: RuntimeMachine, deltaTime: number)
	local data = DataService.TryGet(runtime.Player)
	if not runtime.Active or not data or not runtime.Plot.Parent or not isComplete(data) then
		return
	end

	updatePieces(runtime, data, deltaTime)
	updateProcessor(runtime, data, deltaTime)
	data.Machine.DispatchRemaining -= deltaTime
	if data.Machine.DispatchRemaining <= 0 then
		data.Machine.DispatchRemaining = MachineConfig.DispatchInterval
		dispatchInput(runtime, data)
	end
end

local function isNear(player: Player, model: Model): boolean
	local plot = PlotService.TryGet(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return plot ~= nil
		and model:IsDescendantOf(plot)
		and root ~= nil
		and root:IsA("BasePart")
		and (root.Position - getClosestPoint(model, root.Position)).Magnitude <= 12
end

local function collect(player: Player)
	local data = DataService.TryGet(player)
	local plot = PlotService.TryGet(player)
	local model = plot and getPartModel(plot, "CollectionPoint")
	if
		not data
		or not plot
		or not model
		or not data.Machine.Parts.CollectionPoint.Built
		or not isNear(player, model)
	then
		return
	end

	local requested = math.min(data.Machine.CollectionStored, EconomyService.GetRemainingStorage(data))
	local withdrawn = MachineService.WithdrawCollection(player, requested)
	local accepted = EconomyService.AddCoal(data, withdrawn)
	MachineService.RefreshPresentation(player, plot)
	DisplayService.UpdateAll(player, plot)
	machineMenuEvent:FireClient(player, getMenu(data, "CollectionPoint"))
	FeedbackService.Send(player, if accepted > 0 then `+{round(accepted)} Coal stored` else "Storage full")
	if accepted > 0 then
		QuestService.Notify(player, "CoalManuallyCollected", accepted)
	end
end

function MachineService.WithdrawCollection(player: Player, requestedAmount: number): number
	local data = DataService.TryGet(player)
	local plot = PlotService.TryGet(player)
	if not data or not plot or requestedAmount <= 0 then
		return 0
	end

	local withdrawn = math.min(data.Machine.CollectionStored, requestedAmount)
	data.Machine.CollectionStored -= withdrawn
	MachineService.RefreshPresentation(player, plot)
	DisplayService.UpdateAll(player, plot)
	return withdrawn
end

function MachineService.HandleInteraction(player: Player, interactionId: string, target: Model)
	local data = DataService.TryGet(player)
	local plot = PlotService.TryGet(player)
	local partId = target:GetAttribute("MachinePartId")
	if
		not data
		or not plot
		or typeof(partId) ~= "string"
		or not MachineConfig.Parts[partId]
		or not isNear(player, target)
	then
		return
	end
	local typedPartId = partId :: MachineTypes.MachinePartId

	if interactionId == "BuyMachinePart" then
		local nextPart = getNextPart(data)
		local definition = MachineConfig.Parts[typedPartId]
		if typedPartId ~= nextPart or not canPreview(data, typedPartId) then
			return
		end
		if not EconomyService.TrySpendGold(data, definition.PurchaseCost) then
			FeedbackService.Send(player, `Need {definition.PurchaseCost} Gold`)
			return
		end
		data.Machine.Parts[typedPartId].Built = true
		QuestService.Refresh(player)
		MachineService.RefreshPresentation(player, plot)
		DisplayService.UpdateAll(player, plot)
		FeedbackService.Send(player, `{definition.DisplayName} built`)
	elseif interactionId == "ManageMachinePart" then
		machineMenuEvent:FireClient(player, getMenu(data, typedPartId))
	end
end

local function upgrade(player: Player, partId: MachineTypes.MachinePartId, upgradeType: MachineTypes.MachineUpgradeType)
	local data = DataService.TryGet(player)
	local plot = PlotService.TryGet(player)
	local model = plot and getPartModel(plot, partId)
	if not data or not plot or not model or not data.Machine.Parts[partId].Built or not isNear(player, model) then
		return
	end

	local level
	if partId == "CoalProcessor" and upgradeType == "ProcessingTime" then
		level = data.Machine.Processor.ProcessingTimeLevel
	elseif partId == "CoalProcessor" and upgradeType == "OutputMultiplier" then
		level = data.Machine.Processor.OutputMultiplierLevel
	elseif MachineConfig.Parts[partId].Upgradeable and upgradeType == "Level" then
		level = data.Machine.Parts[partId].Level
	else
		return
	end

	local cost = MachineConfig.GetUpgradeCost(partId, level)
	if not EconomyService.TrySpendGold(data, cost) then
		FeedbackService.Send(player, `Need {cost} Gold`)
		return
	end

	if upgradeType == "ProcessingTime" then
		data.Machine.Processor.ProcessingTimeLevel += 1
	elseif upgradeType == "OutputMultiplier" then
		data.Machine.Processor.OutputMultiplierLevel += 1
	else
		data.Machine.Parts[partId].Level += 1
	end
	QuestService.Refresh(player)
	MachineService.RefreshPresentation(player, plot)
	DisplayService.UpdateAll(player, plot)
	machineMenuEvent:FireClient(player, getMenu(data, partId))
end

function MachineService.SetupPlayer(player: Player, plot: Model)
	MachineService.CleanupPlayer(player)
	local runtime: RuntimeMachine = {
		Active = true,
		Connection = nil,
		PieceVisuals = {},
		Player = player,
		Plot = plot,
	}
	Local.runtimes[player] = runtime
	for _, piece in DataService.Get(player).Machine.Pieces do
		createPieceVisual(runtime, piece)
	end
	MachineService.RefreshPresentation(player, plot)
	runtime.Connection = RunService.Heartbeat:Connect(function(deltaTime)
		tick(runtime, math.min(deltaTime, 0.25))
	end)
end

function MachineService.CleanupPlayer(player: Player)
	local runtime = Local.runtimes[player]
	Local.runtimes[player] = nil
	if not runtime then
		return
	end
	runtime.Active = false
	if runtime.Connection then
		runtime.Connection:Disconnect()
	end
end

function MachineService.Start()
	if Local.started then
		return
	end
	Local.started = true
	machineRequestEvent.OnServerEvent:Connect(function(player, action, partId, upgradeType)
		if not machineRateLimit:CheckRate(player) or typeof(partId) ~= "string" or not MachineConfig.Parts[partId] then
			return
		end

		if action == "Collect" and partId == "CollectionPoint" then
			collect(player)
		elseif
			action == "Upgrade"
			and (upgradeType == "Level" or upgradeType == "ProcessingTime" or upgradeType == "OutputMultiplier")
		then
			upgrade(player, partId :: MachineTypes.MachinePartId, upgradeType :: MachineTypes.MachineUpgradeType)
		end
	end)
end

return MachineService
