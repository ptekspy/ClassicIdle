--!strict

local Types = require(script.Parent.Types)

local DEFAULT_DATA: Types.PlayerData = {
	Gold = 0,
	Wood = 0,
	Stone = 0,
	Coal = 0,
	AutoChopperLevel = 0,
	AutoMinerLevel = 0,
	AutoProcessorLevel = 0,
	StorageLevel = 1,
}

return DEFAULT_DATA