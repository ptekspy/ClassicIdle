# File Manifest

Use this manifest while implementing. Do not rename files or merge responsibilities.

## Config and types

| File | Responsibility |
|---|---|
| `UI/Config/ColorConfig.luau` | Semantic colors only |
| `UI/Config/GradientConfig.luau` | Approved gradients only |
| `UI/Config/HUDConfig.luau` | Demo values and XP curve |
| `UI/Config/IconConfig.luau` | All icon assets |
| `UI/Config/LayoutConfig.luau` | Spacing, radii, strokes, breakpoints, timing |
| `UI/Config/TypographyConfig.luau` | Approved font styles |
| `UI/Types/DesignSystemTypes.luau` | Variant unions |
| `UI/Types/HUDTypes.luau` | HUD-facing data contracts |

## Hooks and primitives

| File | Responsibility |
|---|---|
| `UI/Hooks/useResponsiveLayout.luau` | Viewport mode and region scale |
| `UI/Hooks/useButtonState.luau` | Hover and pressed state |
| `UI/Primitives/Corner.luau` | Only approved `UICorner` creator |
| `UI/Primitives/Gradient.luau` | Only approved HUD `UIGradient` creator |
| `UI/Primitives/Icon.luau` | Config-driven images |
| `UI/Primitives/Padding.luau` | Tokenized padding |
| `UI/Primitives/Stroke.luau` | Only approved HUD `UIStroke` creator |
| `UI/Primitives/Text.luau` | Tokenized typography |

## Shared components

| File | Responsibility |
|---|---|
| `UI/Components/Button.luau` | Shared interactive/disabled button states |
| `UI/Components/IconButton.luau` | Icon-first button |
| `UI/Components/Panel.luau` | Shared outlined/gradient container |
| `UI/Components/ProgressBar.luau` | Continuous and segmented progress |
| `UI/Components/NotificationBadge.luau` | Red count/exclamation badge |
| `UI/Components/CurrencyPill.luau` | Gold/Gems/Fuel |
| `UI/Components/StatusPill.luau` | Best Distance and Level/XP container |
| `UI/Components/ActionTile.luau` | All right-rail actions and Backpack |
| `UI/Components/RewardCard.luau` | Event reward tile |
| `UI/Components/HotbarSlot.luau` | Live and locked dock slots |

## HUD compositions

| File | Exact children |
|---|---|
| `UI/HUD/TopStatusBar.luau` | Gold, Gems, Fuel, Best Distance, Level/XP, Wheel, Calendar |
| `UI/HUD/ZoneProgressBar.luau` | Earth, label, segments, label, Moon |
| `UI/HUD/QuestPanel.luau` | Live main quest card |
| `UI/HUD/DailyRewardPanel.luau` | Disabled daily card |
| `UI/HUD/LimitedEventPanel.luau` | Disabled event card |
| `UI/HUD/LeftPanelColumn.luau` | Quest, Daily, Event |
| `UI/HUD/ActionRail.luau` | Exact eight-tile order |
| `UI/HUD/FactoryHotbar.luau` | Live inventory slots and locked slot |
| `UI/HUD/BottomDock.luau` | Friends, Collapse, Hotbar, Backpack, Launch |
| `UI/HUD/LaunchButton.luau` | Disabled hero action |
| `UI/Screens/MainHudScreen.luau` | Data wiring and region placement only |

## Existing files to edit

| File | Required change |
|---|---|
| `UI/Screens/App.luau` | Mount `MainHudScreen` |
| `UI/Screens/QuestScreen.luau` | Keep target marker; remove visible card |
| `UI/Screens/FactoryScreen.luau` | Keep overlays/controls; remove opener and hotbar |

## Completion check

```bash
find src/ReplicatedStorage/UI/Config src/ReplicatedStorage/UI/Types src/ReplicatedStorage/UI/Hooks src/ReplicatedStorage/UI/Primitives src/ReplicatedStorage/UI/HUD -type f | sort
```

Compare the output against this manifest before final validation.
