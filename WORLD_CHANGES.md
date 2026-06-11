# Persistent NPC System: Required Roblox Studio World Changes

Complete every change in this document inside Roblox Studio before asking Codex to implement the source-code phase.

Do not rename objects differently from the names shown here. The future code will use these names as its world contract.

## Scope And Safety

- Make these changes in **Edit mode**, not while the game is running.
- Modify `ReplicatedStorage.Assets.PlotTemplate`, not a cloned plot under `Workspace.PlayerPlots`.
- Keep `StorageUpgradeButton`, `Tree`, `Rock`, `StorageBin`, `CoalProcessor`, `Ground`, `PlayerSpawn`, and all unrelated plot objects.
- Copy the current NPC rigs into `WorkerTemplates` before deleting them from `PlotTemplate`.
- Do not add scripts to the world objects. Runtime behavior, tags, and default attributes will be managed by source code.
- Save a backup copy of `PlotTemplate` before starting.

The current template uses an `80 x 80` Ground centered at approximately `(0, -0.5, 0)`. All suggested positions below are coordinates inside the current `PlotTemplate`, before the plot is cloned and moved to a plot spawn.

## Required Final Hierarchy

The relevant hierarchy must end up exactly like this:

```text
ReplicatedStorage
  Assets
    PlotTemplate
      Ground
      PlayerSpawn
      NPCPurchasePad
        BaseF
        ...existing decorative pad parts
      StorageUpgradeButton
      WorkerHomes
        Home01
        Home02
        Home03
        Home04
        Home05
        Home06
        Home07
        Home08
      WorkerApproachPoints
        Tree
        Rock
        StorageBin
        CoalProcessor
      Tree
        Trunk
        Leaves
      Rock
        Body
      StorageBin
        Top
        ...existing parts
      CoalProcessor
        ...existing parts
      ...remaining plot objects
    WorkerTemplates
      Wood
        HumanoidRootPart
        Humanoid
        ...complete humanoid rig
      Stone
        HumanoidRootPart
        Humanoid
        ...complete humanoid rig
      CoalProcessor
        HumanoidRootPart
        Humanoid
        ...complete humanoid rig
```

`WorkerHomes` and `WorkerApproachPoints` must be `Folder` instances. `WorkerTemplates` must also be a `Folder`.

## Step 1: Create The NPC Purchase Pad

The current plot has three separate worker purchase pads:

- `AutoChopperButton`, currently near `(18, 0.35, 0.7)`
- `AutoProcessorButton`, currently near `(18, 0.35, -9)`
- `AutoMinerButton`, currently near `(18, 0.35, -18.7)`

Use the current middle pad as the new shared purchase pad:

1. Select `ReplicatedStorage.Assets.PlotTemplate.AutoProcessorButton`.
2. Rename the model to exactly `NPCPurchasePad`.
3. Keep its current position near `(18, 0.35, -9)`.
4. Confirm the model still contains a `BaseF` part.
5. Confirm `BaseF` is a `BasePart` and is the model's `PrimaryPart`.
6. Delete `AutoChopperButton`.
7. Delete `AutoMinerButton`.
8. Leave `StorageUpgradeButton` unchanged.

The future interaction system will use `NPCPurchasePad.BaseF` as the interaction/raycast part. Interacting with this pad will open a role-selection menu; it must not contain role-specific text or scripts.

Recommended presentation changes:

- Change the pad's visible text or decoration to communicate `Hire NPC`.
- Keep a clear standing area around the pad.
- Do not place walls or props between the pad and the plot's central walking area.

## Step 2: Create Worker Templates

The current `AutoChopper` and `AutoMiner` models are complete humanoid rigs. They can be reused as the initial worker visuals.

1. Under `ReplicatedStorage.Assets`, create a `Folder` named exactly `WorkerTemplates`.
2. Copy `PlotTemplate.AutoChopper` into `WorkerTemplates`.
3. Rename the copied model to exactly `Wood`.
4. Copy `PlotTemplate.AutoMiner` into `WorkerTemplates`.
5. Rename the copied model to exactly `Stone`.
6. Copy either `Wood` or `Stone`.
7. Rename that third copy to exactly `CoalProcessor`.
8. After all three templates are present and validated, delete the original `AutoChopper` and `AutoMiner` models from `PlotTemplate`.

