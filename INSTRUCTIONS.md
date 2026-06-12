I want you to implement a quest system for the current Roblox game, but this should be done as a plan-first workflow.

Do not implement code immediately.

First inspect the existing repo, current world structure, NPC systems, resource systems, storage/bin systems, player data, UI patterns, and any existing wayfinding/path systems.

Then produce a technical plan and wait for approval.

# Goal

Implement an early-game quest system that guides the player through the first progression loop.

The quest system should:

* Track quest progress.
* Show the active quest to the player.
* Provide a wayfinding path/marker showing where the player should go.
* Give XP rewards when quests are completed.
* Advance the player through quests in order.
* Integrate with existing resource, gold, NPC, storage, and progression systems.

# Quest story / quest order

Implement this early quest chain in order:

1. Collect 10 Wood
2. Sell your Wood
3. Hire 1 Wood NPC
4. Wait for the Wood NPC to collect 5 Wood
5. Have a total of 25 Gold
6. Hire a Stone NPC
7. Upgrade Storage Bin
8. Hire the Coal NPC
9. Collect a total of 50 Wood and 25 Stone

# XP rewards

Each quest should give the player an XP reward.

Rules:

* Quest 1 should reward exactly 1 XP.
* For the remaining quests, choose sensible XP values based on difficulty and progression impact.
* Harder/later quests should generally reward more XP.
* XP rewards should be defined in quest config/data, not hardcoded deep in quest logic.
* Use the existing player XP/level system if one exists.
* If there is no existing XP reward path, propose the smallest clean integration.

# Quest requirements

Each quest should be config-driven where possible.

Each quest definition should include:

* QuestId
* Title
* Description
* Objective type
* Required amount/value
* XP reward
* Wayfinding target
* Any relevant metadata

Suggested quest IDs:

* CollectWood10
* SellWood
* HireWoodNPC
* WaitWoodNPCCollect5
* Have25Gold
* HireStoneNPC
* UpgradeStorageBin
* HireCoalNPC
* CollectWood50Stone25

Use the repo’s existing naming conventions if different.

# Quest completion details

Quest 1: Collect 10 Wood

* Complete when the player collects 10 Wood.
* This should track newly collected Wood during the quest, not simply existing storage, unless the existing game design strongly suggests otherwise.
* Reward: 1 XP.
* Wayfinding should point to Wood resource nodes.

Quest 2: Sell your Wood

* Complete when the player sells Wood.
* Prefer completing on the first successful Wood sale.
* Wayfinding should point to the sell area/shop/storage sell interaction.

Quest 3: Hire 1 Wood NPC

* Complete when the player purchases/hires their first Wood NPC.
* Wayfinding should point to the Wood NPC purchase/hire location.

Quest 4: Wait for the Wood NPC to collect 5 Wood

* Complete when Wood NPC collection deposits at least 5 Wood while this quest is active.
* This should specifically be NPC-collected Wood, not manual Wood collection.
* Wayfinding should point to the Wood NPC / storage / relevant area, depending on existing world layout.

Quest 5: Have a total of 25 Gold

* Complete when the player’s Gold balance is at least 25.
* If the player already has 25 Gold when this quest starts, it may complete immediately.
* Wayfinding should point toward the best available activity to earn Gold, probably sell/storage area.

Quest 6: Hire a Stone NPC

* Complete when the player purchases/hires a Stone NPC.
* Wayfinding should point to the Stone NPC purchase/hire location.

Quest 7: Upgrade Storage Bin

* Complete when the player upgrades the Storage Bin once.
* Wayfinding should point to the Storage Bin upgrade interaction.

Quest 8: Hire the Coal NPC

* Complete when the player purchases/hires the Coal NPC.
* Wayfinding should point to the Coal NPC purchase/hire location.
* If the Coal NPC is being replaced later by the conveyor machine, do not solve that in this task unless the current game already uses that progression. For this quest task, integrate with the current available Coal NPC purchase flow.

Quest 9: Collect a total of 50 Wood and 25 Stone

