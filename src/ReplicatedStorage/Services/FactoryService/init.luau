--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Services.DataService)
local DisplayService = require(ReplicatedStorage.Services.DisplayService)
local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local FactoryConfig = require(ReplicatedStorage.Factory.Config)
local FactoryGrid = require(ReplicatedStorage.Factory.Grid)
local FactoryTypes = require(ReplicatedStorage.Factory.Types)
local FeedbackService = require(ReplicatedStorage.Services.FeedbackService)
local InteractionConfig = require(ReplicatedStorage.Interaction.Config)
local InteractionService = require(ReplicatedStorage.Services.InteractionService)
local PlotService = require(ReplicatedStorage.Services.PlotService)
local QuestService = require(ReplicatedStorage.Services.QuestService)
local RateLimit = require(ReplicatedStorage.Packages.RateLimit)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)
local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local UnlockService = require(ReplicatedStorage.Services.UnlockService)
local getClosestPoint = require(ReplicatedStorage.Interaction.getClosestPoint)

type Runtime = {
	Models: { [string]: Model },
	Plot: Model,
}

local assets = ReplicatedStorage:WaitForChild("Assets")
local templates = assets:WaitForChild("BuildItemTemplates")
local requestEvent = RemoteManager.FactoryRequest :: RemoteEvent
local stateEvent = RemoteManager.FactoryStateUpdate :: RemoteEvent
local resultEvent = RemoteManager.FactoryActionResult :: RemoteEvent
local menuEvent = RemoteManager.FactoryMenu :: RemoteEvent
local getStateFunction = RemoteManager.GetFactoryState :: RemoteFunction
local rateLimit = RateLimit.New(15)

local Local = {
	runtimes = {} :: { [Player]: Runtime },
	started = false,
}

local FactoryService = {}

local function copyState(data: any): FactoryTypes.ClientState
	return {
		Inventory = table.clone(data.Factory.Inventory),
		PlacedItems = table.clone(data.Factory.PlacedItems),
	}
end

function FactoryService.Publish(player: Player)
	local data = DataService.TryGet(player)
	if data then
		stateEvent:FireClient(player, copyState(data))
	end
end

local function result(player: Player, success: boolean, message: string)
	resultEvent:FireClient(player, success, message)
	if message ~= "" then
		FeedbackService.Send(player, message)
	end
	FactoryService.Publish(player)
end

local function getFolders(plot: Model): (Folder?, Folder?)
	local grid = plot:FindFirstChild("BuildGrid")
	local placed = grid and grid:FindFirstChild("PlacedItems")
	local runtime = grid and grid:FindFirstChild("RuntimeItems")
	return if placed and placed:IsA("Folder") then placed else nil,
		if runtime and runtime:IsA("Folder") then runtime else nil
end

local function isBlocked(plot: Model, bounds: BasePart, gridX: number, gridZ: number): boolean
	local grid = plot:FindFirstChild("BuildGrid")
	local blockers = grid and grid:FindFirstChild("Blockers")
	if not blockers then
		return true
	end
	local world = FactoryGrid.GridToWorld(bounds, gridX, gridZ)
	for _, blocker in blockers:GetChildren() do
		if blocker:IsA("BasePart") then
			local point = blocker.CFrame:PointToObjectSpace(world)
			if math.abs(point.X) < blocker.Size.X * 0.5 and math.abs(point.Z) < blocker.Size.Z * 0.5 then
				return true
			end
		end
	end
	return false
end

local function buildOccupancy(data: any, ignoreId: string?): ({ [string]: FactoryTypes.Occupant }, { [string]: string })
	local solid = {}
	local sockets = {}
	for id, item in data.Factory.PlacedItems do
		if id == ignoreId then
			continue
		end
		local definition = FactoryConfig.Get(item.ItemId)
		if not definition then
			continue
		end
		for _, cell in FactoryGrid.GetFootprint(definition, item.GridX, item.GridZ, item.Rotation) do
			local key = FactoryGrid.CellKey(cell.X, cell.Z)
			if cell.Kind == "OutputSocket" then
				sockets[key] = id
			else
				solid[key] = { ItemId = id, Kind = cell.Kind }
			end
		end
	end
	return solid, sockets
