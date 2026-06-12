--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Button = require(ReplicatedStorage.UI.Components.Button)
local NotificationBadge = require(ReplicatedStorage.UI.Components.NotificationBadge)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	icon: string,
	label: string?,
	badge: string?,
	size: UDim2?,
	layoutOrder: number?,
	onActivated: (() -> ())?,
}

local function IconButton(props: Props)
	return React.createElement("Frame", {
		Size = props.size or UDim2.fromOffset(76, 76),
		LayoutOrder = props.layoutOrder or 0,
		BackgroundTransparency = 1,
	}, {
		Button = React.createElement(Button, {
			text = "",
			variant = "Primary",
			size = UDim2.fromScale(1, 1),
			onActivated = props.onActivated,
		}),
		Icon = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.08),
			Size = UDim2.fromScale(1, 0.65),
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Image = React.createElement(Icon, { icon = props.icon, size = "Medium" }),
		}),
		Label = if props.label
			then React.createElement(Text, {
				text = props.label,
				variant = "Caption",
				color = "Primary",
				position = UDim2.fromScale(0, 0.68),
				size = UDim2.fromScale(1, 0.27),
			})
			else nil,
		Badge = if props.badge
			then React.createElement(NotificationBadge, {
				text = props.badge,
				position = UDim2.fromScale(0.82, 0.02),
			})
			else nil,
	})
end

return IconButton
