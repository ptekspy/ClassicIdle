--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Services.DataService)
local DisplayService = require(ReplicatedStorage.Services.DisplayService)
local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local FeedbackService = require(ReplicatedStorage.Services.FeedbackService)
local InteractionConfig = require(ReplicatedStorage.Interaction.Config)
local Maid = require(ReplicatedStorage.Packages.Maid)
local PlotConfig = require(ReplicatedStorage.Plot.Config)
local PlotService = require(ReplicatedStorage.Services.PlotService)
local QuestService = require(ReplicatedStorage.Services.QuestService)
local RateLimit = require(ReplicatedStorage.Packages.RateLimit)
local RemoteManager = require(ReplicatedStorage.Packages.RemoteManager)
local ResourceNodeService = require(ReplicatedStorage.Services.ResourceNodeService)
local UnlockService = require(ReplicatedStorage.Services.UnlockService)
local MachineService = require(ReplicatedStorage.Services.MachineService)
local WorkerConfig = require(ReplicatedStorage.Worker.Config)
local WorkerService = require(ReplicatedStorage.Services.WorkerService)
local WorkerTypes = require(ReplicatedStorage.Worker.Types)
local canUseCooldown = require(ReplicatedStorage.Utils.Cooldown.canUseCooldown)
local getClosestPoint = require(ReplicatedStorage.Interaction.getClosestPoint)
local getPlotModel = require(ReplicatedStorage.Plot.getModel)
local getPlotPart = require(ReplicatedStorage.Plot.getPart)

local workerMenuEvent = RemoteManager.WorkerMenu :: RemoteEvent
local workerRequestEvent = RemoteManager.WorkerRequest :: RemoteEvent
local workerRateLimit = RateLimit.New(8)

local Local = {
	MANUAL_CHOP_AMOUNT = 1,
	MANUAL_MINE_AMOUNT = 1,
	chopCooldowns = {} :: { [Player]: number },
	mineCooldowns = {} :: { [Player]: number },
	maidsByPlayer = {} :: { [Player]: any },
	started = false,
}

local WorldService = {}

local function setInteractionText(plot: Model, targetPath: string, actionText: string, objectText: string)
	local target = getPlotModel(plot, targetPath)
	target:SetAttribute(InteractionConfig.Attributes.ActionText, actionText)
	target:SetAttribute(InteractionConfig.Attributes.ObjectText, objectText)
end

local function getNPC(data: any, npcId: string): WorkerTypes.NPCData?
	return data.NPCs[npcId]
end

local function isNear(player: Player, target: Model): boolean
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root or not root:IsA("BasePart") then
		return false
	end

	return (root.Position - getClosestPoint(target, root.Position)).Magnitude <= 12
end

local function getPurchaseMenu(data: any)
	local roles = {}

	for role, definition in WorkerConfig.Roles do
		table.insert(roles, {
			Role = role,
			DisplayName = definition.DisplayName,
			Cost = EconomyService.GetNPCPurchaseCost(data, role),
			Unlocked = UnlockService.CanBuyNPCRole(data, role),
		})
	end

	table.sort(roles, function(a, b)
		return a.Cost < b.Cost
	end)

	return { Kind = "Purchase", Roles = roles }
end

local function getManageMenu(npc: WorkerTypes.NPCData)
	return {
		Kind = "Manage",
		NPCId = npc.Id,
		Role = npc.Role,
		DisplayName = WorkerConfig.Roles[npc.Role].DisplayName,
		Speed = EconomyService.GetNPCSpeed(npc),
		Amount = EconomyService.GetNPCAmount(npc),
		SpeedLevel = npc.SpeedLevel,
		AmountLevel = npc.AmountLevel,
		SpeedCost = EconomyService.GetNPCUpgradeCost(npc, "Speed"),
		AmountCost = EconomyService.GetNPCUpgradeCost(npc, "Amount"),
		CargoType = npc.CargoType,
		CargoAmount = npc.CargoAmount,
	}
end

function WorldService.UpdateUnlocks(player: Player, plot: Model)
	local data = DataService.Get(player)
	local manualRock = getPlotPart(plot, PlotConfig.Paths.ManualRock)

	if UnlockService.CanUseManualRock(data) then
		manualRock.Color = Color3.fromRGB(100, 100, 100)
		setInteractionText(plot, InteractionConfig.Definitions.ManualRock.TargetPath, "Mine", "Rock")
	else
		manualRock.Color = Color3.fromRGB(45, 45, 45)
		setInteractionText(plot, InteractionConfig.Definitions.ManualRock.TargetPath, "Locked", "Hire a Wood NPC first")
	end

	MachineService.RefreshPresentation(player, plot)
	DisplayService.UpdateAll(player, plot)
end

