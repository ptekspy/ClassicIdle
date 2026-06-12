--!strict

local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Services.DataService)
local DisplayService = require(ReplicatedStorage.Services.DisplayService)
local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local InteractionConfig = require(ReplicatedStorage.Interaction.Config)
local FactoryService = require(ReplicatedStorage.Services.FactoryService)
local PlotConfig = require(ReplicatedStorage.Plot.Config)
local QuestService = require(ReplicatedStorage.Services.QuestService)
local ResourceNodeService = require(ReplicatedStorage.Services.ResourceNodeService)
local WorkerConfig = require(ReplicatedStorage.Worker.Config)
local WorkerTypes = require(ReplicatedStorage.Worker.Types)
local getPlotPart = require(ReplicatedStorage.Plot.getPart)

type RuntimeWorker = {
	Active: boolean,
	ActionTrack: AnimationTrack,
	IdleTrack: AnimationTrack,
	Model: Model,
	NPC: WorkerTypes.NPCData,
	Player: Player,
	Plot: Model,
	MovementFailures: number,
}

local assets = ReplicatedStorage:WaitForChild("Assets")
local workerTemplates = assets:WaitForChild("WorkerTemplates")

local Local = {
	workersByPlayer = {} :: { [Player]: { [string]: RuntimeWorker } },
}

local WorkerService = {}

local function loadTrack(
	animator: Animator,
	animationId: string,
	looped: boolean,
	priority: Enum.AnimationPriority
): AnimationTrack
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	track.Looped = looped
	track.Priority = priority
	animation:Destroy()
	return track
end

local function setState(worker: RuntimeWorker, state: string)
	worker.Model:SetAttribute("WorkerState", state)
	worker.Model:SetAttribute("CargoType", worker.NPC.CargoType)
	worker.Model:SetAttribute("CargoAmount", worker.NPC.CargoAmount)
end

local function getGroundY(plot: Model): number
	local ground = plot:FindFirstChild("Ground")

	if ground and ground:IsA("BasePart") then
		return ground.Position.Y + ground.Size.Y * 0.5
	end

	return plot:GetPivot().Position.Y
end

local function getHomeCFrame(player: Player, plot: Model, homeSlotId: string): CFrame?
	return FactoryService.GetWorkerHomeCFrame(player, homeSlotId)
end

local function getApproach(plot: Model, path: string): BasePart?
	local ok, result = pcall(getPlotPart, plot, path)
	return if ok then result else nil
end

local function moveToPosition(worker: RuntimeWorker, humanoid: Humanoid, target: Instance, position: Vector3): boolean
	humanoid:MoveTo(position)
	local completed = false
	local reached = false
	local connection = humanoid.MoveToFinished:Connect(function(didReach)
		reached = didReach
		completed = true
	end)
	local startedAt = os.clock()

	while
		worker.Active
		and target.Parent
		and not completed
		and os.clock() - startedAt < WorkerConfig.MoveTimeoutSeconds
	do
		task.wait(0.1)
	end

	connection:Disconnect()
	return worker.Active and target.Parent ~= nil and reached
end

local function moveToPoint(worker: RuntimeWorker, target: Instance, position: Vector3): boolean
	if not worker.Active or not worker.Model.Parent or not target.Parent then
		return false
	end

	local humanoid = worker.Model:FindFirstChildOfClass("Humanoid")
	local root = worker.Model.PrimaryPart

	if not humanoid or not root then
		return false
	end

	setState(worker, "Moving")
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		WaypointSpacing = 4,
	})
	local computed = pcall(function()
		path:ComputeAsync(root.Position, position)
	end)

	if computed and path.Status == Enum.PathStatus.Success then
		for _, waypoint in path:GetWaypoints() do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end

			if not moveToPosition(worker, humanoid, target, waypoint.Position) then
				return false
			end
		end

		return true
	end

	return moveToPosition(worker, humanoid, target, position)
end

local function moveTo(worker: RuntimeWorker, target: BasePart): boolean
	return moveToPoint(worker, target, target.Position)
end

local function playAction(worker: RuntimeWorker)
	setState(worker, "CollectingOrProcessing")
	worker.ActionTrack:Stop(0)
	worker.ActionTrack:Play(0.1)
	task.wait(WorkerConfig.ActionSeconds)
end

