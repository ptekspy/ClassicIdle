--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Services.DataService)
local DisplayService = require(ReplicatedStorage.Services.DisplayService)
local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local FeedbackService = require(ReplicatedStorage.Services.FeedbackService)
local InteractionConfig = require(ReplicatedStorage.Interaction.Config)
local PlotService = require(ReplicatedStorage.Services.PlotService)
local ResourceDropService = require(ReplicatedStorage.Services.ResourceDropService)
local UnlockService = require(ReplicatedStorage.Services.UnlockService)
local canUseCooldown = require(ReplicatedStorage.Utils.Cooldown.canUseCooldown)
local getPart = require(ReplicatedStorage.Utils.Getters.getPart)
local setMachineActive = require(ReplicatedStorage.Utils.Setters.Machine.setMachineActive)

local Local = {
	MANUAL_CHOP_AMOUNT = 1,
	MANUAL_MINE_AMOUNT = 1,

	AUTO_CHOPPER_INTERVAL = 3,
	AUTO_MINER_INTERVAL = 5,
	AUTO_PROCESSOR_INTERVAL = 4,

	chopCooldowns = {} :: { [Player]: number },
	mineCooldowns = {} :: { [Player]: number },
}

local WorldService = {}

local function setInteractionText(part: BasePart, actionText: string, objectText: string)
	part:SetAttribute(InteractionConfig.Attributes.ActionText, actionText)
	part:SetAttribute(InteractionConfig.Attributes.ObjectText, objectText)
end

function WorldService.UpdateUnlocks(player: Player, plot: Model)
	local data = DataService.Get(player)

	local manualRock = getPart("ManualRock", plot)
	local autoMinerButton = getPart("AutoMinerButton", plot)

	if UnlockService.CanUseManualRock(data) then
		manualRock.Color = Color3.fromRGB(100, 100, 100)
		setInteractionText(manualRock, "Mine", "Rock")
	else
		manualRock.Color = Color3.fromRGB(45, 45, 45)
		setInteractionText(manualRock, "Locked", "Buy Auto Chopper First")
	end

	if UnlockService.CanBuyAutoMiner(data) then
		local nextCost = EconomyService.GetAutoMinerCost(data)

		autoMinerButton.Color = Color3.fromRGB(80, 80, 160)
		setInteractionText(autoMinerButton, "Buy Auto Miner", `{nextCost} Gold`)
	else
		autoMinerButton.Color = Color3.fromRGB(45, 45, 45)
		setInteractionText(autoMinerButton, "Locked", "Buy Auto Chopper First")
	end

	local coalProcessor = getPart("CoalProcessor", plot)

	if UnlockService.CanUseCoalProcessor(data) then
		coalProcessor.Color = Color3.fromRGB(30, 30, 30)
		coalProcessor.Transparency = 0
		setInteractionText(coalProcessor, "Process Coal", EconomyService.GetCoalRecipeText())
	else
		coalProcessor.Color = Color3.fromRGB(45, 45, 45)
		coalProcessor.Transparency = 0.55
		setInteractionText(coalProcessor, "Locked", "Buy Auto Miner First")
	end

	local autoProcessorButton = getPart("AutoProcessorButton", plot)

	if UnlockService.CanBuyAutoProcessor(data) then
		local processorCost = EconomyService.GetAutoProcessorCost(data)

		autoProcessorButton.Color = Color3.fromRGB(140, 70, 40)
		setInteractionText(autoProcessorButton, "Buy Auto Processor", `{processorCost} Gold`)
	else
		autoProcessorButton.Color = Color3.fromRGB(45, 45, 45)
		setInteractionText(autoProcessorButton, "Locked", "Buy Auto Miner First")
	end

	local autoChopperButton = getPart("AutoChopperButton", plot)
	local storageUpgradeButton = getPart("StorageUpgradeButton", plot)
	local storageCost = EconomyService.GetStorageUpgradeCost(data)
	setInteractionText(autoChopperButton, "Buy Auto Chopper", `{EconomyService.GetAutoChopperCost(data)} Gold`)
	setInteractionText(storageUpgradeButton, "Upgrade Storage", `{storageCost} Gold`)

	setMachineActive("AutoChopperMachine", data.AutoChopperLevel > 0, plot)
	setMachineActive("AutoMinerMachine", data.AutoMinerLevel > 0, plot)

	DisplayService.UpdateMachineDisplays(player, plot)
	DisplayService.UpdateUpgradeButtonDisplays(player, plot)
	DisplayService.UpdateProcessorDisplays(player, plot)
