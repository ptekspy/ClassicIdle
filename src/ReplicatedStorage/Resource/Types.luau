--!strict

export type ResourceId = string

export type DropAppearance = {
	Size: Vector3,
	Color: Color3,
	Material: Enum.Material,
}

export type ManualCollection = {
	Enabled: boolean,
	ActionText: string,
	ObjectText: string,
	Amount: number,
	Unlock: string?,
}

export type WorkerDefinition = {
	DisplayName: string,
	BaseCost: number,
	TemplateName: string,
	ActionAnimationId: string,
	Behavior: string,
	Unlock: string?,
}

export type ResourceDefinition = {
	DisplayName: string,
	SellPrice: number,
	ShowInLeaderstats: boolean,
	FactoryEnabled: boolean,
	Worker: WorkerDefinition?,
	ManualCollection: ManualCollection,
	DropAppearance: DropAppearance,
}

return {}