end

local function socketCompatible(
	data: any,
	itemId: FactoryTypes.ItemId,
	gridX: number,
	gridZ: number,
	rotation: number,
	socketOwnerId: string
): boolean
	if itemId ~= "StraightConveyor" then
		return false
	end
	local owner = data.Factory.PlacedItems[socketOwnerId]
	local ownerDefinition = owner and FactoryConfig.Get(owner.ItemId)
	local definition = FactoryConfig.Get(itemId)
	local ownerMode = ownerDefinition and FactoryConfig.GetConnectorMode(ownerDefinition, owner.Config.ConnectorMode)
	local mode = definition and FactoryConfig.GetConnectorMode(definition, 1)
	if not owner or not ownerMode or not ownerMode.Output or not mode or not mode.Output then
		return false
	end
	local outputX, outputZ, outputDirection = FactoryGrid.GetConnector(owner, ownerMode.Output)
	local temporary = {
		Id = "",
		ItemId = itemId,
		GridX = gridX,
		GridZ = gridZ,
		Rotation = rotation,
		Config = {},
		State = { StoredAmount = 0 },
	} :: any
	local straightX, straightZ, straightOutputDirection = FactoryGrid.GetConnector(temporary, mode.Output)
	return outputX == straightX
		and outputZ == straightZ
		and straightOutputDirection ~= FactoryGrid.Opposite(outputDirection)
end

local function outputSocketCanShareWithSolid(
	data: any,
	itemId: FactoryTypes.ItemId,
	gridX: number,
	gridZ: number,
	rotation: number,
	solidOwnerId: string
): boolean
	local solidOwner = data.Factory.PlacedItems[solidOwnerId]
	if not solidOwner or solidOwner.ItemId ~= "StraightConveyor" or itemId ~= "ConveyorDropper" then
		return false
	end
	local definition = FactoryConfig.Get(itemId)
	local mode = definition and FactoryConfig.GetConnectorMode(definition, 1)
	local solidDefinition = FactoryConfig.Get(solidOwner.ItemId)
	local solidMode = solidDefinition and FactoryConfig.GetConnectorMode(solidDefinition, solidOwner.Config.ConnectorMode)
	if not mode or not mode.Output or not solidMode or not solidMode.Output then
		return false
	end
	local temporary = {
		Id = "",
		ItemId = itemId,
		GridX = gridX,
		GridZ = gridZ,
		Rotation = rotation,
		Config = { ConnectorMode = 1 },
		State = { StoredAmount = 0 },
	} :: any
	local outputX, outputZ, outputDirection = FactoryGrid.GetConnector(temporary, mode.Output)
	local straightX, straightZ, straightOutputDirection = FactoryGrid.GetConnector(solidOwner, solidMode.Output)
	return outputX == straightX
		and outputZ == straightZ
		and straightOutputDirection ~= FactoryGrid.Opposite(outputDirection)
end

function FactoryService.CanPlace(
	player: Player,
	itemId: FactoryTypes.ItemId,
	gridX: number,
	gridZ: number,
	rotation: number,
	ignoreId: string?
): (boolean, string)
	local data = DataService.TryGet(player)
	local plot = PlotService.TryGet(player)
	local bounds = plot and FactoryGrid.GetBounds(plot)
	local definition = FactoryConfig.Get(itemId)
	if not data or not plot or not bounds or not definition then
		return false, "Factory is unavailable"
	end
	if gridX % 1 ~= 0 or gridZ % 1 ~= 0 or not FactoryConfig.IsRotationAllowed(definition, rotation) then
		return false, "Invalid grid position or rotation"
	end
	local solid, sockets = buildOccupancy(data, ignoreId)
	for _, cell in FactoryGrid.GetFootprint(definition, gridX, gridZ, rotation) do
		if not FactoryGrid.IsInside(bounds, cell.X, cell.Z) or isBlocked(plot, bounds, cell.X, cell.Z) then
			return false, "That cell is outside the available build area"
		end
		local key = FactoryGrid.CellKey(cell.X, cell.Z)
		if cell.Kind == "Solid" then
			if solid[key] then
				return false, "That cell is occupied"
			end
			if sockets[key] and not socketCompatible(data, itemId, gridX, gridZ, rotation, sockets[key]) then
				return false, "The Straight Conveyor cannot face the Dropper body"
			end
		elseif solid[key] then
			if not outputSocketCanShareWithSolid(data, itemId, gridX, gridZ, rotation, solid[key].ItemId) then
				return false, "The Dropper output socket is occupied incorrectly"
			end
		elseif sockets[key] then
			return false, "That output socket overlaps another Dropper"
		end
	end
	return true, ""
