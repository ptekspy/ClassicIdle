--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Button = require(ReplicatedStorage.UI.Components.Button)

export type Props = {
	visible: boolean,
	onActivated: () -> (),
}

local function TouchInteractButton(props: Props)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -24, 1, -118),
		Size = UDim2.fromOffset(104, 104),
		BackgroundTransparency = 1,
		Visible = props.visible,
	}, {
		Button = React.createElement(Button, {
			text = "INTERACT",
			variant = "GreenHero",
			size = UDim2.fromScale(1, 1),
			onActivated = props.onActivated,
		}),
	})
end

return TouchInteractButton
