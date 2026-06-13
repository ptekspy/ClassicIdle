--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FactoryConfig = require(ReplicatedStorage.Factory.Config)
local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)
local BuildControls = require(script.Parent.Parent.Components.BuildControls)
local BuildShop = require(script.Parent.Parent.Components.BuildShop)
local FactoryManageContent = require(script.Parent.Parent.Components.FactoryManageContent)

local EMPTY = {
	shopOpen = false,
	building = false,
	managePayload = nil,
	onToggleShop = function() end,
	onCloseShop = function() end,
	onPurchase = function(_itemId: string) end,
	onSelectItem = function(_itemId: string) end,
	onRotate = function() end,
	onConfirm = function() end,
	onCancel = function() end,
	onMove = function(_payload: any) end,
	onConfigure = function(_placedItemId: string, _value: any) end,
	onCollect = function(_placedItemId: string) end,
	onCloseManage = function() end,
}

local function FactoryScreen(props: { factory: any? })
	local factory = props.factory or EMPTY
	local shopItems = {}

	for _, itemId in FactoryConfig.ItemOrder do
		local definition = FactoryConfig.Items[itemId]
		table.insert(shopItems, {
			id = itemId,
			text = `{definition.DisplayName} - {definition.Price} Gold`,
		})
	end

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = Layout.DisplayOrder.Overlay,
	}, {
		Shop = React.createElement(BuildShop, {
			visible = factory.shopOpen,
			items = shopItems,
			onPurchase = factory.onPurchase,
			onClose = factory.onCloseShop,
		}),
		Controls = React.createElement(BuildControls, {
			visible = factory.building,
			onRotate = factory.onRotate,
			onConfirm = factory.onConfirm,
			onCancel = factory.onCancel,
		}),
		Manage = React.createElement(FactoryManageContent, {
			factory = factory,
		}),
	})
end

return FactoryScreen
