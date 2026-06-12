--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Vendor.React)

local function HotbarSlot(props: {
	text: string,
	layoutOrder: number,
	onActivated: () -> (),
})
	return React.createElement("TextButton", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromOffset(135, 54),
		BackgroundColor3 = Color3.fromRGB(65, 130, 80),
		Font = Enum.Font.GothamBold,
		Text = props.text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
		TextWrapped = true,
		[React.Event.Activated] = props.onActivated,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})
end

return HotbarSlot