local function depositCargo(worker: RuntimeWorker): boolean
	if worker.NPC.CargoAmount <= 0 or not worker.NPC.CargoType then
		return true
	end

	local storage = getApproach(worker.Plot, PlotConfig.Paths.StorageApproach)

	if not storage or not moveTo(worker, storage) then
		return false
	end

	setState(worker, "Depositing")

	while worker.Active and worker.NPC.CargoAmount > 0 do
		local data = DataService.TryGet(worker.Player)

		if not data then
			return false
		end

		local accepted =
			EconomyService.AddResource(data, worker.NPC.CargoType :: WorkerTypes.ResourceType, worker.NPC.CargoAmount)
		worker.NPC.CargoAmount -= accepted

		if accepted > 0 then
			QuestService.Notify(worker.Player, `{worker.NPC.Role}NPCDeposited`, accepted)
		end

		if worker.NPC.CargoAmount <= 0 then
			worker.NPC.CargoType = nil
		end

		setState(worker, if worker.NPC.CargoAmount > 0 then "WaitingForStorageSpace" else "Depositing")
		DisplayService.UpdateAll(worker.Player, worker.Plot)

		if worker.NPC.CargoAmount > 0 then
			task.wait(WorkerConfig.DepositRetrySeconds)
		end
	end

	return true
end

local function waitForStorage(worker: RuntimeWorker)
	local storage = getApproach(worker.Plot, PlotConfig.Paths.StorageApproach)

	if storage then
		moveTo(worker, storage)
	end

	setState(worker, "WaitingForStorageSpace")
	task.wait(WorkerConfig.DepositRetrySeconds)
end

local function runCoalCycle(worker: RuntimeWorker)
	if worker.NPC.CargoAmount > 0 then
		depositCargo(worker)
		return
	end

	local data = DataService.TryGet(worker.Player)
	if not data or EconomyService.IsStorageFull(data) then
		waitForStorage(worker)
		return
	end

	local collectionPoint = FactoryService.GetFirstCollectionModel(worker.Player)
	local collectionRoot = collectionPoint and (collectionPoint.PrimaryPart or collectionPoint:FindFirstChildWhichIsA("BasePart", true))
	if not collectionPoint or not collectionRoot or not moveToPoint(worker, collectionPoint, collectionRoot.Position) then
		task.wait(WorkerConfig.RetrySeconds)
		return
	end

	playAction(worker)
	local withdrawn, resourceType = FactoryService.WithdrawCollection(worker.Player, EconomyService.GetNPCAmount(worker.NPC))
	if withdrawn > 0 then
		worker.NPC.CargoType = resourceType
		worker.NPC.CargoAmount = withdrawn
		setState(worker, "MovingToStorage")
	else
		setState(worker, "FindingWork")
		task.wait(WorkerConfig.RetrySeconds)
	end
end

local function runResourceCycle(worker: RuntimeWorker)
	if worker.NPC.CargoAmount > 0 then
		depositCargo(worker)
		return
	end

	local data = DataService.TryGet(worker.Player)

	if not data or EconomyService.IsStorageFull(data) then
		waitForStorage(worker)
		return
	end

	local root = worker.Model.PrimaryPart
	local definition = WorkerConfig.Roles[worker.NPC.Role]
	local resourceType = definition.ResourceType

	if not root or not resourceType then
		task.wait(WorkerConfig.RetrySeconds)
		return
	end

	setState(worker, "FindingWork")
	local node, reservation = ResourceNodeService.FindAndReserve(
		resourceType,
		root.Position,
		EconomyService.GetNPCAmount(worker.NPC),
		worker.Model
	)

	if not node or not reservation then
		task.wait(WorkerConfig.RetrySeconds)
		return
	end

	local approachPosition = ResourceNodeService.GetApproachPosition(node, root.Position)
	if not moveToPoint(worker, node, approachPosition) or not ResourceNodeService.IsRegistered(node) then
		ResourceNodeService.ReleaseReservation(reservation)
		worker.MovementFailures += 1
		if worker.MovementFailures >= 3 then
			local storage = getApproach(worker.Plot, PlotConfig.Paths.StorageApproach)
			if storage then
				moveTo(worker, storage)
			end
			worker.MovementFailures = 0
		end
		task.wait(WorkerConfig.RetrySeconds)
		return
	end

	worker.MovementFailures = 0
	playAction(worker)
	local collected = ResourceNodeService.CollectReserved(reservation)

	if collected > 0 then
		worker.NPC.CargoType = resourceType
		worker.NPC.CargoAmount += collected
		setState(worker, "MovingToStorage")
	end
end

local function runWorker(worker: RuntimeWorker)
	while worker.Active and worker.Model.Parent and worker.Plot.Parent and DataService.TryGet(worker.Player) do
		local definition = WorkerConfig.Roles[worker.NPC.Role]
		if not definition then
			return
		elseif definition.Behavior == "CoalProcessor" then
			runCoalCycle(worker)
		else
			runResourceCycle(worker)
		end
		task.wait(0.1)
	end
