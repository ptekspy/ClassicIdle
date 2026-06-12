--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataService = require(ReplicatedStorage.Services.DataService)
local DisplayService = require(ReplicatedStorage.Services.DisplayService)
local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local FactoryConfig = require(ReplicatedStorage.Factory.Config)
local FactoryGrid = require(ReplicatedStorage.Factory.Grid)
local FactoryService = require(ReplicatedStorage.Services.FactoryService)
local PlotService = require(ReplicatedStorage.Services.PlotService)
local QuestService = require(ReplicatedStorage.Services.QuestService)
local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local ResourceTypes = require(ReplicatedStorage.Resource.Types)

type MovingItem = {
	Id: string,
	ResourceType: ResourceTypes.ResourceId,
	Amount: number,
	Multiplier: number,
	SourceDropperId: string,
	CurrentItemId: string,
	Progress: number,
	Visual: BasePart,
	Visited: { [string]: boolean },
}

type Runtime = {
	Connection: RBXScriptConnection?,
	Dispatch: { [string]: number },
	Items: { [string]: MovingItem },
	Player: Player,
	Plot: Model,
}

local Local = {
	runtimes = {} :: { [Player]: Runtime },
}

local ConveyorService = {}

local function getModel(plot: Model, itemId: string): Model?
	local grid = plot:FindFirstChild("BuildGrid")
	local folder = grid and grid:FindFirstChild("PlacedItems")
	local model = folder and folder:FindFirstChild(itemId)
	return if model and model:IsA("Model") then model else nil
end

local function getAttachment(model: Model, name: string): Attachment?
	local root = model:FindFirstChild("Root")
	local attachment = root and root:FindFirstChild(name)
	return if attachment and attachment:IsA("Attachment") then attachment else nil
end

local function getPath(plot: Model, item: any): { Vector3 }
	local model = getModel(plot, item.Id)
	if not model then
		return {}
	end
	if item.ItemId == "ConveyorDropper" then
		local drop = getAttachment(model, "DropPoint")
		local finish = getAttachment(model, "PathStart")
		return if drop and finish then { drop.WorldPosition, finish.WorldPosition } else {}
	elseif item.ItemId == "CornerConveyor" then
		local start = getAttachment(model, "PathStart")
		local corner = getAttachment(model, "PathCorner")
		local finish = getAttachment(model, "PathEnd")
		if item.Config.ConnectorMode == 2 then
			return if start and corner and finish then { finish.WorldPosition, corner.WorldPosition, start.WorldPosition } else {}
		end
		return if start and corner and finish then { start.WorldPosition, corner.WorldPosition, finish.WorldPosition } else {}
	elseif item.ItemId == "ConveyorCollectionBin" then
		local start = getAttachment(model, "PathStart")
		local store = getAttachment(model, "StorePoint")
		return if start and store then { start.WorldPosition, store.WorldPosition } else {}
	end
	local start = getAttachment(model, "PathStart")
	local finish = getAttachment(model, "PathEnd")
	return if start and finish then { start.WorldPosition, finish.WorldPosition } else {}
end

local function pathPosition(points: { Vector3 }, progress: number): Vector3?
	if #points < 2 then
		return nil
	end
	if #points == 2 then
		return points[1]:Lerp(points[2], progress)
	end
	if progress <= 0.5 then
		return points[1]:Lerp(points[2], progress * 2)
	end
	return points[2]:Lerp(points[3], (progress - 0.5) * 2)
end

