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