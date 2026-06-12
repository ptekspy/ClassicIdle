# HUD Reference Contract

## Goal

Recreate the attached HUD as the fixed visual contract. At `1920x1080`, element order, relative placement, labels, badges, and proportions must match the reference. Do not render the `HUD DESIGN 4` annotation.

## Fixed desktop composition

| Region | Exact contents, left-to-right or top-to-bottom | Behavior |
|---|---|---|
| Top status bar | Gold, Gems, Fuel, Best Distance, Level/XP, Wheel, Calendar | Gold and XP are live; everything else is disabled demo data |
| Zone bar | Earth icon, `EARTH ZONE`, segmented progress, `68% COMPLETE`, `MOON ZONE`, Moon icon | Disabled demo data |
| Left column | Main Quest, Daily Reward, Limited Event | Main Quest is live; other cards are disabled |
| Right rail | Shop/Build, Rocket/Pets, Worlds/Rebirth, Codes/Settings | Build is functional; all other tiles are disabled |
| Bottom dock | Invite Friends, collapse arrow, numbered hotbar, Backpack, Launch | Hotbar is functional; all other controls are disabled |

## Desktop reference coordinates

Treat these as the authoritative `1920x1080` design coordinates. Convert them to scale by dividing X/width by `1920` and Y/height by `1080`.

| Element | X | Y | Width | Height |
|---|---:|---:|---:|---:|
| Gold | 380 | 24 | 265 | 72 |
| Gems | 660 | 24 | 255 | 72 |
| Fuel | 930 | 24 | 255 | 72 |
| Best Distance | 1200 | 24 | 215 | 72 |
| Level/XP | 1430 | 24 | 250 | 72 |
| Wheel | 1710 | 28 | 72 | 72 |
| Calendar | 1805 | 28 | 72 | 72 |
| Zone progress | 430 | 116 | 1080 | 76 |
| Main Quest | 22 | 158 | 360 | 158 |
| Daily Reward | 22 | 338 | 360 | 170 |
| Limited Event | 22 | 530 | 360 | 300 |
| Right action rail | 1590 | 145 | 285 | 540 |
| Invite Friends | 24 | 900 | 300 | 130 |
| Collapse | 340 | 950 | 44 | 60 |
| Hotbar | 400 | 915 | 850 | 120 |
| Backpack | 1270 | 890 | 120 | 145 |
| Launch | 1410 | 865 | 440 | 170 |

Use these coordinates as the initial implementation. Adjust only during final screenshot comparison, and record every adjustment in this table.

## Demo values

These values must live in `HUDConfig`, not in components:

```txt
Gems: 1,250
Fuel: 2,850
Best Distance: 12.45 km
Zone Progress: 68%
Daily Reward: Play for 20 Minutes, 6/20, 2K coins
Limited Event: Meteor Shower!, 2D 14H 33M, x250 gems, x10K coins
Pets badge: 2
Backpack badge: 3
Launch fuel cost: 125
Calendar day: 31
```

## Live ClassicIdle mapping

- Gold: `usePlayerData().Gold`
- Level and XP: derive from `usePlayerData().XP`
- Main Quest: transient quest state published by `QuestController`
- Factory hotbar: `usePlayerData().Factory.Inventory`
- Build tile: existing `factory.onToggleShop`
- Hotbar selection: existing `factory.onSelectItem`

## Non-negotiable rules

- Do not replace top-bar slots with Wood, Stone, Coal, or storage.
- Do not reorder or omit reference regions on desktop.
- Disabled controls remain fully styled but have no callback.
- No new server remotes, persistence fields, or gameplay systems are created for placeholders.
- Preserve quest wayfinding, build placement, menus, interaction prompts, and feedback.

## Responsive rules

- Desktop (`>=1280px`): preserve the complete composition.
- Tablet (`800-1279px`): preserve every region; reduce group scale and gaps.
- Landscape phone (`<800px`, landscape): hide disabled left cards first, then compact the right rail.
- Portrait phone: functional controls take priority; disabled feature groups may be hidden.

## Done when

- A developer can identify the source and enabled state of every reference element.
- No implementation decision remains about element order or placeholder values.