end

local function isConnectedFrom(data: any, candidate: any, sourceItemId: FactoryTypes.ItemId): boolean
	local candidateDefinition = FactoryConfig.Get(candidate.ItemId)
	local candidateMode = candidateDefinition and FactoryConfig.GetConnectorMode(candidateDefinition, candidate.Config.ConnectorMode)
	if not candidateMode or not candidateMode.Input then
		return false
	end
	local inputX, inputZ, inputDirection = FactoryGrid.GetConnector(candidate, candidateMode.Input)
	for _, source in data.Factory.PlacedItems do
		if source.ItemId ~= sourceItemId then
			continue
		end
		local sourceDefinition = FactoryConfig.Get(source.ItemId)
		local sourceMode = sourceDefinition and FactoryConfig.GetConnectorMode(sourceDefinition, source.Config.ConnectorMode)
		if not sourceMode or not sourceMode.Output then
			continue
		end
		local outputX, outputZ, outputDirection = FactoryGrid.GetConnector(source, sourceMode.Output)
		if sourceMode.Output.SharedCell then
			if candidate.ItemId ~= "StraightConveyor" or not candidateMode.Output then
				continue
			end
			local candidateX, candidateZ, candidateOutputDirection = FactoryGrid.GetConnector(candidate, candidateMode.Output)
			if
				outputX == candidateX
				and outputZ == candidateZ
				and candidateOutputDirection ~= FactoryGrid.Opposite(outputDirection)
			then
				return true
			end
			continue
		else
			local dx, dz = FactoryGrid.DirectionOffset(outputDirection)
			outputX += dx
			outputZ += dz
		end
		if outputX == inputX and outputZ == inputZ and inputDirection == FactoryGrid.Opposite(outputDirection) then
			return true
		end
	end
	return false
end

local function setModelAttributes(player: Player, model: Model, item: FactoryTypes.PlacedItem)
	model.Name = item.Id
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanQuery = true
		end
	end
	model:SetAttribute("PlacedItemId", item.Id)
	model:SetAttribute("BuildItemId", item.ItemId)
	model:SetAttribute("InteractionId", "ManageFactoryItem")
	model:SetAttribute("InteractionActionText", "Manage")
	model:SetAttribute("InteractionObjectText", FactoryConfig.Items[item.ItemId].DisplayName)
	model:SetAttribute("InteractionMaxDistance", 12)
	model:SetAttribute("InteractionOwnerUserId", player.UserId)
	model:SetAttribute(InteractionConfig.Attributes.Scope, InteractionConfig.Scopes.OwnedPlot)
	CollectionService:AddTag(model, InteractionConfig.Tag)
end

local function spawnModel(player: Player, item: FactoryTypes.PlacedItem): Model?
	local runtime = Local.runtimes[player]
	local definition = FactoryConfig.Get(item.ItemId)
	local bounds = runtime and FactoryGrid.GetBounds(runtime.Plot)
	local placedFolder = runtime and getFolders(runtime.Plot)
	local template = definition and templates:FindFirstChild(definition.TemplateName)
	if not runtime or not definition or not bounds or not placedFolder or not template or not template:IsA("Model") then
		return nil
	end
	local model = template:Clone()
	setModelAttributes(player, model, item)
	model.Parent = placedFolder
	model:PivotTo(FactoryGrid.GetCFrame(bounds, item.GridX, item.GridZ, item.Rotation))
	runtime.Models[item.Id] = model
	return model
end

