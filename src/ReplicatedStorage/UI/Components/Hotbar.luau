--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local HotbarSlot = require(script.Parent.HotbarSlot)

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
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
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
		Name = "Hotbar",
		Position = UDim2.new(0.05, 0, 1, -88),
		Size = UDim2.new(0.9, 0, 0, 68),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.08,
	}, children)
end

return Hotbar