end

function WorldService.InteractManualTree(player: Player, plot: Model)
	local data = DataService.TryGet(player)

	if not data then
		return
	end

	if not canUseCooldown(player, Local.chopCooldowns, 0.5) then
		return
	end

	local acceptedAmount = EconomyService.AddWood(data, Local.MANUAL_CHOP_AMOUNT)

	if acceptedAmount <= 0 then
		FeedbackService.Send(player, "Storage full")
		return
	end

	DisplayService.UpdateAll(player, plot)
	FeedbackService.Send(player, `+{acceptedAmount} Wood stored`)
end

function WorldService.InteractManualRock(player: Player, plot: Model)
	local data = DataService.TryGet(player)

	if not data then
		return
	end

	if not UnlockService.CanUseManualRock(data) then
		FeedbackService.Send(player, "Locked: Buy Auto Chopper First")
		return
	end

	if not canUseCooldown(player, Local.mineCooldowns, 0.5) then
		return
	end

	local acceptedAmount = EconomyService.AddStone(data, Local.MANUAL_MINE_AMOUNT)

	if acceptedAmount <= 0 then
		FeedbackService.Send(player, "Storage full")
		return
	end

	DisplayService.UpdateAll(player, plot)
	FeedbackService.Send(player, `+{acceptedAmount} Stone stored`)
end

function WorldService.InteractSellCrate(player: Player, plot: Model)
	local data = DataService.TryGet(player)

	if not data then
		return
	end

	local woodEarned = EconomyService.SellAllWood(data)
	local stoneEarned = EconomyService.SellAllStone(data)
	local coalEarned = EconomyService.SellAllCoal(data)
	local totalEarned = woodEarned + stoneEarned + coalEarned

	if totalEarned <= 0 then
		FeedbackService.Send(player, "No resources to sell")
		return
	end

	DisplayService.UpdateAll(player, plot)
	FeedbackService.Send(player, `Sold resources for {totalEarned} Gold`)
end

function WorldService.InteractAutoChopperButton(player: Player, plot: Model)
	local data = DataService.TryGet(player)

	if not data then
		return
	end

	if not UnlockService.CanBuyAutoChopper(data) then
		return
	end

	local cost = EconomyService.GetAutoChopperCost(data)
	local bought = EconomyService.BuyAutoChopper(data)

	if not bought then
		FeedbackService.Send(player, `Need {cost} Gold`)
		return
	end

	DisplayService.UpdateAll(player, plot)
	WorldService.UpdateUnlocks(player, plot)
	FeedbackService.Send(player, `Auto Chopper upgraded to Lv.{data.AutoChopperLevel}`)
end

function WorldService.InteractAutoMinerButton(player: Player, plot: Model)
	local data = DataService.TryGet(player)

	if not data then
		return
	end

	if not UnlockService.CanBuyAutoMiner(data) then
		FeedbackService.Send(player, "Locked: Buy Auto Chopper First")
		return
	end

	local cost = EconomyService.GetAutoMinerCost(data)
	local bought = EconomyService.BuyAutoMiner(data)

	if not bought then
		FeedbackService.Send(player, `Need {cost} Gold`)
		return
	end

	DisplayService.UpdateAll(player, plot)
	WorldService.UpdateUnlocks(player, plot)
	FeedbackService.Send(player, `Auto Miner upgraded to Lv.{data.AutoMinerLevel}`)
