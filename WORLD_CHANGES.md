# MVP Conveyor Machine: Required Roblox Studio World Changes

Complete every checklist item in this document inside Roblox Studio before asking Codex to implement the source-code phase.

Do not rename objects differently from the names shown here. The source implementation will treat this hierarchy as a world contract.

## Important Workflow Gate

- Make these changes in **Edit mode**, not while the game is running.
- Modify `ReplicatedStorage.Assets.PlotTemplate`, not a cloned plot under `Workspace.PlayerPlots`.
- Do not implement scripts inside any world object.
- Do not add `ProximityPrompt` instances. The game uses its existing custom interaction system.
- Do not manually add the existing `Interactable` tag. Runtime code will add and remove that tag according to progression.
- Do not delete the old Coal Processor NPC template or its approach point yet.
- Do not delete or modify Wood or Stone NPC world objects.
- Do not delete the existing Coal Processor model. It will become the machine's processor model.
- Save the place after completing the work.
- After completing the verification checklist, tell Codex the world changes are complete. Source implementation must not begin before that confirmation.

The current plot uses an `80 x 80` Ground centered at approximately `(0, -0.5, 0)`.

The current important plot objects are approximately:

| Object | Current position/bounding center |
| --- | --- |
| `StorageBin` | `(0, 2.1, 4)` |
| `CoalProcessor` | `(0.15, 2.5, -11.9)` |
| `NPCPurchasePad` | `(17.97, 0.35, -14.97)` |
| `Ground` | `(0, -0.5, 0)` with size `(80, 1, 80)` |

The new machine runs south from the Storage Bin through the existing Coal Processor and toward the Collection Point. All positions in this document are local positions inside the current `PlotTemplate`.

## Workspace And Attachment Decisions

No manual changes are required directly under `Workspace`.

- Do not create machine objects under `Workspace.PlayerPlots`; that folder contains runtime clones.
- Do not create machine objects beside `Workspace.PlotSpawns`.
- Do not modify, move, rename, add, or remove any `Workspace.PlotSpawns` parts.
- The future `PlotService` will continue cloning `ReplicatedStorage.Assets.PlotTemplate` into `Workspace.PlayerPlots`.

No `Attachment` instances are required for this MVP.

- Invisible marker `Part` instances are the complete path-point contract.
- Do not add attachments named `Start`, `End`, `Input`, `Output`, or similar.
- Do not add Beams, AlignPosition constraints, LinearVelocity objects, or physical conveyor constraints.
- Runtime code will interpolate anchored visual resource pieces between the named marker Parts.

## Final Required Hierarchy

The relevant final hierarchy must be exactly:

```text
ReplicatedStorage
  Assets
    PlotTemplate
      Ground
      PlayerSpawn
      Tree
      Rock
      NPCPurchasePad
      SellCrate
      StorageUpgradeButton
      StorageBin
      WorkerHomes
      WorkerApproachPoints
        Tree
        Rock
        StorageBin
        CoalProcessor
      Machine
        RuntimePieces
        Markers
          StorageOutput
        Conveyor1
          InteractionPart
          Visuals
            Foundation
            Belt
            LeftRail
            RightRail
          Markers
            PathStart
            PathEnd
        Upgrader1
          InteractionPart
          Visuals
            Base
            LeftPost
            RightPost
            TopBeam
          Markers
            PathStart
            EffectPoint
            PathEnd
        CoalProcessor
          InteractionPart
          Visuals
            Walls
            Blades
          Markers
            Input
            Output
        Conveyor2
          InteractionPart
          Visuals
            Foundation
            Belt
            LeftRail
            RightRail
          Markers
            PathStart
            PathEnd
        Upgrader2
          InteractionPart
          Visuals
            Base
            LeftPost
            RightPost
            TopBeam
          Markers
            PathStart
            EffectPoint
            PathEnd
        CollectionPoint
          InteractionPart
          Visuals
            Base
            LeftWall
            RightWall
            BackWall
            FrontLip
          Markers
            Input
```

Required classes:

- `Machine` is a `Folder`.
- `RuntimePieces` is a `Folder` and starts empty.
- `Machine.Markers` is a `Folder`.
- Every named machine part is a `Model`.
- Every machine part's `Visuals` and `Markers` children are `Folder` instances.
- Every marker named in the hierarchy is a `Part`.
- Every `InteractionPart` is a `Part`.
- The existing `CoalProcessor.Walls` and `CoalProcessor.Blades` remain `Model` instances.

