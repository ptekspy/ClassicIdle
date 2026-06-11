--!strict

export type ResourceType = "Wood" | "Stone" | "Coal"

export type SpawnDropOptions = {
	Plot: Model,
	ResourceType: ResourceType,
	Amount: number,
	StartPosition: Vector3,
	EndPosition: Vector3,
	OnCollected: () -> (),
}

return {}