The Coal Processor NPC may reuse either existing rig visually for now.

### Validate Every Worker Template

Perform this check separately for `Wood`, `Stone`, and `CoalProcessor`:

- The template is a `Model`.
- The model contains a `Humanoid`.
- The model contains a `BasePart` named exactly `HumanoidRootPart`.
- `Model.PrimaryPart` is set to `HumanoidRootPart`.
- The complete humanoid rig and its joints/constraints were copied.
- Every body `BasePart`, including `HumanoidRootPart`, has `Anchored = false`.
- `HumanoidRootPart.CanCollide = true`.
- Decorative/accessory parts do not introduce large unexpected collisions.
- The default `Animate` script is either deleted or has `Enabled = false`.
- No scripts inside the template perform gameplay behavior.

The current source workers use collision on `HumanoidRootPart`, `UpperTorso`, `LowerTorso`, and `Head`. That is acceptable initially, but manually test that workers do not snag on one another. If they do, keep `HumanoidRootPart.CanCollide = true` and set torso/head collision off.

Do not permanently set `Humanoid.WalkSpeed` in Studio. Code will set the calculated starting speed of `10`.

## Step 3: Create Worker Home Slots

Home slots are persistent spawn and idle locations. The number of home parts is the maximum number of NPCs a player can own.

Create eight slots initially:

1. Under `PlotTemplate`, create a `Folder` named exactly `WorkerHomes`.
2. Inside it, create eight `Part` instances named exactly `Home01` through `Home08`.
3. Apply all required properties below to every home part.
4. Place the homes using the suggested starting positions below.
5. Rotate each home so its front faces toward the center of the plot.

### Required Home Part Properties

| Property | Required value |
| --- | --- |
| Class | `Part` |
| Name | `Home01` through `Home08` |
| Size | `Vector3.new(2, 0.2, 2)` |
| Anchored | `true` |
| CanCollide | `false` |
| CanTouch | `false` |
| CanQuery | `false` |
| Transparency | `1` |
| CastShadow | `false` |

Set each part's Y position to approximately `0.1`, so it sits on top of the Ground without affecting walking.

### Suggested Home Positions

These positions use the currently open east side of the plot and avoid the PlayerSpawn:

| Home | Suggested position |
| --- | --- |
| `Home01` | `(27, 0.1, 18)` |
| `Home02` | `(33, 0.1, 18)` |
| `Home03` | `(27, 0.1, 11)` |
| `Home04` | `(33, 0.1, 11)` |
| `Home05` | `(27, 0.1, 4)` |
| `Home06` | `(33, 0.1, 4)` |
| `Home07` | `(27, 0.1, -3)` |
| `Home08` | `(33, 0.1, -3)` |

The positions are starting recommendations, not visual requirements. Move them slightly if required by decoration, but:

- Keep every home on walkable ground.
- Keep at least `5` studs between home centers.
- Keep all homes away from the Ground edge.
- Keep the route from every home to the center of the plot unobstructed.
- Do not overlap the purchase pad or PlayerSpawn.
- Preserve the exact home names after moving them.

Eight slots means the initial maximum is eight total NPCs across all roles. Add more later only by continuing the zero-padded naming pattern: `Home09`, `Home10`, and so on.

## Step 4: Create Worker Approach Points

Workers will move to authored approach points instead of attempting to walk into object pivots. This is important because the Tree pivot is high above the ground and the StorageBin/CoalProcessor contain collision geometry.

1. Under `PlotTemplate`, create a `Folder` named exactly `WorkerApproachPoints`.
2. Add four `Part` instances named exactly:
   - `Tree`
   - `Rock`
   - `StorageBin`
   - `CoalProcessor`
3. Apply the required marker properties below.
4. Place each marker on walkable ground beside its matching object.
5. Rotate each marker so its front faces the matching object.

### Required Approach Point Properties