local function destroyModel(player: Player, itemId: string)
	local runtime = Local.runtimes[player]
	local model = runtime and runtime.Models[itemId]
	if runtime then
		runtime.Models[itemId] = nil
	end
	if model then
		InteractionService.UnregisterTarget(model)
		model:Destroy()
	end
end

local function isNearPlacedItem(player: Player, placedItemId: string): boolean
	local runtime = Local.runtimes[player]
	local model = runtime and runtime.Models[placedItemId]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return model ~= nil
		and root ~= nil
		and root:IsA("BasePart")
		and (root.Position - getClosestPoint(model, root.Position)).Magnitude <= 12
end

local function purchase(player: Player, itemId: FactoryTypes.ItemId)
	local data = DataService.TryGet(player)
	local definition = FactoryConfig.Get(itemId)
	if not data or not definition then
		return
	end
	if not EconomyService.TrySpendGold(data, definition.Price) then
		result(player, false, `Need {definition.Price} Gold`)
		return
	end
	data.Factory.Inventory[itemId] = (data.Factory.Inventory[itemId] or 0) + 1
	DisplayService.UpdateAll(player, PlotService.Get(player))
	result(player, true, `{definition.DisplayName} added to your hotbar`)
end

local function place(player: Player, itemId: FactoryTypes.ItemId, gridX: number, gridZ: number, rotation: number)
	local data = DataService.TryGet(player)
	if not data or (data.Factory.Inventory[itemId] or 0) <= 0 then
		result(player, false, "You do not own that unplaced item")
		return
	end
	local tutorialItems: { [string]: FactoryTypes.ItemId } = {
		BuildFirstWorkerHome = "WorkerHome",
		BuildStoneWorkerHome = "WorkerHome",
		BuildConveyor1 = "ConveyorDropper",
		BuildUpgrader1 = "StraightConveyor",
		BuildCoalProcessor = "ConveyorCollectionBin",
		BuildUpgrader2 = "ConveyorUpgrader",
		UpgradeConveyor1 = "WorkerHome",
	}
	local requiredItem = tutorialItems[data.Quest.CurrentQuestId]
	if requiredItem and itemId ~= requiredItem then
		result(player, false, `Tutorial: place {FactoryConfig.Items[requiredItem].DisplayName} next`)
		return
	end
	local valid, reason = FactoryService.CanPlace(player, itemId, gridX, gridZ, rotation)
	if not valid then
		result(player, false, reason)
		return
	end
	local tutorialSourceItems: { [string]: FactoryTypes.ItemId } = {
		BuildUpgrader1 = "ConveyorDropper",
		BuildCoalProcessor = "StraightConveyor",
		BuildUpgrader2 = "StraightConveyor",
	}
	local requiredSource = tutorialSourceItems[data.Quest.CurrentQuestId]
	local candidate = {
		Id = "",
		ItemId = itemId,
		GridX = gridX,
		GridZ = gridZ,
		Rotation = rotation,
		Config = { ConnectorMode = 1 },
		State = { StoredAmount = 0 },
	} :: any
	if requiredSource and not isConnectedFrom(data, candidate, requiredSource) then
		result(player, false, `Tutorial: connect this after the {FactoryConfig.Items[requiredSource].DisplayName}`)
		return
	end
	local id = HttpService:GenerateGUID(false)
	local item: FactoryTypes.PlacedItem = {
		Id = id,
		ItemId = itemId,
		GridX = gridX,
		GridZ = gridZ,
		Rotation = rotation :: FactoryTypes.Rotation,
		Config = {
			ConnectorMode = 1,
				ResourceType = if itemId == "ConveyorDropper" then ResourceConfig.GetDefaultFactoryResource() else nil,
		},
		State = { StoredAmount = 0, StoredResourceType = nil },
	}
	data.Factory.PlacedItems[id] = item
	data.Factory.Inventory[itemId] -= 1
	if not spawnModel(player, item) then
		data.Factory.PlacedItems[id] = nil
		data.Factory.Inventory[itemId] += 1
		result(player, false, "The item template could not be spawned")
		return
	end
	QuestService.Notify(player, `FactoryPlaced:{itemId}`)
	result(player, true, `{FactoryConfig.Items[itemId].DisplayName} placed`)
end

