# Player-Buildable Factory: Required Roblox Studio World Changes

Complete this checklist manually in the active **Classic Idle** Roblox Studio place.

Do not change source code yet. Do not delete the existing machine or worker-home objects yet. After completing every verification item at the bottom, confirm the world changes are finished before implementation begins.

## Important Coordinate Convention

The active plot template is:

```text
ReplicatedStorage.Assets.PlotTemplate
```

Its `Ground` is currently:

- Position: `(0, -0.5, 0)`
- Size: `(80, 1, 80)`
- Rotation: `(0, 0, 0)`
- Top surface Y position: `0`

The logical build grid will be 20 cells wide by 20 cells deep:

- Each cell is exactly `4 x 4` studs.
- Grid `(1, 1)` is centered at local plot position `(-38, 0, -38)`.
- Grid `(20, 20)` is centered at local plot position `(38, 0, 38)`.
- Grid X increases toward plot-local East / positive X.
- Grid Z increases toward plot-local South / positive Z.
- North means local negative Z.
- East means local positive X.
- South means local positive Z.
- West means local negative X.

All positions below are relative to the authored `PlotTemplate` as it currently exists.

---

## 1. Fix The Duplicate Plot Spawn Name

Current structure contains two Parts named `Plot08` and no `Plot09`.

Under:

```text
Workspace.PlotSpawns
```

Rename exactly one of the two `Plot08` Parts to:

```text
Plot09
```

Do not move, resize, rotate, or delete either Part.

After renaming, `Workspace.PlotSpawns` must contain exactly:

```text
Plot01
Plot02
Plot03
Plot04
Plot05
Plot06
Plot07
Plot08
Plot09
Plot10
```

---

## 2. Create The Plot BuildGrid Hierarchy

Under:

```text
ReplicatedStorage.Assets.PlotTemplate
```

Create this exact hierarchy:

```text
BuildGrid (Folder)
  Bounds (Part)
  Blockers (Folder)
    WorkerHomes (Part)
    LegacyMachine (Part)
    NPCPurchasePad (Part)
    StorageArea (Part)
    SellCrate (Part)
    PlayerSpawn (Part)
  PlacedItems (Folder)
  RuntimeItems (Folder)
```

Names and classes must match exactly, including capitalization.

### Common BuildGrid Part Properties

Apply all of these properties to `Bounds` and every Part inside `Blockers`:

| Property | Required value |
|---|---|
| `Anchored` | `true` |
| `CanCollide` | `false` |
| `CanTouch` | `false` |
| `CanQuery` | `false` |
| `CastShadow` | `false` |
| `Transparency` | `1` |
| `Rotation` | `(0, 0, 0)` |
| `Material` | `SmoothPlastic` |
| `Color` | Any; invisible at runtime |

Do not add Attachments, scripts, constraints, welds, or descendants to these Parts.

### Bounds

Exact path:

```text
ReplicatedStorage.Assets.PlotTemplate.BuildGrid.Bounds
```

Required properties:

| Property | Required value |
|---|---|
| Class | `Part` |
| Position | `(0, 0.05, 0)` |
| Size | `(80, 0.1, 80)` |
| CollectionService tag | `BuildGridBounds` |
| Attribute `CellSize` | Number: `4` |

Do not add any other attributes or tags.

### Blockers

Each blocker must have the CollectionService tag:

```text
BuildGridBlocker
```

Blockers mark cells unavailable for factory placement. Their X and Z sizes and positions must remain aligned to the 4-stud grid.

| Exact Part name | Position | Size | Covered grid cells |
|---|---:|---:|---|
| `WorkerHomes` | `(0, 0.05, -34)` | `(80, 0.1, 12)` | X `1-20`, Z `1-3` |
| `LegacyMachine` | `(0, 0.05, -12)` | `(8, 0.1, 32)` | X `10-11`, Z `4-11` |
| `NPCPurchasePad` | `(18, 0.05, -16)` | `(12, 0.1, 8)` | X `14-16`, Z `6-7` |
| `StorageArea` | `(-2, 0.05, 4)` | `(20, 0.1, 8)` | X `8-12`, Z `11-12` |
| `SellCrate` | `(-10, 0.05, 22)` | `(12, 0.1, 12)` | X `7-9`, Z `14-16` |
| `PlayerSpawn` | `(8, 0.05, 30)` | `(8, 0.1, 12)` | X `12-13`, Z `17-19` |

