# Migrate Factory UI

## Goal

Move the build shop, hotbar, build controls, and manage panel into React. Keep all placement calculations, ghost models, input listeners, and remotes in `FactoryController`.

Do not replace the whole controller. Follow the exact removals and additions below so the existing factory gameplay remains intact.

## Files changed

Replace:

```txt
src/ReplicatedStorage/UI/Components/BuildShopItem.luau
src/ReplicatedStorage/UI/Components/BuildShop.luau
src/ReplicatedStorage/UI/Components/HotbarSlot.luau
src/ReplicatedStorage/UI/Components/Hotbar.luau
src/ReplicatedStorage/UI/Components/BuildControls.luau
src/ReplicatedStorage/UI/Components/FactoryManageContent.luau
src/ReplicatedStorage/UI/Screens/FactoryScreen.luau
```

Edit:

```txt
src/ReplicatedStorage/UI/Screens/App.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/FactoryController.luau
```

## 1. Create `BuildShopItem`

Replace `src/ReplicatedStorage/UI/Components/BuildShopItem.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function BuildShopItem(props: {
	text: string,
	layoutOrder: number,
	onActivated: () -> (),
})
	return React.createElement("TextButton", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(1, -16, 0, 56),
		BackgroundColor3 = Color3.fromRGB(65, 130, 80),
		Font = Enum.Font.GothamBold,
		Text = props.text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
		TextWrapped = true,
		[React.Event.Activated] = props.onActivated,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})
end

return BuildShopItem
```

## 2. Create `BuildShop`

Replace `src/ReplicatedStorage/UI/Components/BuildShop.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local BuildShopItem = require(script.Parent.BuildShopItem)

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
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
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
		Name = "Shop",
		Position = UDim2.new(1, -320, 0, 80),
		Size = UDim2.fromOffset(300, 430),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.08,
		Visible = props.visible,
	}, children)
end

return BuildShop
```

## 3. Create `HotbarSlot`

Replace `src/ReplicatedStorage/UI/Components/HotbarSlot.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function HotbarSlot(props: {
	text: string,
	layoutOrder: number,
	onActivated: () -> (),
})
	return React.createElement("TextButton", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromOffset(135, 54),
		BackgroundColor3 = Color3.fromRGB(65, 130, 80),
		Font = Enum.Font.GothamBold,
		Text = props.text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
		TextWrapped = true,
		[React.Event.Activated] = props.onActivated,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})
end

return HotbarSlot
```

## 4. Create `Hotbar`

Replace `src/ReplicatedStorage/UI/Components/Hotbar.luau` with:

```luau
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
```

## 5. Create `BuildControls`

Replace `src/ReplicatedStorage/UI/Components/BuildControls.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function control(text: string, order: number, callback: () -> ())
	return React.createElement("TextButton", {
		LayoutOrder = order,
		Size = UDim2.fromOffset(105, 46),
		BackgroundColor3 = Color3.fromRGB(65, 130, 80),
		Font = Enum.Font.GothamBold,
		Text = text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
		TextWrapped = true,
		[React.Event.Activated] = callback,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})
end

local function BuildControls(props: {
	visible: boolean,
	onRotate: () -> (),
	onConfirm: () -> (),
	onCancel: () -> (),
})
	return React.createElement("Frame", {
		Name = "BuildControls",
		Position = UDim2.new(0.5, -180, 1, -165),
		Size = UDim2.fromOffset(360, 62),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.08,
		Visible = props.visible,
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Rotate = control("ROTATE\nR / Y", 1, props.onRotate),
		Confirm = control("PLACE\nCLICK / A", 2, props.onConfirm),
		Cancel = control("CANCEL\nESC / B", 3, props.onCancel),
	})
end

return BuildControls
```

## 6. Create `FactoryManageContent`

