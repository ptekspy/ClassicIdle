--!strict

local function getClosestPoint(target: BasePart | Model, position: Vector3): Vector3
	local targetCFrame: CFrame
	local targetSize: Vector3

	if target:IsA("Model") then
		targetCFrame, targetSize = target:GetBoundingBox()
	else
		targetCFrame = target.CFrame
		targetSize = target.Size
	end

	local localPosition = targetCFrame:PointToObjectSpace(position)
	local halfSize = targetSize * 0.5
	local closestLocalPosition = Vector3.new(
		math.clamp(localPosition.X, -halfSize.X, halfSize.X),
		math.clamp(localPosition.Y, -halfSize.Y, halfSize.Y),
		math.clamp(localPosition.Z, -halfSize.Z, halfSize.Z)
	)

	return targetCFrame:PointToWorldSpace(closestLocalPosition)
end

return getClosestPoint
