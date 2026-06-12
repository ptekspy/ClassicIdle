# ClassicIdle Codebase Snapshot 006: Guided Progression Quests

**Snapshot date:** 2026-06-12
**Repository state:** `main`, guided quest and Coal collector implementation complete and pending snapshot commit
**Previous snapshot:** `005_PERSISTENT_NPC_WORKERS.md`
**Scope:** Persisted quest progression, XP rewards, client quest UI and wayfinding, gameplay-event integration, and Collection Point-to-storage Coal NPC automation.

## Executive Summary

ClassicIdle now guides players through the complete current progression loop with a server-authoritative, config-driven chain of 25 quests:

```text
Manual Wood
  -> selling
  -> Wood NPC
  -> manual Stone
  -> Stone NPC
  -> storage upgrade
  -> six-part conveyor machine
  -> Coal production and collection
  -> Coal NPC collection automation
```

Quest progress, completed quest IDs, current event progress, and XP persist in ProfileStore. State objectives can complete immediately when activated if the player already satisfies them. Event objectives only count successful server-side actions performed while that objective is active.

The client displays the active objective in a responsive quest card and resolves a live waypoint inside the player's owned plot. The waypoint uses a Highlight, BillboardGui, and Beam, and redirects players toward gathering or selling when they cannot afford the next purchase.

This milestone also introduces a new Coal NPC role. Unlike the removed processor worker, this NPC withdraws finished Coal from the machine Collection Point and carries it to shared storage. The Coal NPC costs 500 Gold and unlocks after the Collection Point is built.

The datastore name changed from `IdleGame_PlayerData_v7` to `IdleGame_PlayerData_v8`.

## Snapshot Inventory

- 48 first-party Luau files outside `src/ReplicatedStorage/Packages`
- Approximately 5,213 lines of first-party Luau
- 13 service modules, including new `QuestService`
- 4 client controllers, including new `QuestController`
- Shared Quest, Machine, Plot, Worker, and Interaction contracts
- 7 managed RemoteEvents, including `QuestUpdate`
- 2 managed RemoteFunctions, including `GetQuestState`
- 25 configured quests: 16 state objectives and 9 event objectives
- No automated tests

## Quest Architecture

### Configuration And Types

`ReplicatedStorage.Quest.Config` defines the ordered quest chain. Every definition contains:

- Quest ID, title, and description
- State or event objective identifier
- Required amount
- XP reward
- Wayfinding target type and value

`ReplicatedStorage.Quest.Types` defines shared strict quest definitions, persisted quest data, and the sanitized client payload.

The configured chain awards 489 total XP. Quest 1 awards exactly 1 XP; rewards increase through the progression chain, ending with 75 XP for full Coal collection automation.

### Persisted Player Data

`PlayerData` now includes:

```luau
XP: number
Quest: {
    CurrentQuestId: string?,
    CompletedQuestIds: { [string]: boolean },
    CurrentProgress: number,
}
```

ProfileStore reconciliation adds these fields to missing profiles. On setup, `QuestService` repairs invalid current IDs, resumes the first incomplete quest, evaluates satisfied state objectives, and never re-awards completed quests.

### Server Authority

`QuestService` owns:

- Current objective evaluation
- Event progress updates
- Quest completion and advancement
- Exact-once XP rewards
- Leaderstat XP refresh
- Sanitized client quest-state publication

Gameplay systems notify quests only after successful authoritative mutations:

- `WorldService`: manual gathering, successful sales, NPC purchases/upgrades, and storage upgrades
- `WorkerService`: Wood, Stone, and Coal NPC deposits
- `MachineService`: machine purchases/upgrades, Coal reaching the Collection Point, and manual Coal collection

Clients cannot submit quest progress or request rewards.

## Quest Chain

The 25 objectives cover every major action:

1. Manually collect Wood and stockpile 10 Wood.
2. Sell Wood, hire a Wood NPC, observe a deposit, and upgrade it.
3. Manually collect Stone, save Gold, hire a Stone NPC, and observe a deposit.
4. Upgrade storage and save for the conveyor.
5. Purchase Conveyor 1, Upgrader 1, Coal Processor, Conveyor 2, Upgrader 2, and Collection Point.
6. Produce, manually collect, and sell Coal.
7. Upgrade Conveyor 1, save 500 Gold, hire a Coal NPC, and observe its first storage deposit.

Inventory and ownership objectives use current authoritative player state. Deposit, sale, manual-gathering, production, and collection objectives count successful events only while active.

## Coal NPC Collector

`WorkerTypes.Role` now supports:

```luau
"Wood" | "Stone" | "Coal"
```

The Coal NPC:

- Uses the existing `WorkerTemplates.CoalProcessor` character model
- Costs 500 Gold
- Unlocks after `Machine.Parts.CollectionPoint.Built`
- Reuses worker homes, pathfinding, movement speed, Amount upgrades, persistent cargo, interactions, and management UI
- Travels to the Collection Point, withdraws available Coal, travels to Storage Bin, and deposits accepted Coal
- Waits safely when storage is full and retains cargo across interruptions

`MachineService.WithdrawCollection` centralizes Collection Point withdrawals for both manual collection and Coal NPC collection so Coal is not duplicated or lost.

## UI And Wayfinding

`QuestController` creates a responsive top-left quest card showing:

- Quest title
- Description
- Current progress and required amount
- XP reward

The waypoint resolves only within the local player's owned plot and uses:

- A world-space Highlight on the target
- A BillboardGui labeled `QUEST`
- A Beam from the player's HumanoidRootPart to the target

Targets are resolved from Plot paths, machine-part IDs, or runtime worker role attributes. Earning objectives point to the Sell Crate when resources are available and to the Tree otherwise. Unaffordable purchase objectives use the same earning fallback. Coal production points toward missing Wood or Stone before returning to the Collection Point.

Wayfinding hides when the quest chain is complete and tolerates missing targets without crashing.

## World Contract

The quest UI and waypoint visuals are created at runtime. No authored quest UI or marker objects are required.

Coal NPC collection requires:

```text
ReplicatedStorage.Assets.PlotTemplate
  WorkerApproachPoints
    CollectionPoint
```

`CollectionPoint` is an invisible, anchored, non-colliding Part at approximately `(5, 0.5, -26)`. The marker was added and verified in the active Classic Idle Studio place. `WORLD_CHANGES.md` records its exact required properties.

The place file remains ignored by Git, so the authored marker is not represented by the source commit itself.

## Changes Since The Conveyor Milestone

- Added config-driven guided progression across the existing full game loop.
- Added persisted XP and quest state without introducing a level system.
- Added server-side objective hooks at successful gameplay mutation points.
- Added quest state remotes and responsive client UI.
- Added live plot-local wayfinding with earning fallbacks.
- Added Coal NPC collection automation after the conveyor Collection Point.
- Added a Collection Point worker approach marker and plot validation requirement.
- Bumped the datastore to `IdleGame_PlayerData_v8`.

## Verification Notes

Completed:

- `git diff --check`
- Confirmed exactly 25 quest definitions
- Confirmed 16 state objectives and 9 event objectives
- Confirmed 489 total configured XP
- Argon project build succeeded
- Verified the Studio Collection Point approach marker path and properties
- Saved the active Classic Idle Studio place after adding the marker

Validation caveats:

- The connected Studio instance was not attached to an Argon source-sync session, so the new source implementation was not live-played in that place.
- The local StyLua wrapper could not find its platform binary.
- Argon reports the existing missing top-level `Packages` and `ServerPackages` path warnings.
- No automated test harness exists.
- Full 25-quest progression, rejoin behavior, Coal NPC movement, touch, gamepad, and multiplayer behavior still require live gameplay testing.

## Priority Findings

### P1: Complete Progression Needs An End-To-End Live Test

The entire chain should be played from a fresh `v8` profile through the first Coal NPC deposit. Rejoin tests should cover event-progress quests, machine construction, Coal waiting in the Collection Point, and Coal NPC cargo.

### P1: Studio-Only World Assets Remain Outside Source Control

The Collection Point worker marker and complete machine hierarchy exist only in the ignored place file. A clean source checkout cannot reproduce the complete playable world.

### P1: No Automated Quest Or Worker Tests Exist

Exact-once XP rewards, state-objective auto-advancement, event filtering, Collection Point withdrawal, and Coal NPC cargo behavior are high-value regression targets.

### P2: Quest Events Are Direct Cross-Service Calls

The explicit hooks are readable and appropriate for the current project size. If more quest chains or event consumers are added, a small server gameplay-event abstraction may become useful.

### P2: Wayfinding Uses Runtime-Created Visuals

The MVP waypoint is intentionally simple. It does not calculate a walkable route and may draw through geometry, although it remains useful as a directional guide.

## Recommended Next Steps

1. Live-test all 25 quests from a fresh `v8` profile, including rejoin and multiplayer plots.
2. Test Coal NPC collection with empty, partial, and full shared storage.
3. Add focused automated tests for quest advancement, exact-once XP, and Collection Point withdrawals.
4. Decide how Studio-authored plot assets will be exported or versioned.
5. Add a player-facing wayfinding toggle if settings UI is introduced.
