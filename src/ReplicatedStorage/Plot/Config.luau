--!strict

local Types = require(script.Parent.Types)

local Config = {
	Paths = {
		Ground = "OLD.Ground",
		NPCPurchasePad = "OLD.NPCPurchasePad.BaseF",
		NPCPurchasePadTarget = "OLD.NPCPurchasePad",
		StorageUpgradeButton = "OLD.StorageUpgradeButton.BaseF",
		StorageUpgradeButtonTarget = "OLD.StorageUpgradeButton",
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
		SellTouchPad = "OLD.SellCrate.TouchPad",
		SellBillboard = "OLD.SellCrate.BillboardGui",
		SellBillboardLabel = "OLD.SellCrate.BillboardGui.TextLabel",
		SellScreenLabel = "OLD.SellCrate.Screen.SurfaceGui.TextLabel",
		WorkerHomes = "WorkerHomes",
		WorkerApproachPoints = "WorkerApproachPoints",
		StorageApproach = "WorkerApproachPoints.StorageBin",
		CollectionPointApproach = "WorkerApproachPoints.CollectionPoint",
		StorageDisplayAnchor = "OLD.StorageBin.Top",
		StorageDropTarget = "OLD.StorageBin.Top",
		PlayerSpawn = "OLD.PlayerSpawn",
		Drops = "OLD.Drops",
		BuildGridBounds = "BuildGrid.Bounds",
		BuildGridBlockers = "BuildGrid.Blockers",
		BuildGridPlacedItems = "BuildGrid.PlacedItems",
		BuildGridRuntimeItems = "BuildGrid.RuntimeItems",
	} :: Types.Paths,
}

return Config