local function collectManual(
	player: Player,
	plot: Model,
	nodePath: string,
	resourceType: WorkerTypes.ResourceType,
	amount: number
)
	local data = DataService.TryGet(player)

	if not data or EconomyService.IsStorageFull(data) then
		FeedbackService.Send(player, "Storage full")
		return
	end

	local node = getPlotModel(plot, nodePath)
	local requested = math.min(amount, EconomyService.GetRemainingStorage(data))
	local collected = ResourceNodeService.TryCollect(plot, node, requested)

	if collected <= 0 then
		FeedbackService.Send(player, "Resource is respawning")
		return
	end

	local accepted = EconomyService.AddResource(data, resourceType, collected)
	if accepted > 0 then
		QuestService.Notify(player, `Manual{resourceType}Collected`, accepted)
	end
	DisplayService.UpdateAll(player, plot)
	FeedbackService.Send(player, `+{accepted} {resourceType} stored`)
end

function WorldService.InteractManualTree(player: Player, plot: Model)
	if canUseCooldown(player, Local.chopCooldowns, 0.5) then
		collectManual(player, plot, PlotConfig.Paths.ManualTreeTarget, "Wood", Local.MANUAL_CHOP_AMOUNT)
	end
end

function WorldService.InteractManualRock(player: Player, plot: Model)
	local data = DataService.TryGet(player)

	if not data or not UnlockService.CanUseManualRock(data) then
		FeedbackService.Send(player, "Locked: Hire a Wood NPC first")
		return
	end

	if canUseCooldown(player, Local.mineCooldowns, 0.5) then
		collectManual(player, plot, PlotConfig.Paths.ManualRockTarget, "Stone", Local.MANUAL_MINE_AMOUNT)
	end
end

function WorldService.SellResources(player: Player, plot: Model)
	if PlotService.TryGet(player) ~= plot then
		return
	end

	local data = DataService.TryGet(player)

	if not data then
		return
	end

	local woodBefore = data.Wood
	local coalBefore = data.Coal
	local totalEarned = EconomyService.SellAllWood(data)
		+ EconomyService.SellAllStone(data)
		+ EconomyService.SellAllCoal(data)

	if totalEarned <= 0 then
		FeedbackService.Send(player, "No resources to sell")
		return
	end

	DisplayService.UpdateAll(player, plot)
	FeedbackService.Send(player, `Sold resources for {totalEarned} Gold`)
	if woodBefore > 0 then
		QuestService.Notify(player, "WoodSold", woodBefore)
	end
	if coalBefore > 0 then
		QuestService.Notify(player, "CoalSold", coalBefore)
	end
	QuestService.Refresh(player)
end

function WorldService.InteractStorageUpgradeButton(player: Player, plot: Model)
	local data = DataService.TryGet(player)
	local cost = data and EconomyService.GetStorageUpgradeCost(data) or 0

	if not data or not EconomyService.BuyStorageUpgrade(data) then
		FeedbackService.Send(player, `Need {cost} Gold`)
		return
	end

	DisplayService.UpdateAll(player, plot)
	FeedbackService.Send(player, `Storage capacity upgraded to {EconomyService.GetStorageCapacity(data)}`)
	QuestService.Refresh(player)
end

local function buyNPC(player: Player, role: WorkerTypes.Role)
	local data = DataService.TryGet(player)
	local plot = PlotService.TryGet(player)

	if
		not data
		or not plot
		or not WorkerConfig.Roles[role]
		or not UnlockService.CanBuyNPCRole(data, role)
		or not isNear(player, getPlotModel(plot, PlotConfig.Paths.NPCPurchasePadTarget))
	then
		return
	end

	local homeSlotId = WorkerService.GetAvailableHomeSlot(plot, data)
	local cost = EconomyService.GetNPCPurchaseCost(data, role)

	if not homeSlotId then
		FeedbackService.Send(player, "All NPC homes are occupied")
		return
	end

	if not EconomyService.TrySpendGold(data, cost) then
		FeedbackService.Send(player, `Need {cost} Gold`)
		return
	end

	local id = HttpService:GenerateGUID(false)
	local npc: WorkerTypes.NPCData = {
		Id = id,
		Role = role,
		HomeSlotId = homeSlotId,
		SpeedLevel = 1,
		AmountLevel = 1,
		CargoType = nil,
		CargoAmount = 0,
	}
	data.NPCs[id] = npc

	if not WorkerService.Spawn(player, plot, npc) then
		data.NPCs[id] = nil
		data.Gold += cost
		FeedbackService.Send(player, "NPC could not spawn")
		return
	end

	WorldService.UpdateUnlocks(player, plot)
	QuestService.Refresh(player)
	workerMenuEvent:FireClient(player, getPurchaseMenu(data))
	FeedbackService.Send(player, `{WorkerConfig.Roles[role].DisplayName} hired`)
