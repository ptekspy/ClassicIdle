# ClassicIdle Codebase Snapshot 006: MVP Conveyor Machine

**Snapshot date:** 2026-06-12
**Repository state:** `main`, persisted conveyor-machine implementation complete and pending snapshot commit
**Previous snapshot:** `005_PERSISTENT_NPC_WORKERS.md`
**Scope:** Source files, world-change contract, and live Studio smoke validation of the server-authoritative conveyor Coal-production system.

## Executive Summary

This snapshot records the replacement of both previous Coal-production paths, the manual Coal Processor interaction and the Coal Processor NPC, with one persisted conveyor machine:

```text
Storage Bin
  -> Conveyor 1
  -> Upgrader 1
  -> Coal Processor
  -> Conveyor 2
  -> Upgrader 2
  -> Collection Point
```

Wood and Stone NPC behavior remains intact. Owning the first Stone NPC now unlocks Conveyor 1 for purchase. The remaining machine parts unlock one-by-one in strict flow order, and production does not begin until all six parts are built.

The server owns purchases, upgrades, input withdrawal, visible resource-piece movement, processing, output multiplication, Collection Point storage, and collection. Machine work is persisted and paused when the player leaves, then reconstructed and resumed when they rejoin.

The Collection Point differs from the original fixed-capacity MVP plan: it is now upgradeable. Capacity starts at 50 weighted Coal and increases by 25 per level.

The datastore name changed from `IdleGame_PlayerData_v6` to `IdleGame_PlayerData_v7`. Existing persistent-NPC profiles are intentionally not migrated.

## Snapshot Inventory

### First-Party Code

- 44 Luau files outside `src/ReplicatedStorage/Packages`
- Approximately 4,249 lines of first-party Luau
- 12 service modules, including new `MachineService`
- 3 client controllers, including new `MachineController`
- Shared Machine, Plot, Worker, and Interaction contracts
- 6 managed RemoteEvents: `FeedbackEvent`, `InteractionRequest`, `WorkerMenu`, `WorkerRequest`, `MachineMenu`, and `MachineRequest`
- No automated tests

Snapshot 005 contained 40 first-party Luau files and approximately 3,382 lines. This milestone adds the machine data model, configuration, runtime service, management UI, dynamic interactions, and integration changes while removing Coal NPC and manual Coal-processing behavior.

## World Contract

`WORLD_CHANGES.md` records the exact Studio-only authoring contract. The machine is authored under:

```text
ReplicatedStorage.Assets
  PlotTemplate
    Machine
      RuntimePieces
      Markers
      Conveyor1
      Upgrader1
      CoalProcessor
      Conveyor2
      Upgrader2
      CollectionPoint
```

Each machine model has an `InteractionPart`. Authored attachments and markers define the complete route from the Storage Bin through processing to the Collection Point. All machine parts and runtime resource pieces are anchored.

Runtime code changes authored models between these presentation states:

- `Locked`: hidden and non-interactable
- `Preview`: ghosted and purchasable when it is the next part
- `Built`: visible and manageable
- `Active`: visible and participating in a complete chain

The old `WorkerTemplates.CoalProcessor` and `WorkerApproachPoints.CoalProcessor` objects may remain in Studio temporarily, but source code no longer references them.

Plot assets and the authored machine route remain Studio-only and cannot be recreated from source alone.

## Persistent Data And Economy

### Machine Data

`PlayerData` now includes a persisted `Machine` record containing:

- Built state and upgrade levels for all six machine parts
- Processor Wood and Stone multiplier buffers
- Processor pending output multiplier
- Processor remaining processing time
- Moving and waiting resource-piece records
- Collection Point stored weighted Coal
- Remaining input-dispatch time

Each persisted resource piece contains:

- Stable generated ID
- Resource type
- Amount
- Current multiplier
- Current path stage
- Normalized path progress

The server updates persisted progress while the player is present. On cleanup, unfinished work remains in player data without offline progress. On the next setup, visual pieces are reconstructed from those records and resume from their saved stages.

### Economy Ownership

`EconomyService` remains the authority for:

- Spending Gold
- Reading and mutating storage resources
- Enforcing shared storage capacity
- Transferring Collection Point Coal into player storage

`MachineService` owns machine-specific costs, multipliers, capacity calculations, processing, and progression.

Coal and Gold leaderstats now use `NumberValue` so weighted fractional Coal and fractional values remain representable.

## Progression And Upgrades

The build order is fixed:

```text
Conveyor1
  -> Upgrader1
  -> CoalProcessor
  -> Conveyor2
  -> Upgrader2
  -> CollectionPoint
```

- Conveyor 1 becomes a purchasable preview after the player owns a Stone NPC.
- Buying Conveyor 1 reveals all remaining machine ghosts.
- Only the next unbuilt part in flow order is purchasable.
- Built upgradeable parts can be upgraded before the full chain is complete.
- The machine becomes active only after all six parts are built.

