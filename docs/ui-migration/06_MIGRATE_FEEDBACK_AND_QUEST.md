# Migrate Feedback And Quest

## Goal

Replace the imperative feedback toast and quest card with React components. Keep quest wayfinding imperative.

Complete this file only after `05_UI_FOUNDATION.md`.

## Files changed

Create or replace:

```txt
src/ReplicatedStorage/UI/Components/FeedbackToast.luau
src/ReplicatedStorage/UI/Components/QuestCard.luau
src/ReplicatedStorage/UI/Screens/FeedbackScreen.luau
src/ReplicatedStorage/UI/Screens/QuestScreen.luau
```

Edit:

```txt
src/ReplicatedStorage/UI/Screens/App.luau
src/StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/QuestController.luau
```

## 1. Create `FeedbackToast`

Replace `src/ReplicatedStorage/UI/Components/FeedbackToast.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	message: string,
	messageId: number,
	onFinished: (number) -> (),
}

local function FeedbackToast(props: Props)
	local labelRef = React.useRef(nil :: TextLabel?)

	React.useEffect(function()
		local label = labelRef.current
		if not label then
			return
		end

		label.Position = UDim2.fromScale(0.5, 0.88)
		label.BackgroundTransparency = 1
		label.TextTransparency = 1

		local active = true
		local hideTween: Tween? = nil
		local showTween = TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.15,
			Position = UDim2.fromScale(0.5, 0.82),
			TextTransparency = 0,
		})
		showTween:Play()

		task.spawn(function()
			showTween.Completed:Wait()
			task.wait(1.8)
			if not active then
				return
			end

			hideTween = TweenService:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.77),
				TextTransparency = 1,
			})
			hideTween:Play()
			hideTween.Completed:Wait()

			if active then
				props.onFinished(props.messageId)
			end
		end)

		return function()
			active = false
			showTween:Cancel()
			if hideTween then
				hideTween:Cancel()
			end
		end
	end, { props.messageId })

	return React.createElement("TextLabel", {
		Name = "Feedback",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.88),
		Size = UDim2.new(0.85, 0, 0, 60),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = props.message,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 22,
		TextTransparency = 1,
		TextWrapped = true,
		ref = labelRef,
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(420, 60),
			MinSize = Vector2.new(220, 60),
		}),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
	})
end

return FeedbackToast
```

## 2. Create `FeedbackScreen`

Replace `src/ReplicatedStorage/UI/Screens/FeedbackScreen.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local FeedbackToast = require(script.Parent.Parent.Components.FeedbackToast)

export type FeedbackState = {
	id: number,
	message: string,
	onFinished: (number) -> (),
}

export type Props = {
	feedback: FeedbackState?,
}

local function FeedbackScreen(props: Props)
	local children = {}
	if props.feedback then
		children.Toast = React.createElement(FeedbackToast, {
			message = props.feedback.message,
			messageId = props.feedback.id,
			onFinished = props.feedback.onFinished,
		})
	end

	return React.createElement("ScreenGui", {
		Name = "FeedbackGui",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 10,
	}, children)
end

return FeedbackScreen
```

## 3. Replace feedback code in `ClientBootstrap`

In `src/StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.luau`, remove:

```luau
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
```

Remove the `player`, `playerGui`, `feedbackGui`, `currentLabel`, and old `showFeedback` blocks.

Add beside the other requires:

```luau
local UIState = require(script.Parent.UI.UIState)
```

Replace:

```luau
feedbackEvent.OnClientEvent:Connect(showFeedback)
```

with:

```luau
local feedbackId = 0

feedbackEvent.OnClientEvent:Connect(function(message: string)
	feedbackId += 1
	local thisId = feedbackId

	UIState.Set("feedback", {
		id = thisId,
		message = message,
		onFinished = function(finishedId: number)
			local feedback = UIState.Get().feedback
			if feedback and feedback.id == finishedId then
				UIState.Set("feedback", nil)
			end
		end,
	})
end)
```