local function move(player: Player, placedItemId: string, gridX: number, gridZ: number, rotation: number)
	local data = DataService.TryGet(player)
	local item = data and data.Factory.PlacedItems[placedItemId]
	if not data or not item then
		result(player, false, "Placed item not found")
		return
	end
	if
		(data.Quest.CurrentQuestId == "BuildConveyor2" or data.Quest.CurrentQuestId == "BuildCollectionPoint")
		and item.ItemId ~= "ConveyorCollectionBin"
	then
		result(player, false, "Tutorial: move the Collection Bin")
		return
	end
	local ConveyorService = require(ReplicatedStorage.Services.ConveyorService)
	if ConveyorService.HasActiveItem(player, placedItemId) then
		result(player, false, "Wait for the active conveyor item to leave this piece")
		return
	end
	local valid, reason = FactoryService.CanPlace(player, item.ItemId, gridX, gridZ, rotation, placedItemId)
	if not valid then
		result(player, false, reason)
		return
	end
	local candidate = table.clone(item)
	candidate.GridX = gridX
	candidate.GridZ = gridZ
	candidate.Rotation = rotation
	if data.Quest.CurrentQuestId == "BuildCollectionPoint" and not isConnectedFrom(data, candidate, "ConveyorUpgrader") then
		result(player, false, "Tutorial: reconnect the Collection Bin after the Conveyor Upgrader")
		return
	end
	local oldGridX, oldGridZ, oldRotation = item.GridX, item.GridZ, item.Rotation
	item.GridX = gridX
	item.GridZ = gridZ
	item.Rotation = rotation
	destroyModel(player, placedItemId)
	if not spawnModel(player, item) then
		item.GridX = oldGridX
		item.GridZ = oldGridZ
		item.Rotation = oldRotation
		spawnModel(player, item)
		result(player, false, "The item could not be moved")
		return
	end
	QuestService.Notify(player, `FactoryMoved:{item.ItemId}`)
	result(player, true, "Item moved")
end

function FactoryService.WithdrawCollection(player: Player, requestedAmount: number): (number, FactoryTypes.ResourceType?)
	local data = DataService.TryGet(player)
	if not data or requestedAmount <= 0 then
		return 0, nil
	end
	for _, item in data.Factory.PlacedItems do
		if item.ItemId == "ConveyorCollectionBin" and item.State.StoredAmount > 0 and item.State.StoredResourceType then
			local withdrawn = math.min(requestedAmount, item.State.StoredAmount)
			local resourceType = item.State.StoredResourceType
			item.State.StoredAmount -= withdrawn
			if item.State.StoredAmount <= 0 then
				item.State.StoredResourceType = nil
			end
			FactoryService.Publish(player)
			return withdrawn, resourceType
		end
	end
	return 0, nil
end

local function configure(player: Player, placedItemId: string, value: any)
	local data = DataService.TryGet(player)
	local item = data and data.Factory.PlacedItems[placedItemId]
	if not item then
		return
	end
	local resourceDefinition = ResourceConfig.Get(value)
	if
		item.ItemId == "ConveyorDropper"
		and resourceDefinition
		and resourceDefinition.FactoryEnabled
		and UnlockService.CanCollectResource(data, value)
		and EconomyService.GetResourceAmount(data, value) > 0
	then
		item.Config.ResourceType = value
		result(player, true, `Dropper set to {value}`)
	elseif item.ItemId == "CornerConveyor" and (value == 1 or value == 2) then
		local ConveyorService = require(ReplicatedStorage.Services.ConveyorService)
		if ConveyorService.HasActiveItem(player, placedItemId) then
			result(player, false, "Wait for the active conveyor item to leave this piece")
			return
		end
		item.Config.ConnectorMode = value
		result(player, true, `Corner flow mode {value}`)
	else
		result(player, false, "That configuration is not currently available")
	end
end

