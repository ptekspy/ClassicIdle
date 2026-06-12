# Migrate Feedback And Quest

## Why first

Feedback is the smallest screen UI. Quest UI is read-only and exercises remote-to-React state without moving gameplay actions.

## Files to create

```txt
src/ReplicatedStorage/UI/Components/FeedbackToast.luau
src/ReplicatedStorage/UI/Components/QuestCard.luau
src/ReplicatedStorage/UI/Screens/FeedbackScreen.luau
src/ReplicatedStorage/UI/Screens/QuestScreen.luau
```

## Feedback migration

Copy every visual property from `ClientBootstrap.client.luau` into `FeedbackToast`.

Props:

```luau
export type Props = {
	message: string?,
	visible: boolean,
}
```

Keep animation timing identical:

- show: `0.2`, Back/Out
- visible wait: `1.8`
- hide: `0.25`, Quad/In

Move only presentation into React. In `ClientBootstrap`, replace label creation with:

```luau
feedbackEvent.OnClientEvent:Connect(function(message)
	UIState.Set("feedback", message)
	task.delay(2.25, function()
		if UIState.Get().feedback == message then
			UIState.Set("feedback", nil)
		end
	end)
end)
```

## Quest migration

Move only `QuestGui.QuestCard` into `QuestCard`.

Preserve:

- position `UDim2.fromOffset(20, 20)`
- size and `UISizeConstraint`
- Gotham fonts
- all colors, transparency, truncation, wrapping, and text sizes

Keep these in `QuestController`:

- target resolution
- highlight
- billboard target marker until world-space migration
- beam and attachments
- `QuestUpdate` and `GetQuestState`

Replace direct text/visibility mutation with:

```luau
UIState.Set("quest", state)
```

`QuestScreen` turns the state into `QuestCard` props.

## Disable old UI safely

After React parity is confirmed:

- remove only `FeedbackGui` and feedback label construction from `ClientBootstrap`
- remove only `QuestGui.QuestCard` construction and mutations from `QuestController`
- keep quest wayfinding objects and logic

## Validation

- Trigger repeated feedback messages and confirm replacement behavior matches.
- Progress and complete quests.
- Confirm quest card text and visibility match.
- Confirm wayfinding still works.
- Reset and rejoin.

## Done when

Feedback and quest card have no imperative visual instances and look unchanged.
