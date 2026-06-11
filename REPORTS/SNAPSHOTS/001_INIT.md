# ClassicIdle Codebase Snapshot 001

**Snapshot date:** 2026-06-11  
**Repository state:** `main`, no commits yet; the working tree is entirely untracked  
**Scope:** Files present in the repository. Studio-only instances and behavior were not available for inspection.

## Executive Summary

ClassicIdle is a compact Roblox/Luau tycoon foundation with a complete early-game loop:

1. Manually gather wood.
2. Sell resources for gold.
3. Buy an auto chopper.
4. Unlock stone gathering and an auto miner.
5. Process wood and stone into higher-value coal.
6. Upgrade automation and storage.

The implementation is easy to follow and sensibly separates persistent data, economy rules, unlock rules, display updates, resource-drop visuals, and world interaction wiring. Player progression mutations happen on the server, and shared helper functions keep the economy rules consistent.

The foundation is currently strongest as a single-player prototype synced into an already-prepared Studio place. It is not yet a reproducible or multiplayer-correct baseline. The source project does not define the required world or remote instances, the client bootstrap is empty, and per-player state is rendered by mutating one shared world. Data persistence also needs stronger failure handling before the game is safe to operate with valuable player progress.

## Snapshot Inventory

- 17 Luau files under `src/`
- Approximately 1,402 lines of Luau under `src/`
- 7 service modules, plus 3 service type/default modules
- 5 utility modules
- 1 server bootstrap
- 1 empty client bootstrap
- No external Wally dependencies
- No automated tests
- No Git commit exists to identify this snapshot

The project uses Argon-style source mapping through `default.project.json`. `selene.toml` and `wally.toml` exist, but neither Selene nor Argon was available in the inspected shell environment.

## Architecture

### Runtime Flow

`ServerBootstrap.server.luau` is the composition root. It:

- Loads player data.
- Creates leaderstats and world displays.
- Applies unlock visuals.
- Connects all ProximityPrompt interactions.
- Starts auto-production loops.
- Starts autosave.
- Saves players on removal and server shutdown.

The effective dependency flow is:

```text
ServerBootstrap
  -> DataService
  -> DisplayService
       -> DataService, EconomyService, UnlockService
  -> WorldService
       -> DataService, EconomyService, UnlockService
       -> DisplayService, FeedbackService, ResourceDropService
       -> world getter/setter utilities
```

### Service Responsibilities

| Module | Current responsibility |
| --- | --- |
| `DataService` | In-memory player data, DataStore load/save, reconciliation, autosave |
| `EconomyService` | Resource capacity, selling, processing, prices, and purchases |
| `UnlockService` | Progression gates |
| `WorldService` | Prompt handlers, unlock presentation, automation loops, orchestration |
| `DisplayService` | Leaderstats and world-space billboard text |
| `ResourceDropService` | Tweened resource-drop visuals and completion callbacks |
| `FeedbackService` | Sends feedback strings to a client RemoteEvent |

This division is a good starting point. The main architectural pressure is concentrated in `WorldService`, which is already 446 lines and owns interaction wiring, visual state, production scheduling, and cross-service orchestration.

## Gameplay and Economy Baseline

### Starting Data

| Value | Initial amount |
| --- | ---: |
| Gold | 0 |
| Wood | 0 |
| Stone | 0 |
| Coal | 0 |
| Auto Chopper level | 0 |
| Auto Miner level | 0 |
| Auto Processor level | 0 |
| Storage level | 1 |
| Storage capacity | 25 |

### Resource Values and Production

| Resource/action | Value |
| --- | ---: |
| Manual chop | 1 wood per interaction |
| Manual mine | 1 stone per interaction |
| Wood sell price | 1 gold |
| Stone sell price | 3 gold |
| Coal sell price | 10 gold |
| Coal recipe | 2 wood + 1 stone -> 1 coal |
| Auto chopper | Level wood every 3 seconds |
| Auto miner | Level stone every 5 seconds |
| Auto processor | Up to level recipes every 4 seconds |

Coal converts resources worth 5 gold into 10 gold, creating the intended processing incentive.

### Upgrade Curves