local function collect(player: Player, placedItemId: string)
	local data = DataService.TryGet(player)
	local plot = PlotService.TryGet(player)
	local item = data and data.Factory.PlacedItems[placedItemId]
	if not data or not plot or not item or item.ItemId ~= "ConveyorCollectionBin" then
		return
	end
	if not isNearPlacedItem(player, placedItemId) then
		result(player, false, "Move closer to collect from the Bin")
		return
	end
	local resourceType = item.State.StoredResourceType
	if not resourceType or item.State.StoredAmount <= 0 then
		result(player, false, "Collection Bin is empty")
		return
	end
	local accepted = EconomyService.AddResource(data, resourceType, item.State.StoredAmount)
	item.State.StoredAmount -= accepted
	if item.State.StoredAmount <= 0 then
		item.State.StoredResourceType = nil
	end
	DisplayService.UpdateAll(player, plot)
	QuestService.Notify(player, "FactoryBinCollected", accepted)
	result(player, accepted > 0, if accepted > 0 then `+{accepted} {resourceType} stored` else "Storage full")
end

function FactoryService.HandleInteraction(player: Player, target: Model)
	local data = DataService.TryGet(player)
	local id = target:GetAttribute("PlacedItemId")
	local item = data and typeof(id) == "string" and data.Factory.PlacedItems[id] or nil
	if not item then
		return
	end
	local resourceOptions = {}
	for _, resourceId in ResourceConfig.Order do
		local definition = ResourceConfig.Get(resourceId)
		if
			definition
			and definition.FactoryEnabled
			and UnlockService.CanCollectResource(data, resourceId)
			and EconomyService.GetResourceAmount(data, resourceId) > 0
		then
			table.insert(resourceOptions, resourceId)
		end
	end
	menuEvent:FireClient(player, {
		PlacedItemId = item.Id,
		ItemId = item.ItemId,
		DisplayName = FactoryConfig.Items[item.ItemId].DisplayName,
		ResourceType = item.Config.ResourceType,
		ConnectorMode = item.Config.ConnectorMode,
		GridX = item.GridX,
		GridZ = item.GridZ,
		Rotation = item.Rotation,
		ResourceOptions = resourceOptions,
		StoredAmount = item.State.StoredAmount,
		StoredResourceType = item.State.StoredResourceType,
	})
end

function FactoryService.GetAvailableWorkerHome(data: any): string?
	local used = {}
	for _, npc in data.NPCs do
		used[npc.HomeSlotId] = true
	end
	for id, item in data.Factory.PlacedItems do
		if item.ItemId == "WorkerHome" and not used[id] then
			return id
		end
	end
	return nil
end

function FactoryService.GetWorkerHomeCFrame(player: Player, homeId: string): CFrame?
	local runtime = Local.runtimes[player]
	local model = runtime and runtime.Models[homeId]
	local root = model and model:FindFirstChild("Root")
	local stand = root and root:FindFirstChild("WorkerStand")
	return if stand and stand:IsA("Attachment") then stand.WorldCFrame else model and model:GetPivot() or nil
end

function FactoryService.GetFirstCollectionModel(player: Player): Model?
	local data = DataService.TryGet(player)
	local runtime = Local.runtimes[player]
	if data and runtime then
		for id, item in data.Factory.PlacedItems do
			if item.ItemId == "ConveyorCollectionBin" then
				return runtime.Models[id]
			end
		end
	end
	return nil
end

