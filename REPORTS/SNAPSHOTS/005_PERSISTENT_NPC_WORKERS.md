# ClassicIdle Codebase Snapshot 005: Persistent NPC Workers

**Snapshot date:** 2026-06-11
**Repository state:** `main`, persistent NPC worker implementation complete and pending snapshot commit
**Previous snapshot:** `004_CUSTOM_INTERACTIONS.md`
**Scope:** Source files, world-change contract, and live Studio validation of persistent NPC purchasing, movement, collection, processing, upgrading, storage behavior, and cleanup.

## Executive Summary

This snapshot records the replacement of the fixed AutoChopper, AutoMiner, and AutoProcessor loops with persistent physical NPC workers.

Players now hire Wood, Stone, and Coal Processor NPCs from one purchase pad. Each NPC is represented by a persistent player-data record with its own role, home slot, speed level, amount level, and carried cargo. The server clones the matching worker template, moves it through the plot, performs the assigned work, and deposits output into shared storage.

Wood and Stone NPCs reserve and collect finite resources from the plot's Tree and Rock. Manual collection uses the same finite-node state. Depleted nodes become semi-transparent, display a respawn progress bar, and refill using their authored capacity and respawn attributes.

Coal Processor NPCs visibly travel between storage and the processor to represent separate ingredient-fetch trips, consume one recipe atomically, carry Coal, and return it to storage. Live validation found that direct `Humanoid:MoveTo` could not reliably route around the processor collision, so worker movement now uses `PathfindingService` waypoints with direct movement as a fallback.

The datastore name changed from `IdleGame_PlayerData_v5` to `IdleGame_PlayerData_v6`. Existing fixed-machine profiles are intentionally not migrated.

## Snapshot Inventory

### First-Party Code

- 40 Luau files outside `src/ReplicatedStorage/Packages`
- Approximately 3,382 lines of first-party Luau
- 11 service modules, including new `ResourceNodeService` and expanded `WorkerService`
- 2 client controllers: `InteractionController` and new `WorkerController`
- Shared Plot, Worker, and Interaction contracts
- 4 managed RemoteEvents: `FeedbackEvent`, `InteractionRequest`, `WorkerMenu`, and `WorkerRequest`
- No automated tests

Snapshot 004 contained 29 first-party Luau files and approximately 2,399 lines. This milestone adds the worker/resource architecture, plot-contract helpers, purchase/upgrade UI, and lifecycle orchestration while removing the old fixed-machine loops and helpers.

## World Contract

`WORLD_CHANGES.md` records the required Studio-only world changes. The live template now provides:

```text
ReplicatedStorage.Assets
  PlotTemplate
    NPCPurchasePad
    WorkerHomes
      Home01 ... Home08
    WorkerApproachPoints
      Tree
      Rock
      StorageBin
      CoalProcessor
    Tree
    Rock
    StorageBin
    CoalProcessor
  WorkerTemplates
    Wood
    Stone
    CoalProcessor
```

The authored worker homes are Models rather than invisible marker Parts. Runtime code intentionally uses each home Model's X/Z pivot and places the NPC on the cloned plot's ground height.

The Tree and Rock expose authored `ResourceType`, `Capacity`, and `RespawnSeconds` attributes. Runtime code respects these per-node overrides:

- Tree: Wood, capacity 10, respawn 5 seconds
- Rock: Stone, capacity 25, respawn 10 seconds

The three worker-template `Animate` scripts were disabled in Studio after live testing showed that enabled template scripts generated infinite-yield warnings before workers spawned.

## Persistent Data And Economy

### Player Data

The fixed fields `AutoChopperLevel`, `AutoMinerLevel`, and `AutoProcessorLevel` were replaced by:

```luau
NPCs: { [string]: NPCData }
```

Each NPC record persists:

- Stable generated ID
- Role
- Assigned home slot
- Speed level
- Amount level
- Cargo type
- Cargo amount

Persistent cargo prevents collected or processed resources from being silently lost when storage is full or the player leaves.

### Worker Progression

- Wood NPCs are initially available.
- Owning a Wood NPC unlocks Stone NPCs and manual Rock collection.
- Owning a Stone NPC unlocks Coal Processor NPCs and manual Coal processing.
- Purchase cost is role base cost multiplied by the next owned role count.
- Upgrade cost is role base cost multiplied by the current stat level.
- Speed starts at 10 and increases by 2 per level.
- Wood/Stone amount controls collection quantity.
- Coal amount controls carried Coal capacity.

