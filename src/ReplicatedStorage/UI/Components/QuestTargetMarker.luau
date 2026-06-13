--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local WorldLabel = require(ReplicatedStorage.UI.World.WorldLabel)

local function QuestTargetMarker(props: { adornee: BasePart? })
	return React.createElement("BillboardGui", {
		Adornee = props.adornee,
		Size = UDim2.fromOffset(120, 38),
		StudsOffset = Vector3.new(0, 5, 0),
		AlwaysOnTop = true,
		Enabled = props.adornee ~= nil,
	}, {
		Label = React.createElement(WorldLabel, {
			text = "QUEST",
		}),
	})
end

return QuestTargetMarker
