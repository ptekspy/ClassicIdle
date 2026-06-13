--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)
local Types = require(ReplicatedStorage.UI.Types.DesignSystemTypes)

local values: { [Types.CornerVariant]: number } = {
	Small = Layout.Radius.Small,
	Medium = Layout.Radius.Medium,
	Large = Layout.Radius.Large,
	Pill = Layout.Radius.Pill,
}

return function(props: { variant: Types.CornerVariant })
	local radius = assert(values[props.variant], `Unknown corner variant: {props.variant}`)
	return React.createElement("UICorner", { CornerRadius = UDim.new(0, radius) })
end
