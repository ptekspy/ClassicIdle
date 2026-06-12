# Types And Variant System

## Create `DesignSystemTypes.luau`

```luau
--!strict

export type CornerVariant = "Small" | "Medium" | "Large" | "Pill"
export type StrokeVariant = "Outer" | "Blue" | "Purple"
export type GradientVariant = "PanelBlue" | "PanelPurple" | "ButtonGreen" | "Progress"
export type TextVariant = "Caption" | "Body" | "Label" | "Heading" | "Hero"
export type IconSize = "Tiny" | "Small" | "Medium" | "Large" | "ActionTile" | "Hero"
export type ButtonVariant = "Primary" | "Secondary" | "GreenHero" | "Disabled"
export type PanelVariant = "Standard" | "Quest" | "Event" | "Status"
export type ProgressVariant = "Green" | "Zone" | "XP"

return {}
```

## Create `HUDTypes.luau`

```luau
--!strict

export type QuestView = {
	title: string,
	description: string,
	progress: number,
	required: number,
	xpReward: number,
}

export type HotbarItem = {
	id: string,
	name: string,
	count: number,
	icon: string,
	locked: boolean,
}

export type FactoryActions = {
	onToggleShop: () -> (),
	onSelectItem: (string) -> (),
}

export type ResponsiveMode = "Desktop" | "Tablet" | "LandscapePhone" | "PortraitPhone"

return {}
```

## Controlled variant pattern

Use typed lookup tables. Never silently fall back:

```luau
local radiusByVariant: { [Types.CornerVariant]: number } = {
	Small = Layout.Radius.Small,
	Medium = Layout.Radius.Medium,
	Large = Layout.Radius.Large,
	Pill = Layout.Radius.Pill,
}

local radius = radiusByVariant[props.variant]
assert(radius, `Unknown corner variant: {props.variant}`)
```

## Public prop rules

- Required variants must be explicit.
- Optional callbacks mean disabled behavior only.
- Do not accept arbitrary `style`, `properties`, or token override tables.
- Use `React.ReactNode` only for intentional composition slots.
- Feature-specific data belongs in `HUDTypes`.

## Done when

All new modules can use strict public types without `any`.
