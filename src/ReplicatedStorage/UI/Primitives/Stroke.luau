--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Colors = require(ReplicatedStorage.UI.Config.ColorConfig)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)

local styles: { [Types.StrokeVariant]: { color: Color3, thickness: number } } = {
	Outer = { color = Colors.Stroke.Outer, thickness = Layout.Stroke.Heavy },
	Blue = { color = Colors.Stroke.Blue, thickness = Layout.Stroke.Standard },
	Purple = { color = Colors.Stroke.Purple, thickness = Layout.Stroke.Standard },
}

return function(props: { variant: Types.StrokeVariant })
	local style = assert(styles[props.variant], `Unknown stroke variant: {props.variant}`)
	return React.createElement("UIStroke", {
		Color = style.color,
		Thickness = style.thickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end
