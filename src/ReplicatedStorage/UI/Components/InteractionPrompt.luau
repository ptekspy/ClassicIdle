--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local Corner = require(ReplicatedStorage.UI.Primitives.Corner)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	actionText: string,
	objectText: string,
	inputHint: string,
	visible: boolean,
}

local function InteractionPrompt(props: Props)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.92),
		Size = UDim2.new(0.8, 0, 0, 82),
		BackgroundTransparency = 1,
		Visible = props.visible,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(440, 82),
			MinSize = Vector2.new(240, 82),
		}),
		Panel = React.createElement(Panel, {
			variant = "Status",
			size = UDim2.fromScale(1, 1),
			children = {
				Action = React.createElement(Text, {
					text = props.actionText,
					variant = "Label",
					color = "Primary",
					position = UDim2.fromOffset(18, 8),
					size = UDim2.new(1, -110, 0, 32),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
				Object = React.createElement(Text, {
					text = props.objectText,
					variant = "Body",
					color = "Secondary",
					position = UDim2.fromOffset(18, 40),
					size = UDim2.new(1, -110, 0, 28),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
				InputHint = React.createElement("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Size = UDim2.fromOffset(72, 48),
					BackgroundColor3 = Colors.Text.Primary,
				}, {
					Corner = React.createElement(Corner, { variant = "Medium" }),
					Label = React.createElement(Text, {
						text = props.inputHint,
						variant = "Caption",
						color = "Dark",
						size = UDim2.fromScale(1, 1),
					}),
				}),
			},
		}),
	})
end

return InteractionPrompt
