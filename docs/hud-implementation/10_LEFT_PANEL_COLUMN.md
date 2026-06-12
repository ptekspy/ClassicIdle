# Left Panel Column

## Goal

Implement `Main Quest | Daily Reward | Limited Event` in the exact vertical order.

## Create `QuestPanel.luau`

Props:

```luau
export type Props = {
	title: string, description: string, progress: number, required: number,
	xpReward: number, visible: boolean,
}
```

Compose `Panel("Quest")`, Quest icon, `Main Quest`, red `!` badge, description, progress text/bar, reward gem `50`, and green `Go!` button. The `Go!` button is disabled; existing world wayfinding remains automatic.

Map live quest state:

```luau
title = quest.Title or ""
description = quest.Description or ""
progress = quest.Progress or 0
required = quest.RequiredAmount or 1
xpReward = quest.XPReward or 0
```

## Create `DailyRewardPanel.luau`

Compose the exact card using `HUD.Demo.DailyMinutes`, `DailyRequiredMinutes`, and `DailyCoins`. Render the green `Claim!` button with no callback.

## Create `LimitedEventPanel.luau`

Compose `Panel("Event")`, event header/time, Meteor icon, title/subtitle, two `RewardCard` children, and disabled `Join Event!` green button.

## Create `LeftPanelColumn.luau`

Props:

```luau
export type Props = { quest: any? }
```

Use a vertical list with exact order:

```luau
QuestPanel
DailyRewardPanel
LimitedEventPanel
```

Hide the two disabled cards in phone modes. Never hide the live quest panel while a quest is active.

## Existing quest change

In integration lesson 13, remove only `QuestCard` from `QuestScreen`. Keep `QuestTargetMarker`.

## Validation

- Quest updates when `QuestController` publishes state.
- Daily and event buttons never activate.
- Desktop order and badge positions match the reference.

## Done when

The entire left column is composed from shared components with no inline tokens.