local function normalizeFactoryData(player: Player)
	local data = DataService.Get(player)
	for itemId, count in data.Factory.Inventory do
		if not FactoryConfig.IsItemId(itemId) or typeof(count) ~= "number" or count < 0 then
			data.Factory.Inventory[itemId] = nil
		else
			data.Factory.Inventory[itemId] = math.floor(count)
		end
	end
	local invalid = {}
	for id, item in data.Factory.PlacedItems do
		local definition = typeof(item) == "table" and FactoryConfig.Get(item.ItemId) or nil
		if
			typeof(id) ~= "string"
			or not definition
			or item.Id ~= id
			or typeof(item.GridX) ~= "number"
			or typeof(item.GridZ) ~= "number"
			or typeof(item.Rotation) ~= "number"
			or typeof(item.Config) ~= "table"
			or typeof(item.State) ~= "table"
			or not FactoryConfig.IsRotationAllowed(definition, item.Rotation)
		then
			table.insert(invalid, id)
			continue
		end
		item.Config.ConnectorMode = if FactoryConfig.GetConnectorMode(definition, item.Config.ConnectorMode) then item.Config.ConnectorMode else 1
		if item.ItemId == "ConveyorDropper" then
			local resource = ResourceConfig.Get(item.Config.ResourceType)
			if not resource or not resource.FactoryEnabled then
				item.Config.ResourceType = ResourceConfig.GetDefaultFactoryResource()
			end
		else
			item.Config.ResourceType = nil
		end
		local capacity = definition.CollectionCapacity or math.huge
		item.State.StoredAmount = if typeof(item.State.StoredAmount) == "number"
			then math.clamp(item.State.StoredAmount, 0, capacity)
			else 0
		if item.ItemId ~= "ConveyorCollectionBin" or not ResourceConfig.IsValid(item.State.StoredResourceType) then
			item.State.StoredAmount = 0
			item.State.StoredResourceType = nil
		elseif item.State.StoredAmount <= 0 then
			item.State.StoredResourceType = nil
		end
	end
	for _, id in invalid do
		local item = data.Factory.PlacedItems[id]
		if typeof(item) == "table" and FactoryConfig.IsItemId(item.ItemId) then
			data.Factory.Inventory[item.ItemId] = (data.Factory.Inventory[item.ItemId] or 0) + 1
		end
		data.Factory.PlacedItems[id] = nil
	end
end

local function retireLegacyPlotContent(plot: Model)
	local machine = plot:FindFirstChild("Machine")
	if machine then
		machine:Destroy()
	end
	local workerHomes = plot:FindFirstChild("WorkerHomes")
	if workerHomes then
		workerHomes:Destroy()
	end
	local buildGrid = plot:FindFirstChild("BuildGrid")
	local blockers = buildGrid and buildGrid:FindFirstChild("Blockers")
	if blockers then
		for _, name in { "LegacyMachine", "WorkerHomes" } do
			local blocker = blockers:FindFirstChild(name)
			if blocker then
				blocker:Destroy()
			end
		end
	end
end

function FactoryService.SetupPlayer(player: Player, plot: Model)
	FactoryService.CleanupPlayer(player)
	retireLegacyPlotContent(plot)
	Local.runtimes[player] = { Models = {}, Plot = plot }
	normalizeFactoryData(player)
	local invalid = {}
	for _, item in DataService.Get(player).Factory.PlacedItems do
		local valid = FactoryService.CanPlace(player, item.ItemId, item.GridX, item.GridZ, item.Rotation, item.Id)
		if valid and spawnModel(player, item) then
			continue
		end
		table.insert(invalid, item.Id)
	end
	local data = DataService.Get(player)
	for _, id in invalid do
		local item = data.Factory.PlacedItems[id]
		if item then
			data.Factory.Inventory[item.ItemId] = (data.Factory.Inventory[item.ItemId] or 0) + 1
			data.Factory.PlacedItems[id] = nil
		end
	end
	FactoryService.Publish(player)
end

function FactoryService.CleanupPlayer(player: Player)
	Local.runtimes[player] = nil
end

function FactoryService.Start()
	if Local.started then
		return
	end
	Local.started = true
	getStateFunction.OnServerInvoke = function(player)
		local data = DataService.TryGet(player)
		return if data then copyState(data) else nil
	end
	requestEvent.OnServerEvent:Connect(function(player, action, a, b, c, d)
		if not rateLimit:CheckRate(player) or typeof(action) ~= "string" then
			return
		end
		if action == "Purchase" and FactoryConfig.IsItemId(a) then
			purchase(player, a)
		elseif action == "Place" and FactoryConfig.IsItemId(a) and typeof(b) == "number" and typeof(c) == "number" and typeof(d) == "number" then
			place(player, a, b, c, d)
		elseif action == "Move" and typeof(a) == "string" and typeof(b) == "number" and typeof(c) == "number" and typeof(d) == "number" then
			move(player, a, b, c, d)
		elseif action == "Configure" and typeof(a) == "string" then
			configure(player, a, b)
		elseif action == "Collect" and typeof(a) == "string" then
			collect(player, a)
		end
	end)
end

return FactoryService
