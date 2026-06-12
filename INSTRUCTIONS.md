I want you to implement the MVP conveyor machine system for the current Roblox game, but this must be done as a plan-first workflow.

Do not implement code immediately.

First, inspect the existing repo and Roblox world structure, then produce a technical implementation plan.

After I approve the plan, your next task is to create a `WORLD_CHANGES.md` file before implementing code.

`WORLD_CHANGES.md` must describe every manual Roblox Studio world/model/part/attribute/tag change I need to make before implementation starts.

The file must be ridiculously specific and actionable.

It should include things like:

* Exact Workspace paths to create or modify.
* Exact Model names.
* Exact Part names.
* Exact Attachment names.
* Exact CollectionService tags to add.
* Exact Attributes to add.
* Attribute names, types, and example values.
* Which parts should be anchored.
* Which parts should be CanCollide true/false.
* Which parts should be transparent.
* Which parts are visual only.
* Which parts are interaction/purchase pads.
* Which parts are conveyor start/end points.
* Which parts represent preview/ghost models.
* Which parts should be used as processor input/output points.
* Which parts should be used as collection point input/manual collect area.
* Any required folder structure under Workspace.
* Any required ReplicatedStorage model/template locations.
* Any required naming conventions.
* Any assumptions about existing models.
* Anything I should delete, rename, or move.
* Any ProximityPrompt/NPC/old coal-production world objects that should be left alone until the code is ready.
* Any objects that must not be deleted yet.

The workflow should be:

1. Inspect repo and world using available tools.
2. Produce implementation plan only.
3. Wait for my approval.
4. Create `WORLD_CHANGES.md` with exact manual Roblox Studio changes.
5. Wait for me to make those world changes and confirm.
6. Only then implement the code.

Important:

* Do not start implementation before I confirm the world changes are done.
* Do not assume I know what to create in Roblox Studio.
* `WORLD_CHANGES.md` should be written for someone manually editing the world.
* Be extremely explicit, even if it feels obvious.
* Prefer checklists and exact paths.
* Include a verification checklist at the end of `WORLD_CHANGES.md` so I can confirm the world is ready.

# Goal

Replace the current Coal NPC production loop with a conveyor-based coal machine.

The new machine flow should be:

Storage Bin -> Conveyor 1 -> Upgrader 1 -> Coal Processor -> Conveyor 2 -> Upgrader 2 -> Collection Point

# Current behaviour

* Wood NPC collects Wood and deposits it into the Storage Bin.
* Stone NPC collects Stone and deposits it into the Storage Bin.
* Coal production is currently handled by an NPC-style flow.
* That Coal NPC-style production should be replaced by the conveyor machine.
* The existing Wood and Stone NPC systems should continue to work.

# Desired gameplay behaviour

* The player unlocks the conveyor machine as part of progression.
* After the player buys their first Stone NPC, they should unlock the ability to purchase Conveyor 1.
* Once Conveyor 1 is purchased, the rest of the coal machine should appear as ghost/preview pieces.
* The player then buys the remaining machine parts separately:

  * Upgrader 1
  * Coal Processor
  * Conveyor 2
  * Upgrader 2
  * Collection Point
* The full machine should not run until the required machine chain is built.
* The Collection Point should be manual collection only for now.
* Do not implement the automated Collection Point NPC in this task.

# Machine flow

The machine should work like this:

1. Storage Bin provides raw Wood and Stone.
2. Conveyor 1 visually moves raw resource pieces from storage toward the processor.
3. Upgrader 1 applies a multiplier increase to raw Wood and Stone pieces.
4. Coal Processor buffers inputs.
5. Coal Processor consumes:

   * 2 Wood
   * 1 Stone
6. Coal Processor outputs:

   * 1 Coal
7. Conveyor 2 visually moves the Coal piece toward the Collection Point.
8. Upgrader 2 multiplies the Coal piece’s current multiplier.
9. Collection Point stores the resulting Coal output.
10. Player manually collects from the Collection Point.

# Visual requirement