## Shared Property Rules

Apply these rules unless a later section explicitly gives a different value.

### All Visual Machine Parts

Every `BasePart` under a machine part's `Visuals` folder must use:

| Property | Required value |
| --- | --- |
| `Anchored` | `true` |
| `CanCollide` | `false` |
| `CanTouch` | `false` |
| `CanQuery` | `true` |
| `CastShadow` | `true` |
| `Transparency` | `0` |

These parts are visual only. They do not physically move resources and do not decide gameplay.

Runtime code will change visual transparency for locked and preview states. Author all visuals fully visible with `Transparency = 0`.

Every newly created visual object listed in this document must be a standard `Part`, use `Shape = Block`, and use `Orientation = Vector3.new(0, 0, 0)`.

### All Marker Parts

Every Part under a `Markers` folder, including `Machine.Markers.StorageOutput`, must use:

| Property | Required value |
| --- | --- |
| `Size` | `Vector3.new(0.5, 0.5, 0.5)` |
| `Anchored` | `true` |
| `CanCollide` | `false` |
| `CanTouch` | `false` |
| `CanQuery` | `false` |
| `Transparency` | `1` |
| `CastShadow` | `false` |

Markers are invisible path coordinates. Do not add meshes, decals, prompts, scripts, or constraints to them.

Keep marker orientation at `(0, 0, 0)`. Pieces move from higher Z values toward lower Z values.

### All Interaction Parts

Every machine model's `InteractionPart` must use:

| Property | Required value |
| --- | --- |
| `Anchored` | `true` |
| `CanCollide` | `false` |
| `CanTouch` | `false` |
| `CanQuery` | `true` |
| `Transparency` | `1` |
| `CastShadow` | `false` |

`InteractionPart` is the invisible interaction/raycast volume and must be the `PrimaryPart` of its parent machine-part Model.

Do not place an `InteractionPart` so that it overlaps another machine part's interaction volume.

Every `InteractionPart` must use `Shape = Block` and `Orientation = Vector3.new(0, 0, 0)`.

## Step 1: Create A Backup

Before changing the live template:

1. Duplicate `ReplicatedStorage.Assets.PlotTemplate`.
2. Rename the duplicate exactly `PlotTemplateBeforeConveyor`.
3. Leave `PlotTemplateBeforeConveyor` under `ReplicatedStorage.Assets`.
4. Make all remaining changes only to `ReplicatedStorage.Assets.PlotTemplate`.

Do not rename `PlotTemplate`. Runtime code still requires that exact name.

## Step 2: Create The Machine Folders

Under `ReplicatedStorage.Assets.PlotTemplate`:

1. Create a `Folder` named exactly `Machine`.
2. Under `Machine`, create a `Folder` named exactly `RuntimePieces`.
3. Under `Machine`, create a `Folder` named exactly `Markers`.
4. Under `Machine.Markers`, create a `Part` named exactly `StorageOutput`.
5. Apply the shared marker properties to `StorageOutput`.
6. Set `StorageOutput.Position` to exactly `Vector3.new(0, 1.5, 1.5)`.

`RuntimePieces` must remain empty. Runtime code will place visible Wood, Stone, and Coal pieces there.

`StorageOutput` is the machine withdrawal/start location. It visually represents raw Wood and Stone leaving the existing Storage Bin. Do not move or rename the existing `StorageBin`.

## Step 3: Create Conveyor 1

Under `PlotTemplate.Machine`, create a `Model` named exactly `Conveyor1`.

Set these model details:

| Setting | Required value |
| --- | --- |
| CollectionService tag | `MachinePart` |
| Attribute `MachinePartId` | String: `Conveyor1` |
| Attribute `InitialMachineState` | String: `Locked` |
| Attribute `PurchaseCost` | Number: `100` |
| Attribute `Upgradeable` | Boolean: `true` |

Do not add the `Interactable` tag. Runtime code will add it only after the player owns a Stone NPC.

Create:

- A `Folder` named `Visuals`.
- A `Folder` named `Markers`.
- A `Part` named `InteractionPart`.

Set `Conveyor1.PrimaryPart` to `InteractionPart`.

### Conveyor 1 Visual Parts

Create these Parts under `Conveyor1.Visuals`:

| Name | Size | Position | Color | Material |
| --- | --- | --- | --- | --- |
| `Foundation` | `(4, 0.35, 7)` | `(0, 0.175, -2)` | `(55, 55, 55)` | `Metal` |
| `Belt` | `(3.2, 0.25, 7)` | `(0, 0.475, -2)` | `(25, 25, 25)` | `SmoothPlastic` |
| `LeftRail` | `(0.25, 0.7, 7)` | `(-1.75, 0.65, -2)` | `(120, 120, 120)` | `Metal` |
| `RightRail` | `(0.25, 0.7, 7)` | `(1.75, 0.65, -2)` | `(120, 120, 120)` | `Metal` |

Colors are RGB values. Apply the shared visual properties to all four parts.

### Conveyor 1 Markers

Create these Parts under `Conveyor1.Markers`:

| Name | Position |
| --- | --- |
| `PathStart` | `(0, 1.5, 1.5)` |
| `PathEnd` | `(0, 1.5, -5.5)` |

Apply the shared marker properties.

`Conveyor1.Markers.PathStart` intentionally occupies the same world position as `Machine.Markers.StorageOutput`.

### Conveyor 1 Interaction Part

Set:

| Property | Value |
| --- | --- |
| `Size` | `(4, 1.5, 7)` |
| `Position` | `(0, 0.75, -2)` |

Apply the shared interaction properties.

## Step 4: Create Upgrader 1

Under `PlotTemplate.Machine`, create a `Model` named exactly `Upgrader1`.

Set:

| Setting | Required value |
| --- | --- |
| CollectionService tag | `MachinePart` |
| Attribute `MachinePartId` | String: `Upgrader1` |
| Attribute `InitialMachineState` | String: `Locked` |
| Attribute `PurchaseCost` | Number: `150` |
| Attribute `Upgradeable` | Boolean: `true` |

Create `Visuals`, `Markers`, and `InteractionPart`. Set `Upgrader1.PrimaryPart` to `InteractionPart`.

### Upgrader 1 Visual Parts

Create these Parts under `Upgrader1.Visuals`:

| Name | Size | Position | Color | Material |
| --- | --- | --- | --- | --- |
| `Base` | `(4, 0.35, 2)` | `(0, 0.175, -6.5)` | `(65, 65, 80)` | `Metal` |
| `LeftPost` | `(0.45, 4, 0.45)` | `(-1.65, 2, -6.5)` | `(70, 120, 255)` | `Neon` |
| `RightPost` | `(0.45, 4, 0.45)` | `(1.65, 2, -6.5)` | `(70, 120, 255)` | `Neon` |
| `TopBeam` | `(3.75, 0.45, 0.45)` | `(0, 3.8, -6.5)` | `(70, 120, 255)` | `Neon` |

Apply the shared visual properties.

### Upgrader 1 Markers

| Name | Position |
| --- | --- |
| `PathStart` | `(0, 1.5, -5.5)` |
| `EffectPoint` | `(0, 1.5, -6.5)` |
| `PathEnd` | `(0, 1.5, -7.5)` |

Apply the shared marker properties.

### Upgrader 1 Interaction Part

| Property | Value |
| --- | --- |
| `Size` | `(4, 4, 2)` |
| `Position` | `(0, 2, -6.5)` |

Apply the shared interaction properties.

## Step 5: Reuse And Prepare The Existing Coal Processor

Do not delete the existing `ReplicatedStorage.Assets.PlotTemplate.CoalProcessor` model.

Perform these changes last, after all newly created machine objects have been validated:

1. Drag the existing `PlotTemplate.CoalProcessor` model into `PlotTemplate.Machine`.
2. Confirm its new path is exactly `ReplicatedStorage.Assets.PlotTemplate.Machine.CoalProcessor`.
3. Under `Machine.CoalProcessor`, create a `Folder` named exactly `Visuals`.
4. Move the existing `Walls` model into `CoalProcessor.Visuals`.
5. Move the existing `Blades` model into `CoalProcessor.Visuals`.
6. Under `Machine.CoalProcessor`, create a `Folder` named exactly `Markers`.
7. Under `Machine.CoalProcessor`, create a `Part` named exactly `InteractionPart`.
8. Set `CoalProcessor.PrimaryPart` to the new `InteractionPart`.

Do not visually move, rotate, resize, or rebuild the existing processor. Its bounding center must remain approximately `(0.15, 2.5, -11.9)`.

