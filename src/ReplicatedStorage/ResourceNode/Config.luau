--!strict

local Config = {
	Tags = {
		Node = "ResourceNode",
		Zone = "ResourceZone",
	},
	Attributes = {
		ResourceType = "ResourceType",
		Capacity = "Capacity",
		AvailableAmount = "AvailableAmount",
		ReservedAmount = "ReservedAmount",
		RespawnSeconds = "RespawnSeconds",
		NodeLevel = "NodeLevel",
		IsGenerated = "IsGenerated",
		ZoneId = "ZoneId",
		GeneratedNodeId = "GeneratedNodeId",
		IsDepleted = "IsDepleted",
		IsDisabled = "IsDisabled",
	},
	World = {
		SharedFolder = "Shared",
		ZonesFolder = "ResourceZones",
		NodesFolder = "ResourceNodes",
		TemplatesFolder = "ResourceNodeTemplates",
	},
	DefaultCapacity = 25,
	DefaultRespawnSeconds = 5,
	DefaultNodeLevel = 1,
	DefaultNodeCount = 10,
	DefaultMinimumSpacing = 12,
	DefaultMaxPlacementAttempts = 500,
	PlacementMargin = 5,
	ApproachDistance = 4,
}

return Config
