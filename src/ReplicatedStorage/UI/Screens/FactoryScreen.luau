--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FactoryConfig = require(ReplicatedStorage.Factory.Config)
local React = require(ReplicatedStorage.Vendor.React)
local BuildControls = require(script.Parent.Parent.Components.BuildControls)
local BuildShop = require(script.Parent.Parent.Components.BuildShop)
local FactoryManageContent = require(script.Parent.Parent.Components.FactoryManageContent)
local Hotbar = require(script.Parent.Parent.Components.Hotbar)
local PlayerDataContext = require(script.Parent.Parent.Context.PlayerDataContext)

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
	local playerData = PlayerDataContext.usePlayerData()
	local shopItems = {}
	local hotbarItems = {}

	for _, itemId in FactoryConfig.ItemOrder do
		local definition = FactoryConfig.Items[itemId]
		table.insert(shopItems, {
			id = itemId,
			text = `{definition.DisplayName} - {definition.Price} Gold`,
		})

		local count = playerData.Factory.Inventory[itemId] or 0
		if count > 0 then
			table.insert(hotbarItems, {
				id = itemId,
				text = `{definition.DisplayName}\nx{count}`,
			})
		end
	end

	return React.createElement("ScreenGui", {
		Name = "FactoryGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 35,
	}, {
		OpenShop = React.createElement("TextButton", {
			Position = UDim2.new(1, -130, 0, 20),
			Size = UDim2.fromOffset(110, 50),
			BackgroundColor3 = Color3.fromRGB(65, 130, 80),
			Font = Enum.Font.GothamBold,
			Text = "BUILD SHOP",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
			[React.Event.Activated] = factory.onToggleShop,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
		}),
		Shop = React.createElement(BuildShop, {
			visible = factory.shopOpen,
			items = shopItems,
			onPurchase = factory.onPurchase,
			onClose = factory.onCloseShop,
		}),
		Hotbar = React.createElement(Hotbar, {
			items = hotbarItems,
			onSelect = factory.onSelectItem,
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
