--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local HotbarSlot = require(script.Parent.HotbarSlot)
local Panel = require(script.Parent.Panel)

export type HotbarItem = {
	id: string,
	text: string,
}

local function Hotbar(props: {
	items: { HotbarItem },
	onSelect: (string) -> (),
})
	local children = {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for index, item in props.items do
		children[`Slot{index}`] = React.createElement(HotbarSlot, {
			text = item.text,
			layoutOrder = index,
			onActivated = function()
				props.onSelect(item.id)
			end,
		})
	end

	return React.createElement("Frame", {
		Position = UDim2.new(0.05, 0, 1, -88),
		Size = UDim2.new(0.9, 0, 0, 68),
		BackgroundTransparency = 1,
	}, {
		Panel = React.createElement(Panel, {
			variant = "Status",
			size = UDim2.fromScale(1, 1),
			children = children,
		}),
	})
end

return Hotbar
