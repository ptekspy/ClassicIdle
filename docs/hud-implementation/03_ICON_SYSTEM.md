# Icon System

## Goal

Centralize every icon so final artwork can be replaced without editing components.

## Create `IconConfig.luau`

Use Roblox placeholder assets until final art is uploaded:

```luau
--!strict

local function icon(asset: string, ratio: number?)
	return table.freeze({ Asset = asset, AspectRatio = ratio or 1 })
end

local Icons = {
	Gold = icon("rbxassetid://6031068433"),
	Gems = icon("rbxassetid://6031071053"),
	Fuel = icon("rbxassetid://6034509993"),
	Trophy = icon("rbxassetid://6031225819"),
	Level = icon("rbxassetid://6031068426"),
	Wheel = icon("rbxassetid://6034407078"),
	Calendar = icon("rbxassetid://6031090990"),
	Earth = icon("rbxassetid://6031280882"),
	Moon = icon("rbxassetid://6031280882"),
	Quest = icon("rbxassetid://6031075938"),
	Gift = icon("rbxassetid://6031075931"),
	Meteor = icon("rbxassetid://6031094678"),
	Shop = icon("rbxassetid://6031265983"),
	Build = icon("rbxassetid://6034754445"),
	Rocket = icon("rbxassetid://6031094678"),
	Pets = icon("rbxassetid://6031260793"),
	Worlds = icon("rbxassetid://6031280882"),
	Rebirth = icon("rbxassetid://6031094677"),
	Codes = icon("rbxassetid://6031265976"),
	Settings = icon("rbxassetid://6031280882"),
	Friends = icon("rbxassetid://6034287594"),
	Backpack = icon("rbxassetid://6031265976"),
	Lock = icon("rbxassetid://6031082533"),
	Collapse = icon("rbxassetid://6031090990"),
}

return table.freeze(Icons)
```

## Icon variants

| Variant | Reference size | Use |
|---|---:|---|
| Tiny | 18px | Inline labels |
| Small | 28px | Currency pills |
| Medium | 42px | Quest/reward cards |
| Large | 64px | Status and hotbar |
| ActionTile | 76px | Right action rail |
| Hero | 104px | Launch button |

## Create `IconConfig.md`

Create `docs/hud-implementation/IconConfig.md` from the table below and update it whenever art changes:

| Key | Required visual | Ratio | ScaleType | Padding |
|---|---|---:|---|---:|
| Gold | Gold coin | 1:1 | Fit | 4px |
| Gems | Purple faceted gem | 1:1 | Fit | 2px |
| Fuel | Red fuel can | 1:1 | Fit | 3px |
| Trophy | Gold trophy | 1:1 | Fit | 3px |
| Level | Gold star with `1` | 1:1 | Fit | 1px |
| Wheel | Multicolor spinner | 1:1 | Fit | 0px |
| Calendar | Red/white calendar | 1:1 | Fit | 1px |
| Earth/Moon | Globe and cratered moon | 1:1 | Fit | 0px |
| Action icons | Match reference silhouettes | 1:1 | Fit | 5px |
| Launch | Rocket with flame trail | 1:1 | Fit | 0px |

## Rules

- Components receive an icon key, never an asset string.
- Use `UIAspectRatioConstraint` inside the Icon primitive.
- Do not recolor final multicolor icons.
- Placeholder asset mismatch is acceptable; sizing and replacement path are not.

## Done when

Every reference icon has one config entry and one documented replacement specification.