end

function WorldService.InteractAutoProcessorButton(player: Player, plot: Model)
	local data = DataService.TryGet(player)

	if not data then
		return
	end

	if not UnlockService.CanBuyAutoProcessor(data) then
		FeedbackService.Send(player, "Locked: Buy Auto Miner First")
		return
	end

	local cost = EconomyService.GetAutoProcessorCost(data)
	local bought = EconomyService.BuyAutoProcessor(data)

	if not bought then
		FeedbackService.Send(player, `Need {cost} Gold`)
		return
	end

	WorldService.UpdateUnlocks(player, plot)
	DisplayService.UpdateAll(player, plot)
	FeedbackService.Send(player, `Auto Processor upgraded to Lv.{data.AutoProcessorLevel}`)
end

function WorldService.InteractStorageUpgradeButton(player: Player, plot: Model)
	local data = DataService.TryGet(player)

	if not data then
		return
	end

	if not UnlockService.CanBuyStorageUpgrade(data) then
		return
	end

	local cost = EconomyService.GetStorageUpgradeCost(data)
	local bought = EconomyService.BuyStorageUpgrade(data)

	if not bought then
		FeedbackService.Send(player, `Need {cost} Gold`)
		return
	end

	local capacity = EconomyService.GetStorageCapacity(data)

	WorldService.UpdateUnlocks(player, plot)
	DisplayService.UpdateAll(player, plot)
	FeedbackService.Send(player, `Storage capacity upgraded to {capacity}`)
end

function WorldService.InteractCoalProcessor(player: Player, plot: Model)
	local data = DataService.TryGet(player)

	if not data then
		return
	end

	if not UnlockService.CanUseCoalProcessor(data) then
		FeedbackService.Send(player, "Locked: Buy Auto Miner First")
		return
	end

	if not EconomyService.ProcessCoal(data) then
		FeedbackService.Send(player, `Need {EconomyService.GetCoalRecipeText()}`)
		return
	end

	local processor = getPart("CoalProcessor", plot)
	local storageBin = getPart("StorageBin", plot)

	ResourceDropService.SpawnDrop({
		Plot = plot,
		ResourceType = "Coal",
		Amount = 1,
		StartPosition = processor.Position + Vector3.new(0, 3.5, 0),
		EndPosition = storageBin.Position + Vector3.new(0, 3.5, 0),
		OnCollected = function()
			if PlotService.TryGet(player) ~= plot or not DataService.TryGet(player) then
				return
			end

			DisplayService.UpdateAll(player, plot)
		end,
	})

	DisplayService.UpdateAll(player, plot)
	FeedbackService.Send(player, "+1 Coal processed")
end

local interactionHandlers: { [string]: (Player, Model) -> () } = {
	[InteractionConfig.Definitions.ManualTree.Id] = WorldService.InteractManualTree,
	[InteractionConfig.Definitions.ManualRock.Id] = WorldService.InteractManualRock,
	[InteractionConfig.Definitions.SellCrate.Id] = WorldService.InteractSellCrate,
	[InteractionConfig.Definitions.AutoChopperButton.Id] = WorldService.InteractAutoChopperButton,
	[InteractionConfig.Definitions.AutoMinerButton.Id] = WorldService.InteractAutoMinerButton,
	[InteractionConfig.Definitions.StorageUpgradeButton.Id] = WorldService.InteractStorageUpgradeButton,
	[InteractionConfig.Definitions.AutoProcessorButton.Id] = WorldService.InteractAutoProcessorButton,
	[InteractionConfig.Definitions.CoalProcessor.Id] = WorldService.InteractCoalProcessor,
}

function WorldService.HandleInteraction(player: Player, interactionId: string, plot: Model)
	local handler = interactionHandlers[interactionId]

	if handler then
		handler(player, plot)
	end
end

function WorldService.CleanupPlayer(player: Player)
	Local.chopCooldowns[player] = nil
	Local.mineCooldowns[player] = nil
