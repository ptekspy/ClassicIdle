# ClassicIdle Codebase Snapshot 003: Player Plots and Feedback

**Snapshot date:** 2026-06-11  
**Repository state:** `main`, no commits before this snapshot; the working tree is entirely untracked  
**Previous snapshot:** `002_PROFILE_STORE.md`  
**Scope:** Source files plus a live Studio inspection of the plot template, plot spawns, remotes, and client feedback.

## Executive Summary

This snapshot records the second major foundation upgrade: ClassicIdle now gives every player an isolated cloned tycoon plot instead of making all players share one world.

That resolves the highest-impact multiplayer problem from snapshots 001 and 002. Displays, prompts, unlock visuals, machines, and resource drops are now changed inside the owning player's plot. World interactions verify the triggering player, and plot-specific delayed callbacks verify that the player still owns the same plot before mutating data or presentation.

The game also now has a source-controlled client feedback path. A new `RemoteManager` creates registered remotes on the server, `FeedbackService` sends through it, and `ClientBootstrap` renders responsive tweened feedback messages.

The current foundation successfully supports the intended 10-player plot model in Studio, but the map assets remain Studio-only and cannot be recreated from a fresh source build. The inspected spawn folder also contains two parts named `Plot08` and no `Plot09`. Automated tests, package provenance, data validation, and several typing/formatting improvements remain open.

## Snapshot Inventory

### First-Party Code

- 25 Luau files outside `src/ReplicatedStorage/Packages`
- Approximately 1,942 lines of first-party Luau
- 8 service modules, including the new `PlotService`
- 13 utility modules
- 1 server bootstrap
- 1 active client bootstrap
- No automated tests

Snapshot 002 contained approximately 1,631 lines of first-party Luau. The source has grown by approximately 311 lines, mainly through plot ownership, per-player lifecycle management, remote registration, and client feedback.

### Included Packages

The repository contains 33 package Luau files totaling approximately 7,002 lines:

- `FormatNumber`
- `Logger`
- `Maid`
- `ProfileStore`
- `RateLimit`
- `Remote`
- `RemoteManager`
- `Replica`
- `Signal`

`ProfileStore`, `Maid`, and `RemoteManager` are integrated directly. `Signal` is used transitively by ProfileStore. Several other packages remain available but unused by first-party runtime code.

## Current Architecture

### Player Join Lifecycle

```text
PlayerAdded
  -> DataService.Load
  -> PlotService.Claim
       -> choose an available spawn
       -> clone ReplicatedStorage.Assets.PlotTemplate
       -> assign OwnerUserId and PlotId attributes
       -> connect character respawn placement
  -> DisplayService.SetupLeaderstats
  -> WorldService.SetupPlayer
  -> DisplayService.UpdateAll
  -> WorldService.UpdateUnlocks
  -> PlotService.SpawnCharacter
```

If no plot is available, the profile session is released and the player is kicked with a clear message.

### Player Leave Lifecycle

```text
PlayerRemoving
  -> WorldService.CleanupPlayer
  -> PlotService.Release
  -> DataService.Release
```

Both `WorldService` and `PlotService` use Maid-managed connections. Prompt listeners and character listeners are disconnected when the player leaves, the cloned plot is destroyed, the spawn becomes available, and the ProfileStore session ends.

### Runtime Ownership

| Module | Current responsibility |
| --- | --- |
| `DataService` | ProfileStore session lifecycle and access to plain `PlayerData` |
| `PlotService` | Plot allocation, cloning, ownership, character placement, and release |
| `WorldService` | Per-plot prompts, progression orchestration, and global automation scheduling |
| `DisplayService` | Leaderstats and billboards inside the player's plot |
| `ResourceDropService` | Tweened drops contained inside a specific plot |
| `FeedbackService` | Server-to-client gameplay feedback |
| `RemoteManager` | Creation and shared lookup of registered events/functions |
| `ClientBootstrap` | Responsive tweened feedback UI |

## Changes Since Snapshot 002

### Resolved or Materially Improved

