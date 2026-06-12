# Existing UI Refactor And Integration

## Goal

Mount the new HUD once, remove duplicate visible HUD pieces, and preserve existing gameplay behavior.

## Create `MainHudScreen.luau`

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local PlayerDataContext = require(script.Parent.Parent.Context.PlayerDataContext)
local TopStatusBar = require(script.Parent.Parent.HUD.TopStatusBar)
local ZoneProgressBar = require(script.Parent.Parent.HUD.ZoneProgressBar)
local LeftPanelColumn = require(script.Parent.Parent.HUD.LeftPanelColumn)
local ActionRail = require(script.Parent.Parent.HUD.ActionRail)
local BottomDock = require(script.Parent.Parent.HUD.BottomDock)

local EMPTY_FACTORY = {
	onToggleShop = function() end,
	onSelectItem = function(_id: string) end,
}

return function(props: { quest: any?, factory: any? })
	local data = PlayerDataContext.usePlayerData()
	local factory = props.factory or EMPTY_FACTORY
	return React.createElement("ScreenGui", {
		Name = "MainHudGui", ResetOnSpawn = false, IgnoreGuiInset = false, DisplayOrder = 5,
	}, {
		Top = React.createElement(TopStatusBar, { gold = data.Gold, xp = data.XP }),
		Zone = React.createElement(ZoneProgressBar, { visible = true }),
		Left = React.createElement(LeftPanelColumn, { quest = props.quest }),
		Right = React.createElement(ActionRail, { onBuild = factory.onToggleShop }),
		Bottom = React.createElement(BottomDock, {
			inventory = data.Factory.Inventory, onSelectItem = factory.onSelectItem,
		}),
	})
end
```

## Edit `App.luau`

Require `MainHudScreen` and add:

```luau
MainHud = React.createElement(MainHudScreen, {
	quest = props.state.quest,
	factory = props.state.factory,
}),
```

## Edit `QuestScreen.luau`

- Delete the `QuestCard` require.
- Delete all quest-card calculations and rendering.
- Keep the `ScreenGui` and `QuestTargetMarker` only.
- Keep `DisplayOrder = 15`.

## Edit `FactoryScreen.luau`

- Delete the old `OpenShop` button.
- Delete the old `Hotbar`.
- Keep `BuildShop`, `BuildControls`, and `FactoryManageContent`.
- Stop requiring `PlayerDataContext`, `Hotbar`, and `FactoryConfig` if no longer used.

## Refactor existing shared UI

After the HUD works, update these without changing behavior:

| Existing component | Replace duplicated implementation with |
|---|---|
| `ActionButton` | new `Button` |
| `BuildShopItem` | new `Button` |
| `ModalPanel` | `Panel`, `Text`, `IconButton` |
| `FeedbackToast` | `Panel`, `Text` |
| `InteractionPrompt` | `Panel`, `Text`, `Corner` |
| World labels/progress | Config tokens and primitives where compatible |

Do not force screen-space HUD sizing into world-space components.

## Display order

```txt
Main HUD: 5
Feedback: 10
Quest marker: 15
Interaction: 20
Menus/build overlays: 35
```

## Validation

- Exactly one Main HUD exists.
- No duplicate quest card, shop opener, or hotbar remains.
- Quest marker, factory shop, placement controls, and manage menu still work.
- Existing controllers remain unchanged except where transient callbacks must be exposed.

## Done when

The new HUD owns all reference HUD presentation while existing gameplay behavior remains intact.