end

function WorldService.SetupPlayer(player: Player, _plot: Model)
	WorldService.CleanupPlayer(player)
end

function WorldService.StartAutoChoppers()
	task.spawn(function()
		while true do
			task.wait(Local.AUTO_CHOPPER_INTERVAL)

			for _, player in Players:GetPlayers() do
				local data = DataService.TryGet(player)
				local plot = PlotService.TryGet(player)

				if not data or not plot then
					continue
				end

				local amount = data.AutoChopperLevel

				if amount <= 0 or EconomyService.IsStorageFull(data) then
					continue
				end

				local machine = getPart("AutoChopperMachine", plot)
				local storageBin = getPart("StorageBin", plot)

				ResourceDropService.SpawnDrop({
					Plot = plot,
					ResourceType = "Wood",
					Amount = amount,
					StartPosition = machine.Position + Vector3.new(0, 3.5, 0),
					EndPosition = storageBin.Position + Vector3.new(0, 3, 0),
					OnCollected = function()
						if PlotService.TryGet(player) ~= plot then
							return
						end

						local currentData = DataService.TryGet(player)

						if not currentData then
							return
						end

						local acceptedAmount = EconomyService.AddWood(currentData, amount)
						DisplayService.UpdateAll(player, plot)

						if acceptedAmount <= 0 then
							FeedbackService.Send(player, "Storage full")
						end
					end,
				})
			end
		end
	end)
end

function WorldService.StartAutoMiners()
	task.spawn(function()
		while true do
			task.wait(Local.AUTO_MINER_INTERVAL)

			for _, player in Players:GetPlayers() do
				local data = DataService.TryGet(player)
				local plot = PlotService.TryGet(player)

				if not data or not plot then
					continue
				end

				local amount = data.AutoMinerLevel

				if amount <= 0 or EconomyService.IsStorageFull(data) then
					continue
				end

				local machine = getPart("AutoMinerMachine", plot)
				local storageBin = getPart("StorageBin", plot)

				ResourceDropService.SpawnDrop({
					Plot = plot,
					ResourceType = "Stone",
					Amount = amount,
					StartPosition = machine.Position + Vector3.new(0, 3.5, 0),
					EndPosition = storageBin.Position + Vector3.new(0, 3, 0),
					OnCollected = function()
						if PlotService.TryGet(player) ~= plot then
							return
						end

						local currentData = DataService.TryGet(player)

						if not currentData then
							return
						end

						local acceptedAmount = EconomyService.AddStone(currentData, amount)
						DisplayService.UpdateAll(player, plot)

						if acceptedAmount <= 0 then
							FeedbackService.Send(player, "Storage full")
						end
					end,
				})
			end
		end
	end)
end

function WorldService.StartAutoProcessors()
	task.spawn(function()
		while true do
			task.wait(Local.AUTO_PROCESSOR_INTERVAL)

			for _, player in Players:GetPlayers() do
				local data = DataService.TryGet(player)
				local plot = PlotService.TryGet(player)

				if not data or not plot then
					continue
				end

				local level = data.AutoProcessorLevel

				if level <= 0 then
					continue
				end

				for _ = 1, level do
					if not EconomyService.ProcessCoal(data) then
						break
					end

					local processor = getPart("CoalProcessor", plot)
					local storageBin = getPart("StorageBin", plot)

					ResourceDropService.SpawnDrop({
						Plot = plot,
						ResourceType = "Coal",
						Amount = 1,
						StartPosition = processor.Position + Vector3.new(0, 3.5, 0),
						EndPosition = storageBin.Position + Vector3.new(0, 3.5, 0),
						OnCollected = function()
							if PlotService.TryGet(player) ~= plot or not DataService.TryGet(player) then
								return
							end

							DisplayService.UpdateAll(player, plot)
						end,
					})
				end

				DisplayService.UpdateAll(player, plot)
			end
		end
	end)
end

return WorldService