Initial tuning:

| Setting | Value |
| --- | ---: |
| Conveyor 1 purchase | 100 Gold |
| Upgrader 1 purchase | 150 Gold |
| Coal Processor purchase | 250 Gold |
| Conveyor 2 purchase | 200 Gold |
| Upgrader 2 purchase | 300 Gold |
| Collection Point purchase | 400 Gold |
| Conveyor starting speed | 6 studs/second |
| Conveyor speed per level | +1.5 studs/second |
| Upgrader starting multiplier | x2 |
| Upgrader multiplier per level | +0.5 |
| Processor starting duration | 4 seconds |
| Processor duration per level | -0.5 seconds, minimum 1 second |
| Processor starting output multiplier | x1.5 |
| Processor output multiplier per level | +0.25 |
| Collection Point starting capacity | 50 weighted Coal |
| Collection Point capacity per level | +25 weighted Coal |
| Input dispatch interval | 1 second |

Upgrade cost is the relevant part's purchase cost multiplied by the current upgrade level. The processor exposes separate duration and output-multiplier upgrade paths.

## Machine Runtime

`MachineService` is the server-side registry and orchestrator for each player's live machine.

### Setup And Cleanup

On setup, the service:

1. Reads and normalizes persisted machine data.
2. Resolves the authored machine models and path markers.
3. Applies locked, preview, built, or active presentation.
4. Registers appropriate dynamic interactions.
5. Reconstructs visual resource pieces.
6. Starts the player's Heartbeat-driven machine runtime.

On cleanup, the service stops runtime updates, unregisters dynamic targets, and destroys reconstructed resource visuals. Persisted machine work remains paused in player data.

### Input Dispatch

One Wood or Stone is withdrawn from storage only when its persisted moving-piece record is successfully created.

Dispatch counts the processor's buffered inputs and all matching in-flight pieces. It creates only ingredients still needed by the current recipe:

```text
2 Wood + 1 Stone
```

This prevents the processor from accumulating an unbounded ingredient buffer. If downstream production is blocked by a full Collection Point, no additional inputs are dispatched.

### Visible Resource Pieces

The server creates anchored visible resource Parts and moves them along authored markers using Heartbeat updates. Each visual exposes inspection attributes:

- `ResourceType`
- `Amount`
- `Multiplier`
- `PieceStage`

Persisted server data remains authoritative if a visual is removed or altered.

Piece stages are:

- `InputConveyor`
- `InputUpgrader`
- `OutputConveyor`
- `OutputUpgrader`
- `CollectionWait`

Active pieces use the current conveyor speed, so a speed upgrade affects pieces already in motion.

### Processing And Multiplication

Upgrader 1 multiplies each Wood or Stone piece once as it passes through. The processor stores Wood and Stone multipliers separately until it has two Wood and one Stone.

When processing begins:

1. The exact buffered ingredients are removed.
2. Processing duration is persisted.
3. Pending output multiplier is persisted as:

```text
sum(consumed input multipliers) * processor output multiplier
```

4. One Coal piece is created after the timer completes.

Upgrader 2 multiplies the Coal piece's current multiplier once as it passes through.

### Collection Point

The Collection Point receives the complete weighted Coal value:

```text
Amount * Multiplier
```

A Coal piece deposits only when its complete value fits. If it does not fit, the piece remains safely in `CollectionWait` and downstream production pauses.

Interacting with the built Collection Point opens management controls. The player can:

- Collect as much stored weighted Coal as fits in shared player storage
- Leave any remainder in the Collection Point
- Upgrade Collection Point capacity

## Existing-System Integration

### Workers And Unlocks

`WorkerTypes.Role` is now limited to:

```luau
"Wood" | "Stone"
```

Coal Processor worker purchase, management, spawning, and work-loop behavior were removed. Wood and Stone workers retain their existing finite-node reservations, movement, upgrades, cargo persistence, and storage deposits.

`UnlockService` now treats owning a Stone NPC as the machine progression prerequisite instead of unlocking manual Coal processing.

### Interactions

The manual `ProcessCoal` interaction was removed.

`InteractionService` now exposes reusable runtime target registration and unregistration. `MachineService` uses these helpers to switch ghost purchases and built-part management interactions as progression changes.

Server-side request handling validates ownership, proximity, action type, progression state, current levels, and affordability before applying a purchase, upgrade, collection, or management action.

### UI And Display

`MachineController` follows the existing Worker menu pattern and handles `MachineMenu` payloads and `MachineRequest` actions.

Built machine parts display status and relevant levels. The Collection Point displays stored weighted Coal and current capacity. Fractional Coal is formatted without forcing integer output.