| Snapshot 002 finding | Snapshot 003 status |
| --- | --- |
| Shared world presentation was not multiplayer-correct | Resolved through one cloned, owned plot per player |
| Source-controlled client feedback was absent | Resolved with `ClientBootstrap` tweened feedback UI |
| Required feedback remote was manually created in Studio | Resolved; `RemoteManager` creates registered remotes |
| Leaving during a ProfileStore load could retain state | Resolved with a ProfileStore cancellation condition and leave-aware state clearing |
| Concurrent duplicate loads were not guarded | Improved; `Loading` and `Loaded` states reject another load |
| Prompt connections had no explicit player lifecycle owner | Resolved with per-player Maids in `WorldService` |
| Character respawn placement could outlive a released plot | Resolved with a per-player Maid in `PlotService` |
| Delayed drop callbacks could target a replacement plot | Improved by verifying current plot identity before updates |

### Still Open

| Earlier finding | Current status |
| --- | --- |
| Source cannot recreate required world assets | Still open; plot template and spawn parts are Studio-only |
| Persistence lifecycle has no automated coverage | Still open |
| Existing profile values are not validated | Still open |
| Full-storage coal processing rejects a net-storage-reducing recipe | Still open |
| `WorldService` is becoming a central monolith | Still open at approximately 567 lines |
| Package versions and provenance are not reproducible | Still open |
| No Git baseline | Resolved by the commits created with this snapshot |

## Plot Model

### Allocation

`PlotService`:

- Collects all `BasePart` children of `Workspace.PlotSpawns`.
- Sorts them by name.
- Claims the first spawn without an owner.
- Clones one `PlotTemplate` per player into runtime-created `Workspace.PlayerPlots`.
- Tracks plot by player, spawn by player, and owner by spawn.
- Returns an existing plot when the same player is claimed twice.

### Isolation

All world getters now accept a parent instance, and all gameplay setup receives the player's cloned plot. As a result:

- Prompt connections belong to one player and one plot.
- Billboards display the owning player's values.
- Machine visibility and unlock presentation affect only that plot.
- Resource drops are parented to that plot.
- Automation loops iterate loaded players and resolve each player's current plot.

### Studio Plot Contract

Live Studio inspection found:

```text
ReplicatedStorage
  Assets
    PlotTemplate (Model)
      PlayerSpawn
      Ground
      ManualTree
      ManualRock
      SellCrate
      AutoChopperButton
      AutoMinerButton
      StorageUpgradeButton
      AutoProcessorButton
      CoalProcessor
      AutoChopperMachine
      AutoMinerMachine
      StorageBin
      Drops

Workspace
  PlotSpawns
    Plot01
    Plot02
    Plot03
    Plot04
    Plot05
    Plot06
    Plot07
    Plot08
    Plot08
    Plot10
```

The duplicate `Plot08` should be renamed to `Plot09`. It does not prevent allocation, but both cloned plots receive the same `PlotId`, and name-based ordering cannot distinguish them reliably.

## Remote and Feedback Model

`RemoteManager` currently registers:

- `FeedbackEvent` as a `RemoteEvent`
- `GetWayfindingTarget` as a `RemoteFunction`

On the server, requiring `RemoteManager` creates missing registered remotes inside its `Events` and `Functions` folders. On the client, requiring it waits for those server-created instances.

`FeedbackService.Send(player, message)` fires `FeedbackEvent`. `ClientBootstrap` shows one responsive message at a time, tweening it into view and fading it out after 1.8 seconds. New feedback replaces the previous message instead of stacking indefinitely.

Live Studio verification confirmed:

- Both registered remotes are created with the expected classes.
- A player receives a cloned plot.
- `FeedbackGui` is created on the client.
- Gameplay feedback popups render and tween correctly.
- The obsolete Studio-only feedback script using `ReplicatedStorage.Remotes` was removed.

## What Is Working Well

### Multiplayer State Is Now Structurally Isolated

The move from one shared world to cloned player-owned plots is the most important architecture improvement so far. It removes cross-player visual corruption without requiring every display and unlock effect to become client-local.

### Lifecycle Cleanup Is Explicit

Maid ownership now mirrors runtime ownership:

- `WorldService` owns prompt connections for a player's active plot.
- `PlotService` owns the character respawn connection for a player's claimed plot.
- Release paths clear lookup tables before destroying plots or ending sessions.

### Asynchronous Work Checks Current Ownership

Resource-drop callbacks verify both current profile availability and plot identity. This prevents an old delayed callback from updating a newly claimed replacement plot.

### Remote Creation Is Centralized