## 4. Create `QuestCard`

Replace `src/ReplicatedStorage/UI/Components/QuestCard.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	title: string,
	description: string,
	progressText: string,
	visible: boolean,
}

local function QuestCard(props: Props)
	return React.createElement("Frame", {
		Name = "QuestCard",
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.new(0.38, 0, 0, 150),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.08,
		Visible = props.visible,
	}, {
		Constraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(280, 150),
			MaxSize = Vector2.new(460, 150),
		}),
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 14),
		}),
		Heading = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(16, 10),
			Size = UDim2.new(1, -32, 0, 22),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = "CURRENT QUEST",
			TextColor3 = Color3.fromRGB(110, 215, 125),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Title = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(16, 32),
			Size = UDim2.new(1, -32, 0, 30),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = props.title,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 21,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Description = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(16, 64),
			Size = UDim2.new(1, -32, 0, 42),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = props.description,
			TextColor3 = Color3.fromRGB(215, 215, 215),
			TextSize = 15,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}),
		Progress = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(16, 112),
			Size = UDim2.new(1, -32, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = props.progressText,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
end

return QuestCard
```

## 5. Create `QuestScreen`

Replace `src/ReplicatedStorage/UI/Screens/QuestScreen.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local QuestCard = require(script.Parent.Parent.Components.QuestCard)

export type Props = {
	quest: any?,
}

local function QuestScreen(props: Props)
	local quest = props.quest
	local visible = quest ~= nil and quest.Complete ~= true
	local progressText = ""

	if visible then
		progressText = `{math.floor(quest.Progress * 100) / 100}/{quest.RequiredAmount}  •  +{quest.XPReward} XP`
	end

	return React.createElement("ScreenGui", {
		Name = "QuestGui",
		DisplayOrder = 15,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Card = React.createElement(QuestCard, {
			title = if visible then quest.Title else "",
			description = if visible then quest.Description else "",
			progressText = progressText,
			visible = visible,
		}),
	})
end

return QuestScreen
```

## 6. Edit `QuestController`

Add beside the other requires:

```luau
local UIState = require(script.Parent.Parent.UI.UIState)
```

Delete the old `QuestGui`, `QuestCard`, constraint, corner, heading, title, description, and progress creation blocks.

Keep the quest marker, but replace:

```luau
marker.Parent = gui
```

with:

```luau
marker.Parent = playerGui
```

In `showState`, replace:

```luau
card.Visible = not state.Complete
```

with:

```luau
UIState.Set("quest", state)
```

Delete these three lines:

```luau
title.Text = state.Title
description.Text = state.Description
progress.Text = `{math.floor(state.Progress * 100) / 100}/{state.RequiredAmount}  •  +{state.XPReward} XP`
```

Do not delete `highlight`, `marker`, `beam`, attachments, or target-resolution functions.

## 7. Mount both screens in `App`

Replace `src/ReplicatedStorage/UI/Screens/App.luau` with:

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Vendor.React)
local PlayerDataContext = require(script.Parent.Parent.Context.PlayerDataContext)
local FeedbackScreen = require(script.Parent.FeedbackScreen)
local QuestScreen = require(script.Parent.QuestScreen)

local function App(props: { state: any })
	return React.createElement(PlayerDataContext.Provider, nil, {
		Feedback = React.createElement(FeedbackScreen, {
			feedback = props.state.feedback,
		}),
		Quest = React.createElement(QuestScreen, {
			quest = props.state.quest,
		}),
	})
end

return App
```

## Validation

- Start Play mode and confirm `FeedbackGui` and `QuestGui` exist under `PlayerGui.ReactUI`.
- Confirm there is no second imperative `FeedbackGui`.
- Trigger two feedback messages quickly; the newer message must replace the older one.
- Confirm quest title, description, progress, and visibility match the old card.
- Confirm quest highlight, billboard marker, and beam still work.
- Reset the character and confirm both screens appear once.

## Done when

Feedback and the quest card are React-owned, with no visual or wayfinding regression.
