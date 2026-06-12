# Design Tokens

## Goal

Create the complete semantic token foundation before building components.

## Create `ColorConfig.luau`

```luau
--!strict

local Colors = {
	Panel = {
		Primary = Color3.fromRGB(5, 50, 103),
		Secondary = Color3.fromRGB(8, 72, 145),
		Deep = Color3.fromRGB(2, 24, 51),
		Event = Color3.fromRGB(48, 23, 115),
	},
	Stroke = {
		Outer = Color3.fromRGB(0, 16, 35),
		Blue = Color3.fromRGB(0, 132, 255),
		Purple = Color3.fromRGB(128, 75, 255),
	},
	Button = {
		Green = Color3.fromRGB(44, 213, 14),
		GreenDark = Color3.fromRGB(20, 143, 8),
		Blue = Color3.fromRGB(10, 95, 186),
		Disabled = Color3.fromRGB(70, 80, 92),
	},
	Text = {
		Primary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(198, 226, 255),
		Yellow = Color3.fromRGB(255, 225, 43),
		Dark = Color3.fromRGB(10, 24, 40),
	},
	Progress = {
		Green = Color3.fromRGB(58, 224, 21),
		Yellow = Color3.fromRGB(255, 211, 17),
		Track = Color3.fromRGB(1, 25, 48),
	},
	Badge = {
		Red = Color3.fromRGB(238, 54, 48),
	},
}

return table.freeze(Colors)
```

## Create `GradientConfig.luau`

```luau
--!strict

local Gradients = {
	PanelBlue = ColorSequence.new(Color3.fromRGB(10, 91, 183), Color3.fromRGB(3, 40, 87)),
	PanelPurple = ColorSequence.new(Color3.fromRGB(105, 58, 218), Color3.fromRGB(37, 17, 91)),
	ButtonGreen = ColorSequence.new(Color3.fromRGB(86, 245, 35), Color3.fromRGB(25, 176, 10)),
	Progress = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 222, 17)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(155, 230, 25)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 205, 16)),
	}),
}

return table.freeze(Gradients)
```

## Create `LayoutConfig.luau`

```luau
--!strict

local Layout = {
	ReferenceSize = Vector2.new(1920, 1080),
	Breakpoint = { Desktop = 1280, Tablet = 800 },
	Spacing = { XS = 4, SM = 8, MD = 12, LG = 18, XL = 24 },
	Radius = { Small = 8, Medium = 12, Large = 18, Pill = 999 },
	Stroke = { Thin = 2, Standard = 3, Heavy = 5 },
	TouchTarget = 44,
	DisplayOrder = { HUD = 5, Feedback = 10, QuestMarker = 15, Interaction = 20, Overlay = 35 },
	Animation = { Fast = 0.08, Standard = 0.16, Slow = 0.25 },
}

return table.freeze(Layout)
```

## Create `TypographyConfig.luau`

```luau
--!strict

local Typography = {
	Caption = { Font = Enum.Font.GothamBold, Size = 14 },
	Body = { Font = Enum.Font.Gotham, Size = 17 },
	Label = { Font = Enum.Font.GothamBold, Size = 19 },
	Heading = { Font = Enum.Font.GothamBold, Size = 24 },
	Hero = { Font = Enum.Font.GothamBlack, Size = 38 },
}

return table.freeze(Typography)
```

## Create `HUDConfig.luau`

```luau
--!strict

local HUD = {
	Demo = {
		Gems = 1250, Fuel = 2850, BestDistance = "12.45 km", ZoneProgress = 0.68,
		CalendarDay = 31, PetsBadge = 2, BackpackBadge = 3, LaunchFuelCost = 125,
		DailyMinutes = 6, DailyRequiredMinutes = 20, DailyCoins = "2K",
		EventTitle = "Meteor Shower!", EventTime = "2D 14H 33M", EventGems = "x250", EventCoins = "x10K",
	},
	Level = { BaseRequirement = 25 },
}

return table.freeze(HUD)
```

## Rules

- Components require these modules; they never duplicate values.
- Add tokens only when at least two consumers need them or the value is part of the reference contract.
- Do not put feature callbacks or live player data in config.

## Done when

All five modules exist and contain the only approved raw visual literals.
