--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Button = require(ReplicatedStorage.UI.Components.Button)
local NotificationBadge = require(ReplicatedStorage.UI.Components.NotificationBadge)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	icon: string,
	label: string,
	badge: string?,
	layoutOrder: number?,
	onActivated: (() -> ())?,
}

local function ActionTile(props: Props)
	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder or 0,
		Size = UDim2.fromOffset(116, 126),
		BackgroundTransparency = 1,
	}, {
		Button = React.createElement(Button, {
			text = "",
			variant = "Primary",
			size = UDim2.fromScale(1, 1),
			onActivated = props.onActivated,
		}),
		Icon = React.createElement("Frame", {
			Position = UDim2.fromScale(0, 0.04),
			Size = UDim2.fromScale(1, 0.68),
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Image = React.createElement(Icon, { icon = props.icon, size = "ActionTile" }),
		}),
		Label = React.createElement(Text, {
			text = props.label,
			variant = "Label",
			color = "Primary",
			position = UDim2.fromScale(0, 0.72),
			size = UDim2.fromScale(1, 0.24),
		}),
		Badge = if props.badge
			then React.createElement(NotificationBadge, {
				text = props.badge,
				position = UDim2.fromScale(0.88, 0.08),
			})
			else nil,
	})
end

return ActionTile
