--!strict

local ResourceTypes = require(script.Parent.Parent.Resource.Types)

export type MachinePartId = "Conveyor1" | "Upgrader1" | "CoalProcessor" | "Conveyor2" | "Upgrader2" | "CollectionPoint"
export type MachinePartState = "Locked" | "Preview" | "Built" | "Active"
export type MachineUpgradeType = "Level" | "ProcessingTime" | "OutputMultiplier"
export type PieceStage = "InputConveyor" | "InputUpgrader" | "OutputConveyor" | "OutputUpgrader" | "CollectionWait"
export type ResourceType = ResourceTypes.ResourceId

export type MachinePartData = {
	Built: boolean,
	Level: number,
}

export type MachinePieceData = {
	Id: string,
	ResourceType: ResourceType,
	Amount: number,
	Multiplier: number,
	Stage: PieceStage,
	Progress: number,
}

export type ProcessorData = {
	WoodBuffer: { number },
	StoneBuffer: { number },
	IsProcessing: boolean,
	ProcessingRemaining: number,
	PendingOutputMultiplier: number,
	ProcessingTimeLevel: number,
	OutputMultiplierLevel: number,
}

export type MachineData = {
	Parts: { [MachinePartId]: MachinePartData },
	Pieces: { [string]: MachinePieceData },
	Processor: ProcessorData,
	CollectionStored: number,
	DispatchRemaining: number,
}

return {}