* I expect a visible representation of each resource piece moving on the conveyor belt.
* The moving piece should exist visually in the world.
* The server should remain the source of truth for item state and value.
* Client visuals may mirror server state, but client should not decide resource amounts, multipliers, processing, or collection value.

# Resource piece data

Each moving resource piece should support state such as:

* ResourceType
* Amount
* Multiplier

Raw resource defaults:

* Amount = 1
* Multiplier = 1

Do not duplicate resource pieces as the upgrader behaviour.

# Upgrader behaviour

Upgrader 1:

* Applies to raw Wood and Stone pieces.
* Increases their Multiplier.
* Does not duplicate pieces.
* Should be upgradeable so higher levels increase the multiplier more.

Upgrader 2:

* Applies to output Coal pieces.
* Multiplies the Coal piece’s current Multiplier.
* Should be upgradeable so higher levels increase the multiplier more.

Example:

* Wood piece enters Upgrader 1 with Multiplier 1.
* Upgrader 1 has MultiplierValue of 2.
* Wood leaves with Multiplier 2.

Then later:

* Coal enters Upgrader 2 with Multiplier 7.
* Upgrader 2 multiplier is 2.
* Coal leaves with Multiplier 14.

Use whatever attribute/config naming best matches the existing project.

# Coal Processor behaviour

Coal Processor recipe:

* 2 Wood
* 1 Stone
* outputs 1 Coal

Processor requirements:

* It should buffer inputs until it has enough resources.
* It should not require every ingredient to arrive at the exact same frame/time.
* It needs to preserve the multipliers of consumed input pieces.
* Output Coal should inherit a combined multiplier from the consumed inputs.
* Preferred MVP rule:

  * Coal.Multiplier = sum of the multipliers of the consumed input pieces
* The Coal Processor should also support its own output multiplier.
* Final output from the processor should include both:

  * inherited input multiplier
  * processor output multiplier

Preferred processor formula:

Coal.Multiplier = sum(consumedInputMultipliers) * ProcessorOutputMultiplier

Example:

* Consumed Wood(multiplier 2), Wood(multiplier 2), Stone(multiplier 3)
* Sum = 7
* ProcessorOutputMultiplier = 1.5
* Output Coal.Multiplier = 10.5

Then Upgrader 2 can multiply that again.

# Upgradeable machine stats

The system should support upgrades for machine parts.

Conveyor upgrades:

* Conveyor level should increase conveyor speed.
* Higher level conveyors move pieces faster.
* Starting conveyor speed should be configurable.
* Speed should be read from attributes/config or derived from level.

Upgrader upgrades:

* Upgrader level should increase the multiplier effect.
* Higher level upgraders apply stronger multipliers.
* Starting multiplier should be configurable.
* Multiplier should be read from attributes/config or derived from level.

Coal Processor upgrades:
Coal Processor should have two separately upgradeable attributes:

1. Processing time

   * Higher levels should reduce the time it takes to finish processing.
   * This controls how long the processor takes after it has enough inputs.

2. Processor output multiplier

   * Higher levels should increase the multiplier applied to output Coal.
   * This is separate from the processing speed upgrade.
   * This multiplier applies before Upgrader 2.

These should be separate upgrade paths, not one combined processor level unless the existing project strongly suggests otherwise.

Suggested processor state:

* InputBuffer
* IsProcessing
* ProcessingStartedAt or remaining processing time
* ProcessingDuration
* OutputMultiplier

# Progression / unlock flow

This should feel like a story quest / staged build.

Unlock stages:

1. Player buys first Stone NPC.
2. Conveyor 1 becomes available to purchase.
3. Player buys Conveyor 1.
4. Remaining machine parts appear as ghost previews:

   * Upgrader 1
   * Coal Processor
   * Conveyor 2
   * Upgrader 2
   * Collection Point
5. Player buys each previewed part.
6. Preview part is replaced with the real/built part.
7. Machine only becomes active once the required full chain exists.

# Preview / ghost model behaviour

Preview models should:

* Be visible in-world.
* Be non-functional.
* Be non-interactable unless they are currently purchasable.
* Be visually distinct from built parts.
* Use high transparency, likely around Transparency = 0.8.
* Have a dark or black-ish outline.
* Show the player what the finished machine will look like.

