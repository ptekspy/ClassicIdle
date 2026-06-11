--!strict

local Types = require(script.Parent.Types)
local PlotConfig = require(script.Parent.Parent.Plot.Config)

local Config = {
	Tag = "Interactable",
	Attributes = {
		Id = "InteractionId",
		ActionText = "InteractionActionText",
		ObjectText = "InteractionObjectText",
		MaxDistance = "InteractionMaxDistance",
		OwnerUserId = "InteractionOwnerUserId",
	},
	Definitions = {
		ManualTree = {
			Id = "ManualTree",
			Path = PlotConfig.Paths.ManualTree,
			TargetPath = PlotConfig.Paths.ManualTreeTarget,
			ActionText = "Chop",
			ObjectText = "Tree",
			MaxDistance = 10,
		},
		ManualRock = {
			Id = "ManualRock",
			Path = PlotConfig.Paths.ManualRock,
			TargetPath = PlotConfig.Paths.ManualRockTarget,
			ActionText = "Mine",
			ObjectText = "Rock",
			MaxDistance = 10,
		},
		NPCPurchasePad = {
			Id = "OpenNPCPurchaseMenu",
			Path = PlotConfig.Paths.NPCPurchasePad,
			TargetPath = PlotConfig.Paths.NPCPurchasePadTarget,
			ActionText = "Hire NPC",
			ObjectText = "Choose a role",
			MaxDistance = 10,
		},
		StorageUpgradeButton = {
			Id = "UpgradeStorage",
			Path = PlotConfig.Paths.StorageUpgradeButton,
			TargetPath = PlotConfig.Paths.StorageUpgradeButtonTarget,
			ActionText = "Upgrade Storage",
			ObjectText = "50 Gold",
			MaxDistance = 10,
		},
		CoalProcessor = {
			Id = "ProcessCoal",
			Path = PlotConfig.Paths.CoalProcessor,
			TargetPath = PlotConfig.Paths.CoalProcessorTarget,
			ActionText = "Locked",
			ObjectText = "Buy Auto Miner First",
			MaxDistance = 10,
		},
	} :: { [string]: Types.Definition },
}

return Config
