--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function QuestTargetMarker(props: { adornee: BasePart? })
	return React.createElement("BillboardGui", {
		Name = "QuestTargetMarker",
		Adornee = props.adornee,
		Size = UDim2.fromOffset(120, 38),
		StudsOffset = Vector3.new(0, 5, 0),
		AlwaysOnTop = true,
		Enabled = props.adornee ~= nil,
	}, {
		Label = React.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			BackgroundTransparency = 0.15,
			Font = Enum.Font.GothamBold,
			Text = "QUEST",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 15,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
		}),
	})
end

return QuestTargetMarker
