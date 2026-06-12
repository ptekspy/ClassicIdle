--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Panel = require(ReplicatedStorage.UI.Components.Panel)

export type Props = {
	size: UDim2?,
	layoutOrder: number?,
	children: React.ReactNode,
}

local function StatusPill(props: Props)
	return React.createElement(Panel, {
		variant = "Status",
		size = props.size or UDim2.fromOffset(220, 72),
		layoutOrder = props.layoutOrder,
		children = props.children,
	})
end

return StatusPill
