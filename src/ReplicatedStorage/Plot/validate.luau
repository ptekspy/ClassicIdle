--!strict

local Config = require(script.Parent.Config)
local getBillboardGui = require(script.Parent.getBillboardGui)
local getModel = require(script.Parent.getModel)
local getPart = require(script.Parent.getPart)
local getTextLabel = require(script.Parent.getTextLabel)

local function validate(plot: Model)
	local paths = Config.Paths

	for _, path in {
		paths.ManualTree,
		paths.TreeLeaves,
		paths.ManualRock,
		paths.NPCPurchasePad,
		paths.StorageUpgradeButton,
		paths.CoalProcessor,
		paths.SellTouchPad,
		paths.TreeApproach,
		paths.RockApproach,
		paths.StorageApproach,
		paths.CoalProcessorApproach,
		paths.StorageDisplayAnchor,
		paths.StorageDropTarget,
		paths.PlayerSpawn,
	} do
		getPart(plot, path)
	end

	for _, path in {
		paths.ManualTreeTarget,
		paths.ManualRockTarget,
		paths.NPCPurchasePadTarget,
		paths.StorageUpgradeButtonTarget,
		paths.CoalProcessorTarget,
	} do
		getModel(plot, path)
	end

	for _, folderName in { paths.WorkerHomes, paths.WorkerApproachPoints } do
		local folder = plot:FindFirstChild(folderName)

		if not folder or not folder:IsA("Folder") then
			error(`{plot:GetFullName()} must contain Folder {folderName}`)
		end
	end

	getBillboardGui(plot, paths.SellBillboard)
	getTextLabel(plot, paths.SellBillboardLabel)
	getTextLabel(plot, paths.SellScreenLabel)
end

return validate
