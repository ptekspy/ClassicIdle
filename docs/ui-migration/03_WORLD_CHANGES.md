# World Changes

## Keep these objects

These are gameplay models, targets, or UI adornees. Do not delete them:

```txt
ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate
ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.Screen
ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.TouchPad
ReplicatedStorage.Assets.PlotTemplate.OLD.StorageBin.Top
ReplicatedStorage.Assets.PlotTemplate.OLD.NPCPurchasePad.BaseF
ReplicatedStorage.Assets.PlotTemplate.OLD.StorageUpgradeButton.BaseF
ReplicatedStorage.Assets.PlotTemplate.BuildGrid
ReplicatedStorage.Assets.PlotTemplate.Machine
ReplicatedStorage.Assets.PlotTemplate.WorkerHomes
ReplicatedStorage.Assets.PlotTemplate.WorkerApproachPoints
```

## Delete later

Delete only after `10_MIGRATE_WORLD_SPACE_UI.md` passes:

```txt
ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.BillboardGui
ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.Screen.SurfaceGui
```

## Keep legacy templates untouched

Do not edit or delete:

```txt
ReplicatedStorage.Assets.PlotTemplateV1
ReplicatedStorage.Assets.PlotTemplateV2
ReplicatedStorage.Assets.PlotTemplatev3
ReplicatedStorage.Assets.PlotTemplateV4
ReplicatedStorage.Assets.PlotTemplateV5
```

They are not active, but cleaning them up is outside this migration.

## Required validation before deletion

- Start Play mode and claim a plot.
- Confirm the sell billboard and sell surface display are created by code.
- Sell resources and confirm both values update.
- Stop Play mode.
- Delete only the two active-template UI objects listed above.
- Start Play mode again and confirm `Plot.validate` no longer requires their paths.

## Done when

The active plot template contains no required physical `BillboardGui` or `SurfaceGui`, while all required world parts remain.
