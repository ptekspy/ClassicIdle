--!strict

local ResourceTypes = require(script.Parent.Parent.Resource.Types)

export type ResourceType = ResourceTypes.ResourceId

export type Reservation = {
	Id: string,
	Node: Model,
	Owner: Instance,
	Amount: number,
}

return {}