Important Roblox transparency note:

* If the intention is “20% visible”, Roblox Transparency should be around 0.8.
* Do not use Transparency = 0.2 if that makes the preview too solid.

If the project already has a preview/locked/ghost placement pattern, reuse that.

# Suggested machine part states

Use a clean state model if possible:

* Locked
* Preview
* Built
* Active

Meaning:

* Locked: not visible or not available yet.
* Preview: visible as ghost, not functional.
* Built: purchased and real.
* Active: built and part of a complete working machine.

The machine should not operate if any required part is missing or only in Preview state.

# Collection Point behaviour

* Collection Point stores produced Coal value for manual collection.
* Collection should transfer the correct weighted Coal amount/value.
* If Coal pieces have Amount and Multiplier, collection should account for both.
* Simple MVP approach:

  * When a Coal piece reaches the Collection Point, add `Amount * Multiplier` to the stored Coal amount/value.
* Collection Point should have capacity.
* If Collection Point is full, output should pause safely.
* Do not lose resources if the Collection Point is full.

# Storage Bin behaviour

* Storage Bin must provide raw Wood and Stone to the machine.
* Use existing storage methods if they exist.
* Do not directly mutate player data if the project already has storage/resource services.
* If Storage Bin does not have enough resources, the machine should wait.
* The machine should never create raw resources from nothing.

# Server authority

The conveyor system must be server-authoritative.

Server decides:

* When resources are withdrawn from storage.
* What moving pieces exist.
* Piece ResourceType, Amount, and Multiplier.
* Upgrader effects.
* Processor buffers and outputs.
* Collection Point stored value.
* Manual collection result.

Client may:

* Render visuals.
* Show UI.
* Reflect machine state.

Client must not:

* Decide resource values.
* Decide multipliers.
* Trigger production directly.
* Award resources directly.

# Architecture expectations

Please inspect the repo and reuse existing systems where possible.

Look for existing:

* NPC services
* Resource services
* Storage/bin services
* Collector services
* Unlock/progression systems
* Plot systems
* Item/resource config
* Logger patterns
* Remote/event patterns
* Attribute/config patterns

Prefer a simple architecture such as:

* ConveyorService

  * controls machine loops and moving pieces
  * moves pieces between machine stages
* MachinePartConfig or ConveyorConfig

  * defines speeds, multipliers, upgrade curves, recipe info
* Processor logic

  * may live in ConveyorService for MVP, or separate module if cleaner
* Collection Point logic

  * integrate with existing storage/resource collection patterns

Do not create a huge generic automation framework unless the existing architecture already points that way.

# Implementation phases

Phase 1: Inspect and map current systems

* Find current Coal NPC production code.
* Find Wood/Stone NPC deposit logic.
* Find Storage Bin implementation.
* Find unlock/progression purchase logic.
* Find any existing model/attribute conventions.
* Inspect the current Roblox world structure using Roblox MCP if available.
* Identify exactly what world/model/part changes are needed.

Phase 2: Produce implementation plan only

* Summarise current system.
* Explain proposed implementation.
* List files/modules likely to change.
* List new files/modules likely to be added.
* Explain assumptions.
* Explain risks.
* Stop and wait for approval.

Phase 3: After plan approval, create `WORLD_CHANGES.md`

* Do not implement code yet.
* Create a `WORLD_CHANGES.md` file in the repo.
* This file must contain the exact manual Roblox Studio world changes needed before implementation.
* Be extremely specific and checklist-driven.
* Stop and wait for me to confirm I have made those changes.

Phase 4: Only after I confirm world changes are done, implement machine state/progression

* Add unlock after first Stone NPC purchase.
* Add purchasable Conveyor 1.
* Add preview states for remaining machine pieces.
* Add built/active state tracking.

Phase 5: Add visual conveyor piece movement

* Create visible moving resource pieces.
* Ensure pieces have server-owned state.
* Move pieces through the machine path.
* Keep movement simple and reliable.

Phase 6: Add Upgrader 1 and Processor

