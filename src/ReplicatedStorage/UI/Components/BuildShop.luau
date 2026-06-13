--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local BuildShopItem = require(script.Parent.BuildShopItem)
local Panel = require(script.Parent.Panel)

export type ShopItem = {
	id: string,
	text: string,
}

local function BuildShop(props: {
	visible: boolean,
	items: { ShopItem },
	onPurchase: (string) -> (),
	onClose: () -> (),
})
	local children = {
		Layout = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for index, item in props.items do
		children[`Item{index}`] = React.createElement(BuildShopItem, {
			text = item.text,
			layoutOrder = index,
			onActivated = function()
				props.onPurchase(item.id)
			end,
		})
	end

	children.Close = React.createElement(BuildShopItem, {
		text = "CLOSE",
		layoutOrder = #props.items + 1,
		onActivated = props.onClose,
	})

	return React.createElement("Frame", {
		Position = UDim2.new(1, -320, 0, 80),
		Size = UDim2.fromOffset(300, 430),
		BackgroundTransparency = 1,
		Visible = props.visible,
	}, {
		Panel = React.createElement(Panel, {
			variant = "Status",
			size = UDim2.fromScale(1, 1),
			children = children,
		}),
	})
end

return BuildShop
