--!strict

local Config = require(script.Parent.Config)
local Types = require(script.Parent.Types)

local Grid = {}

local directionOrder = { "North", "East", "South", "West" } :: { Types.Direction }
local directionIndex = { North = 1, East = 2, South = 3, West = 4 }

function Grid.GetBounds(plot: Model): BasePart?
	local buildGrid = plot:FindFirstChild("BuildGrid")
	local bounds = buildGrid and buildGrid:FindFirstChild("Bounds")
	return if bounds and bounds:IsA("BasePart") then bounds else nil
end

function Grid.GetDimensions(bounds: BasePart): (number, number)
	return math.floor(bounds.Size.X / Config.CellSize), math.floor(bounds.Size.Z / Config.CellSize)
end

function Grid.WorldToGrid(bounds: BasePart, worldPosition: Vector3): (number, number)
	local localPosition = bounds.CFrame:PointToObjectSpace(worldPosition)
	return math.floor((localPosition.X + bounds.Size.X * 0.5) / Config.CellSize) + 1,
		math.floor((localPosition.Z + bounds.Size.Z * 0.5) / Config.CellSize) + 1
end

function Grid.GridToWorld(bounds: BasePart, gridX: number, gridZ: number): Vector3
	return bounds.CFrame:PointToWorldSpace(Vector3.new(
		-bounds.Size.X * 0.5 + (gridX - 0.5) * Config.CellSize,
		-bounds.Size.Y * 0.5,
		-bounds.Size.Z * 0.5 + (gridZ - 0.5) * Config.CellSize
	))
end

function Grid.GetCFrame(bounds: BasePart, gridX: number, gridZ: number, rotation: number): CFrame
	return CFrame.new(Grid.GridToWorld(bounds, gridX, gridZ)) * bounds.CFrame.Rotation * CFrame.Angles(0, math.rad(rotation), 0)
end

function Grid.RotateOffset(x: number, z: number, rotation: number): (number, number)
	if rotation == 90 then
		return z, -x
	elseif rotation == 180 then
		return -x, -z
	elseif rotation == 270 then
		return -z, x
	end
	return x, z
end

function Grid.RotateDirection(direction: Types.Direction, rotation: number): Types.Direction
	local index = ((directionIndex[direction] - 1 - math.floor(rotation / 90)) % 4) + 1
	return directionOrder[index]
end

function Grid.Opposite(direction: Types.Direction): Types.Direction
	return Grid.RotateDirection(direction, 180)
end

function Grid.DirectionOffset(direction: Types.Direction): (number, number)
	if direction == "North" then
		return 0, -1
	elseif direction == "East" then
		return 1, 0
	elseif direction == "South" then
		return 0, 1
	end
	return -1, 0
end

function Grid.GetFootprint(
	definition: Types.ItemDefinition,
	gridX: number,
	gridZ: number,
	rotation: number
): { { X: number, Z: number, Kind: Types.CellKind } }
	local cells = {}
	for _, cell in definition.Footprint do
		local x, z = Grid.RotateOffset(cell.X, cell.Z, rotation)
		table.insert(cells, { X = gridX + x, Z = gridZ + z, Kind = cell.Kind })
	end
	return cells
end

function Grid.GetConnector(item: Types.PlacedItem, connector: Types.Connector): (number, number, Types.Direction)
	local x, z = Grid.RotateOffset(connector.CellX, connector.CellZ, item.Rotation)
	return item.GridX + x, item.GridZ + z, Grid.RotateDirection(connector.Direction, item.Rotation)
end

function Grid.IsInside(bounds: BasePart, gridX: number, gridZ: number): boolean
	local width, depth = Grid.GetDimensions(bounds)
	return gridX >= 1 and gridX <= width and gridZ >= 1 and gridZ <= depth
end

function Grid.CellKey(gridX: number, gridZ: number): string
	return `{gridX}:{gridZ}`
end

return Grid
