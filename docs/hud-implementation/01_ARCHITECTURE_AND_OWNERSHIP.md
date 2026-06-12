# Architecture And Ownership

## Goal

Build a strict, reusable design system before composing the HUD.

## Create this structure

```txt
src/ReplicatedStorage/UI/
  Config/        # frozen semantic tokens and reference data
  Types/         # strict public types
  Hooks/         # reusable stateful React behavior
  Primitives/    # tokenized Roblox UI building blocks
  Components/    # reusable product UI
  HUD/           # reference-specific compositions
  Screens/       # data wiring only
```

Use the exact file list from the project plan.

## Dependency direction

```txt
Config + Types
      ↓
Primitives + Hooks
      ↓
Shared Components
      ↓
HUD Compositions
      ↓
MainHudScreen
      ↓
App
```

Dependencies may only point downward in this diagram.

## Ownership

- Config modules own all colors, gradients, icons, typography, spacing, radii, strokes, animation timings, breakpoints, and demo values.
- Primitives translate controlled token variants into Roblox instances.
- Shared components own reusable interaction and presentation patterns.
- HUD compositions arrange shared components to match the reference.
- `MainHudScreen` reads `usePlayerData()` and maps transient props.
- Controllers continue owning input and remote actions.

## Forbidden dependencies

```luau
-- Forbidden inside a primitive, shared component, or HUD composition:
local Players = game:GetService("Players")
local RemoteManager = require(...)
local Replica = require(...)

-- Forbidden outside Config:
Color3.fromRGB(...)
Enum.Font.GothamBold

-- Forbidden outside Primitives:
React.createElement("UICorner", ...)
React.createElement("UIStroke", ...)
React.createElement("UIGradient", ...)
```

## Component API rules

- Use semantic variants, not arbitrary style tables.
- Keep layout-specific `Position` and `Size` in HUD composition files.
- Do not expose every Roblox instance property as a prop.
- Callbacks are optional only for disabled components.
- New files use `--!strict`; avoid `any`.
- Freeze static token/config tables with `table.freeze`.

## Existing UI boundaries

- Replace the visible quest card, factory shop opener, and factory hotbar.
- Keep `QuestScreen` for the world marker only.
- Keep `FactoryScreen` for shop, build controls, and manage overlay only.
- Keep feedback, interaction, worker, and machine screens.

## Done when

- Every planned module has one layer and one owner.
- No feature component accesses services, Replica, or remotes.