local function findNext(data: any, item: any): any?
	local definition = FactoryConfig.Get(item.ItemId)
	local mode = definition and FactoryConfig.GetConnectorMode(definition, item.Config.ConnectorMode)
	if not mode or not mode.Output then
		return nil
	end
	local outputX, outputZ, outputDirection = FactoryGrid.GetConnector(item, mode.Output)
	if not mode.Output.SharedCell then
		local dx, dz = FactoryGrid.DirectionOffset(outputDirection)
		outputX += dx
		outputZ += dz
	end
	for _, candidate in data.Factory.PlacedItems do
		if candidate.Id == item.Id then
			continue
		end
		local candidateDefinition = FactoryConfig.Get(candidate.ItemId)
		if not candidateDefinition then
			continue
		end
		for _, cell in FactoryGrid.GetFootprint(candidateDefinition, candidate.GridX, candidate.GridZ, candidate.Rotation) do
			if cell.Kind == "Solid" and cell.X == outputX and cell.Z == outputZ then
				local candidateMode = FactoryConfig.GetConnectorMode(candidateDefinition, candidate.Config.ConnectorMode)
				if mode.Output.SharedCell and candidate.ItemId == "StraightConveyor" and candidateMode and candidateMode.Output then
					local candidateX, candidateZ, candidateOutputDirection =
						FactoryGrid.GetConnector(candidate, candidateMode.Output)
					if
						candidateX == outputX
						and candidateZ == outputZ
						and candidateOutputDirection ~= FactoryGrid.Opposite(outputDirection)
					then
						return candidate
					end
				elseif candidateMode and candidateMode.Input then
					local inputX, inputZ, inputDirection = FactoryGrid.GetConnector(candidate, candidateMode.Input)
					if inputX == outputX and inputZ == outputZ and inputDirection == FactoryGrid.Opposite(outputDirection) then
						return candidate
					end
				end
			end
		end
	end
	return nil
end

local function createVisual(runtime: Runtime, resourceType: ResourceTypes.ResourceId): BasePart?
	local grid = runtime.Plot:FindFirstChild("BuildGrid")
	local folder = grid and grid:FindFirstChild("RuntimeItems")
	if not folder then
		return nil
	end
	local part = Instance.new("Part")
	local definition = ResourceConfig.Get(resourceType)
	if not definition then
		return nil
	end
	part.Name = HttpService:GenerateGUID(false)
	part.Size = definition.DropAppearance.Size
	part.Color = definition.DropAppearance.Color
	part.Material = definition.DropAppearance.Material
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Parent = folder
	return part
end

local function removeMoving(runtime: Runtime, moving: MovingItem)
	runtime.Items[moving.Id] = nil
	moving.Visual:Destroy()
end

local function finishPiece(runtime: Runtime, moving: MovingItem, current: any)
	local data = DataService.TryGet(runtime.Player)
	if not data then
		return
	end
	if current.ItemId == "ConveyorUpgrader" then
		moving.Multiplier *= FactoryConfig.Items.ConveyorUpgrader.UpgraderMultiplier or 1
	elseif current.ItemId == "ConveyorCollectionBin" then
		local capacity = FactoryConfig.Items.ConveyorCollectionBin.CollectionCapacity or 50
		local amount = moving.Amount * moving.Multiplier
		if
			(current.State.StoredResourceType == nil or current.State.StoredResourceType == moving.ResourceType)
			and current.State.StoredAmount + amount <= capacity
		then
			current.State.StoredResourceType = moving.ResourceType
			current.State.StoredAmount += amount
			QuestService.Notify(runtime.Player, "FactoryResourceCollected", amount)
			FactoryService.Publish(runtime.Player)
			removeMoving(runtime, moving)
		end
		return
	end
	local nextItem = findNext(data, current)
	if nextItem then
		if moving.Visited[nextItem.Id] then
			EconomyService.AddResource(data, moving.ResourceType, moving.Amount)
			DisplayService.UpdateAll(runtime.Player, runtime.Plot)
			removeMoving(runtime, moving)
			return
		end
		moving.Visited[nextItem.Id] = true
		moving.CurrentItemId = nextItem.Id
		local currentDefinition = FactoryConfig.Get(current.ItemId)
		local currentMode = currentDefinition and FactoryConfig.GetConnectorMode(currentDefinition, current.Config.ConnectorMode)
		moving.Progress = if currentMode and currentMode.Output and currentMode.Output.SharedCell then 0.5 else 0
		return
	end
	EconomyService.AddResource(data, moving.ResourceType, moving.Amount)
	DisplayService.UpdateAll(runtime.Player, runtime.Plot)
	removeMoving(runtime, moving)