### Storage

`EconomyService` remains the source of truth for storage capacity and resource mutation. Worker deposits use the same accepted-amount logic as other resource additions.

Workers stop collecting when storage is full, retain existing cargo, wait at the StorageBin approach point, and resume after space becomes available.

## Resource Node Architecture

`ResourceNodeService` owns server-authoritative finite-node state per cloned plot.

For each node it tracks:

- Resource type
- Capacity
- Available amount
- Reserved amount
- Respawn token
- Original part transparencies

Wood and Stone workers reserve an amount before travelling. Reservations allow multiple same-role workers to share a node while preventing them from over-collecting its remaining amount.

Manual collection consumes unreserved node availability through the same service. When a node reaches zero:

1. The node's parts become at least 50% transparent.
2. A BillboardGui progress bar appears.
3. The node refills after its configured respawn duration.
4. Original transparency is restored.
5. The completed progress bar remains visible for one second and then hides.

Plot cleanup invalidates respawn tasks and removes resource-node tags.

## Worker Runtime

`WorkerService` is now the live server registry for spawned NPCs.

### Spawn And Lifecycle

On player setup:

1. Saved NPC records are read from player data.
2. Matching templates are cloned into the player's plot.
3. Each NPC is placed at its assigned authored home.
4. Server network ownership and calculated movement speed are applied.
5. The NPC is tagged as a dynamic interactable.
6. Its work loop starts.

Player cleanup stops every worker loop and destroys runtime models before plot and profile release.

### Runtime State

NPC models expose their current state and cargo through attributes for inspection:

- `Idle`
- `FindingWork`
- `Moving`
- `CollectingOrProcessing`
- `MovingToStorage`
- `Depositing`
- `WaitingForStorageSpace`

### Wood And Stone Loop

```text
Find nearest matching resource node
  -> reserve available amount
  -> navigate to authored node approach point
  -> play action animation
  -> collect reserved amount into persistent cargo
  -> navigate to storage
  -> deposit accepted amount
  -> repeat
```

If movement or the node becomes invalid, the reservation is released and the worker retries later.

### Coal Processor Loop

```text
Wait for recipe and storage room
  -> storage trip representing Wood fetch
  -> processor trip
  -> storage trip representing Stone fetch
  -> processor trip
  -> atomically consume recipe
  -> play processing animation
  -> carry Coal
  -> deposit when carry capacity is reached or work cannot continue
```

Recipe ingredients are consumed together at the processor. Interrupted movement therefore does not delete ingredients.

### Navigation

Worker movement uses `PathfindingService` with humanoid waypoints and direct `Humanoid:MoveTo` fallback.

The implementation originally used direct movement only. Live Coal-worker validation showed the authored processor approach point was separated from storage by processor collision, causing repeated movement failure. Waypoint navigation resolved that route while retaining the simple direct fallback.

## Interaction And UI

### Purchase And Management

The existing model-based custom interaction system now supports:

- `OpenNPCPurchaseMenu` on `NPCPurchasePad`
- `ManageNPC` on dynamically spawned NPC models

`WorkerController` creates one responsive ScreenGui for:

- Role selection, costs, and lock states
- Current NPC cargo and stats
- Individual Speed and Amount upgrades

### Server Authority

`WorkerRequest` is rate-limited. Before purchasing or upgrading, the server verifies:

- The player has loaded data and an owned plot.
- The requested role or upgrade type is valid.
- The player is close to the purchase pad or target NPC.
- Role progression is unlocked.
- A free home slot exists.
- The player can afford the operation.
- The NPC belongs to the player's persistent data and live runtime registry.

Purchase failures after spending refund the cost and remove the incomplete NPC record.

### Dynamic Model Targets

Interaction targeting now resolves from raycast-hit descendants up to tagged interactable Models. This supports complex plot objects and moving NPC rigs using one shared interaction target.

## Changes Since Snapshot 004

### Resolved Or Materially Improved

