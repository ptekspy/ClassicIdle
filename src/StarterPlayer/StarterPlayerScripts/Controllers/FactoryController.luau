--!strict

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local UIState = require(script.Parent.Parent.UI.UIState)

local FactoryConfig = require(ReplicatedStorage.Factory.Config)
local FactoryGrid = require(ReplicatedStorage.Factory.Grid)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)

local player = Players.LocalPlayer
local templates = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("BuildItemTemplates")
local requestEvent = RemoteManager.FactoryRequest :: RemoteEvent
local stateEvent = RemoteManager.FactoryStateUpdate :: RemoteEvent
local resultEvent = RemoteManager.FactoryActionResult :: RemoteEvent
local menuEvent = RemoteManager.FactoryMenu :: RemoteEvent
local getStateFunction = RemoteManager.GetFactoryState :: RemoteFunction

local Local = {
	state = nil :: any,
	selectedItemId = nil :: string?,
	movingItemId = nil :: string?,
	rotation = 0,
	gridX = 1,
	gridZ = 1,
	valid = false,
	ghost = nil :: Model?,
	started = false,
	shopOpen = false,
	managePayload = nil :: any,
}

local FactoryController = {}

local publish: () -> () = function() end


local function getPlot(): Model?
	local plots = workspace:FindFirstChild("PlayerPlots")
	if plots then
		for _, plot in plots:GetChildren() do
			if plot:IsA("Model") and plot:GetAttribute("OwnerUserId") == player.UserId then
				return plot
			end
		end
	end
	return nil
end


local function stopBuild()
	Local.selectedItemId = nil
	Local.movingItemId = nil
	Local.valid = false
	if Local.ghost then
		Local.ghost:Destroy()
		Local.ghost = nil
	end

	publish()
end

local function setGhostColor(valid: boolean)
	if not Local.ghost then
		return
	end
	for _, descendant in Local.ghost:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Transparency = math.max(descendant.Transparency, 0.45)
			descendant.Color = if valid then Color3.fromRGB(80, 220, 100) else Color3.fromRGB(225, 70, 70)
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end
end

local function beginBuild(itemId: string, movingId: string?, gridX: number?, gridZ: number?, rotation: number?)
	stopBuild()
	local definition = FactoryConfig.Get(itemId)
	local template = definition and templates:FindFirstChild(definition.TemplateName)
	if not template or not template:IsA("Model") then
		return
	end
	Local.selectedItemId = itemId
	Local.movingItemId = movingId
	Local.gridX = gridX or Local.gridX
	Local.gridZ = gridZ or Local.gridZ
	Local.rotation = rotation or 0
	Local.ghost = template:Clone()
	Local.ghost.Name = "FactoryGhost"
	Local.ghost.Parent = workspace
	Local.shopOpen = false
	Local.managePayload = nil
	publish()
	setGhostColor(false)
end

local function rotate()
	if Local.selectedItemId then
		Local.rotation = (Local.rotation + 90) % 360
	end
end

local function confirm()
	if not Local.selectedItemId or not Local.valid then
		return
	end
	if Local.movingItemId then
		requestEvent:FireServer("Move", Local.movingItemId, Local.gridX, Local.gridZ, Local.rotation)
	else
		requestEvent:FireServer("Place", Local.selectedItemId, Local.gridX, Local.gridZ, Local.rotation)
	end
end

publish = function()
	UIState.Set("factory", {
		shopOpen = Local.shopOpen,
		building = Local.selectedItemId ~= nil,
		managePayload = Local.managePayload,
		onToggleShop = function()
			Local.shopOpen = not Local.shopOpen
			publish()
		end,
		onCloseShop = function()
			Local.shopOpen = false
			publish()
		end,
		onPurchase = function(itemId: string)
			requestEvent:FireServer("Purchase", itemId)
		end,
		onSelectItem = function(itemId: string)
			beginBuild(itemId, nil, nil, nil, nil)
		end,
		onRotate = rotate,
		onConfirm = confirm,
		onCancel = stopBuild,
		onMove = function(payload: any)
			beginBuild(payload.ItemId, payload.PlacedItemId, payload.GridX, payload.GridZ, payload.Rotation)
		end,
		onConfigure = function(placedItemId: string, value: any)
			requestEvent:FireServer("Configure", placedItemId, value)
		end,
		onCollect = function(placedItemId: string)
			requestEvent:FireServer("Collect", placedItemId)
		end,
		onCloseManage = function()
			Local.managePayload = nil
			publish()
		end,
	})
end

local function isBlocked(plot: Model, bounds: BasePart, gridX: number, gridZ: number): boolean
	local buildGrid = plot:FindFirstChild("BuildGrid")
	local blockers = buildGrid and buildGrid:FindFirstChild("Blockers")
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

