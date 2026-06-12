# Component Catalog And Quality Gates

## Goal

Make every primitive, component, state, and variant reviewable before integrating the full HUD.

## Create `ComponentCatalogScreen.luau`

Create a development-only screen under `UI/Screens`. It must render:

- Every Corner, Stroke, Gradient, Text, and Icon variant.
- Every Panel and Button variant.
- Enabled, hovered, pressed, selected, and disabled examples.
- Every badge style.
- Progress bars at `0`, `0.25`, `0.68`, and `1`.
- Currency and status pills.
- Every action tile and reward card.
- Hotbar slots: empty, count, selected, and locked.

Guard it with:

```luau
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return nil
end
```

Mount it temporarily from `App`, then remove the mount after review. Keep the catalog file for future development.

## Static quality gates

Run:

```bash
rg 'Color3.fromRGB|Color3.new' src/ReplicatedStorage/UI --glob '*.luau'
rg 'Enum.Font.' src/ReplicatedStorage/UI --glob '*.luau'
rg 'createElement\\(\"UICorner|createElement\\(\"UIStroke|createElement\\(\"UIGradient' src/ReplicatedStorage/UI --glob '*.luau'
rg '^--!strict' src/ReplicatedStorage/UI --glob '*.luau' -L
selene src
argon build
```

Expected exceptions:

- Raw colors/fonts: Config modules only.
- Raw `UICorner`/`UIStroke`/`UIGradient`: matching Primitive only.
- World-space UI may retain specialized raw behavior until separately refactored.

## Review checklist

- [ ] No unknown variant silently falls back.
- [ ] No shared component accepts an unrestricted style table.
- [ ] No HUD composition accesses Replica, services, or remotes.
- [ ] No placeholder control receives a callback.
- [ ] Every interactive control has mouse, touch, and gamepad states.
- [ ] Every module is `--!strict`.
- [ ] Config tables are frozen.
- [ ] Components remain focused; reference-specific layout is not pushed into primitives.

## Done when

The catalog demonstrates the complete design system and all quality-gate searches have only documented exceptions.
