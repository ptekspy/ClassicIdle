--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)
local Corner = require(ReplicatedStorage.UI.Primitives.Corner)
local Gradient = require(ReplicatedStorage.UI.Primitives.Gradient)
local Stroke = require(ReplicatedStorage.UI.Primitives.Stroke)

export type Props = { value: number, variant: Types.ProgressVariant, size: UDim2, segmented: number? }

local fillColors: { [Types.ProgressVariant]: Color3 } = {
	Green = Colors.Progress.Green,
	Zone = Colors.Progress.Green,
	XP = Colors.Progress.Yellow,
}

local function createFill(variant: Types.ProgressVariant, size: UDim2, position: UDim2?): React.ReactNode
	return React.createElement("Frame", {
		Size = size,
		Position = position,
		BackgroundColor3 = assert(fillColors[variant], `Unknown progress variant: {variant}`),
	}, {
		Corner = React.createElement(Corner, { variant = "Pill" }),
		Gradient = if variant == "Zone"
			then React.createElement(Gradient, { variant = "Progress", rotation = 0 })
			else nil,
	})
end

local function ProgressBar(props: Props)
	local value = math.clamp(props.value, 0, 1)
	local segmented = props.segmented
	local children: { [string]: React.ReactNode } = {
		Corner = React.createElement(Corner, { variant = "Pill" }),
		Stroke = React.createElement(Stroke, { variant = "Outer" }),
	}

	if segmented ~= nil then
		assert(segmented > 0, "ProgressBar segmented must be greater than zero")
		local filledCount = math.floor(value * segmented + 0.5)
		for index = 1, segmented do
			local segmentWidth = 1 / segmented
			children[`Segment{index}`] = React.createElement("Frame", {
				Position = UDim2.new((index - 1) * segmentWidth, 1, 0, 1),
				Size = UDim2.new(segmentWidth, -2, 1, -2),
				BackgroundColor3 = if index <= filledCount
					then assert(fillColors[props.variant], `Unknown progress variant: {props.variant}`)
					else Colors.Progress.Track,
			}, {
				Corner = React.createElement(Corner, { variant = "Small" }),
				Gradient = if index <= filledCount and props.variant == "Zone"
					then React.createElement(Gradient, { variant = "Progress", rotation = 0 })
					else nil,
			})
		end
	else
		children.Fill = createFill(props.variant, UDim2.fromScale(value, 1), nil)
	end

	return React.createElement("Frame", {
		Size = props.size,
		BackgroundColor3 = Colors.Progress.Track,
		ClipsDescendants = true,
	}, children)
end

return ProgressBar
