--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Button = require(ReplicatedStorage.UI.Components.Button)

export type Props = {
	text: string,
	layoutOrder: number,
	onActivated: () -> (),
}

local function BuildShopItem(props: Props)
	return React.createElement(Button, {
		text = props.text,
		variant = "Primary",
		size = UDim2.new(1, -16, 0, 56),
		layoutOrder = props.layoutOrder,
		onActivated = props.onActivated,
	})
end

return BuildShopItem
