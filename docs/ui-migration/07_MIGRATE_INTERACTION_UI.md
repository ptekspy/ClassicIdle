# Migrate Interaction UI

## Goal

Move the prompt, touch button, and crosshair into React while keeping target selection and input handling in `InteractionController`.

## Files to create

```txt
src/ReplicatedStorage/UI/Components/InteractionPrompt.luau
src/ReplicatedStorage/UI/Components/TouchInteractButton.luau
src/ReplicatedStorage/UI/Components/Crosshair.luau
src/ReplicatedStorage/UI/Screens/InteractionScreen.luau
```

## Controller state contract

Publish:

```luau
UIState.Set("interaction", {
	visible = hasTarget,
	actionText = actionText,
	objectText = objectText,
	inputHint = inputHint,
	inputMode = Local.inputMode,
	onActivated = activateFocusedTarget,
})
```

The callback may be passed to the screen because it invokes existing controller logic and does not make UI authoritative.

## Preserve exact visuals

Copy properties from `InteractionController.luau`:

- prompt position, size, max/min size, corner, colors, and transparency
- action/object label typography
- input-hint block
- circular touch button
- centered crosshair
- display order `20`

## Keep imperative

- `InteractionHighlight`
- target scanning and raycasts
- range and scope checks
- keyboard, mouse, gamepad input listeners
- `InteractionRequest:FireServer`

## Remove old UI

After parity, remove `InteractionGui` and its descendants from controller construction. Keep the `Highlight`.

## Validation

- Test mouse/keyboard, gamepad, and touch emulation.
- Confirm the hint reads `E / CLICK`, `X`, and `TAP` in the correct modes.
- Confirm touch button only appears on touch.
- Confirm crosshair behavior is unchanged.
- Confirm out-of-range and non-owned targets cannot be activated.

## Done when

All interaction visuals are React-owned and interaction security/behavior is unchanged.
