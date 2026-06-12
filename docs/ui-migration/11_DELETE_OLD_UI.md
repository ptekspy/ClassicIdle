# Delete Old UI

## Deletion gate

Do not delete an old UI area until its migration stage passes all validation.

## Source code removal list

Remove imperative visual construction from:

```txt
src/StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/QuestController.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/InteractionController.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/WorkerController.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/MachineController.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/FactoryController.luau
src/ReplicatedStorage/Services/DisplayService/init.luau
src/ReplicatedStorage/Services/ResourceNodeService/init.luau
```

Keep controller/service logic that computes state, handles input, sends remotes, or owns gameplay timing.

## Manual Studio deletion list

| Studio path | Replaced by | Safe after |
|---|---|---|
| `ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.BillboardGui` | `UI/World/SellBillboard.luau` | world-space validation passes |
| `ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.Screen.SurfaceGui` | `UI/World/SellSurfaceDisplay.luau` | world-space validation passes |

## Must not delete

- `SellCrate`, `SellCrate.Screen`, or `SellCrate.TouchPad`
- storage bin and upgrade-button parts
- interaction targets
- quest highlights, beams, and attachments
- factory build templates or grid objects
- legacy plot templates during this task

## After deletion

Run:

```bash
argon build
```

Then start Play mode and verify:

- no `WaitForChild` or plot-validation errors
- no duplicate React or world roots
- all UI still appears
- sell values still update

## Done when

The game starts with no required physical UI and no old imperative UI driving live presentation.
