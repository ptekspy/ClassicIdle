--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function control(text: string, order: number, callback: () -> ())
	return React.createElement("TextButton", {
		LayoutOrder = order,
		Size = UDim2.fromOffset(105, 46),
		BackgroundColor3 = Color3.fromRGB(65, 130, 80),
		Font = Enum.Font.GothamBold,
		Text = text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
		TextWrapped = true,
		[React.Event.Activated] = callback,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})
end

local function BuildControls(props: {
	visible: boolean,
	onRotate: () -> (),
	onConfirm: () -> (),
	onCancel: () -> (),
})
	return React.createElement("Frame", {
		Name = "BuildControls",
		Position = UDim2.new(0.5, -180, 1, -165),
		Size = UDim2.fromOffset(360, 62),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.08,
		Visible = props.visible,
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Rotate = control("ROTATE\nR / Y", 1, props.onRotate),
		Confirm = control("PLACE\nCLICK / A", 2, props.onConfirm),
		Cancel = control("CANCEL\nESC / B", 3, props.onCancel),
	})
end

return BuildControls