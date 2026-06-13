--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FactoryConfig = require(ReplicatedStorage.Factory.Config)
local React = require(ReplicatedStorage.Vendor.React)
local HotbarSlot = require(ReplicatedStorage.UI.Components.HotbarSlot)

export type Props = {
	inventory: { [string]: number },
	onSelectItem: ((string) -> ())?,
}

local function FactoryHotbar(props: Props)
	local children: { [string]: React.ReactNode } = {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),
	}

	local slotNumber = 0
	for _, itemId in FactoryConfig.ItemOrder do
		local count = props.inventory[itemId] or 0
		if count > 0 then
			slotNumber += 1
			children[`Slot{slotNumber}`] = React.createElement(HotbarSlot, {
				slotNumber = slotNumber,
				icon = "Build",
				count = count,
				layoutOrder = slotNumber,
				onActivated = if props.onSelectItem
					then function()
						props.onSelectItem(itemId)
					end
					else nil,
			})
		end
	end

	slotNumber += 1
	children.Locked = React.createElement(HotbarSlot, {
		slotNumber = slotNumber,
		locked = true,
		layoutOrder = slotNumber,
		onActivated = nil,
	})

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Content = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, children),
	})
end

return FactoryHotbar