Apply the shared visual properties to every `BasePart` descendant under `CoalProcessor.Visuals`, including all parts nested below `Walls` and `Blades`.

Set these model details:

| Setting | Required value |
| --- | --- |
| CollectionService tag | `MachinePart` |
| Attribute `MachinePartId` | String: `CoalProcessor` |
| Attribute `InitialMachineState` | String: `Locked` |
| Attribute `PurchaseCost` | Number: `250` |
| Attribute `Upgradeable` | Boolean: `true` |

### Coal Processor Markers

Create these Parts under `CoalProcessor.Markers`:

| Name | Position |
| --- | --- |
| `Input` | `(0, 1.5, -9.6)` |
| `Output` | `(0, 1.5, -14.2)` |

Apply the shared marker properties.

The `Input` marker is where raw pieces disappear into the processor buffer. The `Output` marker is where processed Coal appears.

### Coal Processor Interaction Part

| Property | Value |
| --- | --- |
| `Size` | `(7.7, 4.9, 4.2)` |
| `Position` | `(0.15, 2.5, -11.9)` |

Apply the shared interaction properties.

### Coal Processor Safety

- Leave `WorkerApproachPoints.CoalProcessor` exactly where it is for now.
- Leave `ReplicatedStorage.Assets.WorkerTemplates.CoalProcessor` exactly where it is for now.
- Do not add a `ProximityPrompt` to the processor.
- Do not add input-buffer values or processing attributes in Studio. Runtime and persisted player data will own them.
- The source game will temporarily fail its old plot validation after this move and before code implementation. That is expected; make this move only when you are ready to confirm all world changes.

## Step 6: Create Conveyor 2

Under `PlotTemplate.Machine`, create a `Model` named exactly `Conveyor2`.

Set:

| Setting | Required value |
| --- | --- |
| CollectionService tag | `MachinePart` |
| Attribute `MachinePartId` | String: `Conveyor2` |
| Attribute `InitialMachineState` | String: `Locked` |
| Attribute `PurchaseCost` | Number: `200` |
| Attribute `Upgradeable` | Boolean: `true` |

Create `Visuals`, `Markers`, and `InteractionPart`. Set `Conveyor2.PrimaryPart` to `InteractionPart`.

### Conveyor 2 Visual Parts

Create these Parts under `Conveyor2.Visuals`:

| Name | Size | Position | Color | Material |
| --- | --- | --- | --- | --- |
| `Foundation` | `(4, 0.35, 7)` | `(0, 0.175, -17.7)` | `(55, 55, 55)` | `Metal` |
| `Belt` | `(3.2, 0.25, 7)` | `(0, 0.475, -17.7)` | `(25, 25, 25)` | `SmoothPlastic` |
| `LeftRail` | `(0.25, 0.7, 7)` | `(-1.75, 0.65, -17.7)` | `(120, 120, 120)` | `Metal` |
| `RightRail` | `(0.25, 0.7, 7)` | `(1.75, 0.65, -17.7)` | `(120, 120, 120)` | `Metal` |

Apply the shared visual properties.

### Conveyor 2 Markers

| Name | Position |
| --- | --- |
| `PathStart` | `(0, 1.5, -14.2)` |
| `PathEnd` | `(0, 1.5, -21.2)` |

Apply the shared marker properties.

### Conveyor 2 Interaction Part

| Property | Value |
| --- | --- |
| `Size` | `(4, 1.5, 7)` |
| `Position` | `(0, 0.75, -17.7)` |

Apply the shared interaction properties.

## Step 7: Create Upgrader 2

Under `PlotTemplate.Machine`, create a `Model` named exactly `Upgrader2`.

Set:

| Setting | Required value |
| --- | --- |
| CollectionService tag | `MachinePart` |
| Attribute `MachinePartId` | String: `Upgrader2` |
| Attribute `InitialMachineState` | String: `Locked` |
| Attribute `PurchaseCost` | Number: `300` |
| Attribute `Upgradeable` | Boolean: `true` |

Create `Visuals`, `Markers`, and `InteractionPart`. Set `Upgrader2.PrimaryPart` to `InteractionPart`.

### Upgrader 2 Visual Parts

Create these Parts under `Upgrader2.Visuals`:

| Name | Size | Position | Color | Material |
| --- | --- | --- | --- | --- |
| `Base` | `(4, 0.35, 2)` | `(0, 0.175, -22.2)` | `(80, 65, 65)` | `Metal` |
| `LeftPost` | `(0.45, 4, 0.45)` | `(-1.65, 2, -22.2)` | `(255, 125, 50)` | `Neon` |
| `RightPost` | `(0.45, 4, 0.45)` | `(1.65, 2, -22.2)` | `(255, 125, 50)` | `Neon` |
| `TopBeam` | `(3.75, 0.45, 0.45)` | `(0, 3.8, -22.2)` | `(255, 125, 50)` | `Neon` |

Apply the shared visual properties.

### Upgrader 2 Markers

| Name | Position |
| --- | --- |
| `PathStart` | `(0, 1.5, -21.2)` |
| `EffectPoint` | `(0, 1.5, -22.2)` |
| `PathEnd` | `(0, 1.5, -23.2)` |

Apply the shared marker properties.

### Upgrader 2 Interaction Part

| Property | Value |
| --- | --- |
| `Size` | `(4, 4, 2)` |
| `Position` | `(0, 2, -22.2)` |

Apply the shared interaction properties.

## Step 8: Create The Collection Point

Under `PlotTemplate.Machine`, create a `Model` named exactly `CollectionPoint`.

Set:

| Setting | Required value |
| --- | --- |
| CollectionService tag | `MachinePart` |
| Attribute `MachinePartId` | String: `CollectionPoint` |
| Attribute `InitialMachineState` | String: `Locked` |
| Attribute `PurchaseCost` | Number: `400` |
| Attribute `Upgradeable` | Boolean: `true` |
| Attribute `Capacity` | Number: `50` |

Create `Visuals`, `Markers`, and `InteractionPart`. Set `CollectionPoint.PrimaryPart` to `InteractionPart`.

### Collection Point Visual Parts

Create these Parts under `CollectionPoint.Visuals`:

| Name | Size | Position | Color | Material |
| --- | --- | --- | --- | --- |
| `Base` | `(5, 0.4, 5)` | `(0, 0.2, -26)` | `(50, 50, 50)` | `Metal` |
| `LeftWall` | `(0.4, 2, 5)` | `(-2.3, 1.2, -26)` | `(90, 90, 90)` | `Metal` |
| `RightWall` | `(0.4, 2, 5)` | `(2.3, 1.2, -26)` | `(90, 90, 90)` | `Metal` |
| `BackWall` | `(5, 2, 0.4)` | `(0, 1.2, -28.3)` | `(90, 90, 90)` | `Metal` |
| `FrontLip` | `(5, 0.8, 0.4)` | `(0, 0.6, -23.7)` | `(90, 90, 90)` | `Metal` |

Apply the shared visual properties.

The Collection Point is a manual collection area with upgradeable capacity. Do not add an automated collection NPC, worker home, approach point, touch-to-collect script, or ProximityPrompt.

### Collection Point Marker

Create `CollectionPoint.Markers.Input` at position `(0, 1.5, -23.5)` and apply the shared marker properties.

This is where a Coal piece is deposited into the Collection Point's persisted stored value.

### Collection Point Interaction Part

| Property | Value |
| --- | --- |
| `Size` | `(5, 2.5, 5)` |
| `Position` | `(0, 1.25, -26)` |

Apply the shared interaction properties.

## Step 9: Validate Model States And Preview Behavior

Do not create separate preview or ghost copies.

Each actual model under `PlotTemplate.Machine` is also its future ghost model. Runtime code will change the same model between:

- `Locked`: visuals hidden, collision disabled, interaction disabled.
- `Preview`: visuals approximately 20% visible using `Transparency = 0.8`, dark outline added by code, interaction enabled only for the next purchasable part.
- `Built`: authored appearance restored.
- `Active`: built and participating in the complete machine chain.

The required strict purchase order is:

```text
Conveyor1
Upgrader1
CoalProcessor
Conveyor2
Upgrader2
CollectionPoint
```

Do not manually set any model to ghost transparency. Keep all authored visual parts at `Transparency = 0`.

Do not add a `Highlight`; runtime code will create preview outlines.

## Step 10: Tags And Attributes Audit

Use Roblox Studio's Tag Editor to add exactly one manual CollectionService tag:

| Path | Required tag |
| --- | --- |
| `PlotTemplate.Machine.Conveyor1` | `MachinePart` |
| `PlotTemplate.Machine.Upgrader1` | `MachinePart` |
| `PlotTemplate.Machine.CoalProcessor` | `MachinePart` |
| `PlotTemplate.Machine.Conveyor2` | `MachinePart` |
| `PlotTemplate.Machine.Upgrader2` | `MachinePart` |
| `PlotTemplate.Machine.CollectionPoint` | `MachinePart` |

Do not add `MachinePart` to visual parts, marker parts, folders, Storage Bin, or the Machine folder.

Do not manually add any of these runtime-owned tags:

- `Interactable`
- `MachinePreview`
- `MachineBuilt`
- `MachineActive`
- `MovingResourcePiece`

Confirm the exact model attributes:

| Model | `MachinePartId` | `InitialMachineState` | `PurchaseCost` | `Upgradeable` | Extra |
| --- | --- | --- | ---: | --- | --- |
| `Conveyor1` | `Conveyor1` | `Locked` | `100` | `true` | None |
| `Upgrader1` | `Upgrader1` | `Locked` | `150` | `true` | None |
| `CoalProcessor` | `CoalProcessor` | `Locked` | `250` | `true` | None |
| `Conveyor2` | `Conveyor2` | `Locked` | `200` | `true` | None |
| `Upgrader2` | `Upgrader2` | `Locked` | `300` | `true` | None |
| `CollectionPoint` | `CollectionPoint` | `Locked` | `400` | `true` | `Capacity = 50` |

Attribute types must match the table. Do not enter numeric values as strings.

Do not author levels, multipliers, speeds, processing state, buffers, stored Coal, ownership, or built-state attributes. Those values belong to persisted player data and runtime state. Collection Point capacity starts at `50` and source config increases it by `25` per upgrade level.

## Step 11: Objects To Keep And Objects To Leave Alone

Keep these existing objects exactly where they are:

```text
ReplicatedStorage.Assets.PlotTemplate.StorageBin
ReplicatedStorage.Assets.PlotTemplate.StorageUpgradeButton
ReplicatedStorage.Assets.PlotTemplate.NPCPurchasePad
ReplicatedStorage.Assets.PlotTemplate.Tree
ReplicatedStorage.Assets.PlotTemplate.Rock
ReplicatedStorage.Assets.PlotTemplate.SellCrate
ReplicatedStorage.Assets.PlotTemplate.WorkerHomes
ReplicatedStorage.Assets.PlotTemplate.WorkerApproachPoints
ReplicatedStorage.Assets.WorkerTemplates.Wood
ReplicatedStorage.Assets.WorkerTemplates.Stone
ReplicatedStorage.Assets.WorkerTemplates.CoalProcessor
```

Keep `PlotTemplate.WorkerApproachPoints.CoalProcessor` for now, even though the new source code will stop using it.

Do not manually delete existing saved-data fields or source files. The source implementation will bump the datastore key and remove the Coal NPC role safely.

Do not modify the existing Wood and Stone NPC routes. Confirm the new machine does not overlap:

- `WorkerApproachPoints.StorageBin`
- The route from Rock to Storage Bin
- The route from Tree to Storage Bin
- NPC homes
- `NPCPurchasePad`
- `PlayerSpawn`

Leave all existing `ProximityPrompt` instances alone until source code is ready. Do not add new prompts. Existing runtime code disables old prompts.

## Step 12: Manual Layout And Marker Test

Perform this test in Edit mode with marker transparency temporarily changed only when needed:

1. Temporarily set every machine marker's `Transparency` to `0.5`.
2. Confirm all path markers form a southbound line in this order:
   - `Machine.Markers.StorageOutput`
   - `Conveyor1.Markers.PathStart`
   - `Conveyor1.Markers.PathEnd`
   - `Upgrader1.Markers.PathStart`
   - `Upgrader1.Markers.EffectPoint`
   - `Upgrader1.Markers.PathEnd`
   - `CoalProcessor.Markers.Input`
   - `CoalProcessor.Markers.Output`
   - `Conveyor2.Markers.PathStart`
   - `Conveyor2.Markers.PathEnd`
   - `Upgrader2.Markers.PathStart`
   - `Upgrader2.Markers.EffectPoint`
   - `Upgrader2.Markers.PathEnd`
   - `CollectionPoint.Markers.Input`