- Auto chopper cost: `10 * next level`
- Auto miner cost: `25 * next level`
- Auto processor cost: `100 * next level`
- Storage upgrade cost: `50 * current storage level`
- Each storage upgrade adds 25 capacity

### Unlock Sequence

- Manual tree, auto chopper, and storage upgrades are always available.
- Buying the first auto chopper unlocks manual rock gathering and the auto miner.
- Buying the first auto miner unlocks manual coal processing and the auto processor.

## External Runtime Contract

The repository alone does not define everything required to run the game. The synced Studio place must already contain:

```text
Workspace
  IdleWorld (Folder)
    ManualTree (BasePart + ProximityPrompt)
    ManualRock (BasePart + ProximityPrompt)
    SellCrate (BasePart + ProximityPrompt)
    AutoChopperButton (BasePart + ProximityPrompt)
    AutoMinerButton (BasePart + ProximityPrompt)
    StorageUpgradeButton (BasePart + ProximityPrompt)
    AutoProcessorButton (BasePart + ProximityPrompt)
    CoalProcessor (BasePart + ProximityPrompt)
    AutoChopperMachine (BasePart)
    AutoMinerMachine (BasePart)
    StorageBin (BasePart)

ReplicatedStorage
  Remotes (Folder)
    FeedbackEvent (RemoteEvent)
```

`IdleWorld.Drops` is created at runtime if absent.

These instances are absent from `default.project.json` and the generated `sourcemap.json`. In particular, requiring `FeedbackService` waits indefinitely when `FeedbackEvent` is absent, preventing server startup from completing. The empty `ClientBootstrap.client.luau` also contains no listener that displays messages received from `FeedbackEvent`; that behavior must currently exist only in Studio or is not implemented.

## What Is Working Well

### Clear Economy Core

Economy mutations are centralized in `EconomyService`. Capacity checks, purchases, selling, and processing are reusable and mostly independent from world-instance code. This is the most testable part of the current design.

### Server-Side Progression Mutations

Prompts are connected on the server and purchase/unlock conditions are checked before data is mutated. Clients are not trusted to submit arbitrary currency values or upgrade levels.

### Explicit Progression Rules

`UnlockService` makes progression gates readable and gives them a natural place to grow. The current linear unlock sequence is immediately understandable.

### Basic Persistence Hygiene

Data is copied from defaults rather than sharing the default table, loaded data is reconciled field by field, autosave exists, and player-removal/shutdown saves are present.

### Small, Useful World Utilities

The getters fail loudly when required world instances have the wrong class, and the cooldown helper prevents rapid manual gathering.

## Priority Findings

### P0: Shared World Presentation Is Not Multiplayer-Correct

Player data is per-player, but `DisplayService.UpdateAll` and `WorldService.UpdateUnlocks` mutate shared Workspace instances:

- Billboard text shows one player's resources, levels, and costs to every player.
- Prompt text shows one player's next cost to every player.
- Locked colors/transparency and machine visibility are shared.
- The last player whose state updates effectively controls the world's presentation.

Server-side checks still protect most progression rules, but two players at different progression levels will see misleading and rapidly changing information. Decide whether each server is intentionally single-player or move player-specific presentation to client-side UI/local rendering.

### P0: A Transient Load Failure Can Overwrite Existing Data

When `GetAsync` fails, `DataService.Load` gives the player default data and permits normal play. Autosave or player removal can then `SetAsync` those defaults over the player's existing stored progress.

A load failure should normally prevent the session from becoming save-authoritative. At minimum, track load success and refuse saves for failed loads. For a stronger production baseline, use session locking/profile management and retries.

### P1: The Source Tree Cannot Recreate a Runnable Place

The required `IdleWorld` hierarchy and `FeedbackEvent` remote are not represented by the project mapping. A fresh build from source lacks the game's world contract and can stall during startup.

Bring required instances into source control, generate them during bootstrap, or document and validate a checked-in place/model artifact.

### P1: Client Feedback Is Incomplete in Source

`FeedbackService` fires `FeedbackEvent`, but the client bootstrap is empty. There is no source-controlled code that turns feedback messages into visible UI.

### P1: DataStore Writes Are Vulnerable to Session Races