`PlacedItems` and `RuntimeItems` must remain empty authored Folders. Runtime code will populate them inside cloned player plots.

---

## 3. Create The BuildItemTemplates Folder

Under:

```text
ReplicatedStorage.Assets
```

Create:

```text
BuildItemTemplates (Folder)
```

Inside it, create these six Models:

```text
ConveyorDropper
StraightConveyor
CornerConveyor
ConveyorUpgrader
ConveyorCollectionBin
WorkerHome
```

Do not place these templates inside `PlotTemplate`.

### Common Template Model Contract

Every template Model must contain:

```text
TemplateName (Model)
  Root (Part)
  Visuals (Folder)
  Markers (Folder)
```

For every template Model:

| Requirement | Exact value |
|---|---|
| `PrimaryPart` | Its direct child `Root` |
| Model pivot | Exactly the same position and rotation as `Root` |
| CollectionService tag | `BuildItemTemplate` |
| Attribute `BuildItemId` | String exactly matching Model name |
| Attribute `TemplateVersion` | Number: `1` |

For every `Root` Part:

| Property | Required value |
|---|---|
| Name | `Root` |
| Class | `Part` |
| Position | `(0, 0, 0)` while authored in `BuildItemTemplates` |
| Rotation | `(0, 0, 0)` |
| Size | `(0.2, 0.2, 0.2)` |
| Anchored | `true` |
| CanCollide | `false` |
| CanTouch | `false` |
| CanQuery | `false` |
| CastShadow | `false` |
| Transparency | `1` |

For every visual BasePart under `Visuals`:

- `Anchored = true`
- `CanCollide = false`
- `CanTouch = false`
- `CanQuery = false`
- `CastShadow = true`
- No scripts or constraints
- Keep the visual inside its allowed footprint
- All positions and rotations listed below are local to the template's `Root`.
- Because every authored `Root` is at `(0, 0, 0)` with rotation `(0, 0, 0)`, enter each listed local Position and Rotation directly into Studio.
- Colors are listed as RGB values. Enter them with the Studio color picker.
- Exact primitive visuals are required for the first implementation. Decorative improvements can be made later without renaming or deleting the required Parts.

For every marker Attachment:

- Parent it directly to the template's `Root`.
- Use the exact names and local `Position` values listed below.
- Leave Attachment orientation at `(0, 0, 0)`.
- Do not place marker Attachments inside the `Markers` Folder.
- Keep the empty `Markers` Folder for future marker Parts and organization.

The base orientation for every template is rotation `0`.

### Cell-Edge And Connection Rule

The cell boundary is an inclusive limit, not a required visual gap.

- A 1x1 cell spans local X `-2 to 2` and local Z `-2 to 2`.
- Parts may end exactly at `-2` or `2`.
- Parts must never extend beyond `-2` or `2`.
- Conveyor foundations, belts, and outer rails must reach exactly to every connection-facing edge.
- Adjacent connected conveyor pieces therefore touch with no visible gap.
- Path Attachments on connection edges use exact boundary positions such as Z `2` or `-2`, not inset positions such as `1.8`.
- Decorative pieces that do not form a connection may remain inset.
- The Worker Home intentionally remains inset because it is not a conveyor connection piece.

For example, two connected Straight Conveyors have centers 4 studs apart. The first conveyor's output edge and `PathEnd` meet the next conveyor's input edge and `PathStart` at exactly the same world position.

---

## 4. StraightConveyor Template

Exact path:

```text
ReplicatedStorage.Assets.BuildItemTemplates.StraightConveyor
```

Contract:

- Footprint: `1 x 1` cell.
- Input direction at rotation 0: South.
- Output direction at rotation 0: North.
- All visuals must remain inside local X `-2 to 2` and local Z `-2 to 2`.
- The Foundation, Belt, and Rails must reach the South and North cell edges exactly.

### Exact StraightConveyor Visuals

Create these direct children inside `StraightConveyor.Visuals`:

| Name | Class | Size | Position | Rotation | Color RGB | Material |
|---|---|---:|---:|---:|---:|---|
| `Foundation` | Part | `(4, 0.35, 4)` | `(0, 0.175, 0)` | `(0, 0, 0)` | `(55, 60, 65)` | Metal |
| `Belt` | Part | `(2.8, 0.18, 4)` | `(0, 0.44, 0)` | `(0, 0, 0)` | `(24, 24, 27)` | SmoothPlastic |
| `LeftRail` | Part | `(0.3, 0.45, 4)` | `(-1.65, 0.5, 0)` | `(0, 0, 0)` | `(115, 120, 125)` | Metal |
| `RightRail` | Part | `(0.3, 0.45, 4)` | `(1.65, 0.5, 0)` | `(0, 0, 0)` | `(115, 120, 125)` | Metal |
| `DirectionArrow` | Part | `(0.42, 0.08, 1.15)` | `(0, 0.58, 0.15)` | `(0, 0, 0)` | `(255, 220, 40)` | Neon |
| `ArrowHeadLeft` | Part | `(0.28, 0.08, 0.9)` | `(-0.28, 0.58, -0.65)` | `(0, -45, 0)` | `(255, 220, 40)` | Neon |
| `ArrowHeadRight` | Part | `(0.28, 0.08, 0.9)` | `(0.28, 0.58, -0.65)` | `(0, 45, 0)` | `(255, 220, 40)` | Neon |

The two arrow-head Parts should form a clear point toward negative Z. If the point looks reversed, verify the Rotation signs and do not rotate the complete template.

Required Attachments under `Root`:

| Name | Local Position |
|---|---:|
| `PathStart` | `(0, 0.9, 2)` |
| `PathEnd` | `(0, 0.9, -2)` |

The completed conveyor should look like a low metal square with a black belt running South-to-North, silver side rails, and a yellow arrow pointing North.

---

## 5. CornerConveyor Template

Exact path:

```text
ReplicatedStorage.Assets.BuildItemTemplates.CornerConveyor
```

Contract:

- Footprint: `1 x 1` cell.
- Input direction at rotation 0: South.
- Output direction at rotation 0: East.
- All visuals must remain inside local X `-2 to 2` and local Z `-2 to 2`.
- One model supports all turn orientations through 90-degree rotation.
- The South transport surface must reach Z `2`; the East transport surface must reach X `2`.

### Exact CornerConveyor Visuals

Create these direct children inside `CornerConveyor.Visuals`:

| Name | Class | Size | Position | Rotation | Color RGB | Material |
|---|---|---:|---:|---:|---:|---|
| `Foundation` | Part | `(4, 0.35, 4)` | `(0, 0.175, 0)` | `(0, 0, 0)` | `(55, 60, 65)` | Metal |
| `SouthBelt` | Part | `(2.8, 0.18, 2.5)` | `(0, 0.44, 0.75)` | `(0, 0, 0)` | `(24, 24, 27)` | SmoothPlastic |
| `EastBelt` | Part | `(2.5, 0.18, 2.8)` | `(0.75, 0.44, 0)` | `(0, 0, 0)` | `(24, 24, 27)` | SmoothPlastic |
| `SouthLeftRail` | Part | `(0.3, 0.45, 2.5)` | `(-1.65, 0.5, 0.75)` | `(0, 0, 0)` | `(115, 120, 125)` | Metal |
| `SouthRightRail` | Part | `(0.3, 0.45, 1.2)` | `(1.65, 0.5, 1.4)` | `(0, 0, 0)` | `(115, 120, 125)` | Metal |
| `EastTopRail` | Part | `(2.5, 0.45, 0.3)` | `(0.75, 0.5, -1.65)` | `(0, 0, 0)` | `(115, 120, 125)` | Metal |
| `EastBottomRail` | Part | `(1.2, 0.45, 0.3)` | `(1.4, 0.5, 1.65)` | `(0, 0, 0)` | `(115, 120, 125)` | Metal |
| `DirectionArrow` | Part | `(1.15, 0.08, 0.42)` | `(0.15, 0.58, 0)` | `(0, 0, 0)` | `(255, 220, 40)` | Neon |
| `ArrowHeadNorth` | Part | `(0.9, 0.08, 0.28)` | `(0.65, 0.58, -0.28)` | `(0, 45, 0)` | `(255, 220, 40)` | Neon |
| `ArrowHeadSouth` | Part | `(0.9, 0.08, 0.28)` | `(0.65, 0.58, 0.28)` | `(0, -45, 0)` | `(255, 220, 40)` | Neon |

