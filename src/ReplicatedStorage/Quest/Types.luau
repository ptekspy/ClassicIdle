--!strict

export type QuestId = string
export type ObjectiveType = "Event" | "State"
export type WayfindingType = "PlotPath" | "WorkerRole" | "MachinePart" | "Earning"

export type QuestDefinition = {
	QuestId: QuestId,
	Title: string,
	Description: string,
	ObjectiveType: ObjectiveType,
	Objective: string,
	RequiredAmount: number,
	XPReward: number,
	WayfindingType: WayfindingType,
	WayfindingValue: string,
}

export type QuestData = {
	CurrentQuestId: QuestId?,
	CompletedQuestIds: { [QuestId]: boolean },
	CurrentProgress: number,
}

export type ClientQuestState = {
	QuestId: QuestId?,
	Title: string?,
	Description: string?,
	Progress: number,
	RequiredAmount: number,
	XPReward: number,
	WayfindingType: WayfindingType?,
	WayfindingValue: string?,
	Complete: boolean,
}

return {}