* Pull Wood/Stone from Storage Bin.
* Apply Upgrader 1 raw resource multiplier.
* Buffer processor inputs.
* Process 2 Wood + 1 Stone into Coal.
* Apply ProcessorOutputMultiplier.

Phase 7: Add Conveyor 2, Upgrader 2, Collection Point

* Move Coal to Collection Point.
* Apply Upgrader 2.
* Store weighted Coal output.
* Support manual collection.

Phase 8: Add upgradeable stats

* Conveyor speed upgrade support.
* Upgrader multiplier upgrade support.
* Coal Processor processing-time upgrade support.
* Coal Processor output-multiplier upgrade support.

Phase 9: Validate edge cases

* Missing resources.
* Missing machine parts.
* Full Collection Point.
* Invalid destroyed parts.
* Incomplete machine.
* Manual collection.

# Non-goals for this task

Do not implement:

* Automated Collection Point NPC.
* Multiple processor recipes.
* Multiple machine layouts.
* Advanced conveyor routing.
* Player-designed conveyor placement.
* Generic splitter/combiner network.
* Client-authoritative production.
* Large unrelated refactors.

# Edge cases to handle

* Storage Bin does not have enough Wood.
* Storage Bin does not have enough Stone.
* Processor has partial ingredients.
* Processor is already processing.
* Collection Point is full.
* Machine is incomplete.
* Machine part exists only as Preview.
* Moving piece becomes invalid.
* Upgrader receives the wrong ResourceType.
* Player leaves while machine is running.
* Plot/model is removed while machine is running.
* Upgrade values are missing or invalid.
* Manual collection occurs while output is being added.

# Code standards

* Follow existing repo conventions.
* Inspect nearby files before implementing.
* Match existing naming, folder structure, module style, service/controller patterns, typing style, and logging style.
* Keep code small, readable, and maintainable.
* Prefer explicit state over hidden side effects.
* Avoid broad rewrites.
* Do not introduce new dependencies unless clearly necessary.
* Do not change generated files.
* Do not make unrelated formatting changes.
* Preserve existing public APIs unless necessary.
* Use strict typing where the repo already uses it.
* Handle nil/invalid instances defensively.
* Avoid duplicated logic.
* Prefer shared helpers for:

  * resource validation
  * conveyor item state
  * machine part state
  * multiplier calculation
  * upgrade stat calculation
  * storage capacity checks
  * collection point deposits

# Validation checklist

Progression:

* Buying the first Stone NPC unlocks Conveyor 1.
* Conveyor 1 can be purchased.
* Buying Conveyor 1 reveals the rest of the machine as ghost previews.
* Preview parts look ghosted and are non-functional.
* Buying a preview part replaces it with a real built part.
* Machine does not run until the required chain is complete.

Conveyor:

* Visual resource pieces appear on Conveyor 1.
* Visual Coal pieces appear on Conveyor 2.
* Conveyor speed changes when conveyor level/speed is upgraded.

Upgrader:

* Upgrader 1 increases Wood/Stone multipliers.
* Upgrader 1 does not duplicate pieces.
* Upgrader 1 multiplier improves with upgrade level.
* Upgrader 2 multiplies Coal’s current multiplier.
* Upgrader 2 multiplier improves with upgrade level.

Processor:

* Processor buffers inputs.
* Processor consumes 2 Wood and 1 Stone.
* Processor waits if it has only partial ingredients.
* Processor processing time is respected.
* Processor processing time improves with its processing-time upgrade.
* Processor output multiplier is applied.
* Processor output multiplier improves with its separate output-multiplier upgrade.

Collection Point:

* Coal reaches Collection Point.
* Collection Point stores the correct weighted Coal amount/value.
* Manual collection gives the player the correct Coal value.
* Collection Point capacity is respected.
* If Collection Point is full, output pauses safely.

Safety:

* No resources are lost.
* No resources are duplicated incorrectly.
* Client cannot award itself resources.
* Server rejects invalid production/collection paths.

# Final response after implementation

When finished, summarise:

* What changed.
* Main files touched.
* How the conveyor machine flow works.
* How upgradeable stats work.
* How progression and ghost previews work.
* Any assumptions made.
* What validation was run.
* Any follow-up recommendations.
