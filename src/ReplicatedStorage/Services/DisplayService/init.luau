--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local MachineConfig = require(ReplicatedStorage.Machine.Config)
local PlotConfig = require(ReplicatedStorage.Plot.Config)
local getPlotBillboardGui = require(ReplicatedStorage.Plot.getBillboardGui)
local getPlotPart = require(ReplicatedStorage.Plot.getPart)
local getPlotTextLabel = require(ReplicatedStorage.Plot.getTextLabel)

local Local = {}
local DisplayService = {}

function Local.createOrGetBillboard(part: BasePart, name: string, size: UDim2, offset: Vector3): BillboardGui
	local existing = part:FindFirstChild(name)

	if existing and existing:IsA("BillboardGui") then
		existing.Size = size
		existing.StudsOffset = offset
		existing.MaxDistance = 35
		existing.AlwaysOnTop = false
		return existing
	end

	local gui = Instance.new("BillboardGui")
	gui.Name = name
	gui.Size = size
	gui.StudsOffset = offset
	gui.AlwaysOnTop = false
	gui.MaxDistance = 35
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	label.BackgroundTransparency = 0.2
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	return gui
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

	local wood = Instance.new("IntValue")
	wood.Name = "Wood"
	wood.Value = data.Wood
	wood.Parent = leaderstats

	local stone = Instance.new("IntValue")
	stone.Name = "Stone"
	stone.Value = data.Stone
	stone.Parent = leaderstats

	local coal = Instance.new("NumberValue")
	coal.Name = "Coal"
	coal.Value = data.Coal
	coal.Parent = leaderstats

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
	local wood = leaderstats:FindFirstChild("Wood")
	local stone = leaderstats:FindFirstChild("Stone")
	local coal = leaderstats:FindFirstChild("Coal")
	local xp = leaderstats:FindFirstChild("XP")

	if gold and gold:IsA("NumberValue") then
		gold.Value = data.Gold
	end

	if wood and wood:IsA("IntValue") then
		wood.Value = data.Wood
	end

	if stone and stone:IsA("IntValue") then
		stone.Value = data.Stone
	end

	if coal and coal:IsA("NumberValue") then
		coal.Value = data.Coal
	end

	if xp and xp:IsA("IntValue") then
		xp.Value = data.XP
	end
end

function DisplayService.UpdateStorageDisplay(player: Player, plot: Model)
	local data = DataService.Get(player)
	local storageBin = getPlotPart(plot, PlotConfig.Paths.StorageDisplayAnchor)

	local gui =
		Local.createOrGetBillboard(storageBin, "StorageDisplay", UDim2.fromOffset(170, 85), Vector3.new(0, 3.5, 0))

	local label = gui:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		local used = EconomyService.GetUsedStorage(data)
		local capacity = EconomyService.GetStorageCapacity(data)

		label.Text = `Storage {used}/{capacity}\nWood: {data.Wood}\nStone: {data.Stone}\nCoal: {data.Coal}`
	end
end

function DisplayService.UpdateMachineDisplays(player: Player, plot: Model)
	local data = DataService.Get(player)
	local purchasePad = getPlotPart(plot, PlotConfig.Paths.NPCPurchasePad)
	local gui = Local.createOrGetBillboard(purchasePad, "NPCDisplay", UDim2.fromOffset(190, 75), Vector3.new(0, 3.5, 0))
	local label = gui:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		label.Text = `Hire NPCs\nOwned: {EconomyService.GetNPCCount(data)}`
	end
end

function DisplayService.UpdateUpgradeButtonDisplays(player: Player, plot: Model)
	local data = DataService.Get(player)
	local storageButton = getPlotPart(plot, PlotConfig.Paths.StorageUpgradeButton)

	local storageGui =
		Local.createOrGetBillboard(storageButton, "UpgradeDisplay", UDim2.fromOffset(175, 75), Vector3.new(0, 3.5, 0))

	local storageLabel = storageGui:FindFirstChild("Label")

	if storageLabel and storageLabel:IsA("TextLabel") then
		local cost = EconomyService.GetStorageUpgradeCost(data)
		local currentCapacity = EconomyService.GetStorageCapacity(data)

		storageLabel.Text = `Upgrade Storage\nCapacity: {currentCapacity}\nCost: {cost} Gold`
	end
end

function DisplayService.UpdateProcessorDisplays(player: Player, plot: Model)
	local data = DataService.Get(player)
	local coalProcessor = getPlotPart(plot, PlotConfig.Paths.CoalProcessorInteraction)

	local gui =
		Local.createOrGetBillboard(coalProcessor, "ProcessorDisplay", UDim2.fromOffset(185, 75), Vector3.new(0, 3.5, 0))

	local label = gui:FindFirstChild("Label")
	gui.Enabled = data.Machine.Parts.CoalProcessor.Built

	if label and label:IsA("TextLabel") then
		local processor = data.Machine.Processor
		local status = if processor.IsProcessing
			then `Processing: {math.ceil(processor.ProcessingRemaining)}s`
			else `Buffer: {#processor.WoodBuffer}W/{#processor.StoneBuffer}S`
		label.Text = `Coal Processor\n{status}\n2 Wood + 1 Stone`
	end
end

function DisplayService.UpdateCollectionDisplay(player: Player, plot: Model)
	local data = DataService.Get(player)
	local collection = getPlotPart(plot, PlotConfig.Paths.CollectionPointInteraction)
	local gui =
		Local.createOrGetBillboard(collection, "CollectionDisplay", UDim2.fromOffset(185, 70), Vector3.new(0, 3.5, 0))
	local label = gui:FindFirstChild("Label")
	gui.Enabled = data.Machine.Parts.CollectionPoint.Built
	if label and label:IsA("TextLabel") then
		local level = data.Machine.Parts.CollectionPoint.Level
		label.Text =
			`Collection Point\nCoal: {math.round(data.Machine.CollectionStored * 100) / 100}/{MachineConfig.GetCollectionCapacity(
				level
			)}`
	end
end

function DisplayService.UpdateSellDisplay(player: Player, plot: Model)
	local data = DataService.Get(player)
	local totalSellValue = EconomyService.GetTotalSellValue(data)
	local touchPad = getPlotPart(plot, PlotConfig.Paths.SellTouchPad)
	local billboard = getPlotBillboardGui(plot, PlotConfig.Paths.SellBillboard)
	local billboardLabel = getPlotTextLabel(plot, PlotConfig.Paths.SellBillboardLabel)
	local screenLabel = getPlotTextLabel(plot, PlotConfig.Paths.SellScreenLabel)

	billboard.Adornee = touchPad
	billboardLabel.Text =
		`<stroke color="rgb(0, 118, 0)" joins="miter" thickness="7" transparency="0.5">${totalSellValue}</stroke>`
	screenLabel.Text = `${totalSellValue}`
end

function DisplayService.UpdateAll(player: Player, plot: Model)
	DisplayService.UpdateLeaderstats(player)
	DisplayService.UpdateStorageDisplay(player, plot)
	DisplayService.UpdateMachineDisplays(player, plot)
	DisplayService.UpdateUpgradeButtonDisplays(player, plot)
	DisplayService.UpdateProcessorDisplays(player, plot)
	DisplayService.UpdateCollectionDisplay(player, plot)
	DisplayService.UpdateSellDisplay(player, plot)
end

return DisplayService
