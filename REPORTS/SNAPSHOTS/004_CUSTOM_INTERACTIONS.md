# ClassicIdle Codebase Snapshot 004: Custom Interactions

**Snapshot date:** 2026-06-11  
**Repository state:** `main`, custom interaction implementation complete and pending snapshot commits  
**Previous snapshot:** `003_PLAYER_PLOTS_AND_FEEDBACK.md`  
**Scope:** Source files plus live Studio validation of targeting, prompt migration, server validation, and prompt-free gameplay.

## Executive Summary

This snapshot records the replacement of Roblox's built-in ProximityPrompt interaction UX with a custom device-compatible targeting system.

The interaction source of truth now lives in shared configuration and attributes rather than ProximityPrompt instances. Each cloned player plot receives eight tagged interactable parts. A shared client controller chooses one focused target, renders a white outline and custom prompt, and sends activation requests through `InteractionRequest`. An authoritative server service validates every request before dispatching it to reusable gameplay handlers in `WorldService`.

Mouse targeting, prompt visibility, focus removal, nearby activation, out-of-range rejection, and gameplay with every cloned ProximityPrompt deleted were validated in Studio. Gamepad and touch paths are implemented using centre-screen forgiving targeting, gamepad `X`, and an on-screen touch button, but require final manual device-emulation testing because the Studio bridge cannot inject those input types.

The migration removes the runtime dependency on ProximityPrompt instances. Existing prompts in the Studio-only `PlotTemplate` are disabled when a plot is registered and can now be deleted safely.

## Snapshot Inventory

### First-Party Code

- 29 Luau files outside `src/ReplicatedStorage/Packages`
- Approximately 2,399 lines of first-party Luau
- 9 service modules, including the new `InteractionService`
- 1 client controller module
- Shared interaction config, types, and geometry helper
- 2 managed RemoteEvents: `FeedbackEvent` and `InteractionRequest`
- No automated tests

Snapshot 003 contained 25 first-party Luau files and approximately 1,942 lines. This milestone adds approximately 457 lines while removing all prompt-trigger connection code and the obsolete `getPrompt` utility.

## Interaction Architecture

### End-to-End Flow

```text
PlotService.Claim
  -> InteractionService.RegisterPlot
       -> disable every cloned ProximityPrompt
       -> configure eight intended interactable parts
       -> add Interactable tag
       -> set ID, labels, range, and owner attributes

InteractionController
  -> determine current input mode
  -> select one valid owned target
  -> show white outline and custom prompt
  -> fire InteractionRequest(target)

InteractionService
  -> rate-limit request
  -> verify target type and existence
  -> verify Interactable tag and required attributes
  -> verify target belongs to player's current plot
  -> verify owner user ID
  -> verify distance and line of sight
  -> dispatch validated interaction ID

WorldService.HandleInteraction
  -> run the existing gameplay action
  -> update displays, unlock text, and feedback
```

### Shared Contract

`ReplicatedStorage.Interaction.Config` defines:

- The `Interactable` CollectionService tag.
- Attribute names used by client and server.
- The allowed interaction ID for each plot part.
- Default action text and object text.
- Default maximum interaction range of 10 studs.

Configured interactables:

| Plot part | Interaction ID | Default action |
| --- | --- | --- |
| `ManualTree` | `ManualTree` | Chop |
| `ManualRock` | `ManualRock` | Mine |
| `SellCrate` | `SellCrate` | Sell Storage |
| `AutoChopperButton` | `BuyAutoChopper` | Buy Auto Chopper |
| `AutoMinerButton` | `BuyAutoMiner` | Locked |
| `StorageUpgradeButton` | `UpgradeStorage` | Upgrade Storage |
| `AutoProcessorButton` | `BuyAutoProcessor` | Locked |
| `CoalProcessor` | `ProcessCoal` | Locked |

Accidental prompts on `AutoChopperMachine`, `AutoMinerMachine`, and `PlayerSpawn` are disabled but are not registered as interactions.

### Dynamic Interaction Text

`WorldService.UpdateUnlocks` now writes current action and object text to attributes on the interactable parts.

This replaces previous writes to `ProximityPrompt.ActionText` and `ObjectText`. Dynamic values include:

- Current upgrade costs.
- Locked and unlocked actions.
- Unlock requirements.
- Coal recipe text.

The client prompt reads those attributes every frame while the target is focused, so visible text updates without a separate UI remote.

## Client Targeting

`InteractionController` owns one targeting and presentation loop for all devices.

