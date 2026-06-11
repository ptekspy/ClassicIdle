--!strict

local Types = require(script.Parent.Types)

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
			ActionText = "Chop",
			ObjectText = "Tree",
			MaxDistance = 10,
		},
		ManualRock = {
			Id = "ManualRock",
			ActionText = "Mine",
			ObjectText = "Rock",
			MaxDistance = 10,
		},
		SellCrate = {
			Id = "SellCrate",
			ActionText = "Sell Storage",
			ObjectText = "Wood + Stone + Coal",
			MaxDistance = 10,
		},
		AutoChopperButton = {
			Id = "BuyAutoChopper",
			ActionText = "Buy Auto Chopper",
			ObjectText = "10 Gold",
			MaxDistance = 10,
		},
		AutoMinerButton = {
			Id = "BuyAutoMiner",
			ActionText = "Locked",
			ObjectText = "Buy Auto Chopper First",
			MaxDistance = 10,
		},
		StorageUpgradeButton = {
			Id = "UpgradeStorage",
			ActionText = "Upgrade Storage",
			ObjectText = "50 Gold",
			MaxDistance = 10,
		},
		AutoProcessorButton = {
			Id = "BuyAutoProcessor",
			ActionText = "Locked",
			ObjectText = "Buy Auto Miner First",
			MaxDistance = 10,
		},
		CoalProcessor = {
			Id = "ProcessCoal",
			ActionText = "Locked",
			ObjectText = "Buy Auto Miner First",
			MaxDistance = 10,
		},
	} :: { [string]: Types.Definition },
}

return Config
