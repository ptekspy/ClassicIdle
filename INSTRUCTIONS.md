I want you to help me implement a major system change in my Roblox game, but this time you are teaching me and guiding me step-by-step.

Do not directly implement the code yourself.

Your job is to:

* inspect the existing repo and world structure
* understand the current systems
* explain the correct architecture
* tell me exactly what files to create or edit
* give me the code to paste
* explain where it goes
* explain why each step matters
* wait for me to confirm each step works before moving to the next step

This should be an interactive teaching workflow, not an autonomous implementation workflow.

# Goal

Convert the current premade conveyor machine system into a player-buildable grid-based factory builder.

The machine should no longer be based on fixed Workspace paths or a premade conveyor chain.

Instead, each player plot should have a 4 stud x 4 stud build grid, and players should buy, equip, preview, rotate, place, move, and connect conveyor/factory pieces on their own plot.

The final direction is:

Player buys piece -> piece goes into hotbar -> player equips piece -> build preview appears -> preview snaps to plot grid -> player rotates to valid direction -> player places piece -> server validates placement -> placed piece becomes part of the player’s conveyor graph.

# Current context

The game currently has/had a premade conveyor-style system.

This task replaces that direction with a buildable grid system.

Player plots already exist.

The grid does not need to be physical. It can be a logical grid over the plot.

Grid cell size:

* 4 studs x 4 studs

Every buildable piece should fit into this grid.

The plot should be divided into logical 4x4 cells based on plot origin, width, and height.

Placed pieces should be saved as grid coordinates and rotation, not arbitrary world CFrames.

# Critical workflow requirement

Do not implement everything in one go.

Teach me step-by-step.

Use small safe steps.

After each step:

* explain what changed
* tell me exactly where to put code
* tell me how to test it in Roblox Studio
* tell me what success should look like
* wait for me to confirm before continuing

Do not continue to the next major step until I confirm the previous one works.

# First task

Before giving code, inspect the repo and produce a detailed implementation plan.

The plan should include:

* current systems found
* files/modules relevant to plot, inventory, placement, hotbar, remotes, data, NPCs, conveyors, resources, and storage
* recommended architecture
* implementation phases
* what should be taught first
* likely risks
* what world/model changes are needed

Wait for my approval before starting step-by-step implementation.

# World changes requirement

If any Roblox Studio world/model/template/part/tag/attribute changes are required, create or update WORLD_CHANGES.md immediately after the initial plan, then stop and wait for my confirmation before teaching implementation.

`WORLD_CHANGES.md` must be ridiculously specific and actionable.

It should include:

* exact Workspace paths
* exact Model names
* exact Part names
* exact Attachment names
* exact CollectionService tags
* exact Attributes
* attribute names, types, and example values
* required folder structure
* required ReplicatedStorage template model locations
* what objects I should create
* what objects I should rename
* what objects I should delete
* what objects I must not delete yet
* model scale expectations
* pivot/origin expectations
* verification checklist

Wait for me to make those world changes and confirm before giving code that depends on them.

# Core design rule

This is a grid-based builder.

Do not build this around fixed conveyor paths.

Do not build this around hardcoded Workspace paths for a single premade machine.

The system should derive the factory from the player’s placed grid pieces.

# Grid system

Each player plot should have a logical 4 stud x 4 stud grid.

Requirements:

* Convert world position to grid coordinate.
* Convert grid coordinate to world position.
* Validate whether a cell is inside the plot.
* Validate whether a footprint fits inside the plot.
* Validate whether cells are occupied.
* Support rotation in 90-degree increments.
* Store placed items using grid coordinates and rotation.
* Derive world CFrame from plot origin, grid coordinate, and rotation.

Placed item data should conceptually look like:

```lua
{
    Id = "unique placed item id",
    ItemId = "StraightConveyor",
    GridX = 4,
    GridZ = 7,
    Rotation = 90,
    Config = {
        ResourceType = "Wood",
    },
}
```

Use the existing data style if the repo already has a preferred pattern.

# Buildable pieces

Implement the build system around config-driven buildable pieces.

The first buildable pieces are:

1. Conveyor Dropper
2. Straight Conveyor
3. Corner Conveyor
4. Conveyor Upgrader
5. Conveyor Collection Bin
6. Worker Home

Use the repo’s existing naming style if different.

# Piece: Conveyor Dropper

Purpose:

* Source/start piece for a conveyor chain.
* Lets the player choose an unlocked resource from storage to drop into the conveyor system.
* The selected resource should be changeable after placement.
* It should visually include space for future worker automation.

Footprint:

* 3 grid cells wide by 1 grid cell deep.
* Local cell 1,1 = Worker home / worker automation area.
* Local cell 2,1 = Dropper base.
* Local cell 3,1 = Dropper output cell.

Important placement rule:

* The dropper reserves a 3x1 footprint.
* The output connector is at local offset 3,1.
* A Straight Conveyor should be allowed/required at the dropper output position depending on the current tutorial/progression step.
* The Straight Conveyor is the only conveyor piece allowed to be placed directly under/at the dropper’s output position if that is how the model is laid out.
* If the existing model layout makes “under” ambiguous, treat this as “the straight conveyor connects to the dropper’s output connector.”

Behaviour:

* The dropper should be able to pull the selected resource from storage and create a visible conveyor piece item.
* Server remains authoritative.
* It should only drop resources the player has unlocked and has available in storage.
* Resource type should be configurable after placement.
* Automation worker support should be designed for later but does not need full NPC automation in the first version unless simple.

# Piece: Straight Conveyor

Purpose:

* Moves conveyor items in a straight line.

Footprint:

* 1x1 grid cell.

Requirements:

* Must fit visually inside one 4x4 grid cell.
* Has one input connector and one output connector.
* Can be rotated in 90-degree steps.
* Shows a visible arrow indicating travel direction.
* Can be placed as the first conveyor connected to a dropper output.

# Piece: Corner Conveyor

Purpose:

* Turns conveyor flow.

Footprint:

* 1x1 grid cell.

Requirements:

* One corner piece should support both left and right style turns through rotation/connector logic if possible.
* Do not create separate left and right pieces unless the architecture strongly requires it.
* Has one input connector and one output connector.
* Rotation should determine the actual world input/output directions.
* Shows a visible arrow indicating travel direction.

Preferred connector definition:

* Base orientation could be input South, output East.
* Rotation transforms these directions.

# Piece: Conveyor Upgrader

Purpose:

* Applies a multiplier to resources passing through it.

Footprint:

* Prefer 1x1 grid cell unless existing model/design requires otherwise.
* It may be visually taller than a conveyor but should fit within the 4x4 cell footprint.

Requirements:

* Has one input connector and one output connector.
* Acts like a straight conveyor for connection purposes.
* Applies multiplier logic to passing items.
* Multiplier should be upgradeable later.
* Shows a visible arrow indicating travel direction.

# Piece: Conveyor Collection Bin

Purpose:

* Endpoint for a conveyor chain.
* Stores output from the conveyor until manually collected.
* Later it can support an automation worker that takes end resources back into storage.

Footprint:

* Prefer 1x1 unless existing model/design requires otherwise.

Requirements:

* Has an input connector.
* Stores received conveyor output.
* Supports manual collection first.
* Future automation support should be considered but not fully implemented unless simple.
* Should visually include a worker-home/automation area or a clear place where automation will live later.

# Piece: Worker Home

Purpose:

* A placeable home/slot for general NPCs such as Wood NPC or Stone NPC.
* This is for general NPC workers, separate from conveyor dropper/collector built-in automation areas.

Footprint:

* 1x1 grid cell.

Visual scale:

* Should not fill the full 4x4 cell.
* Around 3.5 studs x 3.5 studs is preferred.
* Leave some visual padding inside the grid cell.

# Important distinction: Worker Home vs automation space

Do not make the entire system depend on every dropper/collector being a separate Worker Home item.

There are two concepts:

1. Standalone Worker Home

* Used for general NPCs like Wood NPC or Stone NPC.

2. Built-in automation space on Dropper/Collection Bin

* Visual/design space reserved for future automation workers.
* Belongs to that machine piece.
* Should not necessarily be a separate placed Worker Home item.

# Build shop / menu

We need a menu to buy build pieces.

Requirements:

* Player can buy pieces from a build menu/shop.
* Purchased pieces go into the player’s build inventory/hotbar.
* Buying does not immediately place the item.
* The hotbar shows owned unplaced pieces.
* Equipping a hotbar piece enters build mode.
* Placing the piece consumes one owned unplaced copy.
* If a placed piece is picked up/deleted, decide whether it returns to inventory or enters move mode. For MVP, moving existing pieces should not duplicate or refund incorrectly.

Initial pieces in shop:

* Conveyor Dropper
* Straight Conveyor
* Corner Conveyor
* Conveyor Upgrader
* Conveyor Collection Bin
* Worker Home

If pricing already exists, integrate with it.
If pricing does not exist, propose simple starter costs in config.

# Hotbar behaviour

After purchasing a piece:

* Add it to build inventory.
* Show it in the hotbar.
* Equipping it enters build mode.
* Build mode shows a ghost preview of the selected piece.
* Hotbar count should decrease only after server confirms placement.
* Hotbar should update if placement fails.

# Build mode preview

When a player equips a buildable piece:

* Enter build mode.
* Show a ghost model of the piece.
* Snap preview to the plot grid.
* Show valid placement in green.
* Show invalid placement in red or another clear invalid state.
* Allow rotation.
* Only allow rotation to valid 90-degree snaps.
* Placement should be cross-platform.

Client preview is only a preview.
Server must validate final placement.

# Cross-platform controls

Support mouse, touch, and gamepad.

Mouse/keyboard:

* Move ghost using mouse position/raycast.
* Click to place.
* Keyboard key such as R to rotate.
* Escape or right click to cancel.

Touch:

* Tap/select grid cell to position preview.
* Use on-screen Rotate button.
* Use on-screen Confirm/Place button.
* Use on-screen Cancel button.
* Avoid accidental immediate placement from a single tap if possible.

Gamepad:

* Use crosshair/selection movement or grid cursor.
* Use A / primary button to place.
* Use B to cancel.
* Use shoulder button, X, Y, or another suitable button to rotate.
* Rotation controls should be discoverable in UI.

If the repo has an existing input abstraction, use it.
Otherwise implement a small clean input abstraction for build mode.

# Server validation

The server must validate all placement requests.

Validate:

* Player owns the plot.
* Player owns the item being placed.
* Item exists in build config.
* Requested grid coordinate is inside the plot.
* Requested rotation is allowed.
* Footprint fits in plot.
* Footprint does not overlap blocked/occupied cells.
* Tutorial/progression permits this item to be placed.
* Connection rules are satisfied when required.
* The player has enough inventory count.
* The model/template exists.
* The resulting placed item can be created safely.

Never trust client preview.

# Occupancy and footprints

Each buildable item should define its footprint in grid cells.

Examples:

* Straight Conveyor: 1x1
* Corner Conveyor: 1x1
* Conveyor Upgrader: 1x1
* Conveyor Collection Bin: likely 1x1
* Worker Home: 1x1
* Conveyor Dropper: 3x1

Placement should reserve all cells in the footprint.

Rotation must rotate the footprint correctly.

The system needs reusable helpers for:

* rotated footprints
* occupied cell lookup
* bounds checking
* world position conversion
* cell-to-cell neighbour lookup

# Connectors and conveyor graph

Use connector definitions rather than relying on part names or `.Touched` alone.

Each conveyor-capable piece should define:

* input connectors
* output connectors
* connector local grid offsets if needed
* connector direction
* supported rotations

Examples:

Straight Conveyor:

* Input South
* Output North

Corner Conveyor:

* Input South
* Output East

Conveyor Upgrader:

* Input South
* Output North

Conveyor Dropper:

* Output at its output cell

Collection Bin:

* Input from one direction

Rotation should transform connector directions.

The conveyor system should resolve connections by grid adjacency.

Connection example:

* Piece A output points North.
* The grid cell North of Piece A contains Piece B.
* Piece B has an input connector pointing South.
* Therefore the pieces are connected.

This graph should drive resource flow.

Do not build the new system around fixed Workspace paths.

# Conveyor item simulation

The conveyor flow should be derived from placed grid pieces.

Requirements:

* Dropper creates visible resource items.
* Items move along connected conveyor graph.
* Straight conveyor moves items forward.
* Corner conveyor redirects items.
* Upgrader modifies items.
* Collection bin receives and stores items.
* Server remains authoritative.
* Visual items should exist in the world so players can see resources moving.
* Avoid relying purely on `.Touched` as the source of truth.

Each moving item should have logical state such as:

* ResourceType
* Amount
* Multiplier
* CurrentPieceId
* ProgressAlongPiece

Use existing resource/multiplier patterns if already present.

# Conveyor arrows

All conveyor models should have a visible arrow showing travel direction.

Requirements:

* Arrow should be visible on the model.
* Arrow should rotate with the placed piece.
* Arrow direction should match the piece’s output direction.
* This applies to:

  * Straight Conveyor
  * Corner Conveyor
  * Conveyor Upgrader
  * Conveyor Dropper output direction if appropriate

If model changes are needed, list them in `WORLD_CHANGES.md`.

# Tutorial / first placement flow

The first guided build should be:

1. Player places a Conveyor Dropper first.
2. Player places a Straight Conveyor connected to the dropper output.
3. Player places a Collection Bin after the straight conveyor.
4. Then the tutorial tells the player to move the Collection Bin.
5. Player places a Conveyor Upgrader after the straight conveyor.
6. Player places the Collection Bin after the Upgrader.

This means the MVP must support:

* placing a dropper first
* enforcing or guiding straight conveyor connection
* placing a collector
* moving an already placed collector
* placing an upgrader
* placing collector after upgrader

The tutorial/progression rules should prevent confusing placements during the first guided flow if that matches the existing quest system.

# Moving existing pieces

Because the tutorial requires moving the collector, the builder must support at least basic moving of placed pieces.

MVP move behaviour:

* Select an existing placed piece.
* Enter move mode.
* Show ghost preview at new grid location.
* Validate new location.
* Confirm move.
* Server updates placed item grid coordinates/rotation.
* No duplicate item is created.
* Inventory count is not incorrectly changed.

If full edit mode is too large, implement the smallest safe move support needed for the tutorial.

# Resource selection for Dropper

The Conveyor Dropper should allow the selected resource type to be changed after placement.

Requirements:

* Player can choose from unlocked resources in storage.
* Initial supported resources likely include Wood and Stone.
* Selection should be stored in the placed item Config.
* Server validates selected resource is unlocked/allowed.
* Dropper only emits the selected resource if storage has that resource.
* UI can be simple for MVP.

# Persistence

Placed build pieces should persist.

Player data should store:

* build inventory / owned unplaced pieces
* placed build items
* item config such as selected dropper resource
* rotation
* grid coordinates
* upgrades later if already implemented

Use existing player data/ProfileStore/Replica patterns if present.

Be careful with data versioning if the repo has DataVersion.

# Plot expansion compatibility

If player plot width/height already exists in player data, placement should respect it.

The grid should be derived from current plot size.

If plot expansion exists or is planned:

* Do not hardcode permanent grid dimensions.
* Use plot dimensions/config.
* Placement should only be allowed inside unlocked plot area.

# Architecture expectations

Please inspect and reuse existing systems where possible.

Look for:

* Plot service
* Player data service
* Replica/ProfileStore usage
* Inventory/hotbar systems
* UI framework
* Resource/storage systems
* Existing conveyor code
* Existing collector/upgrader code
* Existing remotes
* Existing logger
* CollectionService tag patterns
* Existing model templates
* Existing input handling

Prefer a clean architecture such as:

* BuildGridService_Server

  * validates placement/movement
  * owns placed item data
  * spawns/despawns placed models
  * maintains occupancy
* BuildGridController_Client

  * build mode preview
  * grid snapping
  * input handling
  * ghost model
* BuildItemConfig

  * item definitions, footprint, connectors, templates, prices
* ConveyorGraphService_Server

  * resolves conveyor graph from placed items
  * simulates resource flow
* BuildShopService_Server or integration with existing shop system

  * handles purchasing build pieces
* BuildHotbar UI integration

  * shows owned pieces and selected piece
* Shared grid/connector utility module

  * coordinate conversion
  * rotation helpers
  * footprint helpers
  * connector helpers

Only create these exact modules if they fit the repo conventions.
If the repo already has equivalent services/controllers, integrate there.

# Teaching implementation phases

After the plan and any required world changes are approved, teach implementation in this order:

Phase 1: Build item config

* Define buildable items.
* Define footprints.
* Define rotations.
* Define connectors.
* Define template paths.
* Define prices if needed.

Phase 2: Grid utilities

* Implement world-to-grid and grid-to-world conversion.
* Implement rotated footprint calculation.
* Implement bounds and occupancy helpers.
* Test conversion with simple prints/debug.

Phase 3: Server placement validation

* Add remote/event for placement requests.
* Validate item ownership and grid placement.
* Place a simple model on the server.
* Save placed item data.

Phase 4: Client build preview

* Equip hotbar item.
* Show ghost preview.
* Snap to grid.
* Rotate preview.
* Show valid/invalid color.
* Send placement request.

