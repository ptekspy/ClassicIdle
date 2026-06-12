--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local PlayerDataReplicaService = require(script.Parent.PlayerDataReplicaService)
local PlotConfig = require(ReplicatedStorage.Plot.Config)
local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local SellBillboard = require(ReplicatedStorage.UI.World.SellBillboard)
local SellSurfaceDisplay = require(ReplicatedStorage.UI.World.SellSurfaceDisplay)
local WorldLabel = require(ReplicatedStorage.UI.World.WorldLabel)
local WorldUIService = require(script.Parent.WorldUIService)
local getPlotPart = require(ReplicatedStorage.Plot.getPart)

local DisplayService = {}

local function getBillboard(part: BasePart, name: string, size: UDim2, offset: Vector3): BillboardGui
	local existing = part:FindFirstChild(name)
	if existing and existing:IsA("BillboardGui") then
		return existing
	end

	local gui = Instance.new("BillboardGui")
	gui.Name = name
	gui.Size = size
	gui.StudsOffset = offset
	gui.AlwaysOnTop = false
	gui.MaxDistance = 35
	gui.Parent = part
	return gui
end

local function renderWorldLabel(part: BasePart, name: string, size: UDim2, offset: Vector3, text: string)
	local gui = getBillboard(part, name, size, offset)
	WorldUIService.Render(gui, React.createElement(WorldLabel, {
		text = text,
	}))
end

function DisplayService.SetupLeaderstats(player: Player)
	local data = DataService.Get(player)
	local existing = player:FindFirstChild("leaderstats")
	if existing then
		existing:Destroy()
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local gold = Instance.new("NumberValue")
	gold.Name = "Gold"
	gold.Value = data.Gold
	gold.Parent = leaderstats

	for _, resourceId in ResourceConfig.Order do
		local definition = ResourceConfig.Get(resourceId)
		if definition and definition.ShowInLeaderstats then
			local value = Instance.new("NumberValue")
			value.Name = resourceId
			value.Value = EconomyService.GetResourceAmount(data, resourceId)
			value.Parent = leaderstats
		end
	end

	local xp = Instance.new("IntValue")
	xp.Name = "XP"
	xp.Value = data.XP
	xp.Parent = leaderstats
end

function DisplayService.UpdateLeaderstats(player: Player)
	local data = DataService.Get(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	local gold = leaderstats:FindFirstChild("Gold")
	local xp = leaderstats:FindFirstChild("XP")
	if gold and gold:IsA("NumberValue") then
		gold.Value = data.Gold
	end
	for _, resourceId in ResourceConfig.Order do
		local value = leaderstats:FindFirstChild(resourceId)
		if value and (value:IsA("IntValue") or value:IsA("NumberValue")) then
			value.Value = EconomyService.GetResourceAmount(data, resourceId)
		end
	end
	if xp and xp:IsA("IntValue") then
		xp.Value = data.XP
	end

	PlayerDataReplicaService.Sync(player)
end

function DisplayService.UpdateStorageDisplay(player: Player, plot: Model)
	local data = DataService.Get(player)
	local lines = { `Storage {EconomyService.GetUsedStorage(data)}/{EconomyService.GetStorageCapacity(data)}` }
	for _, resourceId in ResourceConfig.Order do
		local definition = ResourceConfig.Get(resourceId)
		if definition then
			table.insert(lines, `{definition.DisplayName}: {EconomyService.GetResourceAmount(data, resourceId)}`)
		end
	end
	renderWorldLabel(
		getPlotPart(plot, PlotConfig.Paths.StorageDisplayAnchor),
		"StorageDisplay",
		UDim2.fromOffset(170, 85),
		Vector3.new(0, 3.5, 0),
		table.concat(lines, "\n")
	)
end

function DisplayService.UpdateMachineDisplays(player: Player, plot: Model)
	local data = DataService.Get(player)
	renderWorldLabel(
		getPlotPart(plot, PlotConfig.Paths.NPCPurchasePad),
		"NPCDisplay",
		UDim2.fromOffset(190, 75),
		Vector3.new(0, 3.5, 0),
		`Hire NPCs\nOwned: {EconomyService.GetNPCCount(data)}`
	)
end

function DisplayService.UpdateUpgradeButtonDisplays(player: Player, plot: Model)
	local data = DataService.Get(player)
	renderWorldLabel(
		getPlotPart(plot, PlotConfig.Paths.StorageUpgradeButton),
		"UpgradeDisplay",
		UDim2.fromOffset(175, 75),
		Vector3.new(0, 3.5, 0),
		`Upgrade Storage\nCapacity: {EconomyService.GetStorageCapacity(data)}\nCost: {EconomyService.GetStorageUpgradeCost(data)} Gold`
	)
end

function DisplayService.UpdateSellDisplay(player: Player, plot: Model)
	local value = EconomyService.GetTotalSellValue(DataService.Get(player))
	local touchPad = getPlotPart(plot, PlotConfig.Paths.SellTouchPad)
	local screenPart = getPlotPart(plot, PlotConfig.Paths.SellScreen)

	local billboard = getBillboard(touchPad, "SellBillboard", UDim2.fromScale(3, 3), Vector3.zero)
	billboard.Adornee = touchPad
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 50
	billboard.SizeOffset = Vector2.new(0, 2)
	WorldUIService.Render(billboard, React.createElement(SellBillboard, { value = value }))

	local surface = screenPart:FindFirstChild("SellSurfaceDisplay")
	if not surface or not surface:IsA("SurfaceGui") then
		surface = Instance.new("SurfaceGui")
		surface.Name = "SellSurfaceDisplay"
		surface.Face = Enum.NormalId.Right
		surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surface.PixelsPerStud = 50
		surface.Parent = screenPart
	end
	WorldUIService.Render(surface, React.createElement(SellSurfaceDisplay, { value = value }))
end

function DisplayService.UpdateAll(player: Player, plot: Model)
	DisplayService.UpdateLeaderstats(player)
	DisplayService.UpdateStorageDisplay(player, plot)
	DisplayService.UpdateMachineDisplays(player, plot)
	DisplayService.UpdateUpgradeButtonDisplays(player, plot)
	DisplayService.UpdateSellDisplay(player, plot)
end

return DisplayService