--!strict

local ResourceTypes = require(script.Parent.Parent.Parent.Resource.Types)

export type ResourceType = ResourceTypes.ResourceId

export type SpawnDropOptions = {
	Plot: Model,
	ResourceType: ResourceType,
	Amount: number,
	StartPosition: Vector3,
	EndPosition: Vector3,
	OnCollected: () -> (),
}

return {}
