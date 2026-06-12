--!strict

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local FactoryConfig = require(ReplicatedStorage.Factory.Config)
local FactoryGrid = require(ReplicatedStorage.Factory.Grid)
local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
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
}

local FactoryController = {}

local gui = Instance.new("ScreenGui")
gui.Name = "FactoryGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 35
gui.Parent = playerGui

local function frame(name: string, size: UDim2, position: UDim2): Frame
	local value = Instance.new("Frame")
	value.Name = name
	value.Size = size
	value.Position = position
	value.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	value.BackgroundTransparency = 0.08
	value.Parent = gui
	Instance.new("UICorner", value).CornerRadius = UDim.new(0, 12)
	return value
end

local function button(parent: Instance, text: string, callback: () -> ()): TextButton
	local value = Instance.new("TextButton")
	value.Size = UDim2.new(1, 0, 0, 48)
	value.BackgroundColor3 = Color3.fromRGB(65, 130, 80)
	value.Font = Enum.Font.GothamBold
	value.Text = text
	value.TextColor3 = Color3.new(1, 1, 1)
	value.TextSize = 15
	value.TextWrapped = true
	value.Parent = parent
	Instance.new("UICorner", value).CornerRadius = UDim.new(0, 8)
	value.Activated:Connect(callback)
	return value
end

local shopButton = Instance.new("TextButton")
shopButton.Name = "OpenShop"
shopButton.Position = UDim2.new(1, -130, 0, 20)
shopButton.Size = UDim2.fromOffset(110, 50)
shopButton.BackgroundColor3 = Color3.fromRGB(65, 130, 80)
shopButton.Font = Enum.Font.GothamBold
shopButton.Text = "BUILD SHOP"
shopButton.TextColor3 = Color3.new(1, 1, 1)
shopButton.TextSize = 14
shopButton.Parent = gui
Instance.new("UICorner", shopButton).CornerRadius = UDim.new(0, 10)

local shop = frame("Shop", UDim2.fromOffset(300, 430), UDim2.new(1, -320, 0, 80))
shop.Visible = false
local shopLayout = Instance.new("UIListLayout", shop)
shopLayout.Padding = UDim.new(0, 8)
shopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local hotbar = frame("Hotbar", UDim2.new(0.9, 0, 0, 68), UDim2.new(0.05, 0, 1, -88))
local hotbarLayout = Instance.new("UIListLayout", hotbar)
hotbarLayout.FillDirection = Enum.FillDirection.Horizontal
hotbarLayout.Padding = UDim.new(0, 6)
hotbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hotbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local controls = frame("BuildControls", UDim2.fromOffset(360, 62), UDim2.new(0.5, -180, 1, -165))
controls.Visible = false
local controlsLayout = Instance.new("UIListLayout", controls)
controlsLayout.FillDirection = Enum.FillDirection.Horizontal
controlsLayout.Padding = UDim.new(0, 8)
controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function control(text: string, callback: () -> ())
	local value = button(controls, text, callback)
	value.Size = UDim2.fromOffset(105, 46)
end

local manage = frame("Manage", UDim2.fromOffset(320, 320), UDim2.new(0.5, -160, 0.5, -160))
manage.Visible = false
local manageLayout = Instance.new("UIListLayout", manage)
manageLayout.Padding = UDim.new(0, 8)
manageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local manageTitle = Instance.new("TextLabel")
manageTitle.Size = UDim2.new(1, 0, 0, 48)
manageTitle.BackgroundTransparency = 1
manageTitle.Font = Enum.Font.GothamBold
manageTitle.TextColor3 = Color3.new(1, 1, 1)
manageTitle.TextSize = 20
manageTitle.Parent = manage

local function manageLabel(text: string)
	local value = Instance.new("TextLabel")
	value.Size = UDim2.new(1, -16, 0, 58)
	value.BackgroundTransparency = 1
	value.Font = Enum.Font.Gotham
	value.Text = text
	value.TextColor3 = Color3.fromRGB(220, 220, 220)
	value.TextSize = 14
	value.TextWrapped = true
	value.Parent = manage
end

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

local function clearChildren(parent: Instance, keep: { Instance })
	local kept = {}
	for _, child in keep do
		kept[child] = true
	end
	for _, child in parent:GetChildren() do
		if not kept[child] then
			child:Destroy()
		end
	end
end

local function stopBuild()
	Local.selectedItemId = nil
	Local.movingItemId = nil
	Local.valid = false
	controls.Visible = false
	if Local.ghost then
		Local.ghost:Destroy()
		Local.ghost = nil
	end
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
	controls.Visible = true
	shop.Visible = false
	manage.Visible = false
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

control("ROTATE\nR / Y", rotate)
control("PLACE\nCLICK / A", confirm)
control("CANCEL\nESC / B", stopBuild)

local function refreshHotbar()
	clearChildren(hotbar, { hotbarLayout })
	if not Local.state then
		return
	end
	for _, itemId in FactoryConfig.ItemOrder do
		local count = Local.state.Inventory[itemId] or 0
		if count > 0 then
			local definition = FactoryConfig.Items[itemId]
			local itemButton = button(hotbar, `{definition.DisplayName}\nx{count}`, function()
				beginBuild(itemId, nil, nil, nil, nil)
			end)
			itemButton.Size = UDim2.fromOffset(135, 54)
		end
	end
end

for _, itemId in FactoryConfig.ItemOrder do
	local definition = FactoryConfig.Items[itemId]
	local itemButton = button(shop, `{definition.DisplayName} - {definition.Price} Gold`, function()
		requestEvent:FireServer("Purchase", itemId)
	end)
	itemButton.Size = UDim2.new(1, -16, 0, 56)
end
local closeShop = button(shop, "CLOSE", function()
	shop.Visible = false
end)
closeShop.Size = UDim2.new(1, -16, 0, 42)

shopButton.Activated:Connect(function()
	shop.Visible = not shop.Visible
end)

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
	clearChildren(manage, { manageLayout, manageTitle })
	manageTitle.Text = payload.DisplayName
	manage.Visible = true
	button(manage, "MOVE", function()
		beginBuild(payload.ItemId, payload.PlacedItemId, payload.GridX, payload.GridZ, payload.Rotation)
	end)
	if payload.ItemId == "ConveyorDropper" then
		manageLabel("Runs automatically while the selected resource is in Storage and a valid conveyor is connected.")
		for _, resourceId in payload.ResourceOptions or {} do
			local definition = ResourceConfig.Get(resourceId)
			if definition then
				button(manage, `DROP {string.upper(definition.DisplayName)}`, function()
					requestEvent:FireServer("Configure", payload.PlacedItemId, resourceId)
				end)
			end
		end
	elseif payload.ItemId == "CornerConveyor" then
		button(manage, "REVERSE CORNER FLOW", function()
			requestEvent:FireServer("Configure", payload.PlacedItemId, if payload.ConnectorMode == 2 then 1 else 2)
		end)
	elseif payload.ItemId == "ConveyorCollectionBin" then
		manageLabel("Factory output waits here. Collect it manually to move as much as possible into Storage.")
		button(manage, `COLLECT {payload.StoredAmount or 0} {payload.StoredResourceType or ""}`, function()
			requestEvent:FireServer("Collect", payload.PlacedItemId)
		end)
	end
	button(manage, "CLOSE", function()
		manage.Visible = false
	end)
end

function FactoryController.Start()
	if Local.started then
		return
	end
	Local.started = true
	stateEvent.OnClientEvent:Connect(function(state)
		Local.state = state
		refreshHotbar()
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
			refreshHotbar()
		end
	end)
end

return FactoryController
