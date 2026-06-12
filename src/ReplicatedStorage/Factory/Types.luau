--!strict

local ResourceTypes = require(script.Parent.Parent.Resource.Types)

export type ItemId =
	"ConveyorDropper"
	| "StraightConveyor"
	| "CornerConveyor"
	| "ConveyorUpgrader"
	| "ConveyorCollectionBin"
	| "WorkerHome"

export type Direction = "North" | "East" | "South" | "West"
export type Rotation = number
export type ResourceType = ResourceTypes.ResourceId
export type CellKind = "Solid" | "OutputSocket"

export type FootprintCell = {
	X: number,
	Z: number,
	Kind: CellKind,
}

export type Connector = {
	CellX: number,
	CellZ: number,
	Direction: Direction,
	SharedCell: boolean?,
}

export type ConnectorMode = {
	Input: Connector?,
	Output: Connector?,
}

export type ItemDefinition = {
	DisplayName: string,
	Price: number,
	TemplateName: string,
	AllowedRotations: { Rotation },
	Footprint: { FootprintCell },
	ConnectorModes: { ConnectorMode },
	UpgraderMultiplier: number?,
	CollectionCapacity: number?,
}

export type PlacedItemConfig = {
	ConnectorMode: number?,
	ResourceType: ResourceType?,
}

export type PlacedItemState = {
	StoredAmount: number,
	StoredResourceType: ResourceType?,
}

export type PlacedItem = {
	Id: string,
	ItemId: ItemId,
	GridX: number,
	GridZ: number,
	Rotation: Rotation,
	Config: PlacedItemConfig,
	State: PlacedItemState,
}

export type FactoryData = {
	Inventory: { [ItemId]: number },
	PlacedItems: { [string]: PlacedItem },
}

export type Occupant = {
	ItemId: string,
	Kind: CellKind,
}

export type ClientState = {
	Inventory: { [ItemId]: number },
	PlacedItems: { [string]: PlacedItem },
}

return {}