Remote names now have a registry and are created consistently. Services and clients no longer rely on a manually prepared `ReplicatedStorage.Remotes` folder.

## Priority Findings

### P1: Plot Assets and Spawn Layout Are Still Studio-Only

`default.project.json` maps source scripts but not `ReplicatedStorage.Assets.PlotTemplate` or `Workspace.PlotSpawns`. A fresh build cannot reproduce the working game and `PlotService` will wait forever for those instances.

Source-control the template and spawn layout as model/place artifacts, generate them, or expand the project mapping once their design is finished.

### P1: Duplicate Spawn Name Produces Duplicate Plot IDs

The live `PlotSpawns` folder contains two `Plot08` parts and no `Plot09`. Both can be claimed because ownership is keyed by instance, but both plots receive `PlotId = "Plot08"`.

### P1: No Automated Gameplay or Lifecycle Tests

The economy, unlock sequence, ProfileStore lifecycle, plot allocation, release behavior, ownership guards, and remote registry remain untested. The game works in Studio, but regressions currently depend on manual discovery.

### P2: `WorldService` Still Owns Too Many Concerns

Plot isolation has made `WorldService` multiplayer-correct, but it still owns all prompt handlers, all automation loops, display orchestration, feedback decisions, and resource-drop scheduling. Additional machines will continue increasing repetition and change risk.

### P2: Existing Profile Values Are Not Validated

ProfileStore reconciliation fills missing fields but does not reject negative, fractional, infinite, or unexpectedly large values. Economy functions assume valid numeric state.

### P2: Coal Processing Still Rejects Some Valid Full-Storage Recipes

`ProcessCoal` requires one free storage slot before consuming two wood and one stone. At full capacity, the recipe is rejected even though processing would reduce used storage by two.

### P2: RemoteManager Has Weak Static Types

The manager dynamically adds remote names to a shared table and does not use strict mode or an exported interface. Consumers currently cast `FeedbackEvent` to `RemoteEvent`. This is workable for a small registry but becomes fragile as client-server contracts grow.

### P2: Formatting and Line Endings Remain Inconsistent

Several edited files contain mixed line endings and visible indentation drift. The available shell did not have Selene or the configured Roblox build tool, so consistent automated formatting and lint checks are not yet part of the workflow.

## Recommended Next Steps

1. Rename the duplicate `Plot08` spawn to `Plot09`.
2. Finish and source-control the plot template and 10-spawn layout.
3. Add focused tests for economy rules, ProfileStore lifecycle, and plot claim/release behavior.
4. Validate loaded `PlayerData` before gameplay starts.
5. Fix full-storage coal processing.
6. Split machine interactions and automation scheduling out of `WorldService` as new content is added.
7. Add typed RemoteManager accessors or a typed remote contract before adding client-to-server gameplay remotes.
8. Establish repeatable format, lint, and build commands.

## Suggested Test Baseline

- Ten players claim ten distinct spawn instances and an eleventh player is rejected.
- Releasing a player destroys their plot and makes exactly one spawn available.
- Respawning moves a player to their current plot and released plots no longer receive callbacks.
- One player's prompts, displays, machines, and drops never mutate another player's plot.
- An old drop callback cannot update a replacement plot.
- Registered remotes are created once with the expected class.
- Feedback reaches only the intended player.
- Failed and cancelled profile loads cannot initialize gameplay.
- Economy mutations never exceed storage or accept invalid loaded values.

## Verification Notes

- All first-party source and relevant package integration points were inspected.
- Live Studio inspection verified the plot template, 10 spawn instances, runtime remotes, cloned player plot, and tweened client feedback.
- A live play test confirmed the feedback popups work.
- The obsolete Studio-only feedback listener was removed.
- No first-party source references the old `ReplicatedStorage.Remotes` path.
- `git diff --check` passed for the most recently edited integration files.
- Selene and the configured Roblox build tool were unavailable in the shell.

## Overall Assessment

ClassicIdle has moved from a readable single-world prototype to a credible multiplayer tycoon foundation. ProfileStore protects persistent sessions, cloned plots isolate player state, Maid-managed cleanup makes ownership explicit, and client feedback gives interactions a polished response.

The next milestone should make the working Studio world reproducible from source and put tests around the now-important lifecycle boundaries. With those in place, new tycoon content can be added with much lower regression risk.
