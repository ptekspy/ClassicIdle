# Migrate World-Space UI

## Goal

Make every gameplay `BillboardGui` and `SurfaceGui` code-created and componentised.

## Important ownership rule

World displays currently show owner-specific data but are created on the server and visible to nearby players. Preserve that visibility behavior. Mount world-space React roots from the server or provide equivalent server-created components; do not silently make them local-only.

## Files to create

```txt
src/ReplicatedStorage/UI/World/WorldLabel.luau
src/ReplicatedStorage/UI/World/SellBillboard.luau
src/ReplicatedStorage/UI/World/SellSurfaceDisplay.luau
src/ReplicatedStorage/UI/World/RespawnProgress.luau
```

## DisplayService migration

Replace `Local.createOrGetBillboard` with a world-UI mounting helper that:

- creates one host per adornee/name
- mounts once
- rerenders with props
- unmounts when the plot is released

Componentise:

- `StorageDisplay`
- `NPCDisplay`
- `UpgradeDisplay`
- sell billboard
- sell surface display

Use the exact current strings and visuals.

## Sell display parity

Preserve the physical UI properties currently authored in Studio:

- Billboard: always on top, max distance `50`, size `{3,0},{3,0}`, size offset `0,2`
- Billboard label: Gotham Bold, rich text, green text, scaled/wrapped, transparent background
- Surface display: right face, `PixelsPerStud = 50`
- Surface label: Gotham Bold, green text, scaled/wrapped, existing `UITextSizeConstraint` and `UIStroke`

After code creates both displays, remove the old path requirements from:

```txt
src/ReplicatedStorage/Plot/Types.luau
src/ReplicatedStorage/Plot/Config.luau
src/ReplicatedStorage/Plot/validate.luau
```

Do not remove `SellCrate.Screen` or `SellCrate.TouchPad`.

## Resource respawn progress

Migrate `ResourceNodeService.createProgressGui` last.

Preserve server-owned timing and depletion state. The React component receives progress as a prop; it must not run authoritative respawn timing.

## Validation

- Test two players viewing each other’s plot displays.
- Sell resources and confirm both sell displays update.
- Upgrade storage and confirm storage/upgrade displays update.
- Hire NPCs and confirm hire display updates.
- Deplete a resource node and confirm respawn progress matches.
- Confirm plot release removes all world UI roots.

## Done when

No required physical world UI remains and every runtime world display is created from componentised code.
