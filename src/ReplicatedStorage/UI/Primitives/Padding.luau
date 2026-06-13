--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Layout = require(ReplicatedStorage.UI.Config.LayoutConfig)

return function(props: { size: "XS" | "SM" | "MD" | "LG" | "XL" })
	local value = assert(Layout.Spacing[props.size], `Unknown padding size: {props.size}`)
	return React.createElement("UIPadding", {
		PaddingTop = UDim.new(0, value),
		PaddingBottom = UDim.new(0, value),
		PaddingLeft = UDim.new(0, value),
		PaddingRight = UDim.new(0, value),
	})
end
