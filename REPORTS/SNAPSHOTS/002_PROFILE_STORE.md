# ClassicIdle Codebase Snapshot 002: ProfileStore

**Snapshot date:** 2026-06-11  
**Repository state:** `main`, no commits yet; the working tree is entirely untracked  
**Previous snapshot:** `001_INIT.md`  
**Scope:** Files present in the repository. Studio-only instances, live DataStores, and runtime behavior were not available for inspection.

## Executive Summary

This snapshot records the first major foundation upgrade: player persistence has moved from a hand-written `DataStoreService` wrapper to ProfileStore-backed sessions.

The change resolves the most dangerous persistence problems identified in snapshot 001:

- A failed load no longer gives the player save-authoritative default data.
- Active sessions are locked against overlapping server ownership.
- Autosave, `UpdateAsync` writes, retries, and shutdown saving are delegated to ProfileStore.
- Players are only initialized after a successful profile load.
- Lost profile sessions cause the affected player to be removed from the server.
- Prompt handlers, automation loops, and delayed resource-drop callbacks now tolerate unavailable player data.
- Profile objects are private to `DataService`; gameplay services consistently consume plain `PlayerData`.

The persistence foundation is now substantially safer. It is not finished: no automated or Studio integration tests verify the lifecycle, leaving during a blocked load is not used as a ProfileStore cancellation condition, duplicate concurrent loads are not guarded, and the new `v5` store has no migration path from the old `v3` store.

The major non-persistence risks from snapshot 001 also remain: per-player state is still presented through one shared world, and a fresh source build still does not define the required world or feedback remote.

## Snapshot Inventory

### First-Party Code

- 25 Luau files outside `src/ReplicatedStorage/Packages`
- Approximately 1,631 lines of first-party Luau
- 7 service modules, plus service type/default modules
- 13 utility modules
- 1 server bootstrap
- 1 empty client bootstrap
- No automated tests
- No Git commit exists to identify this snapshot

Snapshot 001 contained 17 Luau files and approximately 1,402 lines. The first-party source has grown by 8 files and approximately 229 lines, mainly through added utilities, persistence lifecycle state, and asynchronous data guards.

### Included Packages

The repository now contains 30 package Luau files totaling approximately 6,945 lines:

- `FormatNumber`
- `Logger`
- `Maid`
- `ProfileStore`
- `RateLimit`
- `Remote`
- `Replica`
- `Signal`

Only ProfileStore is integrated into runtime behavior. `Signal` is used transitively by ProfileStore. Replica currently contributes a `PlayerDataReplica` type but is not otherwise integrated.

`wally.toml` still declares no dependencies, so package versions and provenance are not represented by the package manifest.

## Persistence Architecture

### Type Boundary

The data boundary is now explicit:

```text
PlayerProfile
  ProfileStore session object
  Owned and accessed only by DataService
  Contains Profile.Data

PlayerData
  Gold, resources, upgrade levels, and storage level
  Returned by DataService.Get and DataService.TryGet
  Consumed by economy, unlock, display, and world services
```

This is the correct separation. Gameplay modules do not need to know how persistence sessions work, and ProfileStore methods cannot accidentally leak into economy APIs.

### Session State

`DataService` tracks each player as:

```text
Loading -> Loaded
Loading -> LoadFailed
Loaded  -> session ended / released
```

Its public behavior is:

| API | Behavior |
| --- | --- |
| `Load(player)` | Starts a ProfileStore session and returns whether gameplay initialization may continue |
| `Get(player)` | Returns `PlayerData` or throws when no active loaded session exists |
| `TryGet(player)` | Returns `PlayerData?` without throwing |
| `IsLoaded(player)` | Reports whether an active loaded session exists |
| `Release(player)` | Clears local ownership and ends the ProfileStore session |

### Load Lifecycle

The current successful load sequence is:

1. Mark the player as `Loading`.
2. Call `ProfileStore:StartSessionAsync`.
3. Reject and kick when no profile is returned.
4. Release immediately if the player left while loading.
5. Associate the profile with the player's user ID.
6. Reconcile missing template fields.
7. Connect an `OnSessionEnd` listener.
8. Store the profile and mark the player as `Loaded`.
9. Initialize displays and unlock state.

### Save Lifecycle

The old custom save APIs, 60-second autosave loop, raw `SetAsync`, and manual `BindToClose` callback have been removed.

ProfileStore now owns:

- Retry and backoff behavior
- Session conflict handling
- `UpdateAsync` writes
- Periodic autosave
- Final save on `EndSession`
- Parallel shutdown release and saving

The included ProfileStore currently uses a default autosave period of 300 seconds. This increases the unsaved window during a hard server crash compared with the previous 60-second custom autosave, although normal leave and shutdown paths perform final saves.

## Changes Since Snapshot 001

### Resolved or Materially Improved

