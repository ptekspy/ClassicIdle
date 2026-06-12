--!strict

local Types = require(script.Parent.Types)

local rotations = { 0, 90, 180, 270 } :: { Types.Rotation }

local Config = {
	CellSize = 4,
	DispatchInterval = 2,
	ConveyorSpeed = 5,
	ItemOrder = {
		"ConveyorDropper",
		"StraightConveyor",
		"CornerConveyor",
		"ConveyorUpgrader",
		"ConveyorCollectionBin",
		"WorkerHome",
	} :: { Types.ItemId },
	Items = {
		ConveyorDropper = {
			DisplayName = "Conveyor Dropper",
			Price = 100,
			TemplateName = "ConveyorDropper",
			AllowedRotations = rotations,
			Footprint = {
				{ X = 0, Z = 0, Kind = "Solid" },
				{ X = 1, Z = 0, Kind = "Solid" },
				{ X = 2, Z = 0, Kind = "OutputSocket" },
			},
			ConnectorModes = {
				{
					Output = { CellX = 2, CellZ = 0, Direction = "East", SharedCell = true },
				},
			},
		},
		StraightConveyor = {
			DisplayName = "Straight Conveyor",
			Price = 25,
			TemplateName = "StraightConveyor",
			AllowedRotations = rotations,
			Footprint = {
				{ X = 0, Z = 0, Kind = "Solid" },
			},
			ConnectorModes = {
				{
					Input = { CellX = 0, CellZ = 0, Direction = "South" },
					Output = { CellX = 0, CellZ = 0, Direction = "North" },
				},
			},
		},
		CornerConveyor = {
			DisplayName = "Corner Conveyor",
			Price = 35,
			TemplateName = "CornerConveyor",
			AllowedRotations = rotations,
			Footprint = {
				{ X = 0, Z = 0, Kind = "Solid" },
			},
			-- Mode 2 reverses flow through the same physical corner, allowing left and right turns.
			ConnectorModes = {
				{
					Input = { CellX = 0, CellZ = 0, Direction = "South" },
					Output = { CellX = 0, CellZ = 0, Direction = "East" },
				},
				{
					Input = { CellX = 0, CellZ = 0, Direction = "East" },
					Output = { CellX = 0, CellZ = 0, Direction = "South" },
				},
			},
		},
		ConveyorUpgrader = {
			DisplayName = "Conveyor Upgrader",
			Price = 150,
			TemplateName = "ConveyorUpgrader",
			AllowedRotations = rotations,
			Footprint = {
				{ X = 0, Z = 0, Kind = "Solid" },
			},
			ConnectorModes = {
				{
					Input = { CellX = 0, CellZ = 0, Direction = "South" },
					Output = { CellX = 0, CellZ = 0, Direction = "North" },
				},
			},
			UpgraderMultiplier = 2,
		},
		ConveyorCollectionBin = {
			DisplayName = "Conveyor Collection Bin",
			Price = 100,
			TemplateName = "ConveyorCollectionBin",
			AllowedRotations = rotations,
			Footprint = {
				{ X = 0, Z = 0, Kind = "Solid" },
			},
			ConnectorModes = {
				{
					Input = { CellX = 0, CellZ = 0, Direction = "South" },
				},
			},
			CollectionCapacity = 50,
		},
		WorkerHome = {
			DisplayName = "Worker Home",
			Price = 50,
			TemplateName = "WorkerHome",
			AllowedRotations = rotations,
			Footprint = {
				{ X = 0, Z = 0, Kind = "Solid" },
			},
			ConnectorModes = {},
		},
	} :: { [Types.ItemId]: Types.ItemDefinition },
}

function Config.Get(itemId: string): Types.ItemDefinition?
	return Config.Items[itemId :: Types.ItemId]
end

function Config.IsItemId(value: any): boolean
	return typeof(value) == "string" and Config.Get(value) ~= nil
end

function Config.IsRotationAllowed(definition: Types.ItemDefinition, rotation: number): boolean
	for _, allowed in definition.AllowedRotations do
		if allowed == rotation then
			return true
		end
	end
	return false
end

function Config.GetConnectorMode(definition: Types.ItemDefinition, mode: number?): Types.ConnectorMode?
	return definition.ConnectorModes[mode or 1]
end

return Config
