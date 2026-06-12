# Migrate Interaction UI

## Goal

Move the interaction prompt, touch button, and crosshair into React. Keep target scanning, highlights, input listeners, and remote calls in `InteractionController`.

## Files changed

Replace:

```txt
src/ReplicatedStorage/UI/Components/InteractionPrompt.luau
src/ReplicatedStorage/UI/Components/TouchInteractButton.luau
src/ReplicatedStorage/UI/Components/Crosshair.luau
src/ReplicatedStorage/UI/Screens/InteractionScreen.luau
```

Edit:

```txt
src/ReplicatedStorage/UI/Screens/App.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/InteractionController.luau
```

## 1. Create `InteractionPrompt`

Replace `src/ReplicatedStorage/UI/Components/InteractionPrompt.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	actionText: string,
	objectText: string,
	inputHint: string,
	visible: boolean,
}

local function InteractionPrompt(props: Props)
	return React.createElement("Frame", {
		Name = "Prompt",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.92),
		Size = UDim2.new(0.8, 0, 0, 82),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.12,
		Visible = props.visible,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(440, 82),
			MinSize = Vector2.new(240, 82),
		}),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Action = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(18, 8),
			Size = UDim2.new(1, -110, 0, 32),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = props.actionText,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 21,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Object = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(18, 40),
			Size = UDim2.new(1, -110, 0, 28),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = props.objectText,
			TextColor3 = Color3.fromRGB(205, 205, 205),
			TextSize = 16,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		InputHint = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -16, 0.5, 0),
			Size = UDim2.fromOffset(72, 48),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBold,
			Text = props.inputHint,
			TextColor3 = Color3.fromRGB(25, 25, 25),
			TextSize = 16,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
		}),
	})
end

return InteractionPrompt
```

## 2. Create `TouchInteractButton`

Replace `src/ReplicatedStorage/UI/Components/TouchInteractButton.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	visible: boolean,
	onActivated: () -> (),
}

local function TouchInteractButton(props: Props)
	return React.createElement("TextButton", {
		Name = "TouchInteract",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -24, 1, -118),
		Size = UDim2.fromOffset(104, 104),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		Text = "INTERACT",
		TextColor3 = Color3.fromRGB(25, 25, 25),
		TextSize = 15,
		Visible = props.visible,
		[React.Event.Activated] = props.onActivated,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})
end

return TouchInteractButton
```

## 3. Create `Crosshair`

Replace `src/ReplicatedStorage/UI/Components/Crosshair.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function Crosshair(props: { visible: boolean })
	return React.createElement("Frame", {
		Name = "Crosshair",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Visible = props.visible,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})
end

return Crosshair
```

## 4. Create `InteractionScreen`

Replace `src/ReplicatedStorage/UI/Screens/InteractionScreen.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local Crosshair = require(script.Parent.Parent.Components.Crosshair)
local InteractionPrompt = require(script.Parent.Parent.Components.InteractionPrompt)
local TouchInteractButton = require(script.Parent.Parent.Components.TouchInteractButton)

local EMPTY = {
	visible = false,
	actionText = "",
	objectText = "",
	inputHint = "",
	inputMode = "MouseKeyboard",
	onActivated = function() end,
}

local function InteractionScreen(props: { interaction: any? })
	local state = props.interaction or EMPTY

	return React.createElement("ScreenGui", {
		Name = "InteractionGui",
		DisplayOrder = 20,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Prompt = React.createElement(InteractionPrompt, {
			actionText = state.actionText,
			objectText = state.objectText,
			inputHint = state.inputHint,
			visible = state.visible,
		}),
		TouchButton = React.createElement(TouchInteractButton, {
			visible = state.visible and state.inputMode == "Touch",
			onActivated = state.onActivated,
		}),
		Crosshair = React.createElement(Crosshair, {
			visible = state.inputMode ~= "MouseKeyboard",
		}),
	})
end

return InteractionScreen
```

## 5. Edit `InteractionController`

Add:

```luau
local UIState = require(script.Parent.Parent.UI.UIState)
```

Delete:

```luau
local playerGui = player:WaitForChild("PlayerGui")
```

Delete the entire visual-construction block from:

```luau
local gui = Instance.new("ScreenGui")
```

through:

```luau
crosshairCorner.Parent = crosshair
```

Keep the `InteractionHighlight` creation block. Move it above `getInputMode` if necessary.

Replace the entire `updatePrompt` function with:

```luau
local function updatePrompt()
	local target = Local.focusedTarget
	local hasTarget = target ~= nil

	highlight.Adornee = target
	highlight.Enabled = hasTarget

	local actionText = if target then target:GetAttribute(InteractionConfig.Attributes.ActionText) else nil
	local objectText = if target then target:GetAttribute(InteractionConfig.Attributes.ObjectText) else nil
	local inputHint = if Local.inputMode == "Touch"
		then "TAP"
		elseif Local.inputMode == "Gamepad" then "X"
		else "E / CLICK"

	UIState.Set("interaction", {
		visible = hasTarget,
		actionText = if typeof(actionText) == "string" then actionText else "Interact",
		objectText = if typeof(objectText) == "string" then objectText else if target then target.Name else "",
		inputHint = inputHint,
		inputMode = Local.inputMode,
		onActivated = activateFocusedTarget,
	})
end
```

Delete:

```luau
touchButton.Activated:Connect(activateFocusedTarget)
```

Do not change raycasting, target validation, highlights, or input listeners.

## 6. Add the screen to `App`

Add:

```luau
local InteractionScreen = require(script.Parent.InteractionScreen)
```

Inside the provider children, add:

```luau
Interaction = React.createElement(InteractionScreen, {
	interaction = props.state.interaction,
}),
```

## Validation

- Confirm only one `InteractionGui` exists, under `PlayerGui.ReactUI`.
- Mouse and keyboard show `E / CLICK`.
- Gamepad shows `X` and the crosshair.
- Touch emulation shows `TAP` and the circular touch button.
- Clicking/tapping the React button invokes the existing validated interaction.
- Out-of-range and other-player targets remain blocked.

## Done when

All interaction visuals are React-owned and interaction behavior is unchanged.
