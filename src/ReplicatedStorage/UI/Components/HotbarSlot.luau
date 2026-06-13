--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local Button = require(ReplicatedStorage.UI.Components.Button)
local Icon = require(ReplicatedStorage.UI.Primitives.Icon)
local Text = require(ReplicatedStorage.UI.Primitives.Text)

export type Props = {
	size: UDim2?,
	text: string?,
	slotNumber: number?,
	icon: string?,
	count: number?,
	selected: boolean?,
	locked: boolean?,
	disabled: boolean?,
	layoutOrder: number,
	onActivated: (() -> ())?,
}

local function HotbarSlot(props: Props)
	local locked = props.locked == true
	local disabled = props.disabled == true
	local count = props.count or 0
	local variant = if locked or disabled then "Disabled" elseif props.selected then "Secondary" else "Primary"
	local icon = if locked then "Lock" else props.icon

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		Size = props.size or UDim2.fromOffset(96, 74),
		BackgroundTransparency = 1,
	}, {
		Button = React.createElement(Button, {
			text = "",
			variant = variant,
			size = UDim2.fromScale(1, 1),
			onActivated = if locked or disabled then nil else props.onActivated,
		}),

		SlotNumber = if props.slotNumber
			then React.createElement(Text, {
				text = tostring(props.slotNumber),
				variant = "Caption",
				color = "Primary",
				position = UDim2.fromOffset(8, 5),
				size = UDim2.fromOffset(26, 22),
				textXAlignment = Enum.TextXAlignment.Left,
			})
			else nil,

		Icon = if icon
			then React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.43),
				Size = UDim2.fromScale(0.72, 0.62),
				BackgroundTransparency = 1,
			}, {
				Layout = React.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Image = React.createElement(Icon, {
					icon = icon,
					size = if locked then "Small" else "Medium",
				}),
			})
			else nil,

		Count = if not locked and count > 0
			then React.createElement(Text, {
				text = `x{count}`,
				variant = "Caption",
				color = "Primary",
				position = UDim2.fromScale(0.45, 0.68),
				size = UDim2.fromScale(0.48, 0.24),
				textXAlignment = Enum.TextXAlignment.Right,
			})
			else nil,

		LockedText = if locked
			then React.createElement(Text, {
				text = "Lv. 20",
				variant = "Caption",
				color = "Secondary",
				position = UDim2.fromScale(0.12, 0.68),
				size = UDim2.fromScale(0.76, 0.24),
			})
			else nil,
	})
end

return HotbarSlot