3. Confirm no marker is inside an opaque visual part.
4. Confirm every marker is approximately `1.5` studs above the Ground surface.
5. Confirm Conveyor 1 visually starts near the Storage Bin.
6. Confirm the existing Coal Processor remains centered at approximately `(0.15, 2.5, -11.9)`.
7. Confirm Conveyor 2 begins at the processor's south/output side.
8. Confirm Coal can visually travel into the open side of the Collection Point.
9. Restore every marker's `Transparency` to `1`.

Then perform this collision and access test:

1. Confirm every new machine visual part is anchored.
2. Confirm every new machine visual part has `CanCollide = false`.
3. Confirm every marker has `CanQuery = false`.
4. Confirm every `InteractionPart` has `CanQuery = true`.
5. Walk a test character beside every machine part.
6. Confirm the player can stand within approximately 10 studs of every model.
7. Confirm the machine does not prevent access to the Storage Bin, NPC Purchase Pad, or Sell Crate.
8. Confirm Wood and Stone NPC approach points remain unobstructed.

## Completion Checklist

Before telling Codex that the world changes are complete, verify every item:

- [ ] I edited `ReplicatedStorage.Assets.PlotTemplate`, not a runtime clone.
- [ ] I made no manual changes under `Workspace`.
- [ ] I created no Attachment instances or physical conveyor constraints.
- [ ] `ReplicatedStorage.Assets.PlotTemplateBeforeConveyor` exists as a backup.
- [ ] `PlotTemplate.Machine` exists and is a Folder.
- [ ] `Machine.RuntimePieces` exists, is a Folder, and is empty.
- [ ] `Machine.Markers.StorageOutput` exists at `(0, 1.5, 1.5)`.
- [ ] `Conveyor1`, `Upgrader1`, `CoalProcessor`, `Conveyor2`, `Upgrader2`, and `CollectionPoint` exist as Models under `Machine`.
- [ ] Every machine-part Model has `Visuals`, `Markers`, and `InteractionPart`.
- [ ] Every machine-part Model uses `InteractionPart` as its `PrimaryPart`.
- [ ] All hierarchy names and capitalization exactly match this document.
- [ ] All six machine-part Models have the `MachinePart` tag.
- [ ] No child parts or folders have the `MachinePart` tag.
- [ ] No machine object has been manually given the `Interactable` tag.
- [ ] All six machine-part Models have the exact required attributes and attribute types.
- [ ] Every visual BasePart is anchored, non-collidable, non-touchable, queryable, and authored at transparency `0`.
- [ ] Every marker is anchored, invisible, non-collidable, non-touchable, and non-queryable.
- [ ] Every InteractionPart is anchored, invisible, non-collidable, non-touchable, and queryable.
- [ ] Conveyor 1 contains the exact four named visual parts and two markers.
- [ ] Upgrader 1 contains the exact four named visual parts and three markers.
- [ ] The existing Coal Processor was moved under `Machine`, not deleted or rebuilt.
- [ ] The existing Coal Processor's `Walls` and `Blades` are under `CoalProcessor.Visuals`.
- [ ] The Coal Processor remains at its original world location.
- [ ] The Coal Processor has exact `Input` and `Output` markers.
- [ ] Conveyor 2 contains the exact four named visual parts and two markers.
- [ ] Upgrader 2 contains the exact four named visual parts and three markers.
- [ ] Collection Point contains the exact five named visual parts and `Input` marker.
- [ ] Collection Point has Number attribute `Capacity = 50`.
- [ ] No duplicate preview/ghost models were created.
- [ ] No Highlights, scripts, touch scripts, or new ProximityPrompts were added.
- [ ] Existing Storage Bin, Storage Upgrade Button, NPC Purchase Pad, Tree, Rock, Sell Crate, Worker Homes, and Worker Approach Points remain.
- [ ] Wood and Stone worker templates remain unchanged.
- [ ] The old Coal Processor worker template remains for now.
- [ ] `WorkerApproachPoints.CoalProcessor` remains for now.
- [ ] The marker path was visually checked in the correct order.
- [ ] The machine does not obstruct Wood or Stone NPC routes.
- [ ] Every machine part is reachable by the player for direct interaction.
- [ ] All temporarily visible markers were restored to `Transparency = 1`.
- [ ] The place was saved after completing the changes.

Once every item is complete, tell Codex: **The conveyor world changes are complete.**

Codex must then inspect the resulting Studio hierarchy before implementing source code.
