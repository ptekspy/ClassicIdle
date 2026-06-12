# Migrate Factory UI

## Goal

Move factory visuals into React without moving build-grid calculations, build ghosts, or input handling.

## Files to create

```txt
src/ReplicatedStorage/UI/Components/Hotbar.luau
src/ReplicatedStorage/UI/Components/HotbarSlot.luau
src/ReplicatedStorage/UI/Components/BuildControls.luau
src/ReplicatedStorage/UI/Components/BuildShop.luau
src/ReplicatedStorage/UI/Components/BuildShopItem.luau
src/ReplicatedStorage/UI/Components/FactoryManageContent.luau
src/ReplicatedStorage/UI/Screens/FactoryScreen.luau
```

## State ownership

`FactoryController` keeps:

- `selectedItemId`, `movingItemId`, rotation, grid coordinates, and validity
- ghost creation and coloring
- grid collision/connector calculations
- raycasting
- keyboard/gamepad input
- all `FactoryRequest` calls

Publish a presentation snapshot whenever state changes:

```luau
UIState.Set("factory", {
	state = Local.state,
	shopOpen = Local.shopOpen,
	building = Local.selectedItemId ~= nil,
	managePayload = Local.managePayload,
	onOpenShop = openShop,
	onCloseShop = closeShop,
	onSelectItem = beginBuild,
	onRotate = rotate,
	onConfirm = confirm,
	onCancel = stopBuild,
	onManageAction = handleManageAction,
})
```

Add `shopOpen` and `managePayload` to `Local`; do not use GUI visibility as state.

## Context usage

`FactoryScreen` may call `usePlayerData()` for persistent factory inventory. Continue consuming `FactoryStateUpdate` and `GetFactoryState` until their payload parity is confirmed. Do not remove those remotes during this migration.

## Preserve exact visuals

Copy all values from `FactoryController.luau`, including:

- display order `35`
- shop button and panel positions
- bottom hotbar size and position
- build-control placement
- manage-panel placement
- item ordering from `FactoryConfig.ItemOrder`
- button sizes, colors, text, and corners

## Migration order

1. Open-shop button and build shop.
2. Hotbar and slots.
3. Build controls.
4. Manage panel.
5. Remove the old `FactoryGui`.

Validate after each sub-step before continuing.

## Validation

- Purchase every item.
- Confirm inventory counts update.
- Place, rotate, cancel, and move items with mouse, keyboard, and gamepad.
- Configure droppers and corner conveyors.
- Collect from collection bins.
- Confirm no duplicated input callbacks or ghosts.

## Done when

All factory screen UI is React-owned while placement behavior remains controller-owned.