The yellow arrow sits over the center of the turn and points toward local East / positive X.

Required Attachments under `Root`:

| Name | Local Position |
|---|---:|
| `PathStart` | `(0, 0.9, 2)` |
| `PathCorner` | `(0, 0.9, 0)` |
| `PathEnd` | `(2, 0.9, 0)` |

The completed corner should visually accept items from its South edge and turn them toward its East edge.

---

## 6. ConveyorUpgrader Template

Exact path:

```text
ReplicatedStorage.Assets.BuildItemTemplates.ConveyorUpgrader
```

Contract:

- Footprint: `1 x 1` cell.
- Input direction at rotation 0: South.
- Output direction at rotation 0: North.
- All footprint-level visuals must remain inside local X `-2 to 2` and local Z `-2 to 2`.
- Taller posts/beams are allowed vertically.
- Its Foundation, Belt, and Rails must reach the South and North cell edges exactly.

### Exact ConveyorUpgrader Visuals

Create these direct children inside `ConveyorUpgrader.Visuals`:

| Name | Class | Size | Position | Rotation | Color RGB | Material |
|---|---|---:|---:|---:|---:|---|
| `Foundation` | Part | `(4, 0.35, 4)` | `(0, 0.175, 0)` | `(0, 0, 0)` | `(40, 70, 90)` | Metal |
| `Belt` | Part | `(2.8, 0.18, 4)` | `(0, 0.44, 0)` | `(0, 0, 0)` | `(24, 24, 27)` | SmoothPlastic |
| `LeftRail` | Part | `(0.3, 0.45, 4)` | `(-1.65, 0.5, 0)` | `(0, 0, 0)` | `(90, 145, 170)` | Metal |
| `RightRail` | Part | `(0.3, 0.45, 4)` | `(1.65, 0.5, 0)` | `(0, 0, 0)` | `(90, 145, 170)` | Metal |
| `LeftPost` | Part | `(0.4, 2.8, 0.4)` | `(-1.55, 1.75, 0)` | `(0, 0, 0)` | `(45, 95, 120)` | Metal |
| `RightPost` | Part | `(0.4, 2.8, 0.4)` | `(1.55, 1.75, 0)` | `(0, 0, 0)` | `(45, 95, 120)` | Metal |
| `TopBeam` | Part | `(3.5, 0.4, 0.4)` | `(0, 3.15, 0)` | `(0, 0, 0)` | `(45, 95, 120)` | Metal |
| `EnergyBeam` | Part | `(3.0, 0.12, 0.12)` | `(0, 1.4, 0)` | `(0, 0, 0)` | `(0, 225, 255)` | Neon |
| `DirectionArrow` | Part | `(0.42, 0.08, 1.15)` | `(0, 0.58, 0.55)` | `(0, 0, 0)` | `(255, 220, 40)` | Neon |
| `ArrowHeadLeft` | Part | `(0.28, 0.08, 0.9)` | `(-0.28, 0.58, -0.25)` | `(0, -45, 0)` | `(255, 220, 40)` | Neon |
| `ArrowHeadRight` | Part | `(0.28, 0.08, 0.9)` | `(0.28, 0.58, -0.25)` | `(0, 45, 0)` | `(255, 220, 40)` | Neon |

