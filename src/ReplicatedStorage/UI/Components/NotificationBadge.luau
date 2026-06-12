--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Corner = require(ReplicatedStorage.UI.Primitives.Corner)
local Stroke = require(ReplicatedStorage.UI.Primitives.Stroke)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = { text: string, position: UDim2? }

local function NotificationBadge(props: Props)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = props.position or UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(28, 24),
		BackgroundColor3 = Colors.Badge.Red,
	}, {
		Corner = React.createElement(Corner, { variant = "Pill" }),
		Stroke = React.createElement(Stroke, { variant = "Outer" }),
		Label = React.createElement(Text, {
			text = props.text,
			variant = "Caption",
			color = "Primary",
			size = UDim2.fromScale(1, 1),
		}),
	})
end

return NotificationBadge