* Complete when the player has collected a cumulative total of:

  * 50 Wood
  * 25 Stone
* This should track collected totals during the quest, not necessarily current storage balance, unless existing systems make cumulative tracking impractical.
* Wayfinding should point to whichever target is still incomplete:

  * Wood nodes if Wood progress is incomplete.
  * Stone nodes if Wood is complete but Stone is incomplete.
  * If both are incomplete, choose the lower percentage completion or whichever is more useful based on existing wayfinding patterns.

# Wayfinding requirements

Every active quest should provide a wayfinding path or marker showing the player where to go.

Please inspect the repo for any existing:

* Wayfinding system
* Arrow/path markers
* Quest marker UI
* Beam/path visuals
* Target marker components
* Settings such as `WayfindingEnabled`

If there is an existing wayfinding system, reuse it.

If there is no existing system, implement the smallest clean MVP:

* Active quest has a world target.
* Client shows a simple marker/path/arrow toward the target.
* Wayfinding should update when quest changes.
* Wayfinding should hide when the quest is complete.
* Wayfinding should respect any existing setting such as `WayfindingEnabled` if present.

Wayfinding targets should be data-driven where possible.

Possible target types:

* ResourceType target, e.g. nearest Wood node.
* Specific model/part target, e.g. Storage Bin.
* NPC purchase target.
* Shop/sell target.
* Upgrade target.

Do not hardcode fragile Workspace paths everywhere if there is a cleaner existing tag/attribute/config pattern.

Use CollectionService tags and/or attributes if that matches the project.

# Player data / persistence

Quest progress should be persisted if the project already has persistent player data.

Please inspect existing player data shape and profile/store patterns.

Quest data should likely include:

* CurrentQuestId
* CompletedQuestIds
* Per-quest progress values
* Cumulative tracking where needed

Be careful with data migrations/versioning if the project has a DataVersion system.

Do not break existing player data.

# Event integration

The quest system should listen to existing server-side events/actions where possible, such as:

* Resource collected
* Resource sold
* NPC hired
* NPC deposited resources
* Gold changed
* Storage upgraded

Do not rely on client-only state for quest progress.

Quest progress should be server-authoritative.

Client can display quest state, but the server should decide completion and rewards.

# Architecture expectations

Please inspect the repo and reuse existing systems where possible.

Look for existing:

* Player data service
* Replica/ProfileStore usage
* Resource service
* Sell/storage service
* NPC hire/purchase service
* Storage bin upgrade service
* UI state replication
* Remote/event manager
* Logger
* CollectionService tag patterns
* Wayfinding settings or systems

Prefer a simple architecture such as:

* QuestConfig

  * static quest definitions
* QuestService_Server

  * tracks progress
  * listens to relevant gameplay events
  * completes quests
  * awards XP
  * advances quest chain
* QuestController_Client or existing UI integration

  * displays active quest
  * displays progress
  * manages wayfinding target display
* QuestTypes

  * shared strict types if the repo uses typed modules

Use the existing service/module/controller style.

# Implementation workflow

Phase 1: Inspect and plan

* Inspect current codebase.
* Identify existing player data, XP, resources, NPC, sell, storage, and wayfinding systems.
* Identify where quest progress should hook into existing events.
* Identify world targets needed for wayfinding.
* Produce a plan only.
* Wait for approval.

Phase 2: After plan approval, create `WORLD_CHANGES.md` if needed

* If any manual Roblox Studio world/model/part/attribute/tag changes are needed, create or update `WORLD_CHANGES.md`.
* Be extremely specific.
* Include exact Workspace paths, tags, attributes, part names, marker targets, and verification steps.
* Wait for confirmation before implementing code if world changes are required.

Phase 3: Implement quest data/config

* Add quest config for the 9 quests.
* Add XP rewards.
* Add objective definitions.
* Add wayfinding target definitions.

Phase 4: Implement server quest tracking

