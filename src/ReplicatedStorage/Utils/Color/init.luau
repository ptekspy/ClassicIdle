--!strict

local Color = {}

local function clamp(value: number): number
	return math.clamp(value, 0, 1)
end

local function channelToLinear(channel: number): number
	if channel <= 0.03928 then
		return channel / 12.92
	end

	return ((channel + 0.055) / 1.055) ^ 2.4
end

function Color.Alpha(color: Color3, alpha: number): { Color: Color3, Transparency: number }
	return {
		Color = color,
		Transparency = 1 - clamp(alpha),
	}
end

function Color.Lighten(color: Color3, amount: number): Color3
	local factor = clamp(amount)
	return Color3.new(
		color.R + (1 - color.R) * factor,
		color.G + (1 - color.G) * factor,
		color.B + (1 - color.B) * factor
	)
end

function Color.Darken(color: Color3, amount: number): Color3
	local factor = 1 - clamp(amount)
	return Color3.new(color.R * factor, color.G * factor, color.B * factor)
end

function Color.GetLuminance(color: Color3): number
	return 0.2126 * channelToLinear(color.R) + 0.7152 * channelToLinear(color.G) + 0.0722 * channelToLinear(color.B)
end

function Color.GetContrastRatio(first: Color3, second: Color3): number
	local firstLuminance = Color.GetLuminance(first)
	local secondLuminance = Color.GetLuminance(second)
	local light = math.max(firstLuminance, secondLuminance)
	local dark = math.min(firstLuminance, secondLuminance)

	return (light + 0.05) / (dark + 0.05)
end

return Color