The cyan `EnergyBeam` crosses above the belt at the `EffectPoint`. It must not block the yellow travel arrow.

Required Attachments under `Root`:

| Name | Local Position |
|---|---:|
| `PathStart` | `(0, 0.9, 2)` |
| `EffectPoint` | `(0, 0.9, 0)` |
| `PathEnd` | `(0, 0.9, -2)` |

The completed Upgrader should read as a Straight Conveyor passing through a cyan energy gate.

---

## 7. ConveyorCollectionBin Template

Exact path:

```text
ReplicatedStorage.Assets.BuildItemTemplates.ConveyorCollectionBin
```

Contract:

- Footprint: `1 x 1` cell.
- Input direction at rotation 0: South.
- No output connector.
- All physical bin visuals must remain inside local X `-2 to 2` and local Z `-2 to 2`.
- Leave the local East side visually readable as the future automation-worker side.
- The Foundation, side walls, and low front lip reach the cell edges so the bin meets its incoming conveyor cleanly.

### Exact ConveyorCollectionBin Visuals

Create these direct children inside `ConveyorCollectionBin.Visuals`:

| Name | Class | Size | Position | Rotation | Color RGB | Material |
|---|---|---:|---:|---:|---:|---|
| `Foundation` | Part | `(4, 0.35, 4)` | `(0, 0.175, 0)` | `(0, 0, 0)` | `(80, 52, 30)` | WoodPlanks |
| `BinFloor` | Part | `(3.2, 0.25, 3.2)` | `(0, 0.48, 0)` | `(0, 0, 0)` | `(120, 76, 40)` | WoodPlanks |
| `LeftWall` | Part | `(0.3, 1.8, 4)` | `(-1.85, 1.35, 0)` | `(0, 0, 0)` | `(120, 76, 40)` | WoodPlanks |
| `RightWall` | Part | `(0.3, 1.8, 4)` | `(1.85, 1.35, 0)` | `(0, 0, 0)` | `(120, 76, 40)` | WoodPlanks |
| `BackWall` | Part | `(3.4, 1.8, 0.3)` | `(0, 1.35, -1.85)` | `(0, 0, 0)` | `(120, 76, 40)` | WoodPlanks |
| `FrontLip` | Part | `(3.4, 0.65, 0.4)` | `(0, 0.78, 1.8)` | `(0, 0, 0)` | `(120, 76, 40)` | WoodPlanks |
| `BinGlow` | Part | `(2.7, 0.08, 2.7)` | `(0, 0.64, -0.1)` | `(0, 0, 0)` | `(255, 185, 70)` | Neon |

Set `BinGlow.Transparency = 0.55`. It provides a visible storage area without filling the bin.

Required Attachments under `Root`:

| Name | Local Position |
|---|---:|
| `PathStart` | `(0, 1, 2)` |
| `StorePoint` | `(0, 1, 0)` |
| `AutomationStand` | `(3, 0, 0)` |

`AutomationStand` intentionally sits outside the physical 1x1 footprint. It is only a future worker destination and must not have a visible or collidable Part.

No `DirectionArrow` is required on the Collection Bin.

The completed bin must have a low open South/front edge so arriving resources visibly enter it.

---

## 8. WorkerHome Template

Exact path:

```text
ReplicatedStorage.Assets.BuildItemTemplates.WorkerHome
```

Contract:

- Footprint: `1 x 1` cell.
- Maximum footprint-level visual size: approximately `(3.5, any height, 3.5)`.
- Leave visible padding between the home and the edges of the 4x4 cell.
- This is the standalone home for general Wood, Stone, and Coal NPCs.

### Exact WorkerHome Visuals

Create these direct children inside `WorkerHome.Visuals`:

| Name | Class | Size | Position | Rotation | Color RGB | Material |
|---|---|---:|---:|---:|---:|---|
| `Foundation` | Part | `(3.5, 0.3, 3.5)` | `(0, 0.15, 0)` | `(0, 0, 0)` | `(95, 62, 35)` | WoodPlanks |
| `BackWall` | Part | `(3.2, 2.2, 0.25)` | `(0, 1.4, 1.45)` | `(0, 0, 0)` | `(140, 92, 50)` | WoodPlanks |
| `LeftWall` | Part | `(0.25, 2.2, 2.8)` | `(-1.48, 1.4, 0.05)` | `(0, 0, 0)` | `(140, 92, 50)` | WoodPlanks |
| `RightWall` | Part | `(0.25, 2.2, 2.8)` | `(1.48, 1.4, 0.05)` | `(0, 0, 0)` | `(140, 92, 50)` | WoodPlanks |
| `Roof` | Part | `(3.5, 0.35, 3.5)` | `(0, 2.68, 0)` | `(0, 0, 0)` | `(145, 48, 38)` | Brick |
| `BedBase` | Part | `(1.25, 0.35, 2.1)` | `(0.75, 0.48, 0.45)` | `(0, 0, 0)` | `(75, 48, 30)` | WoodPlanks |
| `BedCover` | Part | `(1.15, 0.18, 1.45)` | `(0.75, 0.74, 0.6)` | `(0, 0, 0)` | `(70, 130, 190)` | Fabric |
| `Pillow` | Part | `(1.0, 0.18, 0.42)` | `(0.75, 0.75, -0.25)` | `(0, 0, 0)` | `(235, 235, 225)` | Fabric |
| `HomeSign` | Part | `(1.5, 0.65, 0.15)` | `(0, 2.0, -1.53)` | `(0, 0, 0)` | `(230, 185, 85)` | Wood |

The open side faces local North / negative Z. `WorkerStand` at the Root is the position where the worker returns; keep the center floor clear around that point.

Required Attachment under `Root`:

| Name | Local Position |
|---|---:|
| `WorkerStand` | `(0, 0, 0)` |

No `DirectionArrow` is required.

---

## 9. ConveyorDropper Template

Exact path:

```text
ReplicatedStorage.Assets.BuildItemTemplates.ConveyorDropper
```

Contract:

- Footprint: `3 x 1` cells.
- `Root` is the center of local cell 1.
- The footprint extends toward local East / positive X.
- Local cell centers are:
  - Cell 1, automation area: `(0, 0, 0)`
  - Cell 2, dropper base: `(4, 0, 0)`
  - Cell 3, shared output socket: `(8, 0, 0)`
- Input connector: none.
- Output direction at rotation 0: East.
- A Straight Conveyor will be allowed to share local cell 3.
- Do not place large solid Dropper visuals in local cell 3 that would obscure an overlapping Straight Conveyor.

Allowed footprint bounds:

- Local X: `-2 to 10`
- Local Z: `-2 to 2`

### Exact ConveyorDropper Visuals

Create these direct children inside `ConveyorDropper.Visuals`:

| Name | Class | Size | Position | Rotation | Color RGB | Material |
|---|---|---:|---:|---:|---:|---|
| `AutomationPad` | Part | `(3.5, 0.3, 3.5)` | `(0, 0.15, 0)` | `(0, 0, 0)` | `(95, 62, 35)` | WoodPlanks |
| `AutomationRing` | Part, Shape `Cylinder` | `(0.12, 2.6, 2.6)` | `(0, 0.38, 0)` | `(0, 0, 90)` | `(255, 185, 70)` | Neon |
| `DropperFoundation` | Part | `(4, 0.35, 4)` | `(4, 0.175, 0)` | `(0, 0, 0)` | `(55, 60, 65)` | Metal |
| `DropperBody` | Part | `(2.8, 2.2, 2.8)` | `(4, 1.45, 0)` | `(0, 0, 0)` | `(75, 85, 95)` | Metal |
| `TopHopper` | Part | `(3.4, 0.7, 3.4)` | `(4, 2.9, 0)` | `(0, 0, 0)` | `(105, 115, 125)` | Metal |
| `HopperOpening` | Part | `(2.5, 0.08, 2.5)` | `(4, 3.29, 0)` | `(0, 0, 0)` | `(20, 20, 22)` | SmoothPlastic |
| `RaisedChute` | Part | `(3.2, 0.7, 1.4)` | `(6.55, 2.0, 0)` | `(0, 0, -12)` | `(85, 95, 105)` | Metal |
| `OutputNozzle` | Part | `(0.7, 1.0, 1.4)` | `(7.9, 1.45, 0)` | `(0, 0, 0)` | `(105, 115, 125)` | Metal |
| `DirectionArrow` | Part | `(1.3, 0.08, 0.42)` | `(7.25, 2.42, 0)` | `(0, 0, 0)` | `(255, 220, 40)` | Neon |
| `ArrowHeadNorth` | Part | `(0.9, 0.08, 0.28)` | `(7.85, 2.42, -0.28)` | `(0, 45, 0)` | `(255, 220, 40)` | Neon |
| `ArrowHeadSouth` | Part | `(0.9, 0.08, 0.28)` | `(7.85, 2.42, 0.28)` | `(0, -45, 0)` | `(255, 220, 40)` | Neon |

