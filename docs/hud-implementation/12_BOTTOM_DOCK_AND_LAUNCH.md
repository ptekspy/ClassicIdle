# Bottom Dock And Launch

## Goal

Implement `Invite Friends | Collapse | Hotbar | Backpack | Launch`.

## Create `FactoryHotbar.luau`

Props:

```luau
export type Props = {
	inventory: { [string]: number },
	onSelectItem: (string) -> (),
}
```

Iterate `FactoryConfig.ItemOrder`. Create numbered slots only for counts greater than zero. Each live slot calls `onSelectItem(itemId)`. Append one disabled locked slot after live slots so the dock matches the reference.

Each slot displays:

```txt
slot number
configured placeholder icon
count when greater than one
```

Use the shared `HotbarSlot`; do not reuse the old visual implementation.

## Create `LaunchButton.luau`

Compose a large `Button("GreenHero")`, `Icon("Hero", "Rocket")`, `LAUNCH`, and `Fuel Cost: 125`. Pass no callback. It must remain visually green like the reference while disabled.

## Create `BottomDock.luau`

Props:

```luau
export type Props = {
	inventory: { [string]: number },
	onSelectItem: (string) -> (),
}
```

Compose in exact order:

1. Disabled Invite Friends panel with `+10% Coins`
2. Disabled collapse `IconButton`
3. `FactoryHotbar`
4. Disabled Backpack `ActionTile` with badge `3`
5. Disabled `LaunchButton`

## Responsive behavior

- Desktop: preserve the complete row.
- Tablet: reduce group scale and slot spacing.
- Landscape phone: hide Invite Friends and Backpack; preserve Hotbar and Launch.
- Portrait phone: preserve Hotbar; show compact disabled Launch.

## Validation

- Live inventory changes update slot count.
- Selecting an item starts existing placement behavior.
- Invite, Collapse, Backpack, locked slot, and Launch never activate.

## Done when

The bottom dock matches the reference and the hotbar remains server-authoritative through existing factory actions.