end

local function upgradeNPC(player: Player, npcId: string, upgradeType: WorkerTypes.UpgradeType)
	local data = DataService.TryGet(player)
	local plot = PlotService.TryGet(player)
	local npc = data and getNPC(data, npcId)
	local model = WorkerService.GetModel(player, npcId)

	if not data or not plot or not npc or not model or not isNear(player, model) then
		return
	end

	local cost = EconomyService.GetNPCUpgradeCost(npc, upgradeType)

	if not EconomyService.TrySpendGold(data, cost) then
		FeedbackService.Send(player, `Need {cost} Gold`)
		return
	end

	if upgradeType == "Speed" then
		npc.SpeedLevel += 1
	else
		npc.AmountLevel += 1
	end

	WorkerService.RefreshStats(player, npcId)
	QuestService.Refresh(player)
	DisplayService.UpdateAll(player, plot)
	workerMenuEvent:FireClient(player, getManageMenu(npc))
end

local interactionHandlers: { [string]: (Player, Model, Model) -> () } = {
	[InteractionConfig.Definitions.ManualTree.Id] = function(player, plot)
		WorldService.InteractManualTree(player, plot)
	end,
	[InteractionConfig.Definitions.ManualRock.Id] = function(player, plot)
		WorldService.InteractManualRock(player, plot)
	end,
	[InteractionConfig.Definitions.StorageUpgradeButton.Id] = function(player, plot)
		WorldService.InteractStorageUpgradeButton(player, plot)
	end,
	[InteractionConfig.Definitions.NPCPurchasePad.Id] = function(player)
		local data = DataService.TryGet(player)
		if data then
			workerMenuEvent:FireClient(player, getPurchaseMenu(data))
		end
	end,
	ManageNPC = function(player, _, target)
		local data = DataService.TryGet(player)
		local npcId = target:GetAttribute("NPCId")
		local npc = data and typeof(npcId) == "string" and getNPC(data, npcId) or nil
		if npc then
			workerMenuEvent:FireClient(player, getManageMenu(npc))
		end
	end,
	BuyMachinePart = function(player, _, target)
		MachineService.HandleInteraction(player, "BuyMachinePart", target)
	end,
	ManageMachinePart = function(player, _, target)
		MachineService.HandleInteraction(player, "ManageMachinePart", target)
	end,
}

function WorldService.HandleInteraction(player: Player, interactionId: string, plot: Model, target: Model)
	local handler = interactionHandlers[interactionId]

	if handler then
		handler(player, plot, target)
	end
end

function WorldService.SetupPlayer(player: Player, plot: Model)
	WorldService.CleanupPlayer(player)
	ResourceNodeService.SetupPlot(plot)
	WorkerService.SetupPlayer(player, plot)
	MachineService.SetupPlayer(player, plot)

	local maid = Maid.New(nil)
	local touchPad = getPlotPart(plot, PlotConfig.Paths.SellTouchPad)
	local touchingParts = {} :: { [BasePart]: boolean }
	local isInside = false
	Local.maidsByPlayer[player] = maid

	maid:Add(touchPad.Touched:Connect(function(part)
		local character = player.Character
		if PlotService.TryGet(player) == plot and character and part:IsDescendantOf(character) then
			touchingParts[part] = true
			if not isInside then
				isInside = true
				WorldService.SellResources(player, plot)
			end
		end
	end))

	maid:Add(touchPad.TouchEnded:Connect(function(part)
		touchingParts[part] = nil
		task.defer(function()
			if next(touchingParts) == nil then
				isInside = false
			end
		end)
	end))
end

function WorldService.CleanupPlayer(player: Player)
	local plot = PlotService.TryGet(player)
	local maid = Local.maidsByPlayer[player]
	Local.maidsByPlayer[player] = nil

	if maid then
		maid:Cleanup()
	end

	WorkerService.CleanupPlayer(player)
	MachineService.CleanupPlayer(player)
	if plot then
		ResourceNodeService.CleanupPlot(plot)
	end
	Local.chopCooldowns[player] = nil
	Local.mineCooldowns[player] = nil
end

function WorldService.Start()
	if Local.started then
		return
	end
	Local.started = true

	workerRequestEvent.OnServerEvent:Connect(function(player, action, first, second)
		if not workerRateLimit:CheckRate(player) or typeof(action) ~= "string" then
			return
		end

		if action == "Buy" and (first == "Wood" or first == "Stone" or first == "Coal") then
			buyNPC(player, first)
		elseif action == "Upgrade" and typeof(first) == "string" and (second == "Speed" or second == "Amount") then
			upgradeNPC(player, first, second)
		end
	end)
	MachineService.Start()
end

return WorldService
