--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Button = require(ReplicatedStorage.UI.Components.Button)
local Panel = require(ReplicatedStorage.UI.Components.Panel)

local function control(text: string, order: number, callback: () -> ())
	return React.createElement(Button, {
		text = text,
		variant = "Primary",
		size = UDim2.fromOffset(105, 46),
		layoutOrder = order,
		onActivated = callback,
	})
end

local function BuildControls(props: {
	visible: boolean,
	onRotate: () -> (),
	onConfirm: () -> (),
	onCancel: () -> (),
})
	return React.createElement("Frame", {
		Position = UDim2.new(0.5, -180, 1, -165),
		Size = UDim2.fromOffset(360, 62),
		BackgroundTransparency = 1,
		Visible = props.visible,
	}, {
		Panel = React.createElement(Panel, {
			variant = "Status",
			size = UDim2.fromScale(1, 1),
			children = {
				Layout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 8),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Rotate = control("ROTATE\nR / Y", 1, props.onRotate),
				Confirm = control("PLACE\nCLICK / A", 2, props.onConfirm),
				Cancel = control("CANCEL\nESC / B", 3, props.onCancel),
			},
		}),
	})
end

return BuildControls