| Snapshot 001 finding | Snapshot 002 status |
| --- | --- |
| Failed loads could overwrite real progress with defaults | Resolved by refusing gameplay initialization when `StartSessionAsync` fails |
| `SetAsync` writes were vulnerable to overlapping server sessions | Resolved through ProfileStore session locking and `UpdateAsync` |
| Custom serial shutdown saves were fragile | Resolved through ProfileStore shutdown handling |
| Prompts and automation could access data before loading | Improved: all gameplay entry points use `TryGet` guards |
| Delayed resource-drop callbacks could run after player removal | Improved: all four delayed callbacks check `TryGet` |
| Strict mode was ineffective in core services | Improved: strict directives are now at line 1 in all service modules |
| Profile and gameplay data types were inconsistent | Resolved: profiles stay private to `DataService`; consumers use `PlayerData` |

### Still Open

| Snapshot 001 finding | Snapshot 002 status |
| --- | --- |
| Shared world presentation is not multiplayer-correct | Unchanged |
| Source cannot recreate required `IdleWorld` and remotes | Unchanged |
| Client feedback listener is absent | Unchanged |
| Loaded numeric values are not validated beyond template reconciliation | Unchanged |
| Full-storage coal processing rejects a net-storage-reducing recipe | Unchanged |
| `WorldService` is becoming a central monolith | Increased from 446 to 511 lines |
| No automated tests | Unchanged |
| No Git baseline | Unchanged |

## What Is Working Well

### Persistence Responsibilities Are Better Defined

`DataService` is now a small session boundary instead of a partial persistence framework. It delegates the difficult storage behavior to ProfileStore while exposing a simple gameplay-facing API.

### Gameplay Cannot Start on Failed Loads

`ServerBootstrap` stops initialization when `DataService.Load` returns false. This removes the previous path where players could enter the game with temporary defaults that might later overwrite real progress.

### Session Loss Is Handled Explicitly

The `OnSessionEnd` handler removes the local profile and kicks a player whose active session is lost. Gameplay guards then prevent further mutations through that ended session.

### Asynchronous Boundaries Are Guarded

`WorldService` uses `TryGet` at:

- All 8 ProximityPrompt handlers
- All 3 automation loops
- All 4 delayed resource-drop callbacks

This is a meaningful lifecycle improvement. Player departure or profile loss no longer turns those paths into expected `DataService.Get` errors.

### Gameplay Code Uses Plain Data

`EconomyService`, `UnlockService`, `DisplayService`, and `WorldService` work with `PlayerData`, not ProfileStore objects. The economy remains usable as a mostly pure domain module and is easier to test.

## Priority Findings

### P0: Shared World Presentation Is Still Not Multiplayer-Correct

Player progression is isolated, but prompts, billboards, machine visibility, transparency, and colors are still changed on shared Workspace instances.

The last player to update the world controls what every player sees. Server-side purchase and unlock checks protect progression, but the displayed costs, locks, resources, and machine states become misleading as soon as players have different progress.

Choose one player per server/plot, create separate player-owned plots, or move per-player presentation to client-local UI and rendering.

### P1: The `v5` Store Has No Migration Path

The original implementation used `IdleGame_PlayerData_v3`; the ProfileStore implementation uses `IdleGame_PlayerData_v5`.

ProfileStore requires a different stored envelope, so changing the store name was appropriate. However, any existing `v3` progress is currently abandoned rather than migrated. Before treating existing progress as valuable, define whether old data should be ignored, migrated once, or retained as a recovery source.

### P1: Leaving During a Failed Load Can Leak Session State

`StartSessionAsync` yields and is called without a `Cancel` condition.

If a player leaves while loading:

1. `PlayerRemoving` calls `Release` and clears the player's state.
2. The pending load later returns `nil`.
3. `Load` writes `LoadFailed` back into `Local.states`.
4. The departed `Player` remains referenced by the state table.

Pass a cancellation condition based on whether the player is still present, and avoid writing failure state for players who have already left.

### P1: Concurrent Duplicate Loads Are Not Guarded

The common connect-then-iterate bootstrap pattern can theoretically invoke `onPlayerAdded` twice for the same player during a timing race. Because `Load` yields, two calls may attempt to start the same profile session.

ProfileStore handles duplicate in-server load jobs, but one caller may receive `nil` and kick a player while another caller is successfully loading them. `DataService.Load` should reject or join an existing `Loading`/`Loaded` operation before starting another session.

### P1: Persistence Lifecycle Is Untested

No test verifies:

- Failed loads never become writable sessions.
- A second server cannot concurrently own the same profile.
- Leaving during loading releases or cancels the load.
- Session loss kicks the player and blocks further mutations.
- Delayed callbacks safely stop after release.
- Reconciliation adds new default fields.
- Normal leave and shutdown save expected mutations.

