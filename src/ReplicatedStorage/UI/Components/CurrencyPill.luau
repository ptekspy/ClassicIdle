--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local Button = require(ReplicatedStorage.UI.Components.Button)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	icon: string,
	value: string,
	showPlus: boolean,
	enabled: boolean,
}

local function CurrencyPill(props: Props)
	return React.createElement(Panel, {
		variant = "Status",
		size = UDim2.fromScale(1, 1),
		children = {
			Icon = React.createElement("Frame", {
				Position = UDim2.fromOffset(12, 0),
				Size = UDim2.fromOffset(50, 72),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Image = React.createElement(Icon, {
					icon = props.icon,
					size = "Medium",
				}),
			}),

			Value = React.createElement(Text, {
				text = props.value,
				variant = "Heading",
				color = "Primary",
				position = UDim2.fromOffset(70, 0),
				size = UDim2.new(1, -124, 1, 0),
				textXAlignment = Enum.TextXAlignment.Left,
			}),

			Plus = if props.showPlus
				then React.createElement("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.fromScale(0.96, 0.5),
					Size = UDim2.fromOffset(44, 44),
					BackgroundTransparency = 1,
				}, {
					Button = React.createElement(Button, {
						text = "+",
						variant = "GreenHero",
						size = UDim2.fromScale(1, 1),
						onActivated = nil,
					}),
				})
				else nil,
		},
	})
end

return CurrencyPill