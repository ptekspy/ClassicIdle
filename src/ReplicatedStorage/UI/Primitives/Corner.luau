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
	return React.createElement("UICorner", { CornerRadius = UDim.new(0, assert(values[props.variant])) })
end
