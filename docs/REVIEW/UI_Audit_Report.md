# UI Audit Review

## Overview

This review covers the current UI architecture in `ClassicIdle` as of 2026-06-12. The codebase already has a React-Lua based UI implementation, and the primary source of truth for in-game UI is the React component tree under `src/ReplicatedStorage/UI` paired with `UIState` in `src/StarterPlayer/StarterPlayerScripts/UI/UIState.luau`.

## Findings

### 1. React-Lua is already the active screen UI platform

- `src/StarterPlayer/StarterPlayerScripts/UI/UIRoot.luau` mounts a React root into `PlayerGui.ReactUI`.
- `src/ReplicatedStorage/UI/Screens/App.luau` composes all major UI screens.
- Screen UI elements are implemented as components in `src/ReplicatedStorage/UI/Components`.
- The app uses `PlayerDataContext` and Replica to expose player data to React UI.

### 2. UI state is centralized and controller-driven

- `src/StarterPlayer/StarterPlayerScripts/UI/UIState.luau` stores keys for `feedback`, `quest`, `questMarker`, `interaction`, `workerMenu`, `machineMenu`, and `factory`.
- Controllers in `src/StarterPlayer/StarterPlayerScripts/Controllers/` publish UI payloads to `UIState` instead of directly creating UI nodes.
- This separation is good for migration and keeps game logic separate from presentation.

### 3. The majority of active UI is already componentized

Active screens and components include:

- `FeedbackScreen`, `QuestScreen`, `InteractionScreen`, `WorkerScreen`, `MachineScreen`, `FactoryScreen`
- `ActionButton`, `BuildControls`, `BuildShop`, `Crosshair`, `FeedbackToast`, `Hotbar`, `InteractionPrompt`, `ModalPanel`, `QuestCard`, `QuestTargetMarker`, `TouchInteractButton`, `WorkerMenuContent`, etc.

These are all implemented as React components, making the UI already fit the intended componentized pattern.

### 4. World-space UI is programmatic but still uses anchored runtime GUI hosts

- `src/ReplicatedStorage/Services/DisplayService/init.luau` creates runtime `BillboardGui` and `SurfaceGui` objects for:
  - storage display
  - NPC hire display
  - storage upgrade display
  - sell display
- `src/ReplicatedStorage/Services/WorldUIService/init.luau` renders React into world UI hosts.

This is acceptable, but it remains an area where UI is tied to runtime anchored instances rather than a purely screen-space component tree.

### 5. No active legacy `ScreenGui` constructors were found in source

- A workspace-wide grep for `Instance.new("ScreenGui")`, `BillboardGui`, and `SurfaceGui` only returned world-space display creators in `DisplayService` and `ResourceNodeService`.
- There is no evidence in source code of new physical screen UI being created directly in active gameplay code.

### 6. There may still be legacy place assets not visible in source

- The `PlotTemplate` assets contain `OLD.SellCrate` UI objects.
- These may still exist in the `.rbxl` or plot template assets and should be verified in Studio before deletion.

### 7. The existing `docs/ui-migration` directory likely reflects a planned migration

- The repository already contains migration documentation files such as `00_UI_AUDIT.md` through `12_FINAL_VALIDATION.md`.
- The current source appears to already implement the core React migration described by those docs.
- This suggests the repo is in a post-migration or partially migrated state rather than a pre-migration state.

## Risks

### A. World-space UI lifecycle

- `WorldUIService` keeps React roots tied to host instances but only unmounts when explicitly asked.
- If a world-space host is destroyed without unmounting, stale roots could remain.

### B. Physical asset dependency

- `DisplayService` relies on specific plot anchor parts from `PlotConfig.Paths`.
- Changes to plot template part names or structure could break UI display placement.

### C. Controller startup state

- The review noted `MachineController` exists but may not be started in all bootstrap paths.
- Confirm that machine menu functionality is active in the current runtime.

### D. Documentation vs. reality

- `docs/ui-migration` may be stale compared to the current implementation.
- A documentation audit is advised to ensure instructions match the actual code.

## Recommendations

1. Treat `src/ReplicatedStorage/UI` and `src/StarterPlayer/StarterPlayerScripts/UI` as the current UI implementation.
2. Validate runtime behavior for all UI screens in Studio and ensure `PlayerGui.ReactUI` is the only active screen-root for gameplay UI.
3. Inspect `PlotTemplate` assets and `Classic Idle.rbxl` for legacy `OLD.SellCrate` UI objects before any deletion.
4. Keep the controller-to-`UIState` pattern; it is the correct architecture for this codebase.
5. Review or update the existing `docs/ui-migration` files to reflect actual implemented state and remove outdated migration steps if already completed.
6. Consider adding a cleanup or unmount step for world-space React roots when anchors are destroyed or replaced.

## Conclusion

The UI architecture in `ClassicIdle` is already mostly migrated to React-Lua. The current codebase has a clean component hierarchy, a centralized UI state bridge, and explicit controllers for gameplay-driven UI. The main remaining work is verifying legacy plot assets and confirming that world-space UI anchor creation remains correct.

This report is intended for the development team to use as a basis for verification, cleanup, and ongoing documentation alignment.