end

local function dispatch(runtime: Runtime, data: any, dropper: any)
	for _, moving in runtime.Items do
		if moving.SourceDropperId == dropper.Id then
			return
		end
	end
	local resourceType = dropper.Config.ResourceType
	local definition = ResourceConfig.Get(resourceType)
	if
		not resourceType
		or not definition
		or not definition.FactoryEnabled
		or not findNext(data, dropper)
		or not EconomyService.RemoveResource(data, resourceType, 1)
	then
		return
	end
	local visual = createVisual(runtime, resourceType)
	if not visual then
		EconomyService.AddResource(data, resourceType, 1)
		return
	end
	local id = visual.Name
	runtime.Items[id] = {
		Id = id,
		ResourceType = resourceType,
		Amount = 1,
		Multiplier = 1,
		SourceDropperId = dropper.Id,
		CurrentItemId = dropper.Id,
		Progress = 0,
		Visual = visual,
		Visited = { [dropper.Id] = true },
	}
	DisplayService.UpdateAll(runtime.Player, runtime.Plot)
end

local function tick(runtime: Runtime, deltaTime: number)
	local data = DataService.TryGet(runtime.Player)
	if not data then
		return
	end
	for id, item in data.Factory.PlacedItems do
		if item.ItemId == "ConveyorDropper" then
			runtime.Dispatch[id] = (runtime.Dispatch[id] or 0) - deltaTime
			if runtime.Dispatch[id] <= 0 then
				runtime.Dispatch[id] = FactoryConfig.DispatchInterval
				dispatch(runtime, data, item)
			end
		end
	end
	for _, moving in runtime.Items do
		local current = data.Factory.PlacedItems[moving.CurrentItemId]
		local points = current and getPath(runtime.Plot, current) or {}
		if not current or #points < 2 then
			EconomyService.AddResource(data, moving.ResourceType, moving.Amount)
			DisplayService.UpdateAll(runtime.Player, runtime.Plot)
			removeMoving(runtime, moving)
			continue
		end
		local distance = 0
		for index = 1, #points - 1 do
			distance += (points[index + 1] - points[index]).Magnitude
		end
		moving.Progress = math.clamp(moving.Progress + deltaTime * FactoryConfig.ConveyorSpeed / math.max(distance, 0.1), 0, 1)
		local position = pathPosition(points, moving.Progress)
		if position then
			moving.Visual.Position = position
			moving.Visual:SetAttribute("Multiplier", moving.Multiplier)
		end
		if moving.Progress >= 1 then
			finishPiece(runtime, moving, current)
		end
	end
end

function ConveyorService.HasActiveItem(player: Player, placedItemId: string): boolean
	local runtime = Local.runtimes[player]
	if runtime then
		for _, moving in runtime.Items do
			if moving.CurrentItemId == placedItemId then
				return true
			end
		end
	end
	return false
end

function ConveyorService.SetupPlayer(player: Player, plot: Model)
	ConveyorService.CleanupPlayer(player)
	local runtime: Runtime = { Connection = nil, Dispatch = {}, Items = {}, Player = player, Plot = plot }
	Local.runtimes[player] = runtime
	runtime.Connection = RunService.Heartbeat:Connect(function(deltaTime)
		tick(runtime, math.min(deltaTime, 0.25))
	end)
end

function ConveyorService.CleanupPlayer(player: Player)
	local runtime = Local.runtimes[player]
	Local.runtimes[player] = nil
	if not runtime then
		return
	end
	if runtime.Connection then
		runtime.Connection:Disconnect()
	end
	local data = DataService.TryGet(player)
	if data then
		for _, moving in runtime.Items do
			EconomyService.AddResource(data, moving.ResourceType, moving.Amount)
			moving.Visual:Destroy()
		end
	end
end

return ConveyorService