### Mouse and Keyboard

- Raycasts through the mouse cursor.
- Shows the focused target's outline and prompt.
- Activates with mouse click or `E`.

### Gamepad

- Raycasts through the viewport centre.
- Falls back to nearby valid interactables projected near the screen centre.
- Scores fallback candidates using screen-centre distance and world distance.
- Shows a centre crosshair and `X` hint.
- Activates with gamepad `X`.

### Touch

- Uses the same centre-screen ray and forgiving fallback as gamepad.
- Shows the centre crosshair.
- Shows a large on-screen interaction button only while a target is focused.
- Activates through the touch button.

### Focus Presentation

- Only one target can be focused.
- A single `Highlight` instance is reused.
- Highlight fill is fully transparent.
- Highlight outline is white.
- One responsive bottom-screen custom prompt shows action, object text, and device hint.
- Looking away or moving out of range clears the prompt and highlight.

### Top-Down Camera Fix

Live testing found that invisible `Workspace.PlotSpawns` placement parts overlap the playable plots and have `CanQuery = true`. At steep camera angles, targeting rays could hit an invisible spawn marker before the intended interactable.

Client targeting and server line-of-sight rays now exclude `Workspace.PlotSpawns`. Real plot geometry and walls continue to participate in raycasts.

## Server Authority and Security

`InteractionService` treats every client activation as untrusted.

Before dispatching an interaction, it verifies:

- Requests do not exceed the server rate limit.
- The submitted value is a live `BasePart` in Workspace.
- The part has the `Interactable` tag.
- Required ID, owner, and range attributes have valid types.
- The part belongs to the requesting player's current plot.
- The owner attribute matches the requesting player's user ID.
- The character has a valid `HumanoidRootPart`.
- The closest point on the target is within the configured range.
- The character has line of sight to the target.

Gameplay permissions remain checked inside the relevant `WorldService` handler. For example, a validated request to use a locked rock still produces the locked feedback rather than granting stone.

## ProximityPrompt Migration

### Removed Dependencies

- `WorldService` no longer connects `ProximityPrompt.Triggered`.
- `WorldService` no longer reads or writes ProximityPrompt labels.
- The `getPrompt.luau` utility has been removed.
- Gameplay handlers are reusable server functions dispatched by interaction ID.

### Temporary Compatibility

`InteractionService.RegisterPlot` disables every ProximityPrompt found in a cloned plot. This prevents built-in prompt UI and duplicate activation while the Studio template still contains old prompts.

Live testing deleted all 11 ProximityPrompts from a cloned plot and confirmed that the new interaction system continued activating gameplay without errors.

The remaining manual migration step is to delete the old ProximityPrompt instances from the Studio-only `ReplicatedStorage.Assets.PlotTemplate`.

## Changes Since Snapshot 003

### Resolved or Materially Improved

| Snapshot 003 state | Snapshot 004 status |
| --- | --- |
| Interactions depended on ProximityPrompt instances | Resolved; prompts are no longer required |
| Prompt labels were the interaction UI source of truth | Resolved through shared config and part attributes |
| Prompt callbacks directly owned gameplay handlers | Resolved through reusable `WorldService` actions |
| Client had feedback UI but no gameplay targeting controller | Resolved with `InteractionController` |
| Remote registry lacked a client-to-server gameplay request | Added `InteractionRequest` with authoritative validation |
| Prompt connection lifecycle needed per-player cleanup | Removed; no per-prompt connections remain |
| Accidental prompts could appear on non-interactable parts | Resolved by disabling all cloned prompts and tagging only eight parts |

### Still Open

| Earlier finding | Current status |
| --- | --- |
| Plot assets and spawn layout are Studio-only | Still open |
| Duplicate `Plot08` spawn name | Still open |
| No automated gameplay or lifecycle tests | Still open |
| Existing profile values are not validated | Still open |
| Full-storage coal processing rejects a valid recipe | Still open |
| `WorldService` owns many gameplay concerns | Improved by interaction extraction, but still open |
| RemoteManager has weak static types | Still open |
| Old prompts remain in the Studio template | Safe to delete manually |

## What Is Working Well

### Interaction UX and Authority Are Separate

The client decides what to focus and how to present it, while the server independently decides whether an activation is valid. A modified client cannot bypass plot ownership, range, line-of-sight, or progression checks.

### Migration Has a Clear Source of Truth

New interactions are added in one shared definition table and mapped to one server handler. Prompt instances are no longer hidden configuration objects.