| Property | Required value |
| --- | --- |
| Class | `Part` |
| Size | `Vector3.new(2, 0.2, 2)` |
| Anchored | `true` |
| CanCollide | `false` |
| CanTouch | `false` |
| CanQuery | `false` |
| Transparency | `1` |
| CastShadow | `false` |

Use approximately `Y = 0.1` for every approach point.

### Suggested Approach Positions

Start with these positions and adjust only if manual movement testing shows a collision or animation-range problem:

| Approach point | Current matching object location | Suggested marker position | Placement intent |
| --- | --- | --- | --- |
| `Tree` | Tree near `(-19, 0, 1)` at ground level | `(-11, 0.1, 1)` | Stand east of the trunk and face west toward it. |
| `Rock` | Rock near `(-19, 0, -18)` | `(-12, 0.1, -18)` | Stand east of the rock and face west toward it. |
| `StorageBin` | Bin near `(0, 0, 4)` | `(0, 0.1, 9)` | Stand south/north according to Studio axes as needed, facing the bin, without entering its walls. |
| `CoalProcessor` | Processor near `(0, 0, -12)` | `(0, 0.1, -6)` | Stand on the open side facing the processor controls/output area. |

When positioning markers, use the visible front arrow of the selected Part or set its orientation deliberately. The future code will use the marker's position for movement and its orientation to face the NPC during the action.

Only one approach marker per object is required for the first implementation. Leave enough open area around each marker for at least two workers to wait without blocking all routes.

## Step 5: Configure Resource Nodes

Keep the existing `Tree` and `Rock` models in `PlotTemplate`.

### Tree

1. Confirm `PlotTemplate.Tree` is a `Model`.
2. Confirm its `PrimaryPart` is `Trunk`.
3. Add these attributes to the **Tree model**, not the Trunk:

| Attribute | Type | Value |
| --- | --- | --- |
| `ResourceType` | String | `Wood` |
| `Capacity` | Number | `25` |
| `RespawnSeconds` | Number | `5` |

### Rock

1. Confirm `PlotTemplate.Rock` is a `Model`.
2. Confirm its `PrimaryPart` is `Body`.
3. Add these attributes to the **Rock model**, not the Body:

| Attribute | Type | Value |
| --- | --- | --- |
| `ResourceType` | String | `Stone` |
| `Capacity` | Number | `25` |
| `RespawnSeconds` | Number | `5` |

Do not add `AvailableAmount` or `ReservedAmount` in Studio. Runtime code will initialize and manage those values for each cloned plot.

The code will use `Capacity = 25` and `RespawnSeconds = 5` when those attributes are missing, but author them now so each node is easy to tune later.

Verify that:

- Tree and Rock parts are anchored.
- The models remain visible and recognizable at 50% transparency.
- There is open ground around each approach marker.
- There is clear space above each node for a depletion progress BillboardGui.
- The node model does not contain scripts that independently hide, destroy, or respawn it.

## Step 6: Validate Storage And Processor Access

Do not rename `StorageBin`, `StorageBin.Top`, or `CoalProcessor`.

### StorageBin

- Keep `StorageBin.Top` as the model's `PrimaryPart`.
- Confirm the `StorageBin` approach point is outside the bin collision.
- Confirm a worker standing at the marker can face the bin.
- Keep a clear waiting area around the marker for workers whose storage is full.

### CoalProcessor

- Keep the current CoalProcessor model and its existing primary part.
- Confirm the `CoalProcessor` approach point is outside all processor collision.
- Confirm the route between `StorageBin` and `CoalProcessor` is clear.
- Leave enough space for a Coal NPC to visibly travel between storage and the processor repeatedly.

## Step 7: Navigation And Collision Test

The first source implementation will use direct `Humanoid:MoveTo`, not PathfindingService. The layout must therefore provide clear, direct walking routes.

Perform this manual test in Studio before marking the world work complete:

1. Temporarily copy one validated worker template into `PlotTemplate`.
2. Place it on each `HomeXX` marker in turn.
3. In Play mode or with a temporary command-bar test, move it to each approach point:
   - Home to Tree
   - Home to Rock
   - Home to StorageBin
   - Home to CoalProcessor
   - Tree to StorageBin
   - Rock to StorageBin
   - StorageBin to CoalProcessor
   - CoalProcessor to StorageBin
