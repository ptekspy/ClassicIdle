--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local UnlockService = require(script.Parent.UnlockService)
local getPart = require(ReplicatedStorage.Utils.Getters.getPart)

local Local = {}
local DisplayService = {}

function Local.createOrGetBillboard(
	part: BasePart,
	name: string,
	size: UDim2,
	offset: Vector3
): BillboardGui
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

	local gold = Instance.new("IntValue")
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

	local coal = Instance.new("IntValue")
	coal.Name = "Coal"
	coal.Value = data.Coal
	coal.Parent = leaderstats
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

	if gold and gold:IsA("IntValue") then
		gold.Value = data.Gold
	end

	if wood and wood:IsA("IntValue") then
		wood.Value = data.Wood
	end

	if stone and stone:IsA("IntValue") then
		stone.Value = data.Stone
	end

	if coal and coal:IsA("IntValue") then
		coal.Value = data.Coal
	end
end

function DisplayService.UpdateStorageDisplay(player: Player, plot: Model)
	local data = DataService.Get(player)
	local storageBin = getPart("StorageBin", plot)

	local gui = Local.createOrGetBillboard(
		storageBin,
		"StorageDisplay",
		UDim2.fromOffset(170, 85),
		Vector3.new(0, 3.5, 0)
	)

	local label = gui:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		local used = EconomyService.GetUsedStorage(data)
		local capacity = EconomyService.GetStorageCapacity(data)

		label.Text = `Storage {used}/{capacity}\nWood: {data.Wood}\nStone: {data.Stone}\nCoal: {data.Coal}`
	end
end

function DisplayService.UpdateMachineDisplays(player: Player, plot: Model)
	local data = DataService.Get(player)

	local chopper = getPart("AutoChopperMachine", plot)
	local miner = getPart("AutoMinerMachine", plot)

	local chopperGui = Local.createOrGetBillboard(
		chopper,
		"MachineDisplay",
		UDim2.fromOffset(180, 70),
		Vector3.new(0, 3.5, 0)
	)

	local minerGui = Local.createOrGetBillboard(
		miner,
		"MachineDisplay",
		UDim2.fromOffset(180, 70),
		Vector3.new(0, 3.5, 0)
	)

	local chopperLabel = chopperGui:FindFirstChild("Label")
	local minerLabel = minerGui:FindFirstChild("Label")

	if chopperLabel and chopperLabel:IsA("TextLabel") then
		if data.AutoChopperLevel <= 0 then
			chopperLabel.Text = "Auto Chopper\nLocked"
		else
			chopperLabel.Text = `Auto Chopper Lv.{data.AutoChopperLevel}\n+{data.AutoChopperLevel} Wood / 3s`
		end
	end

	if minerLabel and minerLabel:IsA("TextLabel") then
		if data.AutoMinerLevel <= 0 then
			minerLabel.Text = "Auto Miner\nLocked"
		else
			minerLabel.Text = `Auto Miner Lv.{data.AutoMinerLevel}\n+{data.AutoMinerLevel} Stone / 5s`
		end
	end
end

function DisplayService.UpdateUpgradeButtonDisplays(player: Player, plot: Model)
	local data = DataService.Get(player)

	local chopperButton = getPart("AutoChopperButton", plot)
	local minerButton = getPart("AutoMinerButton", plot)
	local storageButton = getPart("StorageUpgradeButton", plot)
	local processorButton = getPart("AutoProcessorButton", plot)

	local chopperGui = Local.createOrGetBillboard(
		chopperButton,
		"UpgradeDisplay",
		UDim2.fromOffset(175, 75),
		Vector3.new(0, 3.5, 0)
	)

	local minerGui = Local.createOrGetBillboard(
		minerButton,
		"UpgradeDisplay",
		UDim2.fromOffset(175, 75),
		Vector3.new(0, 3.5, 0)
	)

	local storageGui = Local.createOrGetBillboard(
		storageButton,
		"UpgradeDisplay",
		UDim2.fromOffset(175, 75),
		Vector3.new(0, 3.5, 0)
	)

	local processorGui = Local.createOrGetBillboard(
		processorButton,
		"UpgradeDisplay",
		UDim2.fromOffset(175, 75),
		Vector3.new(0, 3.5, 0)
	)

	local chopperLabel = chopperGui:FindFirstChild("Label")
	local minerLabel = minerGui:FindFirstChild("Label")
	local storageLabel = storageGui:FindFirstChild("Label")
	local processorLabel = processorGui:FindFirstChild("Label")

	if chopperLabel and chopperLabel:IsA("TextLabel") then
		local cost = EconomyService.GetAutoChopperCost(data)

		chopperLabel.Text =
				`Upgrade Chopper\nLv.{data.AutoChopperLevel} → Lv.{data.AutoChopperLevel + 1}\nCost: {cost} Gold`
	end

	if minerLabel and minerLabel:IsA("TextLabel") then
		if UnlockService.CanBuyAutoMiner(data) then
			local cost = EconomyService.GetAutoMinerCost(data)

			minerLabel.Text =
					`Upgrade Miner\nLv.{data.AutoMinerLevel} → Lv.{data.AutoMinerLevel + 1}\nCost: {cost} Gold`
		else
			minerLabel.Text = "Auto Miner\nLocked\nBuy Chopper First"
		end
	end

	if storageLabel and storageLabel:IsA("TextLabel") then
		local cost = EconomyService.GetStorageUpgradeCost(data)
		local currentCapacity = EconomyService.GetStorageCapacity(data)

		storageLabel.Text = `Upgrade Storage\nCapacity: {currentCapacity}\nCost: {cost} Gold`
	end

	if processorLabel and processorLabel:IsA("TextLabel") then
		if UnlockService.CanBuyAutoProcessor(data) then
			local cost = EconomyService.GetAutoProcessorCost(data)

			processorLabel.Text =
					`Upgrade Processor\nLv.{data.AutoProcessorLevel} → Lv.{data.AutoProcessorLevel + 1}\nCost: {cost} Gold`
		else
			processorLabel.Text = "Auto Processor\nLocked\nBuy Auto Miner First"
		end
	end
end

function DisplayService.UpdateProcessorDisplays(player: Player, plot: Model)
	local data = DataService.Get(player)
	local coalProcessor = getPart("CoalProcessor", plot)

	local gui = Local.createOrGetBillboard(
		coalProcessor,
		"ProcessorDisplay",
		UDim2.fromOffset(185, 75),
		Vector3.new(0, 3.5, 0)
	)

	local label = gui:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		if UnlockService.CanUseCoalProcessor(data) then
			label.Text = `Coal Processor\n{EconomyService.GetCoalRecipeText()} → 1 Coal`
		else
			label.Text = "Coal Processor\nLocked\nBuy Auto Miner First"
		end
	end
end

function DisplayService.UpdateAll(player: Player, plot: Model)
	DisplayService.UpdateLeaderstats(player)
	DisplayService.UpdateStorageDisplay(player, plot)
	DisplayService.UpdateMachineDisplays(player, plot)
	DisplayService.UpdateUpgradeButtonDisplays(player, plot)
	DisplayService.UpdateProcessorDisplays(player, plot)
end

return DisplayService
