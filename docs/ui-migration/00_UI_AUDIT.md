# UI Audit

## Purpose

Use this inventory as the source of truth while migrating. Do not delete or disable an old UI area until its migration file says to do so.

## Current architecture

- `StarterGui` contains no `ScreenGui` objects.
- All current screen UI is created imperatively by client scripts.
- The active plot template is `ReplicatedStorage.Assets.PlotTemplate`.
- The active plot contains two physical Studio-authored UI objects under `OLD.SellCrate`.
- Several world-space displays are already created programmatically by server services.
- React and ReactRoblox are declared in `wally.toml`. Confirm `wally install` has generated their package folders before starting.
- Replica is vendored at `src/ReplicatedStorage/Packages/Replica`, but gameplay code does not currently create or consume player-data replicas.
- Most persistent player data is only available to UI indirectly through leaderstats, remote payloads, and remote functions.

## Screen UI audit

| Source | Runtime object | Responsibility | Current type | Dependencies | Migrate | Risk |
|---|---|---|---|---|---|---|
| `src/StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.luau` | `PlayerGui.FeedbackGui` | Animated feedback messages | Imperative generated UI | `FeedbackEvent`, `TweenService` | Yes | Low |
| `Controllers/QuestController.luau` | `PlayerGui.QuestGui.QuestCard` | Current quest card | Imperative generated UI | `QuestUpdate`, `GetQuestState` | Yes | Medium |
| `Controllers/QuestController.luau` | `PlayerGui.QuestGui.QuestTargetMarker` | Quest target billboard | Imperative generated UI | quest wayfinding resolver | Yes | Medium |
| `Controllers/InteractionController.luau` | `PlayerGui.InteractionGui.Prompt` | Interaction prompt | Imperative generated UI | focused target and input mode | Yes | Medium |
| `Controllers/InteractionController.luau` | `TouchInteract`, `Crosshair` | Touch/gamepad interaction controls | Imperative generated UI | `UserInputService`, `InteractionRequest` | Yes | Medium |
| `Controllers/WorkerController.luau` | `PlayerGui.WorkerGui` | NPC hire and upgrade menu | Imperative generated UI | `WorkerMenu`, `WorkerRequest` | Yes | Medium |
| `Controllers/MachineController.luau` | `PlayerGui.MachineGui` | Machine upgrade menu | Imperative generated UI | `MachineMenu`, `MachineRequest` | Yes | Medium |
| `Controllers/FactoryController.luau` | `PlayerGui.FactoryGui.OpenShop` | Build-shop toggle | Imperative generated UI | local UI state | Yes | Medium |
| `Controllers/FactoryController.luau` | `Shop` | Build shop | Imperative generated UI | `Factory.Config`, `FactoryRequest` | Yes | Medium |
| `Controllers/FactoryController.luau` | `Hotbar` | Placeable-item hotbar | Imperative generated UI | `FactoryStateUpdate`, `GetFactoryState` | Yes | High |
| `Controllers/FactoryController.luau` | `BuildControls` | Rotate/place/cancel buttons | Imperative generated UI | build-mode callbacks | Yes | High |
| `Controllers/FactoryController.luau` | `Manage` | Placed-item management | Imperative generated UI | `FactoryMenu`, `FactoryRequest` | Yes | High |

## Non-UI objects owned by UI controllers

Keep these imperative. They are gameplay presentation helpers, not React UI:

- `Workspace.InteractionHighlight`
- `Workspace.QuestTargetHighlight`
- `Workspace.QuestWayfindingBeam`
- quest wayfinding attachments
- `Workspace.FactoryGhost`
- raycasts, target selection, build-grid calculations, and input listeners

## World-space UI audit

| Source or Studio path | Responsibility | Current type | Delete eventually | Risk |
|---|---|---|---|---|
| `ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.BillboardGui` | Sell value above crate | Physical Studio UI | Yes, after replacement | High |
| `ReplicatedStorage.Assets.PlotTemplate.OLD.SellCrate.Screen.SurfaceGui` | Sell value on crate screen | Physical Studio UI | Yes, after replacement | High |
| `Services/DisplayService/init.luau` → `StorageDisplay` | Storage summary | Server-created `BillboardGui` | Replace code, runtime object is temporary | Medium |
| `Services/DisplayService/init.luau` → `NPCDisplay` | Hire-NPC summary | Server-created `BillboardGui` | Replace code, runtime object is temporary | Medium |
| `Services/DisplayService/init.luau` → `UpgradeDisplay` | Storage upgrade summary | Server-created `BillboardGui` | Replace code, runtime object is temporary | Medium |
| `Services/ResourceNodeService/init.luau` → `RespawnProgress` | Resource respawn progress | Server-created `BillboardGui` | Replace code, runtime object is temporary | High |

## Physical UI that is not active

`PlotTemplateV2`, `PlotTemplatev3`, `PlotTemplateV4`, and `PlotTemplateV5` also contain sell-crate UI. They are legacy asset versions and are not cloned by `PlotService`.

Do not delete them as part of this migration. Archive cleanup is a separate task.

## Requested areas not currently present

No dedicated gameplay UI was found for:

- a screen-space resources panel
- a screen-space currency display
- a separate storage/bin screen
- a rocket stats or progress screen
- image-based buttons or labels
- `UIGridLayout`, `UIPadding`, or `UIGradient`

Gold, XP, and selected resources currently appear through Roblox leaderstats. Storage contents appear in the world-space `StorageDisplay`. Do not invent new screens during a visual-parity migration.

## Data-flow audit

| UI state | Current source | Target source |
|---|---|---|
| Gold, resources, XP, storage level, NPCs, factory inventory, quest data | Server data, partially exposed through leaderstats/remotes | Owner-only Replica through `usePlayerData()` |
| Quest presentation and wayfinding metadata | `QuestUpdate` and `GetQuestState` | Keep these remotes initially |
| Factory menu payload and authoritative factory state | Factory remotes/functions | Keep remotes; context may supply inventory display data later |
| Worker and machine menu payloads | Menu remotes | Keep remotes |
| Focused interaction and input mode | Local controller state | Local React screen props |
| Feedback message | `FeedbackEvent` | Local React screen state |

## Important issue found

`MachineController.luau` exists but is not required or started by `ClientBootstrap.client.luau`. Validate whether machine menus currently appear before migrating them. The migration should start it explicitly when the React machine menu is ready.

## Done when

- Every row above has a matching migration stage.
- No Studio-authored UI outside the listed sell-crate objects is treated as required active UI.
- Gameplay helpers are not accidentally moved into React.
