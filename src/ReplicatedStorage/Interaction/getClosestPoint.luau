--!strict

local function getClosestPoint(part: BasePart, position: Vector3): Vector3
	local localPosition = part.CFrame:PointToObjectSpace(position)
	local halfSize = part.Size * 0.5
	local closestLocalPosition = Vector3.new(
		math.clamp(localPosition.X, -halfSize.X, halfSize.X),
		math.clamp(localPosition.Y, -halfSize.Y, halfSize.Y),
		math.clamp(localPosition.Z, -halfSize.Z, halfSize.Z)
	)

	return part.CFrame:PointToWorldSpace(closestLocalPosition)
end

return getClosestPoint
