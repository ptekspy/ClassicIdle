--!strict

export type Role = "Wood" | "Stone" | "Coal"
export type ResourceType = "Wood" | "Stone" | "Coal"
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