`WorldService` now delegates machine setup, interaction routing, unlock refresh, and cleanup to `MachineService`.

## Changes Since Snapshot 005

### Resolved Or Materially Improved

| Snapshot 005 state | Snapshot 006 status |
| --- | --- |
| Coal Processor NPC performed visible ingredient trips | Replaced by persisted visible conveyor resource pieces |
| Manual Coal processing remained available | Removed; the complete machine is the only Coal-production path |
| First Stone NPC unlocked Coal NPC and manual processing | First Stone NPC unlocks Conveyor 1 |
| Coal output went directly into shared storage | Weighted Coal waits in an upgradeable Collection Point |
| Coal recipe used one fixed output amount | Two upgraders and processor output upgrades combine persisted multipliers |
| Worker interactions were the only dynamic targets | Machine previews and built parts use reusable dynamic registration |
| Datastore used `IdleGame_PlayerData_v6` | Bumped to `IdleGame_PlayerData_v7` |

### Still Open

| Earlier finding | Current status |
| --- | --- |
| Plot assets and spawn layout are Studio-only | Still open; now includes the complete machine hierarchy and route |
| No automated gameplay or lifecycle tests | Still open and now covers persisted machine processing |
| Existing profile values are not fully validated | Partially improved by machine normalization; malformed profile risk remains |
| RemoteManager has weak static types | Still open and now covers six gameplay events |
| Gamepad and touch require device-emulation testing | Still open |
| Interaction line-of-sight validation is absent | Still open |

## Priority Findings

### P1: The Complete Production Loop Needs A Dedicated Multiplayer Playtest

Studio smoke validation confirmed that plots clone, all six machine parts initialize, and the processor model resolves with its corrected PrimaryPart. Configuration calculations and startup behavior were also validated.

The complete player-facing sequence has not yet been manually exercised end-to-end:

```text
Stone NPC unlock
  -> six purchases
  -> upgrades
  -> dispatch
  -> processing
  -> Collection Point full behavior
  -> partial collection
  -> leave and rejoin
```

This should be tested with multiple players before considering the milestone production-ready.

### P1: Machine World Assets Remain Outside Source Control

The source tree contains the required contract and validation logic, but the authored `PlotTemplate.Machine` models, markers, attachments, and route geometry exist only in Studio.

An incorrect marker name or modified model hierarchy can disable production despite a clean source checkout.

### P1: No Automated Machine Or Economy Tests Exist

The multiplier formula, exact-once upgrader behavior, recipe buffering, collection capacity, and persisted reconstruction are high-value regression targets. The repository still has no automated Luau test harness.

### P2: Runtime Cost Scales Per Player And Per Piece

Each active player machine owns a Heartbeat connection and updates persisted piece progress continuously while pieces move. This is acceptable for the MVP, but should be profiled with realistic server population and piece counts.

### P2: Machine Tuning And Authored Attributes Can Drift

Runtime tuning comes from `Machine/Config.luau`. Some authored attributes and world-document values also describe costs and capacity. These parallel representations can drift unless one source is treated as documentation-only or validated against runtime config.

### P2: Interaction Requests Still Lack Line-Of-Sight Validation

Proximity and ownership checks are server-authoritative, but a nearby player can still interact through obstructing geometry. The new machine interactions inherit this earlier limitation.

## Verification Notes

Completed validation for this snapshot:

- `git diff --check`
- Targeted Selene validation with zero errors
- Targeted StyLua validation for new machine files
- Argon project build
- Studio source sync and server boot smoke test
- Plot cloning and machine hierarchy resolution
- All six machine parts initialized in `Locked` state
- Coal Processor PrimaryPart resolves to `InteractionPart`
- Collection Point capacity calculation: level 1 = 50, level 2 = 75
- Conveyor speed calculation: level 2 = 7.5
- Upgrader multiplier calculation: level 2 = 2.5
- Processor duration calculation: level 2 = 3.5 seconds
- Processor output multiplier calculation: level 2 = 1.75
- Example complete-output calculation = 21 weighted Coal

Validation caveats:

- Selene retains one pre-existing deprecated-API warning in `WorkerService`.
- Argon reports the existing missing top-level `Packages` and `ServerPackages` path warnings.
- The complete purchase-to-production multiplayer loop was not manually played through.
- Touch and gamepad interaction behavior was not tested.

## Recommended Next Steps

1. Run the complete multiplayer machine test matrix, including leave/rejoin during every piece stage and processor timing.
2. Add automated tests around machine config calculations, recipe buffering, exact-once upgrades, and Collection Point transfers.
3. Add server-side interaction line-of-sight validation.
4. Profile Heartbeat and persisted-progress mutation cost under realistic player and piece counts.
5. Decide how Studio-authored machine assets will be versioned or reproducibly exported.