* Add quest state to player data.
* Track progress server-side.
* Listen to relevant gameplay actions/events.
* Complete quests in order.
* Award XP.
* Advance to next quest.

Phase 5: Implement client UI / wayfinding

* Display active quest title/description/progress.
* Show XP reward if appropriate.
* Show wayfinding target/path/marker.
* Update when quest progress changes.
* Hide/complete quest UI when finished.

Phase 6: Validate

* Test each quest in order.
* Test persistence if supported.
* Test rejoin mid-quest.
* Test already-satisfied conditions.
* Test wayfinding target updates.

# Non-goals for this task

Do not implement:

* A full branching quest system.
* Daily quests.
* Quest dialogue.
* Cutscenes.
* Multiple quest chains.
* Quest rewards other than XP unless existing design requires it.
* A large generic achievement system.
* Major unrelated UI rewrites.
* Client-authoritative quest completion.

# Edge cases to handle

* Player already has enough Gold when “Have 25 Gold” starts.
* Player already hired an NPC before the related quest starts.
* Player rejoins mid-quest.
* Player completes a requirement while UI is not loaded.
* Resource nodes are missing.
* Wayfinding target cannot be found.
* Quest progress event fires multiple times.
* XP reward should not be granted twice.
* Completed quests should not be re-completed.
* Player data is missing quest fields and needs defaults.
* Player leaves during quest progress update.
* The current quest references a world target that does not exist yet.

# Code standards

* Follow existing repo conventions.
* Inspect nearby files before implementing.
* Match existing naming, folder structure, module style, service/controller patterns, typing style, and logging style.
* Keep code small, readable, and maintainable.
* Prefer config-driven quest definitions.
* Prefer explicit objective handlers over brittle string checks.
* Avoid broad rewrites.
* Do not introduce new dependencies unless clearly necessary.
* Do not change generated files.
* Do not make unrelated formatting changes.
* Preserve existing public APIs unless necessary.
* Use strict typing where the repo already uses it.
* Handle nil/invalid instances defensively.
* Avoid duplicated logic.
* Prefer shared helpers for:

  * quest lookup
  * quest progress updates
  * objective completion checks
  * XP reward application
  * wayfinding target resolution

# Validation checklist

Quest chain:

* New player starts at “Collect 10 Wood”.
* Collecting Wood updates quest progress.
* Collecting 10 Wood completes quest 1 and awards 1 XP.
* Selling Wood completes quest 2.
* Hiring Wood NPC completes quest 3.
* Wood NPC depositing 5 Wood completes quest 4.
* Having 25 Gold completes quest 5.
* Hiring Stone NPC completes quest 6.
* Upgrading Storage Bin completes quest 7.
* Hiring Coal NPC completes quest 8.
* Collecting total 50 Wood and 25 Stone completes quest 9.

Rewards:

* XP is awarded once per quest.
* Quest 1 gives exactly 1 XP.
* Later quests give sensible XP values based on difficulty.
* XP uses the existing player XP system.

Wayfinding:

* Every quest shows a valid wayfinding target.
* Wayfinding updates when the quest changes.
* Wayfinding points to Wood nodes for Wood collection.
* Wayfinding points to sell area for selling.
* Wayfinding points to NPC hire areas for NPC quests.
* Wayfinding points to Storage Bin upgrade area for storage upgrade.
* Wayfinding handles missing targets gracefully.
* Wayfinding hides or updates after quest completion.

Persistence:

* Rejoining preserves current quest.
* Rejoining preserves quest progress.
* Completed quests do not reward XP again.

Safety:

* Quest progress is server-authoritative.
* Client cannot spoof quest completion.
* Repeated gameplay events do not double-complete quests.
* Missing or invalid data does not crash the game.

# Final response after implementation

When finished, summarise:

* What changed.
* Main files touched.
* How the quest system works.
* How quest progress is tracked.
* How XP rewards are assigned.
* How wayfinding targets are resolved.
* Any world changes required.
* Any assumptions made.
* What validation was run.
* Any follow-up recommendations.
