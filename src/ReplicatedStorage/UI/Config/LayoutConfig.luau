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