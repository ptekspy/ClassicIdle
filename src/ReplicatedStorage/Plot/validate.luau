--!strict

local Config = require(script.Parent.Config)
local getModel = require(script.Parent.getModel)
local getPart = require(script.Parent.getPart)
local resolve = require(script.Parent.resolve)

local function validate(plot: Model)
	local paths = Config.Paths

	for _, path in
		{
			paths.Ground,
			paths.NPCPurchasePad,
			paths.StorageUpgradeButton,
			paths.MachineStorageOutput,
			paths.Conveyor1Interaction,
			paths.Upgrader1Interaction,
			paths.CoalProcessorInteraction,
			paths.Conveyor2Interaction,
			paths.Upgrader2Interaction,
			paths.CollectionPointInteraction,
			paths.SellTouchPad,
			paths.StorageApproach,
			paths.CollectionPointApproach,
			paths.StorageDisplayAnchor,
			paths.StorageDropTarget,
			paths.PlayerSpawn,
			paths.BuildGridBounds,
			paths.SellScreen
		}
	do
		getPart(plot, path)
	end

	for _, path in
		{
			paths.NPCPurchasePadTarget,
			paths.StorageUpgradeButtonTarget,
			paths.Conveyor1,
			paths.Upgrader1,
			paths.CoalProcessor,
			paths.Conveyor2,
			paths.Upgrader2,
			paths.CollectionPoint,
		}
	do
		getModel(plot, path)
	end

	for _, folderName in
		{
			paths.WorkerHomes,
			paths.WorkerApproachPoints,
			paths.Machine,
			paths.MachineRuntimePieces,
			paths.BuildGridBlockers,
			paths.BuildGridPlacedItems,
			paths.BuildGridRuntimeItems,
			paths.Drops,
		}
	do
		local folder = resolve(plot, folderName)

		if not folder or not folder:IsA("Folder") then
			error(`{plot:GetFullName()} must contain Folder {folderName}`)
		end
	end
end

return validate