local function canPreviewPlace(plot: Model, bounds: BasePart): boolean
	local definition = Local.selectedItemId and FactoryConfig.Get(Local.selectedItemId)
	if not definition or not Local.state then
		return false
	end
	local solids = {}
	local sockets = {}
	for id, item in Local.state.PlacedItems do
		if id ~= Local.movingItemId then
			local itemDefinition = FactoryConfig.Get(item.ItemId)
			if itemDefinition then
				for _, cell in FactoryGrid.GetFootprint(itemDefinition, item.GridX, item.GridZ, item.Rotation) do
					if cell.Kind == "Solid" then
						solids[FactoryGrid.CellKey(cell.X, cell.Z)] = item
					else
						sockets[FactoryGrid.CellKey(cell.X, cell.Z)] = item
					end
				end
			end
		end
	end
	local candidate = {
		Id = "",
		ItemId = Local.selectedItemId,
		GridX = Local.gridX,
		GridZ = Local.gridZ,
		Rotation = Local.rotation,
		Config = { ConnectorMode = 1 },
		State = { StoredAmount = 0 },
	}
	local function canShare(dropper: any, straight: any): boolean
		if dropper.ItemId ~= "ConveyorDropper" or straight.ItemId ~= "StraightConveyor" then
			return false
		end
		local dropperMode = FactoryConfig.Items.ConveyorDropper.ConnectorModes[1]
		local straightMode = FactoryConfig.Items.StraightConveyor.ConnectorModes[1]
		local outputX, outputZ, outputDirection = FactoryGrid.GetConnector(dropper, dropperMode.Output)
		local straightX, straightZ, straightOutputDirection = FactoryGrid.GetConnector(straight, straightMode.Output)
		return outputX == straightX
			and outputZ == straightZ
			and straightOutputDirection ~= FactoryGrid.Opposite(outputDirection)
	end
	for _, cell in FactoryGrid.GetFootprint(definition, Local.gridX, Local.gridZ, Local.rotation) do
		if not FactoryGrid.IsInside(bounds, cell.X, cell.Z) or isBlocked(plot, bounds, cell.X, cell.Z) then
			return false
		end
		local key = FactoryGrid.CellKey(cell.X, cell.Z)
		if cell.Kind == "Solid" then
			if solids[key] then
				return false
			end
			if sockets[key] and not canShare(sockets[key], candidate) then
				return false
			end
		elseif sockets[key] or (solids[key] and not canShare(candidate, solids[key])) then
			return false
		end
	end
	return true
end

local function getPlaneHit(ray: Ray, bounds: BasePart): Vector3?
	local normal = bounds.CFrame.UpVector
	local denominator = ray.Direction:Dot(normal)
	if math.abs(denominator) < 0.0001 then
		return nil
	end
	local distance = (bounds.Position - ray.Origin):Dot(normal) / denominator
	return if distance >= 0 then ray.Origin + ray.Direction * distance else nil
end

local function updateGhost()
	local ghost = Local.ghost
	local plot = getPlot()
	local bounds = plot and FactoryGrid.GetBounds(plot)
	local camera = workspace.CurrentCamera
	if not ghost or not bounds or not camera then
		return
	end
	local viewportPoint
	if UserInputService:GetLastInputType() == Enum.UserInputType.Touch
		or string.find(UserInputService:GetLastInputType().Name, "Gamepad", 1, true)
	then
		viewportPoint = camera.ViewportSize * 0.5
	else
		viewportPoint = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	end
	local ray = camera:ViewportPointToRay(viewportPoint.X, viewportPoint.Y)
	local hit = getPlaneHit(ray, bounds)
	if hit then
		Local.gridX, Local.gridZ = FactoryGrid.WorldToGrid(bounds, hit)
	end
	ghost:PivotTo(FactoryGrid.GetCFrame(bounds, Local.gridX, Local.gridZ, Local.rotation))
	Local.valid = canPreviewPlace(plot, bounds)
	setGhostColor(Local.valid)
end

local function showMenu(payload: any)
	if typeof(payload) ~= "table" or typeof(payload.PlacedItemId) ~= "string" then
		return
	end
	Local.managePayload = payload
	publish()
end

function FactoryController.Start()
	if Local.started then
		return
	end
	Local.started = true
	stateEvent.OnClientEvent:Connect(function(state)
		Local.state = state
		publish()
		if Local.selectedItemId and not Local.movingItemId and (state.Inventory[Local.selectedItemId] or 0) <= 0 then
			stopBuild()
		end
	end)
	resultEvent.OnClientEvent:Connect(function(success)
		if success and Local.selectedItemId then
			stopBuild()
		end
	end)
	menuEvent.OnClientEvent:Connect(showMenu)
	UserInputService.InputBegan:Connect(function(input, processed)
		if not Local.selectedItemId or processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.R or input.KeyCode == Enum.KeyCode.ButtonY then
			rotate()
		elseif input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
			stopBuild()
		elseif input.KeyCode == Enum.KeyCode.ButtonA or input.UserInputType == Enum.UserInputType.MouseButton1 then
			confirm()
		end
	end)
	RunService.RenderStepped:Connect(updateGhost)
	task.spawn(function()
		local ok, state = pcall(function()
			return getStateFunction:InvokeServer()
		end)
		if ok and state then
			Local.state = state
			publish()
		end
	end)

	publish()
end

return FactoryController