### Device Paths Reuse Targeting Logic

Mouse, gamepad, and touch share the same target validity, range, focus, highlight, prompt, and activation flow. Only target-point selection and UI hints differ.

### WorldService Is Smaller and Easier to Invoke

Removing eight prompt connection wrappers made the gameplay actions explicit functions. This makes them easier to test and keeps remote validation outside the economy and world logic.

## Priority Findings

### P1: Gamepad and Touch Need Manual Device Testing

The implemented input paths could not be activated through the Studio MCP bridge because synthetic gamepad/touch injection lacks the required Roblox capability. Verify target forgiveness, UI placement, and activation using Studio device emulation or physical devices.

### P1: Plot Assets Still Cannot Be Recreated from Source

The working `PlotTemplate`, old ProximityPrompts, and `PlotSpawns` remain Studio-only. A fresh source build still cannot reproduce the game.

### P1: No Automated Interaction Tests

Server validation now protects an important client-to-server boundary but has no automated coverage. Ownership, range, tags, line of sight, invalid target types, and request throttling should receive focused tests.

### P2: Client Target Search Runs Every Render Frame

Mouse targeting performs one raycast per frame. Gamepad/touch fallback may iterate all tagged interactables and perform line-of-sight checks when the centre ray misses. This is reasonable for the current 80 maximum interactables across 10 plots, but should be profiled if plot count or interaction density grows.

### P2: Interaction Labels Are Attributes with Weak Static Types

Attributes replicate efficiently and are easy to inspect, but invalid runtime values are only handled defensively. A typed client/server interaction state model may become worthwhile as interactions gain hold durations, disabled states, icons, or richer requirements.

### P2: RemoteManager Still Uses Dynamic Untyped Members

Consumers cast `InteractionRequest` and `FeedbackEvent` manually. The growing remote contract makes typed RemoteManager accessors increasingly valuable.

## Recommended Next Steps

1. Manually test gamepad and touch using Studio device emulation.
2. Delete all old ProximityPrompts from `ReplicatedStorage.Assets.PlotTemplate`.
3. Rename the duplicate `Plot08` spawn to `Plot09`.
4. Source-control the completed plot template and spawn layout.
5. Add server tests for invalid interaction requests and valid handler dispatch.
6. Add pure tests for interaction targeting scores and range geometry.
7. Add typed RemoteManager accessors.
8. Continue splitting machine-specific orchestration out of `WorldService`.

## Suggested Interaction Test Matrix

| Scenario | Expected result |
| --- | --- |
| Mouse aims at owned target in range | Target highlights and prompt appears |
| Mouse looks away | Highlight and prompt disappear |
| Player moves out of range | Focus clears and activation does nothing |
| Client submits another player's target | Server rejects request |
| Client submits an untagged part | Server rejects request |
| Client submits target from too far away | Server rejects request |
| Client submits target through blocking geometry | Server rejects request |
| Client spams requests | Excess requests are rate-limited |
| Locked interaction is requested | Handler preserves progression rules |
| All ProximityPrompts are deleted | New interaction system continues working |
| Gamepad aim is slightly imperfect | Forgiving fallback selects intended target |
| Touch target is valid | Touch button appears and activates target |

## Verification Notes

- Live Studio playtests created eight tagged interactables for the claimed plot.
- All cloned built-in ProximityPrompts were disabled.
- Client created `InteractionGui` and one reusable `InteractionHighlight`.
- Mouse targeting displayed the custom prompt and white outline.
- Looking away removed the prompt and outline.
- A valid nearby `SellCrate` request increased gold from 76 to 99.
- Manually firing the same request from approximately 141 studs away left gold unchanged at 99.
- All 11 cloned ProximityPrompts were deleted during play; prompt-free gameplay activation still worked.
- The top-down targeting issue was traced to invisible PlotSpawn markers and fixed by excluding them from interaction raycasts.
- Client and server implementation logs were clean during final fresh-run validation.
- No first-party source contains a `.Triggered` connection or `getPrompt` call.
- `git diff --check` passed.
- Selene and the Roblox build tool were unavailable. The installed StyLua wrapper could not find its Linux binary.

## Overall Assessment

ClassicIdle now has a credible interaction boundary for a multiplayer tycoon. The custom client UX supports the intended device families, the server owns every meaningful decision, and the old prompt instances are no longer architectural dependencies.

The next milestone should finish the Studio-side cleanup, manually verify gamepad and touch, and place automated tests around the new remote validation boundary before the interaction catalogue grows.
