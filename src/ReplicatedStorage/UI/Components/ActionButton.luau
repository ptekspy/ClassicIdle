--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)
local Button = require(ReplicatedStorage.UI.Components.Button)

export type Props = {
	text: string,
	enabled: boolean?,
	height: number?,
	textSize: number?,
	layoutOrder: number?,
	onActivated: (() -> ())?,
}

local function ActionButton(props: Props)
	local enabled = props.enabled ~= false and props.onActivated ~= nil

	return React.createElement(Button, {
		text = props.text,
		variant = if enabled then "Primary" else "Disabled",
		size = UDim2.new(1, 0, 0, props.height or 64),
		layoutOrder = props.layoutOrder,
		onActivated = if enabled then props.onActivated else nil,
	})
end

return ActionButton