ProfileStore includes a mock store API, but the current DataService does not expose a clean dependency seam for testing with it.

### P1: The Source Tree Still Cannot Recreate a Runnable Place

`Workspace.IdleWorld`, its 11 named parts, their required prompts, and `ReplicatedStorage.Remotes.FeedbackEvent` are still absent from the project mapping. A fresh source build cannot reproduce the inspected runtime contract.

### P1: Client Feedback Is Still Incomplete

`FeedbackService` fires `FeedbackEvent`, but `ClientBootstrap.client.luau` remains empty. No source-controlled client code displays those messages.

### P2: ProfileStore and Server-Oriented Packages Live in ReplicatedStorage

ProfileStore and Replica server modules are mapped under `ReplicatedStorage`, so they replicate to clients even though persistence and server replica implementation are server concerns.

This does not grant clients authority over server profiles, but it increases replicated source size and makes accidental client-side requiring easier. Consider separating shared package types/client modules from server-only implementations.

### P2: Package Versioning Is Not Reproducible

The package source is checked into `src/ReplicatedStorage/Packages`, while `wally.toml` has no dependency entries or lockfile. The current snapshot records package code, but there is no manifest-level explanation of package versions or update source.

### P2: Data Reconciliation Does Not Validate Existing Values

`profile:Reconcile()` fills missing fields but does not sanitize existing values. Negative, fractional, infinite, or unexpectedly large currencies and levels can survive loading and violate economy assumptions.

### P2: Mixed Line Endings and Formatting Drift

Core edited services currently contain mixed CRLF and LF line endings, and `WorldService` has visible indentation drift around automation loops. This does not define gameplay behavior, but it makes review harder and can hide structural mistakes.

### P2: Unused Future-Facing Types and Packages Add Noise

`PlayerDataReplica` is declared but unused. Most included packages are not yet integrated. Keeping planned dependencies can be reasonable, but unused architecture should not influence current service boundaries until it has a concrete role.

## Current External Runtime Contract

The required Studio hierarchy remains:

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

## Recommended Next Steps

1. **Test the persistence lifecycle in Studio.** Verify load failure, duplicate sessions, leave-during-load, session loss, reconciliation, normal leave, and shutdown.
2. **Add load cancellation and duplicate-load protection.** This closes the remaining known ProfileStore lifecycle races.
3. **Choose the multiplayer model.** Shared world presentation remains the highest-impact gameplay architecture problem.
4. **Make the runtime contract reproducible.** Source-control or generate the world, prompts, remotes, and feedback UI.
5. **Decide the `v3` to `v5` data policy.** Explicitly migrate, archive, or discard old progress.
6. **Normalize formatting and line endings.** Then run strict type checking and linting consistently.
7. **Add automated economy and lifecycle tests.**
8. **Create the first Git commit.** Snapshot comparison remains descriptive until the repository has a durable version-control baseline.

## Suggested ProfileStore Test Matrix

| Scenario | Expected result |
| --- | --- |
| New player joins | Profile is created from defaults, reconciled, and marked loaded |
| Returning player joins | Existing data loads without resetting values |
| DataStore access fails | Player is not initialized and cannot save defaults |
| Same player joins another server | Only one server owns the active session |
| Player leaves during load | Pending load cancels or immediately releases without retained state |
| Player leaves after load | Profile session ends and final changes save |
| Session ends externally | Local profile is removed, player is kicked, and gameplay guards reject access |
| Drop callback runs after leave | Callback returns without mutation or error |
| New default field is introduced | Reconcile adds it without replacing existing values |
| Server closes | Active profiles perform final shutdown saves |

## Verification Notes

- All first-party Luau source and relevant ProfileStore lifecycle code were inspected.
- No legacy first-party `DataStoreService`, `GetAsync`, `SetAsync`, custom autosave, or manual `BindToClose` calls remain.
- Profile objects and direct `profile.Data` access are confined to `DataService`.
- All service modules now place `--!strict` on line 1.
- The generated sourcemap still contains no `IdleWorld` hierarchy or `Remotes.FeedbackEvent`.
- The repository still has no commits.
- Argon, Selene, Luau LSP, and a working Linux StyLua binary were unavailable.
- No build, lint, format, Studio playtest, live DataStore test, or shutdown test was run.

## Overall Assessment

The ProfileStore migration successfully addresses the most dangerous weakness in snapshot 001. Persistence is no longer a hand-built collection of optimistic DataStore calls; it now has explicit session ownership, failure-aware initialization, safe release behavior, and guarded asynchronous consumers.

This is a meaningful foundation milestone. The next persistence work should be validation rather than another redesign: close the leave/duplicate-load races, test the lifecycle under failure, and decide how old data should be handled. After that, the most valuable architectural improvement shifts back to multiplayer world ownership and presentation.
