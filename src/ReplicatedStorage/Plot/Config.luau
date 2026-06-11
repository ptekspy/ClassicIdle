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
		CoalProcessor = "CoalProcessor.Walls.Roof",
		CoalProcessorTarget = "CoalProcessor",
		SellTouchPad = "SellCrate.TouchPad",
		SellBillboard = "SellCrate.BillboardGui",
		SellBillboardLabel = "SellCrate.BillboardGui.TextLabel",
		SellScreenLabel = "SellCrate.Screen.SurfaceGui.TextLabel",
		WorkerHomes = "WorkerHomes",
		WorkerApproachPoints = "WorkerApproachPoints",
		TreeApproach = "WorkerApproachPoints.Tree",
		RockApproach = "WorkerApproachPoints.Rock",
		StorageApproach = "WorkerApproachPoints.StorageBin",
		CoalProcessorApproach = "WorkerApproachPoints.CoalProcessor",
		StorageDisplayAnchor = "StorageBin.Top",
		StorageDropTarget = "StorageBin.Top",
		PlayerSpawn = "PlayerSpawn",
	} :: Types.Paths,
}

return Config