For `AutomationRing`, insert a normal `Part`, set `Shape = Cylinder`, then use the listed Size, Position, and Rotation.

Critical output-socket clearance rule:

- In local cell 3, X `6 to 10`, do not add any visual Part below Y `1.1`.
- `OutputNozzle` ends above the conveyor item path.
- Do not add a floor, belt, foundation, rail, or worker pad at local position `(8, 0, 0)`.
- A complete Straight Conveyor template must be able to overlap cell 3 without visual collision.

Required Attachments under `Root`:

| Name | Local Position |
|---|---:|
| `AutomationStand` | `(0, 0, 0)` |
| `DropPoint` | `(5.5, 1.2, 0)` |
| `PathStart` | `(6, 0.9, 0)` |

The completed Dropper should read left-to-right as worker automation pad, Dropper machine, then a raised output chute above the shared Straight Conveyor socket.

---

## 10. Objects That Must Not Be Deleted Yet

Keep all of these intact:

```text
ReplicatedStorage.Assets.PlotTemplate.Machine
ReplicatedStorage.Assets.PlotTemplate.WorkerHomes
ReplicatedStorage.Assets.PlotTemplate.WorkerApproachPoints
ReplicatedStorage.Assets.WorkerTemplates
```

Also keep:

- Every current `MachinePart` CollectionService tag.
- Every current machine attribute.
- Every current machine marker and interaction Part.
- Existing fixed worker-home Models.
- Existing storage, sell crate, NPC purchase pad, and player spawn objects.
- Old plot template versions such as `PlotTemplateV4` or `PlotTemplateV5`.

Only the active `ReplicatedStorage.Assets.PlotTemplate` receives the new `BuildGrid`.

---

## 11. Final Explorer Hierarchy Check

The relevant final hierarchy must look exactly like:

```text
ReplicatedStorage
  Assets
    BuildItemTemplates
      ConveyorDropper
        Root
          AutomationStand
          DropPoint
          PathStart
        Visuals
          AutomationPad
          AutomationRing
          DropperFoundation
          DropperBody
          TopHopper
          HopperOpening
          RaisedChute
          OutputNozzle
          DirectionArrow
          ArrowHeadNorth
          ArrowHeadSouth
        Markers
      StraightConveyor
        Root
          PathStart
          PathEnd
        Visuals
          Foundation
          Belt
          LeftRail
          RightRail
          DirectionArrow
          ArrowHeadLeft
          ArrowHeadRight
        Markers
      CornerConveyor
        Root
          PathStart
          PathCorner
          PathEnd
        Visuals
          Foundation
          SouthBelt
          EastBelt
          SouthLeftRail
          SouthRightRail
          EastTopRail
          EastBottomRail
          DirectionArrow
          ArrowHeadNorth
          ArrowHeadSouth
        Markers
      ConveyorUpgrader
        Root
          PathStart
          EffectPoint
          PathEnd
        Visuals
          Foundation
          Belt
          LeftRail
          RightRail
          LeftPost
          RightPost
          TopBeam
          EnergyBeam
          DirectionArrow
          ArrowHeadLeft
          ArrowHeadRight
        Markers
      ConveyorCollectionBin
        Root
          PathStart
          StorePoint
          AutomationStand
        Visuals
          Foundation
          BinFloor
          LeftWall
          RightWall
          BackWall
          FrontLip
          BinGlow
        Markers
      WorkerHome
        Root
          WorkerStand
        Visuals
          Foundation
          BackWall
          LeftWall
          RightWall
          Roof
          BedBase
          BedCover
          Pillow
          HomeSign
        Markers
    PlotTemplate
      BuildGrid
        Bounds
        Blockers
          WorkerHomes
          LegacyMachine
          NPCPurchasePad
          StorageArea
          SellCrate
          PlayerSpawn
        PlacedItems
        RuntimeItems
      Machine
      WorkerHomes
      WorkerApproachPoints
```

