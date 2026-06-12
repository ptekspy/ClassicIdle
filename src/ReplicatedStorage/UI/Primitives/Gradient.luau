--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Gradients = require(ReplicatedStorage.UI.Config.GradientConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)

return function(props: { variant: Types.GradientVariant, rotation: number? })
	return React.createElement("UIGradient", {
		Color = assert(Gradients[props.variant]), Rotation = props.rotation or 90,
	})
end