# Interaction Hooks And Shared Components

## Goal

Centralize interaction state and build reusable product-level components.

## Create `useButtonState.luau`

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

return function(enabled: boolean)
	local hovered, setHovered = React.useState(false)
	local pressed, setPressed = React.useState(false)
	return {
		hovered = hovered, pressed = pressed,
		onEnter = if enabled then function() setHovered(true) end else nil,
		onLeave = if enabled then function() setHovered(false); setPressed(false) end else nil,
		onDown = if enabled then function() setPressed(true) end else nil,
		onUp = if enabled then function() setPressed(false) end else nil,
	}
end
```

## Shared component contracts

Create these files. Each must use Config and Primitives only; never inline raw style tokens.

```txt
src/ReplicatedStorage/UI/Components/
  Button.luau
  IconButton.luau
  Panel.luau
  ProgressBar.luau
  NotificationBadge.luau
  CurrencyPill.luau
  StatusPill.luau
  ActionTile.luau
  RewardCard.luau
  HotbarSlot.luau
```

Every file must:

1. Begin with `--!strict`.
2. Export its public `Props` type.
3. Require only `React`, Config, Types, Hooks, Primitives, or lower-level shared components.
4. Return one named component function.
5. Include no raw colors, fonts, corners, strokes, gradients, Replica, remotes, or services.

### `Panel.luau`

Props:

```luau
{ variant: "Standard" | "Quest" | "Event" | "Status", size: UDim2, position: UDim2?,
  anchorPoint: Vector2?, layoutOrder: number?, children: React.ReactNode }
```

Render a transparent `Frame` containing the approved gradient, `Corner("Large")`, and matching blue/purple stroke. `Event` uses `PanelPurple`; all others use `PanelBlue`.

### `Button.luau`

Props:

```luau
{ text: string, variant: "Primary" | "Secondary" | "GreenHero" | "Disabled",
  size: UDim2, layoutOrder: number?, onActivated: (() -> ())? }
```

Derive `enabled = props.onActivated ~= nil and props.variant ~= "Disabled"`. Use `useButtonState`. Disabled buttons must set:

```luau
Active = false
Selectable = false
AutoButtonColor = false
[React.Event.Activated] = nil
```

Use a `TextButton`, `Corner`, `Stroke`, `Gradient`, and `Text`. Apply a subtle `UIScale` of `0.96` while pressed and `1.03` while hovered.

### `IconButton.luau`

Compose `Button` presentation with `Icon`; accept an optional label and badge.

### `ProgressBar.luau`

Props:

```luau
{ value: number, variant: "Green" | "Zone" | "XP", size: UDim2, segmented: number? }
```

Clamp value to `0..1`. The segmented variant creates exactly `segmented` equal child frames; filled segment count is `math.floor(value * segmented + 0.5)`.

### `NotificationBadge.luau`

Props: `{ text: string, position: UDim2? }`. Compose a red pill panel and caption text. Never own behavior.

### `CurrencyPill.luau`

Props:

```luau
{ icon: string, value: string, showPlus: boolean, enabled: boolean }
```

Compose `Panel("Status")`, `Icon("Small")`, value text, and a green plus button. The plus button receives no callback while placeholders remain disabled.

### `StatusPill.luau`

General top-bar pill for Best Distance and Level/XP. Accept children instead of arbitrary visual overrides.

### `ActionTile.luau`

Props:

```luau
{ icon: string, label: string, badge: string?, onActivated: (() -> ())? }
```

All eight right-rail tiles use this component. Only Build receives a callback.

### `RewardCard.luau`

Props:

```luau
{ icon: string, value: string, layoutOrder: number }
```

Used only for event reward tiles.

## Required refactors

- `ActionButton`, `BuildShopItem`, and old `HotbarSlot` must eventually compose the new `Button`.
- Existing modal and feedback components must eventually compose `Panel` and `Text`.
- Do not delete existing components until integration lesson 13.

## Validation

- Demonstrate every enabled, hovered, pressed, selected, and disabled state in the component catalog.
- Confirm disabled buttons never call a callback.

## Done when

Every repeated HUD presentation pattern has exactly one shared implementation.
