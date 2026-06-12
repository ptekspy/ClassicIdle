--!strict

local Types = require(script.Parent.Types)

local Config = {
	Paths = {
		ManualTree = "Tree.Trunk",
		ManualTreeTarget = "Tree",
		TreeLeaves = "Tree.Leaves",
		ManualRock = "Rock.Body",
		ManualRockTarget = "Rock",
		NPCPurchasePad = "NPCPurchasePad.BaseF",
		NPCPurchasePadTarget = "NPCPurchasePad",
		StorageUpgradeButton = "StorageUpgradeButton.BaseF",
		StorageUpgradeButtonTarget = "StorageUpgradeButton",
		Machine = "Machine",
		MachineRuntimePieces = "Machine.RuntimePieces",
		MachineStorageOutput = "Machine.Markers.StorageOutput",
		Conveyor1 = "Machine.Conveyor1",
		Conveyor1Interaction = "Machine.Conveyor1.InteractionPart",
		Upgrader1 = "Machine.Upgrader1",
		Upgrader1Interaction = "Machine.Upgrader1.InteractionPart",
		CoalProcessor = "Machine.CoalProcessor",
		CoalProcessorInteraction = "Machine.CoalProcessor.InteractionPart",
		Conveyor2 = "Machine.Conveyor2",
		Conveyor2Interaction = "Machine.Conveyor2.InteractionPart",
		Upgrader2 = "Machine.Upgrader2",
		Upgrader2Interaction = "Machine.Upgrader2.InteractionPart",
		CollectionPoint = "Machine.CollectionPoint",
		CollectionPointInteraction = "Machine.CollectionPoint.InteractionPart",
		SellTouchPad = "SellCrate.TouchPad",
		SellBillboard = "SellCrate.BillboardGui",
		SellBillboardLabel = "SellCrate.BillboardGui.TextLabel",
		SellScreenLabel = "SellCrate.Screen.SurfaceGui.TextLabel",
		WorkerHomes = "WorkerHomes",
		WorkerApproachPoints = "WorkerApproachPoints",
		TreeApproach = "WorkerApproachPoints.Tree",
		RockApproach = "WorkerApproachPoints.Rock",
		StorageApproach = "WorkerApproachPoints.StorageBin",
		CollectionPointApproach = "WorkerApproachPoints.CollectionPoint",
		StorageDisplayAnchor = "StorageBin.Top",
		StorageDropTarget = "StorageBin.Top",
		PlayerSpawn = "PlayerSpawn",
	} :: Types.Paths,
}

return Config