Phase 5: Build shop and hotbar

* Purchase pieces.
* Add to build inventory.
* Show in hotbar.
* Equip piece from hotbar.
* Decrement only after successful placement.

Phase 6: Move existing piece

* Select placed collector.
* Move it to new grid location.
* Validate move on server.
* Update model and saved data.

Phase 7: Conveyor connectors and graph

* Resolve connections between placed pieces.
* Validate dropper -> conveyor -> collector chain.
* Add arrows/visual direction if not already in model.

Phase 8: Conveyor item movement MVP

* Dropper emits selected resource from storage.
* Item moves along graph.
* Upgrader modifies multiplier.
* Collection bin receives item.
* Manual collection works.

Phase 9: Tutorial restrictions

* Enforce/guided flow:

  * Dropper first
  * Straight conveyor connected to output
  * Collector
  * Move collector
  * Upgrader
  * Collector after upgrader

Phase 10: Persistence and cleanup

* Ensure placed items reload.
* Ensure inventory reloads.
* Ensure ghost/move/build states reset correctly.
* Validate after player rejoin.

Each phase should be taught separately and wait for confirmation.

# Non-goals for the first implementation

Do not implement:

* Full arbitrary factory networks with splitters/combiners.
* Advanced pathfinding.
* Multiplayer trading of build pieces.
* Polished final UI.
* Advanced model art.
* Multiple floors.
* Diagonal placement.
* Non-90-degree rotation.
* Large terrain/world generation.
* Full worker automation for dropper/collector unless already easy.
* Complex performance optimization before the MVP works.
* A full drag-and-drop editor if simple click/tap placement is enough.

# Edge cases

Handle or design for:

* Player tries to place outside plot.
* Player tries to overlap pieces.
* Player tries to place without owning item.
* Player rotates to invalid orientation.
* Player leaves while in build mode.
* Client sends invalid grid coordinate.
* Client sends invalid item id.
* Model template missing.
* Plot origin missing.
* Plot size missing.
* Existing placed item data is invalid.
* Player tries to move collector onto occupied cells.
* Player tries to delete/move a piece while conveyor items are active.
* Dropper has no selected resource.
* Dropper selected resource is no longer unlocked.
* Storage does not have enough resource to drop.
* Conveyor graph is incomplete.
* Conveyor loop exists.
* Collection bin is missing.
* Collection bin is full.
* Upgrader receives unsupported resource type.
* Hotbar count desyncs.
* Server rejects placement after client showed valid preview.

# Code standards

* Follow existing repo conventions.
* Inspect nearby files before giving code.
* Match existing naming, folder structure, module style, service/controller patterns, typing style, and logging style.
* Keep code small, readable, and maintainable.
* Teach using small increments.
* Prefer strict typing where the repo already uses it.
* Avoid broad rewrites.
* Do not introduce new dependencies unless clearly necessary.
* Do not change generated files.
* Do not make unrelated formatting changes.
* Preserve existing public APIs unless necessary.
* Handle nil/invalid instances defensively.
* Avoid duplicated logic.
* Prefer shared helpers for:

  * grid coordinate conversion
  * rotated footprints
  * occupied cells
  * connector transforms
  * placement validation
  * hotbar inventory updates
  * conveyor graph resolution

# What your answers should look like

Because you are teaching me, structure each implementation step like this:

1. What we are building in this step
2. Why this step exists
3. Files to create/edit
4. Exact code to paste
5. Any Roblox Studio changes needed
6. How to test it
7. What success looks like
8. Common errors to watch for
9. Stop and wait for my confirmation

Do not dump 20 files at once.

Do not skip explanations.

Do not assume I know where code goes.

Do not continue to the next step until I confirm.

# Initial response required

Your first response should not contain implementation code.

First response should:

* Summarise what you found in the repo.
* Identify the current systems that matter.
* Propose the architecture.
* Propose the teaching phases.
* Identify required world/model/template changes.
* Identify any assumptions.
* Ask only genuinely blocking questions.

Then follow this rule:

If world/model/template changes are needed:

* Create or update `WORLD_CHANGES.md`.
* Make it extremely specific and checklist-driven.
* Stop and wait for me to make those changes and confirm.

If no world/model/template changes are needed:

* Do not create `WORLD_CHANGES.md`.
* Stop and wait for me to confirm that you should continue to the first teaching implementation step.

Do not start implementation code in the initial response.
Do not continue until I explicitly confirm.
