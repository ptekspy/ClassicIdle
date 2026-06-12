--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Button = require(ReplicatedStorage.UI.Components.Button)
local NotificationBadge = require(ReplicatedStorage.UI.Components.NotificationBadge)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	text: string?,
	slotNumber: number?,
	icon: string?,
	count: number?,
	selected: boolean?,
	locked: boolean?,
	layoutOrder: number,
	onActivated: (() -> ())?,
}

local function HotbarSlot(props: Props)
	local locked = props.locked == true
	local variant = if locked then "Disabled" elseif props.selected then "Secondary" else "Primary"
	local icon = if locked then "Lock" else props.icon

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromOffset(135, 64),
		BackgroundTransparency = 1,
	}, {
		Button = React.createElement(Button, {
			text = props.text or "",
			variant = variant,
			size = UDim2.fromScale(1, 1),
			onActivated = if locked then nil else props.onActivated,
		}),
		Icon = if icon
			then React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.6, 0.8),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Image = React.createElement(Icon, {
					icon = icon,
					size = "Medium",
				}),
			})
			else nil,
		Number = if props.slotNumber
			then React.createElement(Text, {
				text = tostring(props.slotNumber),
				variant = "Caption",
				color = "Primary",
				position = UDim2.fromOffset(7, 5),
				size = UDim2.fromOffset(22, 20),
			})
			else nil,
		Count = if props.count and props.count > 1
			then React.createElement(NotificationBadge, {
				text = tostring(props.count),
				position = UDim2.fromScale(0.88, 0.78),
			})
			else nil,
	})
end

return HotbarSlot
