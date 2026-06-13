--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Icons = require(ReplicatedStorage.UI.Config.IconConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)

local sizes: { [Types.IconSize]: number } = {
	Tiny = 18,
	Small = 28,
	Medium = 42,
	Large = 64,
	ActionTile = 76,
	Hero = 104,
}

return function(props: { icon: string, size: Types.IconSize, layoutOrder: number? })
	local definition = assert(Icons[props.icon], `Unknown icon: {props.icon}`)
	local pixels = assert(sizes[props.size], `Unknown icon size: {props.size}`)
	return React.createElement("ImageLabel", {
		LayoutOrder = props.layoutOrder or 0,
		Size = UDim2.fromOffset(pixels, pixels),
		BackgroundTransparency = 1,
		Image = definition.Asset,
		ScaleType = Enum.ScaleType.Fit,
	}, {
		Aspect = React.createElement("UIAspectRatioConstraint", { AspectRatio = definition.AspectRatio }),
	})
end
