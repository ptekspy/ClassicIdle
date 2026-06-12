# Top Status Bar

## Goal

Implement the exact order `Gold | Gems | Fuel | Best Distance | Level/XP | Wheel | Calendar`.

## Create `TopStatusBar.luau`

Props:

```luau
export type Props = { gold: number, xp: number }
```

Use a horizontal `UIListLayout` and compose these children in this exact order:

```luau
Gold = CurrencyPill({ icon = "Gold", value = FormatNumber.FormatCompact(props.gold), showPlus = true, enabled = false })
Gems = CurrencyPill({ icon = "Gems", value = FormatNumber.FormatCompact(HUD.Demo.Gems), showPlus = true, enabled = false })
Fuel = CurrencyPill({ icon = "Fuel", value = FormatNumber.FormatCompact(HUD.Demo.Fuel), showPlus = true, enabled = false })
BestDistance = StatusPill({ icon = "Trophy", heading = "Best Distance", value = HUD.Demo.BestDistance })
Level = LevelStatusPill({ xp = props.xp })
Wheel = IconButton({ icon = "Wheel", badge = "!", onActivated = nil })
Calendar = IconButton({ icon = "Calendar", label = tostring(HUD.Demo.CalendarDay), onActivated = nil })
```

## Create `LevelStatusPill.luau`

Use this exact display-only helper:

```luau
local function getLevelProgress(totalXP: number): (number, number, number)
	local level = 1
	local spent = 0
	while totalXP - spent >= HUD.Level.BaseRequirement * level do
		spent += HUD.Level.BaseRequirement * level
		level += 1
	end
	local required = HUD.Level.BaseRequirement * level
	return level, totalXP - spent, required
end
```

Render the star icon, `Level {level}`, and an XP progress bar labelled `{current} / {required}`.

## Reference proportions

| Item | Width share |
|---|---:|
| Gold/Gems/Fuel | 0.16 each |
| Best Distance | 0.13 |
| Level/XP | 0.19 |
| Wheel/Calendar | 0.07 each |

## Validation

- Gold changes when Replica Gold changes.
- Level progress changes when Replica XP changes.
- Placeholder plus buttons, Wheel, and Calendar do nothing.
- Desktop order is exact.

## Done when

The top bar visually matches the reference and has no resource substitutions.
