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
		Scope = "InteractionScope",
	},
	Scopes = {
		OwnedPlot = "OwnedPlot",
		Shared = "Shared",
	},
	Definitions = {
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
	} :: { [string]: Types.Definition },
}

return Config