| Snapshot 004 state | Snapshot 005 status |
| --- | --- |
| Fixed auto-machine timers generated resources | Replaced by physical persistent NPC workers |
| Auto workers stood still | Workers navigate between work, processor, and storage locations |
| Worker output was based on one fixed machine level | Each NPC has individual speed and amount levels |
| Resource nodes were unlimited | Tree and Rock now use finite shared capacity and respawn |
| Multiple collectors had no reservation model | Atomic amount reservations prevent over-collection |
| Storage-full auto loops simply skipped work | NPCs retain cargo, wait at storage, and resume |
| Coal processing was a stationary timer | Coal NPCs perform visible ingredient and output trips |
| Separate role purchase pads existed | One purchase pad opens a role-selection menu |
| Runtime workers were fixed plot models | Workers clone from shared templates and persist by ID |
| Full-storage coal recipes were rejected incorrectly | Recipe processing consumes inputs before adding output |

### Still Open

| Earlier finding | Current status |
| --- | --- |
| Plot assets and spawn layout are Studio-only | Still open; now includes worker templates, homes, approaches, and attributes |
| No automated gameplay or lifecycle tests | Still open |
| Existing profile values are not validated | Still open; datastore bump avoids migration but not malformed v6 data |
| RemoteManager has weak static types | Still open and now covers four gameplay events |
| Gamepad and touch require device-emulation testing | Still open |

## Priority Findings

### P1: Interaction Line-Of-Sight Validation Was Removed

Model-based interaction validation still checks tag, owner, plot membership, required attributes, and distance. The earlier server line-of-sight check was removed while interaction targets changed from BaseParts to Models.

This allows a nearby modified client to request interaction through blocking geometry. Restore a model-aware server line-of-sight check before adding plots with meaningful walls or barriers.

### P1: Studio-Only Worker Assets Cannot Be Recreated From Source

The functional `PlotTemplate`, `WorkerTemplates`, worker homes, approach points, resource attributes, and disabled template animation scripts remain outside the source mapping.

A fresh source build cannot reproduce the validated persistent-NPC game without manually applying `WORLD_CHANGES.md`.

### P1: No Automated Worker Or Resource Tests

Reservations, depletion, respawn, storage waiting, recipe consumption, purchases, upgrades, and cleanup are important economy boundaries with no automated coverage.

### P2: Coal Ingredient Fetching Is Representational

Coal workers visibly make separate Wood and Stone fetch trips, but ingredients are not reserved during those trips. They are atomically consumed only after the worker reaches the processor.

This prevents resource loss and duplication, but several Coal workers may make trips before one discovers another worker consumed the last available recipe.

### P2: Worker Homes Are Visual Models

The live worker homes are decorative Models with pivots above ground, rather than simple marker Parts. Runtime code projects their X/Z pivots onto the plot ground and faces NPCs toward the plot center.

This works for the current layout but makes authored home orientation irrelevant and couples placement to the plot's `Ground` part.

### P2: Worker Loops Use Polling

Storage-full workers and workers without available work retry on configured delays. This is straightforward for the current eight-worker maximum, but event-driven wakeups may become useful with larger worker counts.

## Verification Notes

Live Studio validation covered:

- Clean server startup with no game-source errors.
- Persistent NPC reload after stopping and restarting play.
- Wood NPC purchase, movement, reservation, collection, deposit, and repeated work.
- Stone role unlock, purchase, collection, and deposit.
- Coal role unlock, purchase, recipe trips, processing, cargo, deposit, and continued work.
- Manual collection sharing finite node capacity with workers.
- Tree depletion, transparency, progress bar, refill, and resumed collection.
- Per-NPC Speed upgrade from 10 to 12.
- Full-storage waiting with retained cargo.
- Automatic worker resume after resources were sold.
- Multiple simultaneous workers operating on one plot.
- Clean startup after introducing PathfindingService movement.

`git diff --check` passed.

`selene`, Argon, and the installed StyLua wrapper were unavailable or non-functional in the local environment, so those checks could not run.

The Studio MCP output includes an Assistant-plugin version warning unrelated to game source. No game-source runtime errors remained in the final clean play session.

## Recommended Next Steps

1. Restore server-side model-aware interaction line-of-sight validation.
2. Source-control the plot template, worker templates, and plot spawn layout.
3. Add focused tests for resource reservations, depletion, respawn, storage waiting, and Coal recipe concurrency.
4. Add data validation for malformed `NPCs` records and invalid home-slot assignments.
5. Add typed RemoteManager accessors and payload contracts.
6. Manually validate purchase/management UI on touch and gamepad.
7. Consider event-driven worker wakeups if worker limits increase.