end

local function createWorker(player: Player, plot: Model, npc: WorkerTypes.NPCData): RuntimeWorker?
	local definition = WorkerConfig.Roles[npc.Role]
	if not definition then
		return nil
	end
	local template = workerTemplates:FindFirstChild(definition.TemplateName)
	local homeCFrame = getHomeCFrame(player, plot, npc.HomeSlotId)

	if not template or not template:IsA("Model") or not homeCFrame then
		return nil
	end

	local workersFolder = plot:FindFirstChild("Workers")

	if not workersFolder then
		workersFolder = Instance.new("Folder")
		workersFolder.Name = "Workers"
		workersFolder.Parent = plot
	end

	local model = template:Clone()
	model.Name = npc.Id
	model:SetAttribute("NPCId", npc.Id)
	model:SetAttribute("Role", npc.Role)
	model:SetAttribute("InteractionId", "ManageNPC")
	model:SetAttribute("InteractionActionText", "Manage NPC")
	model:SetAttribute("InteractionObjectText", definition.DisplayName)
	model:SetAttribute("InteractionMaxDistance", 10)
	model:SetAttribute("InteractionOwnerUserId", player.UserId)
	model:SetAttribute(InteractionConfig.Attributes.Scope, InteractionConfig.Scopes.OwnedPlot)
	model.Parent = workersFolder
	model:PivotTo(homeCFrame)
	CollectionService:AddTag(model, InteractionConfig.Tag)

	local animate = model:FindFirstChild("Animate")

	if animate and animate:IsA("BaseScript") then
		animate.Enabled = false
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root or not root:IsA("BasePart") then
		model:Destroy()
		return nil
	end

	humanoid.WalkSpeed = EconomyService.GetNPCSpeed(npc)
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	pcall(function()
		root:SetNetworkOwner(nil)
	end)

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local worker: RuntimeWorker = {
		Active = true,
		ActionTrack = loadTrack(
			animator :: Animator,
			definition.ActionAnimationId,
			false,
			Enum.AnimationPriority.Action
		),
		IdleTrack = loadTrack(animator :: Animator, WorkerConfig.IdleAnimationId, true, Enum.AnimationPriority.Idle),
		Model = model,
		NPC = npc,
		Player = player,
		Plot = plot,
		MovementFailures = 0,
	}

	worker.IdleTrack:Play(0.2)
	setState(worker, "Idle")
	return worker
end

function WorkerService.GetAvailableHomeSlot(plot: Model, data: any): string?
	return FactoryService.GetAvailableWorkerHome(data)
end

function WorkerService.Spawn(player: Player, plot: Model, npc: WorkerTypes.NPCData): boolean
	local workers = Local.workersByPlayer[player]

	if not workers or workers[npc.Id] then
		return false
	end

	local worker = createWorker(player, plot, npc)

	if not worker then
		return false
	end

	workers[npc.Id] = worker
	task.spawn(runWorker, worker)
	return true
end

function WorkerService.RefreshStats(player: Player, npcId: string)
	local worker = Local.workersByPlayer[player] and Local.workersByPlayer[player][npcId]
	local humanoid = worker and worker.Model:FindFirstChildOfClass("Humanoid")

	if worker and humanoid then
		humanoid.WalkSpeed = EconomyService.GetNPCSpeed(worker.NPC)
		worker.Model:SetAttribute(
			"InteractionObjectText",
			`{WorkerConfig.Roles[worker.NPC.Role].DisplayName} • Speed {humanoid.WalkSpeed} • Amount {EconomyService.GetNPCAmount(
				worker.NPC
			)}`
		)
	end
end

function WorkerService.GetModel(player: Player, npcId: string): Model?
	local worker = Local.workersByPlayer[player] and Local.workersByPlayer[player][npcId]
	return if worker then worker.Model else nil
end

function WorkerService.SetupPlayer(player: Player, plot: Model)
	WorkerService.CleanupPlayer(player)
	Local.workersByPlayer[player] = {}

	local data = DataService.Get(player)

	for _, npc in data.NPCs do
		WorkerService.Spawn(player, plot, npc)
	end
end

function WorkerService.CleanupPlayer(player: Player)
	local workers = Local.workersByPlayer[player]
	Local.workersByPlayer[player] = nil

	if not workers then
		return
	end

	for _, worker in workers do
		worker.Active = false
		worker.IdleTrack:Stop()
		worker.ActionTrack:Stop()
		worker.Model:Destroy()
	end
end

return WorkerService
