--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

export type Props = {
	text: string,
	enabled: boolean?,
	height: number?,
	textSize: number?,
	layoutOrder: number?,
	onActivated: () -> (),
}

local function ActionButton(props: Props)
	local enabled = props.enabled ~= false

	return React.createElement("TextButton", {
		Size = UDim2.new(1, 0, 0, props.height or 64),
		LayoutOrder = props.layoutOrder or 0,
		BackgroundColor3 = if enabled then Color3.fromRGB(65, 130, 80) else Color3.fromRGB(65, 65, 65),
		AutoButtonColor = enabled,
		Font = Enum.Font.GothamBold,
		Text = props.text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = props.textSize or 18,
		TextWrapped = true,
		Active = enabled,
		[React.Event.Activated] = if enabled then props.onActivated else nil,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
	})
end

return ActionButton