Replace `src/ReplicatedStorage/UI/Components/FactoryManageContent.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local ResourceConfig = require(ReplicatedStorage.Resource.Config)
local ActionButton = require(script.Parent.ActionButton)

local function label(text: string, order: number)
	return React.createElement("TextLabel", {
		LayoutOrder = order,
		Size = UDim2.new(1, -16, 0, 58),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		TextWrapped = true,
	})
end

local function FactoryManageContent(props: { factory: any })
	local factory = props.factory
	local payload = factory.managePayload
	if not payload then
		return nil
	end

	local children = {
		Layout = React.createElement("UIListLayout", {
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Title = React.createElement("TextLabel", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = payload.DisplayName,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 20,
		}),
		Move = React.createElement(ActionButton, {
			text = "MOVE",
			height = 48,
			textSize = 15,
			layoutOrder = 2,
			onActivated = function()
				factory.onMove(payload)
			end,
		}),
	}

	local order = 3
	if payload.ItemId == "ConveyorDropper" then
		children.Description = label("Runs automatically while the selected resource is in Storage and a valid conveyor is connected.", order)
		order += 1
		for _, resourceId in payload.ResourceOptions or {} do
			local definition = ResourceConfig.Get(resourceId)
			if definition then
				children[`Resource{resourceId}`] = React.createElement(ActionButton, {
					text = `DROP {string.upper(definition.DisplayName)}`,
					height = 48,
					textSize = 15,
					layoutOrder = order,
					onActivated = function()
						factory.onConfigure(payload.PlacedItemId, resourceId)
					end,
				})
				order += 1
			end
		end
	elseif payload.ItemId == "CornerConveyor" then
		children.Reverse = React.createElement(ActionButton, {
			text = "REVERSE CORNER FLOW",
			height = 48,
			textSize = 15,
			layoutOrder = order,
			onActivated = function()
				factory.onConfigure(payload.PlacedItemId, if payload.ConnectorMode == 2 then 1 else 2)
			end,
		})
	elseif payload.ItemId == "ConveyorCollectionBin" then
		children.Description = label("Factory output waits here. Collect it manually to move as much as possible into Storage.", order)
		children.Collect = React.createElement(ActionButton, {
			text = `COLLECT {payload.StoredAmount or 0} {payload.StoredResourceType or ""}`,
			height = 48,
			textSize = 15,
			layoutOrder = order + 1,
			onActivated = function()
				factory.onCollect(payload.PlacedItemId)
			end,
		})
	end

	children.Close = React.createElement(ActionButton, {
		text = "CLOSE",
		height = 48,
		textSize = 15,
		layoutOrder = 100,
		onActivated = factory.onCloseManage,
	})

	return React.createElement("Frame", {
		Name = "Manage",
		Position = UDim2.new(0.5, -160, 0.5, -160),
		Size = UDim2.fromOffset(320, 320),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.08,
	}, children)
end

return FactoryManageContent
```

## 7. Create `FactoryScreen`

Replace `src/ReplicatedStorage/UI/Screens/FactoryScreen.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FactoryConfig = require(ReplicatedStorage.Factory.Config)
local React = require(ReplicatedStorage.Vendor.React)
local BuildControls = require(script.Parent.Parent.Components.BuildControls)
local BuildShop = require(script.Parent.Parent.Components.BuildShop)
local FactoryManageContent = require(script.Parent.Parent.Components.FactoryManageContent)
local Hotbar = require(script.Parent.Parent.Components.Hotbar)

local EMPTY = {
	state = nil,
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
	local hotbarItems = {}

	for _, itemId in FactoryConfig.ItemOrder do
		local definition = FactoryConfig.Items[itemId]
		table.insert(shopItems, {
			id = itemId,
			text = `{definition.DisplayName} - {definition.Price} Gold`,
		})

		local count = if factory.state then factory.state.Inventory[itemId] or 0 else 0
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
```

## 8. Remove only visual construction from `FactoryController`

Add:

```luau
local UIState = require(script.Parent.Parent.UI.UIState)
```

Delete:

```luau
local playerGui = player:WaitForChild("PlayerGui")
```

Add these fields to `Local`:

```luau
shopOpen = false,
managePayload = nil :: any,
```

Immediately after:

```luau
local FactoryController = {}
```

add:

```luau
local publish: () -> () = function() end
```

Delete the complete visual block beginning at:

```luau
local gui = Instance.new("ScreenGui")
```

and ending after the `manageLabel` function.

Delete the entire `clearChildren` function.

Delete these old visibility mutations from `stopBuild`:

```luau
controls.Visible = false
```

Add this at the end of `stopBuild`:

```luau
publish()
```

Delete these three lines from `beginBuild`:

```luau
controls.Visible = true
shop.Visible = false
manage.Visible = false
```

Replace them with:

```luau
Local.shopOpen = false
Local.managePayload = nil
publish()
```

Delete all of the following:

- the three `control(...)` calls
- the entire `refreshHotbar` function
- the loop that creates shop item buttons
- `closeShop`
- `shopButton.Activated:Connect(...)`

## 9. Add the presentation publisher

Immediately after the existing `confirm` function, add:

```luau
publish = function()
	UIState.Set("factory", {
		state = Local.state,
		shopOpen = Local.shopOpen,
		building = Local.selectedItemId ~= nil,
		managePayload = Local.managePayload,
		onToggleShop = function()
			Local.shopOpen = not Local.shopOpen
			publish()
		end,
		onCloseShop = function()
			Local.shopOpen = false
			publish()
		end,
		onPurchase = function(itemId: string)
			requestEvent:FireServer("Purchase", itemId)
		end,
		onSelectItem = function(itemId: string)
			beginBuild(itemId, nil, nil, nil, nil)
		end,
		onRotate = rotate,
		onConfirm = confirm,
		onCancel = stopBuild,
		onMove = function(payload: any)
			beginBuild(payload.ItemId, payload.PlacedItemId, payload.GridX, payload.GridZ, payload.Rotation)
		end,
		onConfigure = function(placedItemId: string, value: any)
			requestEvent:FireServer("Configure", placedItemId, value)
		end,
		onCollect = function(placedItemId: string)
			requestEvent:FireServer("Collect", placedItemId)
		end,
		onCloseManage = function()
			Local.managePayload = nil
			publish()
		end,
	})
end
```

## 10. Replace `showMenu`

Replace the entire existing `showMenu` function with:

```luau
local function showMenu(payload: any)
	if typeof(payload) ~= "table" or typeof(payload.PlacedItemId) ~= "string" then
		return
	end
	Local.managePayload = payload
	publish()
end
```

## 11. Update controller refresh points

In the `stateEvent.OnClientEvent` callback, replace:

```luau
refreshHotbar()
```

with:

```luau
publish()
```

In the initial `GetFactoryState` task, replace:

```luau
refreshHotbar()
```

with:

```luau
publish()
```

At the end of `FactoryController.Start`, before its final `end`, add:

```luau
publish()
```

Do not modify `isBlocked`, `canPreviewPlace`, `getPlaneHit`, `updateGhost`, input handling, or remote calls.

## 12. Add `FactoryScreen` to `App`

Add:

```luau
local FactoryScreen = require(script.Parent.FactoryScreen)
```

Inside the provider children, add:

```luau
Factory = React.createElement(FactoryScreen, {
	factory = props.state.factory,
}),
```

## Validation

- Confirm only one `FactoryGui` exists and it is under `PlayerGui.ReactUI`.
- Open and close the shop.
- Purchase every factory item.
- Confirm hotbar counts update after purchases and placements.
- Select, rotate, place, cancel, and move items.
- Configure droppers and corner conveyors.
- Collect from collection bins.
- Confirm `FactoryGhost` still appears once and is destroyed after placement/cancel.
- Confirm keyboard, mouse, and gamepad placement controls still work.

## Done when

All factory visuals are React-owned while existing factory gameplay code remains authoritative.
