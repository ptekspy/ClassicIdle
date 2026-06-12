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