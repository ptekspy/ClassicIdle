--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Corner = require(ReplicatedStorage.UI.Primitives.Corner)

local function Crosshair(props: { visible: boolean })
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Colors.Text.Primary,
		Visible = props.visible,
	}, {
		Corner = React.createElement(Corner, { variant = "Pill" }),
	})
end

return Crosshair
