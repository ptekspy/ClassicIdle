--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Panel = require(ReplicatedStorage.UI.Components.Panel)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = { icon: string, value: string, layoutOrder: number }

local function RewardCard(props: Props)
	return React.createElement(Panel, {
		variant = "Event",
		size = UDim2.fromOffset(112, 104),
		layoutOrder = props.layoutOrder,
		children = {
			Icon = React.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.68),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Image = React.createElement(Icon, { icon = props.icon, size = "Large" }),
			}),
			Value = React.createElement(Text, {
				text = props.value,
				variant = "Label",
				color = "Yellow",
				position = UDim2.fromScale(0, 0.68),
				size = UDim2.fromScale(1, 0.28),
			}),
		},
	})
end

return RewardCard
