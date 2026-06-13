--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FactoryConfig = require(ReplicatedStorage.Factory.Config)
local React = require(ReplicatedStorage.Vendor.React)
local HotbarSlot = require(ReplicatedStorage.UI.Components.HotbarSlot)

export type Props = {
	inventory: { [string]: number },
	onSelectItem: ((string) -> ())?,
}

local SLOT_COUNT = 8
local SLOT_PADDING = 8

local ICON_BY_ITEM: { [string]: string } = {
	ConveyorDropper = "Build",
	StraightConveyor = "Build",
	CornerConveyor = "Build",
	ConveyorUpgrader = "Settings",
	ConveyorCollectionBin = "Backpack",
	WorkerHome = "Friends",
}

local function FactoryHotbar(props: Props)
	local children: { [string]: React.ReactNode } = {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, SLOT_PADDING),
		}),
	}

	for slotNumber = 1, SLOT_COUNT do
		local itemId = FactoryConfig.ItemOrder[slotNumber]
		local count = if itemId then props.inventory[itemId] or 0 else 0
		local hasItemDefinition = itemId ~= nil

		children[`Slot{slotNumber}`] = React.createElement(HotbarSlot, {
			size = UDim2.new(1 / SLOT_COUNT, -SLOT_PADDING, 0, 86),
			slotNumber = slotNumber,
			icon = if itemId then ICON_BY_ITEM[itemId] or "Build" else nil,
			count = count,
			locked = not hasItemDefinition,
			disabled = hasItemDefinition and count <= 0,
			layoutOrder = slotNumber,
			onActivated = if itemId and count > 0 and props.onSelectItem
				then function()
					props.onSelectItem(itemId)
				end
				else nil,
		})
	end

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