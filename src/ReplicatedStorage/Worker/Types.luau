--!strict

local ResourceTypes = require(script.Parent.Parent.Resource.Types)

export type Role = string
export type ResourceType = ResourceTypes.ResourceId
export type UpgradeType = "Speed" | "Amount"

export type NPCData = {
	Id: string,
	Role: Role,
	HomeSlotId: string,
	SpeedLevel: number,
	AmountLevel: number,
	CargoType: ResourceType?,
	CargoAmount: number,
}

return {}