4. Confirm the worker reaches each marker without becoming stuck.
5. Confirm the worker remains upright and on the Ground.
6. Confirm the worker does not collide with invisible placement parts.
7. Remove the temporary worker copy after testing.

Check these specific conditions:

- Ground is continuous between all homes, nodes, storage, and processor.
- No decoration, invisible part, old button, or spawn marker blocks a direct route.
- All approach points are on reachable walkable ground.
- No worker-template body part is anchored.
- Workers can leave every home without immediately colliding with another home position.
- The StorageBin and CoalProcessor waiting areas can hold multiple workers.
- The Tree and Rock remain readable at 50% transparency.
- A BillboardGui above Tree and Rock will not overlap a roof or other object.

If a direct route is blocked, rearrange the obstruction or marker now. Do not rely on future pathfinding to compensate for a blocked layout.

## Step 8: Remove Obsolete Plot Objects

After worker templates and the new purchase pad are complete, confirm these old fixed-system objects no longer exist under `PlotTemplate`:

```text
AutoChopper
AutoMiner
AutoChopperButton
AutoMinerButton
AutoProcessorButton
```

The former `AutoProcessorButton` should now exist only under its new name, `NPCPurchasePad`.

Do not remove:

```text
StorageUpgradeButton
CoalProcessor
Tree
Rock
StorageBin
```

## Completion Checklist

Before telling Codex that the world changes are complete, verify every item:

- [ ] I edited `ReplicatedStorage.Assets.PlotTemplate`, not a runtime cloned plot.
- [ ] `NPCPurchasePad` exists and contains `BaseF`.
- [ ] `NPCPurchasePad.BaseF` is the purchase pad model's `PrimaryPart`.
- [ ] The old `AutoChopperButton` and `AutoMinerButton` were removed.
- [ ] The former `AutoProcessorButton` was renamed to `NPCPurchasePad`.
- [ ] `StorageUpgradeButton` remains unchanged.
- [ ] `ReplicatedStorage.Assets.WorkerTemplates` exists.
- [ ] Worker templates named exactly `Wood`, `Stone`, and `CoalProcessor` exist.
- [ ] Every worker template has a `Humanoid` and `HumanoidRootPart`.
- [ ] Every worker template uses `HumanoidRootPart` as its `PrimaryPart`.
- [ ] No worker-template body part is anchored.
- [ ] Every worker template's default `Animate` script is deleted or disabled.
- [ ] The old fixed `AutoChopper` and `AutoMiner` models were removed from `PlotTemplate`.
- [ ] `PlotTemplate.WorkerHomes` exists as a Folder.
- [ ] Home parts are named exactly `Home01` through `Home08`.
- [ ] Every home is invisible, anchored, non-collidable, non-touchable, and non-queryable.
- [ ] Every home is on walkable ground and faces the intended idle direction.
- [ ] `PlotTemplate.WorkerApproachPoints` exists as a Folder.
- [ ] Approach points named exactly `Tree`, `Rock`, `StorageBin`, and `CoalProcessor` exist.
- [ ] Every approach point is invisible, anchored, non-collidable, non-touchable, and non-queryable.
- [ ] Every approach point is reachable and faces its matching object.
- [ ] `Tree.PrimaryPart` is `Trunk`.
- [ ] Tree has `ResourceType = "Wood"`, `Capacity = 25`, and `RespawnSeconds = 5`.
- [ ] `Rock.PrimaryPart` is `Body`.
- [ ] Rock has `ResourceType = "Stone"`, `Capacity = 25`, and `RespawnSeconds = 5`.
- [ ] StorageBin and CoalProcessor have clear approach/waiting areas.
- [ ] Tree and Rock have clear space for a progress BillboardGui.
- [ ] All listed direct walking routes were manually tested.
- [ ] The final hierarchy names match this document exactly.
- [ ] The place was saved after completing the changes.

Once every item is complete, tell Codex that `WORLD_CHANGES.md` has been completed. Source-code implementation must not begin before that confirmation.
