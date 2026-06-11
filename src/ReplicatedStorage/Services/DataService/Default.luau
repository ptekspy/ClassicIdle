--!strict

local Types = require(script.Parent.Types)

local DEFAULT_DATA: Types.PlayerData = {
	Gold = 0,
	Wood = 0,
	Stone = 0,
	Coal = 0,
	StorageLevel = 1,
	NPCs = {},
}

return DEFAULT_DATA
