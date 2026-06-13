--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local IconButton = require(ReplicatedStorage.UI.Components.IconButton)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	title: string,
	visible: boolean,
	onClose: () -> (),
	children: React.ReactNode,
}

local function ModalPanel(props: Props)
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Colors.Panel.Deep,
		BackgroundTransparency = 0.45,
		Visible = props.visible,
	}, {
		Panel = React.createElement(Panel, {
			variant = "Standard",
			anchorPoint = Vector2.new(0.5, 0.5),
			position = UDim2.fromScale(0.5, 0.5),
			size = UDim2.new(0.85, 0, 0, 390),
			children = {
				Constraint = React.createElement("UISizeConstraint", {
					MinSize = Vector2.new(300, 390),
					MaxSize = Vector2.new(520, 390),
				}),
				Title = React.createElement(Text, {
					text = props.title,
					variant = "Heading",
					color = "Primary",
					position = UDim2.fromOffset(20, 14),
					size = UDim2.new(1, -80, 0, 42),
					textXAlignment = Enum.TextXAlignment.Left,
				}),
				Close = React.createElement("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -14, 0, 14),
					Size = UDim2.fromOffset(42, 42),
					BackgroundTransparency = 1,
				}, {
					Button = React.createElement(IconButton, {
						icon = "Collapse",
						size = UDim2.fromScale(1, 1),
						onActivated = props.onClose,
					}),
				}),
				Content = React.createElement("Frame", {
					Position = UDim2.fromOffset(20, 68),
					Size = UDim2.new(1, -40, 1, -88),
					BackgroundTransparency = 1,
				}, {
					Layout = React.createElement("UIListLayout", {
						Padding = UDim.new(0, 10),
					}),
					Body = React.createElement(React.Fragment, nil, props.children),
				}),
			},
		}),
	})
end

return ModalPanel
