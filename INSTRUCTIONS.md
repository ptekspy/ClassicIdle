I want you to come up with an implementation plan for improving the AutoCollector NPC system.

Do not implement the changes yet. First inspect the existing codebase and produce a clear technical plan.

Current behaviour:

* We currently have NPCs for auto collectors.
* The NPCs stand still.
* A resource piece spawns out of the NPC’s hand.
* This is only placeholder behaviour and needs replacing.

Desired behaviour:

* AutoCollector NPCs should physically collect resources from world resource nodes.
* An NPC should be assigned to a specific resource type, for example Wood, Stone, or Coal.
* If the NPC is assigned to Wood, it should find resource nodes where `ResourceType` is `Wood`.
* The NPC should walk to the nearest valid resource node.
* The NPC should collect from that node.
* The NPC should then walk back to the assigned storage bin.
* The NPC should deposit the collected resources into the storage bin.
* The NPC should repeat this loop.

NPC stats:

* NPCs should have a movement speed.
* Starting speed should be `10`, slower than a normal player.
* NPCs should have a collection amount.
* Starting collection amount should be `1`.
* These values should probably come from attributes or config so different NPCs/upgrades can modify them later.

Resource node behaviour:

* Resource nodes should have a `ResourceType`, for example `Wood`.
* Resource nodes may have different levels or capacities later.
* The collection amount may need to respect the resource node’s current available amount.
* The system should support world nodes having different values/levels via attributes or config.

Storage bin behaviour:

* The NPC should deposit collected resources into the assigned storage bin.
* If the storage bin is full, the NPC should wait at the storage bin.
* Once there is room again, the NPC should deposit and continue the collection loop.
* The NPC should not keep collecting if it cannot deposit.
* The system should avoid dropping or deleting resources when the bin is full.

Planning requirements:

* Inspect the existing AutoCollector/NPC/resource/storage code.
* Identify the current placeholder behaviour.
* Identify where resource spawning currently happens.
* Identify the best place to move this logic into a proper NPC collection loop.
* Identify existing services/modules/types/configs that should be reused.
* Identify whether CollectionService tags, attributes, or existing config should be used to find resource nodes.
* Identify how storage bin capacity is currently represented.
* Identify how resource deposits are currently handled.
* Identify how this should work on the server.

Architecture considerations:

* NPC movement should be server-authoritative.
* The client should not decide collection, deposit, or storage amounts.
* Use Roblox PathfindingService only if necessary.
* If the world/resource layout is simple enough, Humanoid:MoveTo may be enough initially.
* The plan should explain whether PathfindingService is needed now or should be deferred.
* NPCs should not all pick the exact same node if there are multiple collectors, unless the current game rules allow that.
* Consider reserving or locking a target node while an NPC is travelling to it.
* Consider what should happen if a target node disappears, is depleted, or becomes invalid while the NPC is moving.
* Consider what should happen if the storage bin is destroyed, locked, full, or unavailable.
* Consider how the loop should stop/cleanup when the NPC, plot, player, or collector is removed.

Suggested NPC state machine:

* Idle
* FindingResourceNode
* MovingToResourceNode
* Collecting
* MovingToStorageBin
* Depositing
* WaitingForStorageSpace

The plan may adjust these states if the existing codebase suggests a better approach.

Validation cases to include in the plan:

* NPC finds the nearest valid resource node for its assigned `ResourceType`.
* NPC walks to the resource node.
* NPC collects the correct amount.
* NPC walks back to storage.
* NPC deposits into storage.
* NPC waits if storage is full.
* NPC resumes once storage has room.
* NPC handles no available resource nodes gracefully.
* NPC handles a node being removed while travelling.
* NPC handles storage becoming invalid.
* Multiple NPCs can operate without fighting over the same target in a broken way.

Code standards:

* Follow the existing repo conventions.
* Inspect nearby files before proposing changes.
* Match existing naming, folder structure, module style, typing style, logging style, and service/controller patterns.
* Keep the proposed implementation small, readable, and maintainable.
* Prefer clear modules with single responsibilities.
* Avoid broad rewrites.
* Do not introduce new dependencies unless clearly necessary.
* Do not change generated files.
* Do not make unrelated formatting changes.
* Preserve existing public APIs unless there is a strong reason to change them.
* Use strict typing where the repo already uses it.
* Handle nil/invalid instances defensively.
* Avoid duplicated logic.
* Prefer shared helpers for common resource lookup, distance checks, capacity checks, and deposit logic.

Output required:

* A concise summary of the current system.
* A proposed architecture.
* The main files/modules that should change.
* Any new modules/types/configs that should be added.
* The proposed NPC state machine.
* How resource nodes should be discovered.
* How storage capacity/deposit should be handled.
* How NPC stats should be configured.
* Edge cases and how to handle them.
* Step-by-step implementation plan.
* Validation/testing plan.
* Any questions or assumptions that need confirming before implementation.