Every visual named above is required. Extra decorative BaseParts under each `Visuals` Folder are allowed only when they remain inside the stated footprint and do not interfere with marker paths or the Dropper output socket.

---

## 12. Final Verification Checklist

Do not confirm completion until every item passes.

### Plot And Grid

- [ ] One duplicate `Plot08` was renamed to `Plot09`; all ten spawn names are unique.
- [ ] The new hierarchy is under the active `ReplicatedStorage.Assets.PlotTemplate`, not an old template version.
- [ ] `BuildGrid.Bounds` is exactly at `(0, 0.05, 0)` with Size `(80, 0.1, 80)`.
- [ ] `Bounds` has tag `BuildGridBounds`.
- [ ] `Bounds` has Number Attribute `CellSize = 4`.
- [ ] All six blockers exist with exact names, positions, sizes, and tag `BuildGridBlocker`.
- [ ] All grid Parts are anchored, invisible, non-colliding, non-touchable, and non-queryable.
- [ ] `PlacedItems` is an empty Folder.
- [ ] `RuntimeItems` is an empty Folder.

### Templates

- [ ] `BuildItemTemplates` contains exactly the six required template Models.
- [ ] Every template has tag `BuildItemTemplate`.
- [ ] Every template has the correct String Attribute `BuildItemId`.
- [ ] Every template has Number Attribute `TemplateVersion = 1`.
- [ ] Every template has a direct `Root`, `Visuals`, and `Markers` child.
- [ ] Every template's `PrimaryPart` is its `Root`.
- [ ] Every template pivot exactly matches its `Root`.
- [ ] Every `Root` is at `(0, 0, 0)`, rotation `(0, 0, 0)`, and is invisible/non-colliding.
- [ ] Every required Attachment exists directly under its template's `Root`.
- [ ] Every required Attachment has the exact local Position listed above.
- [ ] Every required visual Part listed in sections 4-9 and the final hierarchy exists with the exact Class/Shape, Size, Position, Rotation, Color, and Material.
- [ ] Every visual BasePart is anchored.
- [ ] Every visual BasePart has `CanCollide`, `CanTouch`, and `CanQuery` set to `false`.
- [ ] Straight, Corner, Upgrader, and Dropper each have `Visuals.DirectionArrow`.
- [ ] Every arrow matches its template's base output direction.
- [ ] Every 1x1 physical model fits within one 4x4 cell.
- [ ] Dropper physical visuals fit within its 3x1 footprint and leave the output socket usable.
- [ ] Existing Machine, WorkerHomes, WorkerApproachPoints, and WorkerTemplates still exist.

### Manual Visual Check

- [ ] Temporarily set `Bounds` Transparency to `0.75`; confirm it covers the Ground exactly, then restore it to `1`.
- [ ] Temporarily set blocker Transparency to `0.5`; confirm each permanent object is covered, then restore all blockers to `1`.
- [ ] Rotate a duplicate of each template by `90`, `180`, and `270` degrees; confirm pivots remain centered and arrows rotate correctly.
- [ ] Delete all temporary duplicates after the visual check.

After all checks pass, save the place and confirm that the world changes are complete. Source implementation must wait for that confirmation.
