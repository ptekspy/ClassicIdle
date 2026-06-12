--!strict

local Types = require(script.Parent.Types)

local DEFAULT_DATA: Types.PlayerData = {
	Gold = 0,
	Wood = 0,
	Stone = 0,
	Coal = 0,
	StorageLevel = 1,
	NPCs = {},
	Machine = {
		Parts = {
			Conveyor1 = { Built = false, Level = 1 },
			Upgrader1 = { Built = false, Level = 1 },
			CoalProcessor = { Built = false, Level = 1 },
			Conveyor2 = { Built = false, Level = 1 },
			Upgrader2 = { Built = false, Level = 1 },
			CollectionPoint = { Built = false, Level = 1 },
		},
		Pieces = {},
		Processor = {
			WoodBuffer = {},
			StoneBuffer = {},
			IsProcessing = false,
			ProcessingRemaining = 0,
			PendingOutputMultiplier = 0,
			ProcessingTimeLevel = 1,
			OutputMultiplierLevel = 1,
		},
		CollectionStored = 0,
		DispatchRemaining = 0,
	},
}

return DEFAULT_DATA
