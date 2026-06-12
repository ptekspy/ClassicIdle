--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	visible: boolean,
	onActivated: () -> (),
}

local function TouchInteractButton(props: Props)
	return React.createElement("TextButton", {
		Name = "TouchInteract",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -24, 1, -118),
		Size = UDim2.fromOffset(104, 104),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		Text = "INTERACT",
		TextColor3 = Color3.fromRGB(25, 25, 25),
		TextSize = 15,
		Visible = props.visible,
		[React.Event.Activated] = props.onActivated,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})
end

return TouchInteractButton