`SetAsync` writes the entire mutable data table without session ownership or conflict handling. If the same player is present in overlapping server sessions, a stale server can overwrite newer progress. Shutdown saves are also performed serially, which becomes less reliable as server population grows.

### P1: Player Data Readiness and Delayed Callback Races

Automation loops and prompts call `DataService.Get`, which throws when data is not loaded. A slow `GetAsync` can leave a newly joined player interactable before loading finishes. Resource-drop callbacks can also run after a player leaves and `DataService.Forget` removes their data.

Introduce an explicit loaded/active session state and make delayed work tolerate session closure.

### P2: Strict Typing Is Only Partially Effective

`--!strict` appears after executable statements in `DataService`, `DisplayService`, `EconomyService`, and `WorldService`, so it is not functioning as the file mode directive. The five utility modules also have no strict directive.

`DataService` additionally annotates several values with bare `PlayerData` instead of `Types.PlayerData`. Effective strict checking would expose this.

### P2: Loaded Data Validation Is Too Permissive

Reconciliation accepts any number for currencies and upgrade levels. It does not enforce non-negative values, integers, finite numbers, or sensible upper bounds. Corrupt legacy data can therefore break economy assumptions.

### P2: Coal Processing Rejects Some Valid Full-Storage Recipes

`ProcessCoal` checks room for the output before consuming its inputs. At full storage, processing is rejected even though consuming 2 wood and 1 stone before adding 1 coal would reduce used capacity by 2.

### P2: `WorldService` Is Becoming a Central Monolith

The module currently owns all prompt setup, all automation loops, unlock visuals, machine visuals, and orchestration. Adding more resources, machines, or tycoon plots will create repetitive handlers and make lifecycle management harder.

### P3: Tooling and Documentation Are Minimal

- No tests cover the economy, unlock sequence, persistence reconciliation, or lifecycle behavior.
- The README only contains Argon build/serve commands.
- No required Studio hierarchy or gameplay architecture is documented outside this snapshot.
- Wally declares no dependencies.
- The root `init.luau` is not mapped by `default.project.json` and appears unused.

## Recommended Next Steps

1. **Choose the multiplayer model.** Either configure one player per server/plot or make all per-player displays and unlock presentation client-local.
2. **Protect persistence.** Prevent saving after failed loads, add retries and loaded-session state, then adopt session locking or a proven profile abstraction.
3. **Make builds reproducible.** Source-control or generate `IdleWorld`, prompts, remotes, and client feedback UI.
4. **Add focused tests.** Start with pure economy calculations, unlock rules, reconciliation, and failed-load save behavior.
5. **Restore effective strict mode.** Move directives to line 1, fix annotations, and apply strict mode to utilities.
6. **Split world orchestration as the game grows.** Separate interaction controllers, automation scheduling, and presentation updates while retaining the current service boundaries.
7. **Create the first Git commit.** A committed baseline will make future snapshots and regressions meaningfully comparable.

## Suggested Test Baseline

The first automated suite should verify:

- Resource additions never exceed storage capacity.
- Selling clears resources and awards the expected gold.
- Coal processing consumes and produces the correct amounts, including at full storage.
- Every upgrade charges the correct cost and increments exactly once.
- Unlock conditions follow the intended sequence.
- Reconciliation fills missing fields and rejects invalid numeric values.
- Failed loads cannot later save default data.
- Delayed production callbacks do not error after player removal.

## Verification Notes

- Full repository file inventory and all Luau source files were inspected.
- The generated sourcemap confirms that no Workspace world hierarchy or Remotes folder is mapped.
- The repository has no commits and no existing snapshot report.
- Argon, Selene, and a working Linux StyLua binary were unavailable, so no build, lint, format, Studio playtest, or DataStore integration test was run.

## Overall Assessment

ClassicIdle is a good readable prototype foundation with a real gameplay loop rather than an empty scaffold. Its economy and unlock separation provide a useful base for iteration. The next milestone should focus less on adding content and more on making the foundation reproducible, persistence-safe, and explicit about multiplayer behavior. Once those three areas are addressed, the current service layout can support a much larger tycoon game without requiring a rewrite.
